### Control Plane SG
resource "aws_security_group" "k8s_control_plane_sg" {
  name        = "k8s-control-plane-sg"
  description = "Security group for Kubernetes control plane (API server, etcd, controllers)"

  # Allow Kubernetes API server (6443) from all worker nodes
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    description = "Allow Kubernetes API server access from worker nodes"
    security_groups = [aws_security_group.k8s_node_sg.id]
  }

  # Allow etcd server client API (2379-2380) from kube-apiserver and etcd itself
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    description = "Allow etcd server client API access from kube-apiserver and etcd nodes"
    self        = true
  }

  # Allow Kubelet API (10250) from self and worker nodes
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    description = "Allow Kubelet API access from self and worker nodes"
    self        = true
    security_groups = [aws_security_group.k8s_node_sg.id]
  }

  # Allow kube-scheduler (10259) from self only
  ingress {
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    description = "Allow kube-scheduler to communicate within control plane"
    self        = true
  }

  # Allow kube-controller-manager (10257) from self only
  ingress {
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    description = "Allow kube-controller-manager to communicate within control plane"
    self        = true
  }
  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Allow SSH from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow all outbound traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# NodeSG
resource "aws_security_group" "k8s_node_sg" {
  name        = "k8s-node-sg"
  description = "Security group for Kubernetes worker nodes"

  # Allow Kubelet API (10250) from control plane and self
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    description = "Allow Kubelet API access from self and control plane"
    self        = true
    security_groups = [aws_security_group.k8s_control_plane_sg.id]
  }

  # Allow kube-proxy (10256) from self (other worker nodes) and Load Balancers
  ingress {
    from_port   = 10256
    to_port     = 10256
    protocol    = "tcp"
    description = "Allow kube-proxy communication between worker nodes and load balancers"
    self        = true
  }

  # Allow NodePort services (30000-32767) from anywhere (adjust as needed)
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    description = "Allow NodePort services access from all sources"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Allow SSH from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow all outbound traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

