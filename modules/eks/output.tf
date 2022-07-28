output "cluster_security_group_id" {
  description = "O ID do grupo de segurança do cluster EKS"
  value       = aws_eks_cluster.eks_cluster.vpc_config.0.cluster_security_group_id
}