#!/bin/bash
set -e  # Exit if any command fails

PRIVATE_KEY="$1"
NODE1_IP="$2"
NODE2_IP="$3"

# Fetch private key from AWS SSM and save it securely
echo "$PRIVATE_KEY" | sudo tee /home/ubuntu/siva > /dev/null
sudo chmod 400 /home/ubuntu/siva

# Install Ansible
sudo apt update && sudo apt install -y ansible

# Create Ansible inventory file
cat <<EOL | sudo tee /home/ubuntu/inventory.ini > /dev/null
[control-plane]
control-plane ansible_host=127.0.0.1 ansible_connection=local

[nodes]
node-1 ansible_host=$NODE1_IP ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/siva ansible_ssh_common_args="-o StrictHostKeyChecking=no"
node-2 ansible_host=$NODE2_IP ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/siva ansible_ssh_common_args="-o StrictHostKeyChecking=no"
EOL

# Run Ansible Playbooks
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /home/ubuntu/inventory.ini /home/ubuntu/common.yml
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /home/ubuntu/inventory.ini /home/ubuntu/master.yml
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /home/ubuntu/inventory.ini /home/ubuntu/node.yml
