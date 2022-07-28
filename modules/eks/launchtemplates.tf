locals {
  dns = cidrhost("${aws_eks_cluster.eks_cluster.kubernetes_network_config[0].service_ipv4_cidr}", 10)
}

data "aws_ssm_parameter" "eks_ami" {
  # exemplo:
  # aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.21/amazon-linux-2/recommended/image_id
  name = "/aws/service/eks/optimized-ami/${var.kubernetes_version}/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "kube_system" {
  name = "${var.service}-${var.environment}-kube-system"

  default_version = "1"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20
    }
  }

  image_id = data.aws_ssm_parameter.eks_ami.value

  user_data = base64encode(templatefile("${path.module}/kube-system-userdata.tpl", { CLUSTER_NAME = aws_eks_cluster.eks_cluster.name, B64_CLUSTER_CA = aws_eks_cluster.eks_cluster.certificate_authority[0].data, API_SERVER_URL = aws_eks_cluster.eks_cluster.endpoint, K8S_CLUSTER_DNS_IP = local.dns, AMI_ID = data.aws_ssm_parameter.eks_ami.value, NODE_GROUP = "kube-system" }))

  tags = {
    Name = "${var.service}-${var.environment}-eks"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.service}-${var.environment}-nodegroup-kube-system"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${var.service}-${var.environment}-nodegroup-kube-system"
    }
  }
}