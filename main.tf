# # terraform block
# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "5.90.0"
#     }
#   }
#   backend "s3" {
#     bucket = "kubeadm-konkas-tech"
#     key    = "kubeadm/terraform.tfstate"
#     region = "ap-south-1"
#   }
# }
# # Provider
# provider "aws" {
#   region = "ap-south-1"
# }

# # Data Blocks
# data "aws_ami" "example" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
#   }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# data "aws_ssm_parameter" "private_key" {
#   name            = "siva"
#   with_decryption = true
# }

# # Resource Block
# resource "aws_instance" "k8s_nodes" {
#   for_each                    = var.instance_types
#   ami                         = data.aws_ami.example.id
#   instance_type               = each.value
#   key_name                    = "siva"
#   security_groups = each.key == "control-plane" ? [aws_security_group.k8s_control_plane_sg.name] : [aws_security_group.k8s_node_sg.name]
#   associate_public_ip_address = true

#   root_block_device {
#     volume_size = 30
#     volume_type = "gp3"
#   }
#   tags = {
#     Name = "${each.key}"
#   }
# }

# resource "null_resource" "run_ansible" {
#   triggers = {
#            always_run = timestamp()  # This ensures the resource always changes
#   }
#   depends_on = [aws_instance.k8s_nodes]
#   for_each = toset(var.playbook_names)

#   provisioner "file" {
#     source      = "ansible-playbooks/${each.key}"
#     destination = "/home/ubuntu/${each.key}"

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = data.aws_ssm_parameter.private_key.value 
#       host        = aws_instance.k8s_nodes["control-plane"].public_ip
#     }
#   }

#   # Execute Ansible
#   provisioner "remote-exec" {
#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = data.aws_ssm_parameter.private_key.value 
#       host        = aws_instance.k8s_nodes["control-plane"].public_ip
#     }

#     inline = [
#     # Fetch private key from AWS SSM and save it securely
#     "echo '${data.aws_ssm_parameter.private_key.value}' | sudo tee /home/ubuntu/siva > /dev/null",
#     "sudo chmod 400 /home/ubuntu/siva",

#     # Install Ansible
#     "sudo apt update && sudo apt install -y ansible",

#     # Create Ansible inventory file
#     "echo '[control-plane]' | sudo tee /home/ubuntu/inventory.ini > /dev/null",
#     "echo 'control-plane ansible_host=127.0.0.1 ansible_connection=local' | sudo tee -a /home/ubuntu/inventory.ini > /dev/null",
#     "echo '[nodes]' | sudo tee -a /home/ubuntu/inventory.ini > /dev/null",
#     "echo 'node-1 ansible_host=${aws_instance.k8s_nodes["node-1"].private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/siva ansible_ssh_common_args="-o StrictHostKeyChecking=no"' | sudo tee -a /home/ubuntu/inventory.ini > /dev/null",
#     "echo 'node-2 ansible_host=${aws_instance.k8s_nodes["node-2"].private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/siva ansible_ssh_common_args="-o StrictHostKeyChecking=no"' | sudo tee -a /home/ubuntu/inventory.ini > /dev/null"

#     # Verify files and key
#     "ls -l /home/ubuntu/",
#     "md5sum /home/ubuntu/siva",  # Validate private key
#     "ssh-keygen -y -f /home/ubuntu/siva"  # Ensure key is valid

#     # Ensure Playbook files exist
#     "ls -l /home/ubuntu/*.yml",
#     "sudo chmod +r /home/ubuntu/*.yml",

#     # Run Ansible Playbooks
#     "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /home/ubuntu/inventory.ini /home/ubuntu/common.yml",
#     "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /home/ubuntu/inventory.ini /home/ubuntu/master.yml",
#     "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /home/ubuntu/inventory.ini /home/ubuntu/node.yml"
#   ]
#   }
# }

# # r53 records
# resource "aws_route53_record" "www" {
#   for_each = var.instance_types
#   zone_id  = "Z011675617HENPLWZ1EJC"
#   name     = "${each.key}.konkas.tech"
#   type     = "A"
#   ttl      = "300"
#   records  = [aws_instance.k8s_nodes[each.key].public_ip]
#   allow_overwrite = true
# }