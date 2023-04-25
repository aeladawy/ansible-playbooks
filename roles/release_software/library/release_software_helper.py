#!/usr/bin/python

DOCUMENTATION = '''
---
module: release_software_helper
version_added: "0.0.1"
author: Marcel Koenig
short_description: Helper module for releasing
description:
  - The Release Helper manages some of the steps common in deploying software.

options:
  path:
    required: true
    description:
      - the root path of the project. Alias I(dest).
        Returned in the C(release_software_helper.project_path) fact.

  state:
    required: false
    choices: [ prepare, finalize, clean ]
    default: prepare
    description:
      - the state of the project.
        C(prepare) will create the project I(root) folder, and in it the I(releases) and I(shared) folders,
        C(finalize) will create a symlink to the newly deployed release and optionally clean old releases,
        C(clean) will remove old releases,

  release:
    required: false
    description:
      - the release version that is being deployed. Defaults to a timestamp format %Y%m%d%H%M%S (i.e. '20141119223359').
        This parameter is optional during C(state=prepare), but needs to be set explicitly for C(state=finalize).

  releases_path:
    required: false
    default: releases
    description:
      - the name of the folder that will hold the releases. This can be relative to C(path) or absolute.
        Returned in the C(release_software_helper.releases_path) fact.

  shared_path:
    required: false
    default: shared
    description:
      - the name of the folder that will hold the shared resources. This can be relative to C(path) or absolute.
        If this is set to an empty string, no shared folder will be created.
        Returned in the C(release_software_helper.shared_path) fact.

  shared_folders:
    required: false
    description:
      - a list of shared sub folders to create relative to C(shared_path).

  build_path:
    required: false
    default: /tmp/builds
    description:
      - the name of the folder where the new release is build.
        Returned in the C(release_software_helper.build_path) fact.

  current_path:
    required: false
    default: current
    description:
      - the name of the symlink that is created when the deploy is finalized. Used in C(finalize) and C(clean).
        Returned in the C(release_software_helper.current_path) fact.

  clean:
    required: false
    default: True
    description:
      - Whether to run the clean procedure in case of C(state=finalize).

  keep_releases:
    required: false
    default: 5
    description:
      - the number of old releases to keep when cleaning. Used in C(finalize) and C(clean).

notes:
  - Facts are only returned for  C(state=prepare). If you use both, you should pass any overridden
    parameters to both calls, otherwise the second call will overwrite the facts of the first one.
  - When using C(state=clean), the releases are ordered by I(creation date). You should be able to switch to a
    new naming strategy without problems.
  - Because of the default behaviour of generating the I(new_release) fact, this module will not be idempotent
    unless you pass your own release name with C(release). Due to the nature of deploying software, this should not
    be much of a problem.
'''
import os
import shutil
import time
import traceback

from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils._text import to_native

class ReleaseSoftwareHelper(object):
    
    def __init__(self, module):
        """ Initialize this Release Helper class """
        
        self.module = module
        self.file_args = module.load_file_common_arguments(module.params)

        self.clean = module.params['clean']
        self.current_path = module.params['current_path']
        self.keep_releases = module.params['keep_releases']
        self.path = module.params['path']
        self.release = module.params['release']
        self.releases_path = module.params['releases_path']
        self.shared_path = module.params['shared_path']
        self.shared_folders = module.params['shared_folders']
        self.state = module.params['state']
    
    def gather_facts(self):
        """ Gather all facts needed for this class to work """

        current_path   = os.path.join(self.path, self.current_path)
        releases_path  = os.path.join(self.path, self.releases_path)
        shared_path    = os.path.join(self.path, self.shared_path)
        shared_folders = []
        
        # generate shared folders
        if self.shared_folders:
            for s_folder in self.shared_folders:
                shared_folders.append(os.path.join(shared_path, s_folder))

        # get the previous release facts
        previous_release, previous_release_path = self._get_last_release(current_path)

        # if no release is given vcreate one by the timestamp
        if not self.release and (self.state == 'prepare'):
            self.release = time.strftime("%Y%m%d%H%M%S")

        new_release_path = os.path.join(releases_path, self.release)

        return {
            'project_path':             self.path,
            'current_path':             current_path,
            'releases_path':            releases_path,
            'shared_path':              shared_path,
            'shared_folders':           shared_folders,
            'previous_release':         previous_release,
            'previous_release_path':    previous_release_path,
            'new_release':              self.release,
            'new_release_path':         new_release_path,
            'clean':                    self.clean,
            'keep_releases':            self.keep_releases
        }
        
    def delete_path(self, path):
        """ Delete the given path if it's a directory """

        if not os.path.lexists(path):
            return False

        if not os.path.isdir(path):
            self.module.fail_json(msg="%s exists but is not a directory" % path)

        if not self.module.check_mode:
            try:
                shutil.rmtree(path, ignore_errors=False)
            except Exception as e:
                self.module.fail_json(msg="rmtree failed: %s" % to_native(e), exception=traceback.format_exc())

        return True
    
    def create_path(self, path):
        """ Creates the given path """

        changed = False

        if not os.path.lexists(path):
            changed = True
            if not self.module.check_mode:
                os.makedirs(path)

        elif not os.path.isdir(path):
            self.module.fail_json(msg="%s exists but is not a directory" % path)
       
        if not self.module.check_mode:
            changed += self.module.set_directory_attributes_if_different(self._get_file_args(path), changed)

        return changed
    
    def check_link(self, path):
        """ Checks that the given path is a symlink """
        if os.path.lexists(path):
            if not os.path.islink(path):
                self.module.fail_json(msg="%s exists but is not a symbolic link" % path)
    
    def create_link(self, source, link_name):
        """ Creates a symlink """
        if not self.module.check_mode:
            if os.path.islink(link_name):
                os.unlink(link_name)
            os.symlink(source, link_name)

        return True
    
    def cleanup(self, releases_path, reserve_version):
        """ Removes release folders and only keeps num of eleases defined in keep_releases """
        changes = 0

        if os.path.lexists(releases_path):
            releases = [f for f in os.listdir(releases_path) if os.path.isdir(os.path.join(releases_path, f))]
            try:
                releases.remove(reserve_version)
            except ValueError:
                pass

            if not self.module.check_mode:
                releases.sort(key=lambda x: os.path.getctime(os.path.join(releases_path, x)), reverse=True)
                for release in releases[self.keep_releases:]:
                    changes += self.delete_path(os.path.join(releases_path, release))
            elif len(releases) > self.keep_releases:
                changes += (len(releases) - self.keep_releases)

        return changes
       
    def _get_file_args(self, path):
        """ Gets the file args from the given path """
        file_args = self.file_args.copy()
        file_args['path'] = path
        return file_args
    
    def _get_last_release(self, current_path):
        """ Returns the release path provided by the current link """
        previous_release = None
        previous_release_path = None

        if os.path.lexists(current_path):
            previous_release_path = os.path.realpath(current_path)
            previous_release  = os.path.basename(previous_release_path)

        return previous_release, previous_release_path

