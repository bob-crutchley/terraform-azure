#!/bin/bash

# website
ansible-playbook \
    -i "$(terraform output website_fqdn)," \
    -u jenkins \
    --ssh-common-args="-o StrictHostKeyChecking=no" playbooks/website.yml

# database
ansible-playbook \
    -i "$(terraform output database_fqdn)," \
    -u jenkins \
    --ssh-common-args="-o StrictHostKeyChecking=no" playbooks/database.yml

