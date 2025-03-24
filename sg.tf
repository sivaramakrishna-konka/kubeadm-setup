# Control Plane Security Group
resource "aws_security_group" "k8s_control_plane_sg" {
  name        = "k8s-control-plane-sg"
  description = "Security group for Kubernetes control plane (API server, etcd, controllers)"

  # Allow etcd server client API (2379-2380) from itself
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    description = "Allow etcd server client API access from kube-apiserver and etcd nodes"
    self        = true
  }

  # Allow Kubelet API (10250) from itself
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    description = "Allow Kubelet API access from itself"
    self        = true
  }

  # Allow kube-scheduler (10259) from self
  ingress {
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    description = "Allow kube-scheduler to communicate within control plane"
    self        = true
  }

  # Allow kube-controller-manager (10257) from self
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

# Worker Node Security Group
resource "aws_security_group" "k8s_node_sg" {
  name        = "k8s-node-sg"
  description = "Security group for Kubernetes worker nodes"

  # Allow kube-proxy (10256) from self (other worker nodes) and Load Balancers
  ingress {
    from_port   = 10256
    to_port     = 10256
    protocol    = "tcp"
    description = "Allow kube-proxy communication between worker nodes and load balancers"
    self        = true
  }

  # Allow NodePort services (30000-32767) from anywhere
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

# Separate Rules to Allow Cross Communication

resource "aws_security_group_rule" "allow_api_server_from_nodes" {
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.k8s_control_plane_sg.id
  source_security_group_id = aws_security_group.k8s_node_sg.id
  description              = "Allow Kubernetes API server access from worker nodes"
}

resource "aws_security_group_rule" "allow_kubelet_from_control_plane" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.k8s_node_sg.id
  source_security_group_id = aws_security_group.k8s_control_plane_sg.id
  description              = "Allow Kubelet API access from control plane"
}
