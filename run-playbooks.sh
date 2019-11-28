#!/bin/bash
set -e

export MYSQL_HOST=$(terraform output database_hostname)
export API_HOST=$(terraform output api_hostname)

# database
ansible-playbook \
    -i "$(terraform output database_fqdn)," \
    -u jenkins \
    --ssh-common-args="-o StrictHostKeyChecking=no" playbooks/database.yml

# api
ansible-playbook \
    -i "$(terraform output api_fqdn)," \
    -u jenkins \
    --ssh-common-args="-o StrictHostKeyChecking=no" playbooks/api.yml

# website
ansible-playbook \
    -i "$(terraform output website_fqdn)," \
    -u jenkins \
    --ssh-common-args="-o StrictHostKeyChecking=no" playbooks/website.yml
