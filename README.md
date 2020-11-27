# pulp-2to3-migration-test-fixtures

This repository contains Pulp 2 snapshots in the form of mongodump archives, /var/lib/pulp/content
 archives, and /var/lib/pulp/published archives to be used in tests for the pulp-2to3-migration
  plugin.
 

### Structure

There is a separate directory for each Pulp 2 snapshot.
Each directory has to have:
 - a mongodb archive
 - a /var/lib/pulp/content snapshot
 - a /var/lib/pulp/published snapshot
 
Each directory should have a config to generate the Pulp 2 snapshot.
The config helps to regenerate the snapshot if needed and it serves as a documentation of what is
 present in the snapshot.


#### Naming conventions

##### Directory

Name directory in the way it would be clear what is roughly there.
Currently the name is not parsed and is not used in any scripts, however the suggested name is
 the following: ``plugintype_state_usefulid1_usefulid2_etc``.  
Plugintype is `file`, `rpm`, `container`, `deb`, or `mix` if there are multiple plugins in a
 snapshot.  
State can be `base`, `changed` or whatever you find useful. The idea is to have some reference for
 the tests where multiple snapshots are required.
The rest of identifiers which make it easier to figure out which snapshot is chosen can
 be specified separated by the underscore.

Examples:
 * file_base_4repos
 * file_changed_4repos_removal
 * mix_base_rpm_container

##### MongoDB archive

The CI script relies on the name being ``mongodb.<the directory name for your snaphot>.archive``.

Examples:
 * mongodb.file_base_4repos.archive
 * mongodb.file_changed_4repos_removal.archive
 * mongodb.mix_base_rpm_container.archive


#### Config to generate a snapshot

```json

{
    "name": "file_base_4repos",
    "plugins": {
        "name": "file",
        "remote_base_url": "https://fixtures.pulpproject.org/", # it is used in combination with
                                                                # provided repo_id to form a remote
                                                                # url, if a url is not specified
                                                                # explicitly for a repo.
        "repositories": {
            "repo_id": "file", "download_policy": "immediate", "mode": "additive",
            "repo_id": "file2", "download_policy": "on_demand", "mode": "mirror", "url": "a custom URL",
            "repo_id": "file-many", "download_policy": "on_demand", "mode": "mirror",
            "repo_id": "file-large", "download_policy": "immediate", "mode": "additive",
       },
       "post_repo_creation_commands": [
            "any custom commands",
            "to run in bash",
            "after repositories are created/synced/published",
            "but before a dump is created"
       ]
    }
}
```


#### How to generate a snapshot

TODO: provide a script and instructions to use it


#### A manual way to create a snapshot

    sudo systemctl stop httpd pulp_workers pulp_resource_manager pulp_celerybeat
    mongo pulp_database --eval "db.dropDatabase()"
    sudo rm -rf /var/lib/pulp/content
    sudo rm -rf /var/lib/pulp/published
    sudo -u apache pulp-manage-db;
    sudo systemctl start httpd pulp_workers pulp_resource_manager pulp_celerybeat
    pulp-admin login -u admin -p admin
    pulp-admin iso repo create --feed https://fixtures.pulpproject.org/file/ --repo-id file
    pulp-admin iso repo create --feed https://fixtures.pulpproject.org/file2/ --repo-id file2 --download-policy on_demand
    pulp-admin iso repo create --feed https://fixtures.pulpproject.org/file-many/ --repo-id file-many --download-policy on_demand
    pulp-admin iso repo create --feed https://fixtures.pulpproject.org/file-large/ --repo-id file-large
    pulp-admin iso repo sync run --repo-id file &
    pulp-admin iso repo sync run --repo-id file2 &
    pulp-admin iso repo sync run --repo-id file-many &
    pulp-admin iso repo sync run --repo-id file-large &
    
    mongodump --archive=mongodb.file_base_4repos.archive --db=pulp_database
    tar -zcvf pulp2_var_lib_published.file_base_4repos.tar.gz  /var/lib/pulp/published
    tar -zcvf pulp2_var_lib_content.file_base_4repos.tar.gz  /var/lib/pulp/content
    mkdir file_base_4repos
    cd file_base_4repos
    tar -xvf pulp2_var_lib_published.file_base_4repos.tar.gz
    tar -xvf pulp2_var_lib_content.file_base_4repos.tar.gz


### How to use a snapshot in a test

Use the provided `set_pulp2_snapshot(your_snapshot_directory_name)` function to set up the test
 class or a specific test. The function can be used multiple times in one test if it needs to
 emulate some change in pulp 2. The function removes all the mongo and related FS data and rolls
 out a specified snapshot.
 
It's better to run tests when pulp 2 is not running because some collections might get created while
 you are restoring the database. E.g. locks, reserved_resources, task_status, etc due to the
 running services and periodic tasks. (TODO: exclude affected collections at the mongodump time)


    It's a good idea to group tests which can use the same snapshot in one test class. If the
    snapshot rollout happens in setUpclass method and not for every test, it's more efficient.
