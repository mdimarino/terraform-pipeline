### EKS ###

resource "aws_security_group" "eks_cluster" {
  name        = "${var.service}-${var.environment}-eks"
  description = "Grupo de Seguranca extra das ENIs do control plane"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Permite trafego indo para qualquer lugar"
  }

  tags = {
    Name = "${var.service}-${var.environment}-eks"
  }
}
