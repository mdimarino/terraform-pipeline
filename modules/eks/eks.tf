resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.service}-${var.environment}"
  role_arn = aws_iam_role.eks_role.arn

  version = var.kubernetes_version

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = [aws_security_group.eks_cluster.id]
    subnet_ids              = concat(var.public_subnets_ids, var.private_subnets_ids)
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
    ip_family         = "ipv4"
  }

  depends_on = [
    aws_cloudwatch_log_group.eks_log_group,
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy_attach_eks_role,
    aws_security_group.eks_cluster
  ]

  timeouts {
    create = "30m"
    update = "1h"
    delete = "15m"
  }

  tags = {
    Name = "${var.service}-${var.environment}"
  }
}

resource "aws_eks_fargate_profile" "namespaces" {

  count = length(var.fargate_profile_namespaces)

  cluster_name           = aws_eks_cluster.eks_cluster.name
  fargate_profile_name   = var.fargate_profile_namespaces[count.index]
  pod_execution_role_arn = aws_iam_role.eks_fargate_role.arn
  subnet_ids             = var.private_subnets_ids

  selector {
    namespace = var.fargate_profile_namespaces[count.index]
    labels    = {}
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_fargate_logging_policy_attach_eks_fargate_role
  ]

  timeouts {
    create = "10m"
    delete = "10m"
  }

  tags = {
    Name = "${var.service}-${var.environment}"
  }
}

resource "aws_eks_node_group" "eks_node_groups" {

  count = length(var.eks_node_groups)

  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.eks_node_groups[count.index]
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.private_subnets_ids

  capacity_type = "SPOT"

  instance_types = ["t3a.medium", "t3.medium", "t3a.small", "t3.small"]

  scaling_config {
    desired_size = 3
    max_size     = 6
    min_size     = 1
  }

  update_config {
    max_unavailable = 2
  }

  launch_template {
    id      = aws_launch_template.kube_system.id
    version = aws_launch_template.kube_system.latest_version
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy_attach_eks_node_group_role,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy_attach_eks_node_group_role,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only_policy_attach_eks_node_group_role,
    aws_iam_role_policy_attachment.amazon_ssm_managed_instance_core_policy_attach_eks_node_group_role
  ]

  tags = {
    Name = "${var.service}-${var.environment}"
  }
}