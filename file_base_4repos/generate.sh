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
pulp-admin iso repo sync run --repo-id file
pulp-admin iso repo sync run --repo-id file2
pulp-admin iso repo sync run --repo-id file-many
pulp-admin iso repo sync run --repo-id file-large
    
mkdir file_base_4repos
cd file_base_4repos
mongodump --archive=mongodb.file_base_4repos.archive --db=pulp_database
sudo -u apache tar -zcvf pulp2_var_lib_published.file_base_4repos.tar.gz  /var/lib/pulp/published
sudo -u apache tar -zcvf pulp2_var_lib_content.file_base_4repos.tar.gz  /var/lib/pulp/content
tar -xvf pulp2_var_lib_published.file_base_4repos.tar.gz
tar -xvf pulp2_var_lib_content.file_base_4repos.tar.gz
rm pulp2_var_lib_published.file_base_4repos.tar.gz
rm pulp2_var_lib_content.file_base_4repos.tar.gz

