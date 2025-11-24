from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible.plugins.callback.default import CallbackModule as DefaultCallback
import re

SECRET_MASK = "***SECRET***"

class CallbackModule(DefaultCallback):
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'secret_mask'

    def _mask_secrets_in_text(self, text):
        if not isinstance(text, str):
            return text
        # Example patterns: secret=..., password=..., my_secret_var: '...'
        patterns = [
            r"(secret\s*[:=]\s*)(['\"]?)(.*?)(['\"])(?=\s|$)",
            r"(password\s*[:=]\s*)(['\"]?)(.*?)(['\"])(?=\s|$)",
            r"(my_secret_var\s*[:=]\s*)(.*?)(?=\s|$)"
        ]
        masked = text
        for pat in patterns:
            masked = re.sub(pat, r"\1\2" + SECRET_MASK + r"\4", masked, flags=re.IGNORECASE)
        return masked

    def _mask_diff(self, diff):
        if isinstance(diff, dict):
            masked = {}
            for k, v in diff.items():
                if isinstance(v, str):
                    masked[k] = self._mask_secrets_in_text(v)
                else:
                    masked[k] = self._mask_diff(v)
            return masked
        elif isinstance(diff, list):
            return [self._mask_diff(i) for i in diff]
        elif isinstance(diff, str):
            return self._mask_secrets_in_text(diff)
        return diff

    def v2_runner_on_ok(self, result, **kwargs):
        if 'diff' in result._result:
            result._result['diff'] = self._mask_diff(result._result['diff'])
        super(CallbackModule, self).v2_runner_on_ok(result, **kwargs)

    def v2_runner_on_failed(self, result, **kwargs):
        if 'diff' in result._result:
            result._result['diff'] = self._mask_diff(result._result['diff'])
        super(CallbackModule, self).v2_runner_on_failed(result, **kwargs)

    def v2_playbook_on_stats(self, stats):
        super(CallbackModule, self).v2_playbook_on_stats(stats)
