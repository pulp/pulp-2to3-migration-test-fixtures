sudo systemctl stop httpd pulp_workers pulp_resource_manager pulp_celerybeat
mongo pulp_database --eval "db.dropDatabase()"
sudo rm -rf /var/lib/pulp/content
sudo rm -rf /var/lib/pulp/published
sudo -u apache pulp-manage-db;
sudo systemctl start httpd pulp_workers pulp_resource_manager pulp_celerybeat
pulp-admin login -u admin -p admin
pulp-admin rpm repo create --repo-id rpm-empty
pulp-admin rpm repo create --repo-id rpm-empty-for-copy
pulp-admin rpm repo create --feed https://fixtures.pulpproject.org/rpm-with-modules/ --repo-id rpm-with-modules --download-policy on_demand
pulp-admin rpm repo create --feed https://fixtures.pulpproject.org/rpm-distribution-tree/ --repo-id rpm-distribution-tree --download-policy on_demand
pulp-admin rpm repo create --feed https://fixtures.pulpproject.org/srpm-unsigned/ --repo-id srpm-unsigned --download-policy on_demand 
pulp-admin rpm repo sync run --repo-id rpm-with-modules
pulp-admin rpm repo sync run --repo-id rpm-distribution-tree
pulp-admin rpm repo sync run --repo-id srpm-unsigned

mkdir rpm_base_4repos
cd rpm_base_4repos
mongodump --archive=mongodb.rpm_base_4repos.archive --db=pulp_database
sudo -u apache tar -zcvf pulp2_var_lib_published.rpm_base_4repos.tar.gz  /var/lib/pulp/published
sudo -u apache tar -zcvf pulp2_var_lib_content.rpm_base_4repos.tar.gz  /var/lib/pulp/content
tar -xvf pulp2_var_lib_published.rpm_base_4repos.tar.gz
tar -xvf pulp2_var_lib_content.rpm_base_4repos.tar.gz
rm pulp2_var_lib_published.rpm_base_4repos.tar.gz
rm pulp2_var_lib_content.rpm_base_4repos.tar.gz
