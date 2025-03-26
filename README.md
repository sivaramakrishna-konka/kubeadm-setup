# Kubeadm Setup

## Overview
This project sets up a **3-node Kubernetes cluster** using **kubeadm**. The infrastructure is provisioned with **Terraform**, and **Ansible** automates the installation and configuration of the cluster. The setup runs through a **GitHub Actions pipeline** and leverages **OIDC** for authentication, eliminating the need for credentials.

## Architecture
- **3-node cluster** (1 Master, 2 Workers)
- **Terraform** provisions cloud instances
- **Ansible** automates the kubeadm cluster setup (runs on the Master node)
- **Ansible uses the private key for authentication** to connect to agent nodes for installation and configuration
- **GitHub Actions** pipeline automates the entire process
- **OIDC authentication** for permission management (no credentials required)
- **Workflows for creation and deletion** are available in the same repository under `.github/workflows/`.
- **GitHub-hosted runners** are used, eliminating the need to install Terraform locally.

## Prerequisites
Ensure you have the following set up:
- GitHub Actions workflow configured
- OIDC authentication enabled
- Private and public key pair configured in AWS
- Place the **private key** in the repository securely for access (used by Ansible for authentication)
- Ensure line endings use **LF** instead of **CRLF**

## Setup Guide

### Step 1: Trigger the GitHub Actions Pipeline
1. Trigger the pipeline manually or push changes to the repository.
2. The pipeline will:
   - Use Terraform (on GitHub-hosted runners) to create instances
   - Use Ansible (running on the Master node) to configure the cluster

### Step 2: Verify the Cluster
Once the setup is complete, SSH into the master node and run:
```sh
kubectl get nodes
```
You should see all three nodes in a **Ready** state.

## Cleanup
To destroy the setup, simply trigger the GitHub Actions pipeline for teardown.

## Workflows
The repository includes predefined GitHub Actions workflows for:
- **Cluster Creation**: `.github/workflows/provision.yml` (Trigger to create the cluster)
- **Cluster Deletion**: `.github/workflows/destroy.yml` (Trigger to delete the cluster)

## Contributions
Feel free to fork and contribute by submitting PRs!

## License
This project is licensed under the MIT License.
