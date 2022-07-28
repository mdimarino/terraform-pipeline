locals {
  issuer = replace("${aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer}", "https://", "")
}

data "tls_certificate" "eks_cluster" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy" "amazon_ec2_container_registry_read_only_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

### EKS CLUSTER ###

data "aws_iam_policy" "amazon_eks_cluster_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy" "amazon_eks_vpc_resource_controller" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

data "aws_iam_policy_document" "assume_role_eks_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "cluster_policy_cloudwatchmetrics_iam_policy" {
  name        = "${var.service}-${var.environment}-cluster-PolicyCloudWatchMetrics"
  path        = "/"
  description = "Permite que o cluster coloque métricas em qualquer CloudWatch Logs"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "cloudwatch:PutMetricData"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      }
    ]
  })

  tags = {
    Name = "${var.service}-${var.environment}-cluster-PolicyCloudWatchMetrics"
  }
}

resource "aws_iam_policy" "cluster_policy_elb_permissions_iam_policy" {
  name        = "${var.service}-${var.environment}-cluster-PolicyELBPermissions"
  path        = "/"
  description = "Permite que o cluster leia informações sobre elementos EC2"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeInternetGateways"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      }
    ]
  })

  tags = {
    Name = "${var.service}-${var.environment}-cluster-PolicyELBPermissions"
  }
}

resource "aws_iam_role" "eks_role" {
  name               = "${var.service}-${var.environment}-eks"
  assume_role_policy = data.aws_iam_policy_document.assume_role_eks_policy.json

  tags = {
    Name = "${var.service}-${var.environment}-eks"
  }
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy_attach_eks_role" {
  role       = aws_iam_role.eks_role.name
  policy_arn = data.aws_iam_policy.amazon_eks_cluster_policy.arn
}

resource "aws_iam_role_policy_attachment" "amazon_eks_vpc_resource_controller_attach_eks_role" {
  role       = aws_iam_role.eks_role.name
  policy_arn = data.aws_iam_policy.amazon_eks_vpc_resource_controller.arn
}

resource "aws_iam_role_policy_attachment" "cluster_policy_cloudwatchmetrics_iam_policy_attach_eks_role" {
  role       = aws_iam_role.eks_role.name
  policy_arn = aws_iam_policy.cluster_policy_cloudwatchmetrics_iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "cluster_policy_elb_permissions_iam_policy_attach_eks_role" {
  role       = aws_iam_role.eks_role.name
  policy_arn = aws_iam_policy.cluster_policy_elb_permissions_iam_policy.arn
}

resource "aws_iam_openid_connect_provider" "eks_cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

### AWS LOAD BALANCER CONTROLLER ###

resource "aws_iam_policy" "aws_load_balancer_controller_iam_policy" {
  name        = "${var.service}-${var.environment}-AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "AWS Load Balancer Controller to an Amazon EKS cluster"

  # origem: https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.1/docs/install/iam_policy.json

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:CreateServiceLinkedRole"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "iam:AWSServiceName" : "elasticloadbalancing.amazonaws.com"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateSecurityGroup"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags"
        ],
        "Resource" : "arn:aws:ec2:*:*:security-group/*",
        "Condition" : {
          "StringEquals" : {
            "ec2:CreateAction" : "CreateSecurityGroup"
          },
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        "Resource" : "arn:aws:ec2:*:*:security-group/*",
        "Condition" : {
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "true",
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DeleteSecurityGroup"
        ],
        "Resource" : "*",
        "Condition" : {
          "Null" : {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup"
        ],
        "Resource" : "*",
        "Condition" : {
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ],
        "Resource" : [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ],
        "Condition" : {
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "true",
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ],
        "Resource" : [
          "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DeleteTargetGroup"
        ],
        "Resource" : "*",
        "Condition" : {
          "Null" : {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ],
        "Resource" : "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = {
    Name = "${var.service}-${var.environment}-AWSLoadBalancerControllerIAMPolicy"
  }
}

resource "aws_iam_role" "amazon_eks_load_balancer_controller_role" {
  name = "${var.service}-${var.environment}-AmazonEKSLoadBalancerControllerRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.issuer}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.issuer}:aud" : "sts.amazonaws.com",
            "${local.issuer}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.service}-${var.environment}-AmazonEKSLoadBalancerControllerRole"
  }
}

resource "aws_iam_role_policy_attachment" "amazon_eks_load_balancer_controller_role_attach_aws_load_balancer_controller_iam_policy" {
  role       = aws_iam_role.amazon_eks_load_balancer_controller_role.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller_iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "amazon_eks_load_balancer_controller_role_attach_eks_fargate_logging_policy_iam_policy" {
  role       = aws_iam_role.amazon_eks_load_balancer_controller_role.name
  policy_arn = aws_iam_policy.eks_fargate_logging_policy.arn
}

### API-GATEWAY INGRESS CONTROLLER ###

resource "aws_iam_policy" "amazon_apigateway_ingress_controller_iam_policy" {
  name        = "${var.service}-${var.environment}-AmazonAPIGatewayIngressControllerIAMPolicy"
  path        = "/"
  description = "Amazon API Gateway ingress controller to an Amazon EKS cluster"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "apigateway:*"
        ],
        "Resource" : "arn:aws:apigateway:*::/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:CreateServiceLinkedRole",
        "Resource" : "*"
      }
    ]
  })

  tags = {
    Name = "${var.service}-${var.environment}-AmazonAPIGatewayIngressControllerIAMPolicy"
  }
}

