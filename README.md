# Kubeadm Cluster Automation with Terraform and Ansible

## Overview
This project automates the creation of a Kubernetes cluster using **kubeadm**, **Terraform**, and **Ansible**. The entire setup is fully automated and completes within approximately **5 minutes**.

## Key Features
- **GitHub Workflows**: Automates instance creation and execution of Ansible playbooks using Terraform's `remote-exec`.
- **AWS Parameter Store**: Stores and fetches required key securely using Terraform `data` block.
- **Ubuntu AMI Fetching**: Dynamically retrieves the latest Ubuntu AMI.
- **OIDC Authentication**: Implements OIDC for authentication and authorization with AWS.
- **GitHub Hosted Runners**: Executes Terraform and Ansible playbooks.
- **Provisioning Playbook** (`provision.yml`): Triggers the creation of the **kubeadm** cluster.
- **Destruction Playbook** (`destroy.yml`): Triggers the deletion of the **kubeadm** cluster.
- **Ansible Playbook**: Configures a **3-node Kubernetes cluster**.
- **Terraform Remote-Exec**: Installs Ansible on the master node before running playbooks.
- **Security Group (SG) Configuration**: Currently allows all traffic (not following security best practices since this is for practice only).

## Prerequisites
- No need for local Terraform, Ansible, or AWS CLI configuration as GitHub Workflows handle everything.
- Basic knowledge of:
  - **GitHub Workflows**
  - **Terraform**
  - **Ansible**

## Deployment Steps
1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd <repo-directory>
   ```
2. Trigger the GitHub workflow to provision infrastructure.
3. Monitor the GitHub Actions workflow for instance provisioning and configuration.
4. Once completed, access the Kubernetes cluster using:
   ```bash
   kubectl get nodes
   ```

## Cleanup
To destroy the setup, simply trigger the GitHub Actions pipeline for teardown.

## Note
- This setup is purely for practice and **does not** follow security best practices.

## Workflows
The repository includes predefined GitHub Actions workflows for:
- **Cluster Creation**: `.github/workflows/provision.yml` (Trigger to create the cluster)
- **Cluster Deletion**: `.github/workflows/destroy.yml` (Trigger to delete the cluster)

## Contributions
Feel free to fork and contribute by submitting PRs!

## License
This project is licensed under the MIT License.