def main():
    """ Main function """

    # Init the Ansible module
    module = AnsibleModule(
        argument_spec = dict(
            path = dict(required=True, type='path'),
            release = dict(required=False, type='str', default=None),
            releases_path = dict(required=False, type='str', default='releases'),
            shared_path = dict(required=False, type='path', default=''),
            shared_folders = dict(required=False, type='list'),
            current_path = dict(required=False, type='path', default='current'),
            keep_releases = dict(required=False, type='int', default=5),
            clean = dict(required=False, type='bool', default=True),
            state = dict(required=False, choices=['prepare', 'query', 'finalize', 'clean', 'rollback'], default='prepare')
        ),
        add_file_common_args = True,
        supports_check_mode  = True
    )

    # Init the Releasehelper class and gather the facts
    release_software_helper = ReleaseSoftwareHelper(module)
    facts = release_software_helper.gather_facts()

    result = {
        'state': release_software_helper.state
    }

    changes = 0

    if release_software_helper.state == 'prepare':
        """ Create the folders needed or a release """
        release_software_helper.check_link(facts['current_path'])
        changes += release_software_helper.create_path(facts['project_path'])
        changes += release_software_helper.create_path(facts['releases_path'])

        if (facts['shared_path']):
            changes += release_software_helper.create_path(facts['shared_path'])
    
        for s_folder in facts['shared_folders']:
            release_software_helper.create_path(s_folder)

        result['ansible_facts'] = { 'release_software_helper': facts }

    elif release_software_helper.state == 'finalize':
        """ Move the build to the release folder than
            link current to the new release folder and
            clean old releases """

        if not release_software_helper.release:
            module.fail_json(msg="'release' is a required parameter for state=finalize (try the 'release_software_helper.new_release' fact)")
        if release_software_helper.clean and release_software_helper.keep_releases < 0:
            module.fail_json(msg="'keep_releases' should be at least 0")

        if  not module.check_mode and not os.path.lexists(facts['new_release_path']):
            module.fail_json(msg="no new release path exists")

        if  not module.check_mode: 
            if not os.path.exists(facts['current_path']) or not os.path.samefile(facts['new_release_path'], facts['current_path']):   
                changes += release_software_helper.create_link(facts['new_release_path'], facts['current_path'])

        if release_software_helper.clean:
            changes += release_software_helper.cleanup(facts['releases_path'], facts['new_release'])
        
    
    elif release_software_helper.state == 'clean':
        """ Clean old releases """
        if release_software_helper.keep_releases < 0:
            module.fail_json(msg="'keep_releases' should be at least 0")
        changes += release_software_helper.cleanup(facts['releases_path'], facts['new_release'])

    if changes > 0:
        result['changed'] = True
    else:
        result['changed'] = False

    module.exit_json(**result)


if __name__ == '__main__':
    main()
