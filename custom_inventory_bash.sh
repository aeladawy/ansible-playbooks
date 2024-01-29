#! /bin/bash

if [ "$1" == "--list" ]; then
cat<<EOF
{
  "bash_hosts": {
    "hosts": [
      "myhost.domain.com",
      "localhost"
    ],
    "vars": {
      "host_test": "test-value"
    }
  },
  "_meta": {
    "hostvars": {
      "myhost.domain.com": {
        "host_specific_test_var": "test-value"
      }
    }
  }
}
EOF
elif [ "$1" == "--host" ]; then
  echo '{"_meta": {hostvars": {}}}'
else
  echo "{ }"
fi
