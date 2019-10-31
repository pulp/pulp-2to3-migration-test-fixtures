# pulp-2to3-migration-test-fixtures

This repository contains a mongodump archives, /var/lib/pulp/content archives, and /var/lib/published archives.

The following commands were used to generated the current snapshots. 

    sudo systemctl stop httpd pulp_workers pulp_resource_manager pulp_celerybeat
    mongo pulp_database --eval "db.dropDatabase()"
    sudo rm -rf /var/lib/pulp/content
    sudo rm -rf /var/lib/pulp/published
    sudo -u apache pulp-manage-db;
    sudo systemctl start httpd pulp_workers pulp_resource_manager pulp_celerybeat
    pulp-admin login -u admin -p admin
    pulp-admin iso repo create --feed https://repos.fedorapeople.org/pulp/pulp/fixtures/file/ --repo-id file
    pulp-admin iso repo create --feed https://repos.fedorapeople.org/pulp/pulp/fixtures/file2/ --repo-id file2 --download-policy on_demand
    pulp-admin iso repo create --feed https://repos.fedorapeople.org/pulp/pulp/fixtures/file-many/ --repo-id file-many --download-policy on_demand
    pulp-admin iso repo create --feed https://repos.fedorapeople.org/pulp/pulp/fixtures/file-large/ --repo-id file-large
    pulp-admin iso repo sync run --repo-id file &
    pulp-admin iso repo sync run --repo-id file2 &
    pulp-admin iso repo sync run --repo-id file-many &
    pulp-admin iso repo sync run --repo-id file-large &
    
    mongodump --archive=pulp2filecontent.20191031.archive --db=pulp_database
    tar -zcvf pulp2_var_lib_published.20191031.tar.gz  /var/lib/pulp/published
    tar -zcvf pulp2_var_lib_content.20191031.tar.gz  /var/lib/pulp/content
    mkdir 20191031
    cd 20191031
    tar -xvf pulp2_var_lib_published.20191031.tar.gz
    tar -xvf pulp2_var_lib_content.20191031.tar.gz 