resource "aws_iam_role" "amazon_apigateway_ingress_controller_role" {
  name = "${var.service}-${var.environment}-AmazonAPIGatewayIngressControllerRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.issuer}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.issuer}:aud" : "sts.amazonaws.com",
            "${local.issuer}:sub" : "system:serviceaccount:kube-system:ack-apigatewayv2-controller"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.service}-${var.environment}-AmazonAPIGatewayIngressControllerRole"
  }
}

resource "aws_iam_role_policy_attachment" "amazon_apigateway_ingress_controller_role_attach_amazon_apigateway_ingress_controller_iam_policy" {
  role       = aws_iam_role.amazon_apigateway_ingress_controller_role.name
  policy_arn = aws_iam_policy.amazon_apigateway_ingress_controller_iam_policy.arn
}

### EKS FARGATE ###

data "aws_iam_policy" "amazon_eks_fargate_pod_execution_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}

resource "aws_iam_policy" "eks_fargate_logging_policy" {
  name        = "${var.service}-${var.environment}-eks-fargate-logging-policy"
  path        = "/"
  description = "Política que permite aos Pods Fargate logar no CloudWatch"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = {
    Name = "${var.service}-${var.environment}-eks-fargate-logging-policy"
  }
}

data "aws_iam_policy_document" "assume_role_eks_fargate_pods_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_fargate_role" {
  name = "${var.service}-${var.environment}-fargate-eks"

  assume_role_policy = data.aws_iam_policy_document.assume_role_eks_fargate_pods_policy.json

  tags = {
    Name = "${var.service}-${var.environment}-fargate-eks"
  }
}

resource "aws_iam_role_policy_attachment" "amazon_eks_fargate_pods_policy_attach_eks_fargate_role" {
  role       = aws_iam_role.eks_fargate_role.name
  policy_arn = data.aws_iam_policy.amazon_eks_cluster_policy.arn
}

resource "aws_iam_role_policy_attachment" "amazon_eks_fargate_logging_policy_attach_eks_fargate_role" {
  role       = aws_iam_role.eks_fargate_role.name
  policy_arn = aws_iam_policy.eks_fargate_logging_policy.arn
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only_policy_attach_eks_fargate_role" {
  role       = aws_iam_role.eks_fargate_role.name
  policy_arn = data.aws_iam_policy.amazon_ec2_container_registry_read_only_policy.arn
}

# em pods fargate as permissões IAM só podem ser atribuidas via kubernetes service account
# todo namespace tem um service account 'default', que por padrão, todo pod neste namespace é associado
resource "aws_iam_role" "default_namespace_service_account_namespace_role" {

  count = length(var.fargate_profile_namespaces)

  name = "${var.service}-${var.environment}-${var.fargate_profile_namespaces[count.index]}-DefaultSARole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.issuer}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.issuer}:aud" : "sts.amazonaws.com",
            "${local.issuer}:sub" : "system:serviceaccount:${var.fargate_profile_namespaces[count.index]}:default"
          }
        }
      }
    ]
  })

  tags = {
    Name = "eks-namespace-${var.fargate_profile_namespaces[count.index]}-DefaultServiceAccountRole"
  }
}

resource "aws_iam_role_policy_attachment" "amazon_eks_fargate_logging_policy_attach_default_namespace_service_account_namespace_role" {
  count      = length(var.fargate_profile_namespaces)
  role       = aws_iam_role.default_namespace_service_account_namespace_role[count.index].name
  policy_arn = aws_iam_policy.eks_fargate_logging_policy.arn
}

### EKS MANAGED NODE GROUP ###

data "aws_iam_policy" "amazon_ssm_managed_instance_core_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "amazon_eks_worker_node_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "amazon_eks_cni_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy_document" "assume_role_eks_node_group" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.service}-${var.environment}-node-group-eks"

  assume_role_policy = data.aws_iam_policy_document.assume_role_eks_node_group.json

  tags = {
    Name = "${var.service}-${var.environment}-node-group-eks"
  }
}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core_policy_attach_eks_node_group_role" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = data.aws_iam_policy.amazon_ssm_managed_instance_core_policy.arn
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy_attach_eks_node_group_role" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = data.aws_iam_policy.amazon_eks_worker_node_policy.arn
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy_attach_eks_node_group_role" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = data.aws_iam_policy.amazon_eks_cni_policy.arn
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only_policy_attach_eks_node_group_role" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = data.aws_iam_policy.amazon_ec2_container_registry_read_only_policy.arn
}
