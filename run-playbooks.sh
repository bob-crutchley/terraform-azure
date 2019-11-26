#!/bin/bash

# NGINX
ansible-playbook \
    -i "$(terraform output nginx_fqdn)," \
    -u jenkins \
    --ssh-common-args="-o StrictHostKeyChecking=no" playbooks/nginx.yml

