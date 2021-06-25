sudo systemctl stop httpd pulp_workers pulp_resource_manager pulp_celerybeat
mongo pulp_database --eval "db.dropDatabase()"
sudo rm -rf /var/lib/pulp/content
sudo rm -rf /var/lib/pulp/published
sudo -u apache pulp-manage-db;
sudo systemctl start httpd pulp_workers pulp_resource_manager pulp_celerybeat
pulp-admin login -u admin -p admin
pulp-admin deb repo create --repo-id debian-empty
pulp-admin deb repo create --feed https://fixtures.pulpproject.org/debian/ --repo-id debian --releases ragnarok
pulp-admin deb repo create --feed https://fixtures.pulpproject.org/debian-complex-dists/ --repo-id debian-complex-dists --releases ragnarok/updates
pulp-admin deb repo create --feed https://fixtures.pulpproject.org/debian_update/ --repo-id debian_update --releases ginnungagap --architecture ppc64
pulp-admin deb repo sync run --repo-id debian
pulp-admin deb repo sync run --repo-id debian-complex-dists
pulp-admin deb repo sync run --repo-id debian_update

mkdir deb_base_4repos
cd deb_base_4repos
mongodump --archive=mongodb.deb_base_4repos.archive --db=pulp_database
sudo -u apache tar -zcvf pulp2_var_lib_published.deb_base_4repos.tar.gz  /var/lib/pulp/published
sudo -u apache tar -zcvf pulp2_var_lib_content.deb_base_4repos.tar.gz  /var/lib/pulp/content
tar -xvf pulp2_var_lib_published.deb_base_4repos.tar.gz
tar -xvf pulp2_var_lib_content.deb_base_4repos.tar.gz
rm pulp2_var_lib_published.deb_base_4repos.tar.gz
rm pulp2_var_lib_content.deb_base_4repos.tar.gz
