# Exemplos de subredes usando CIDR 172.16.

# Cada subrede terá 2048 endereços para hosts.
# A AWS reserva os IPs .1(VPC router), .2(Amazon-provided DNS) e .3(uso futuro).
# Netmask: 255.255.248.0 = 21

# zona a publica  01 172.16.0.0/21 - 172.16.0.4 a 172.16.7.254
# zona a privada  01 172.16.8.0/21 - 172.16.8.4 a 172.16.15.254

# zona b publica  02 172.16.16.0/21 - 172.16.16.4 a 172.16.23.254
# zona b privada  02 172.16.24.0/21 - 172.16.24.4 a 172.16.31.254

# zona c publica  03 172.16.32.0/21 - 172.16.32.4 a 172.16.39.254
# zona c privada  03 172.16.40.0/21 - 172.16.40.4 a 172.16.47.254

# zona d publica 04 172.16.48.0/21 - 172.16.48.4 a 172.16.55.254
# zona d privada 04 172.16.56.0/21 - 172.16.56.4 a 172.16.63.254

# zona e publica 05 172.16.64.0/21 - 172.16.64.4 a 172.16.71.254
# zona e privada 05 172.16.72.0/21 - 172.16.72.4 a 172.16.79.254

# zona f publica 06 172.16.80.0/21 - 172.16.80.4 a 172.16.87.254
# zona f privada 06 172.16.88.0/21 - 172.16.88.4 a 172.16.95.254

# zona a database 01 172.16.96.0/21  - 172.16.96.4 a 172.16.103.254
# zona b database 02 172.16.104.0/21 - 172.16.104.4 a 172.16.111.254
# zona c database 03 172.16.112.0/21 - 172.16.112.4 a 172.16.119.254
# zona d database 04 172.16.120.0/21 - 172.16.120.4 a 172.16.127.254
# zona e database 05 172.16.128.0/21 - 172.16.128.4 a 172.16.135.254
# zona f database 06 172.16.136.0/21 - 172.16.136.4 a 172.16.143.254

# intervalos restantes
# 172.16.144.0/21, 172.16.152.0/21, 172.16.160.0/21,172.16.168.0/21, 172.16.176.0/21, 172.16.184.0/21, 172.16.192.0/21, 172.16.200.0/21, 172.16.208.0/21, 172.16.216.0/21, 172.16.224.0/21, 172.16.232.0/21, 172.16.240.0/21, 172.16.248.0/21

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr-block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.service}-${var.environment}"
  }
}

resource "aws_vpc_dhcp_options" "vpc_dhcp_options" {
  domain_name         = "${var.service}-${var.environment}"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "${var.service}-${var.environment}-dhcp-options"
  }
}

resource "aws_vpc_dhcp_options_association" "vpc_dhcp_options_association" {
  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.vpc_dhcp_options.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.service}-${var.environment}-igw"
  }
}

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = {
    Name = "${var.service}-${var.environment}-public-route"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public-subnet-cidr-blocks)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public-subnet-cidr-blocks[count.index]
  availability_zone       = var.availability-zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.service}-${var.environment}-public-subnet-0${count.index + 1}"
    # https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count          = length(var.public-subnet-cidr-blocks)
  subnet_id      = aws_subnet.public_subnets.*.id[count.index]
  route_table_id = aws_default_route_table.default_route_table.default_route_table_id
}

resource "aws_route" "public_route_to_igw" {
  route_table_id         = aws_default_route_table.default_route_table.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_subnet" "private_subnets" {
  count                   = length(var.private-subnet-cidr-blocks)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private-subnet-cidr-blocks[count.index]
  availability_zone       = var.availability-zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.service}-${var.environment}-private-subnet-0${count.index + 1}"
    # https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_route_table" "private_route_tables" {
  count  = length(var.private-subnet-cidr-blocks)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.service}-${var.environment}-private-route-0${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = length(var.private-subnet-cidr-blocks)
  subnet_id      = aws_subnet.private_subnets.*.id[count.index]
  route_table_id = aws_route_table.private_route_tables.*.id[count.index]
}

resource "aws_subnet" "database_subnets" {
  count                   = var.create-database-subnets ? length(var.database-subnet-cidr-blocks) : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.database-subnet-cidr-blocks[count.index]
  availability_zone       = var.availability-zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.service}-${var.environment}-database-subnet-0${count.index + 1}"
  }
}

resource "aws_route_table" "database_route_tables" {
  count  = var.create-database-subnets ? length(var.database-subnet-cidr-blocks) : 0
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.service}-${var.environment}-database-route-0${count.index + 1}"
  }
}

resource "aws_route_table_association" "database_route_table_association" {
  count          = var.create-database-subnets ? length(var.database-subnet-cidr-blocks) : 0
  subnet_id      = aws_subnet.database_subnets.*.id[count.index]
  route_table_id = aws_route_table.database_route_tables.*.id[count.index]
}

resource "aws_eip" "nat_eips" {
  count = var.create-nat-gateways ? length(var.public-subnet-cidr-blocks) : 0
  vpc   = true

  tags = {
    Name = "${var.service}-${var.environment}-nat-gateway-ip-0${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat_gateways" {
  count         = var.create-nat-gateways ? length(var.public-subnet-cidr-blocks) : 0
  allocation_id = aws_eip.nat_eips.*.id[count.index]
  subnet_id     = aws_subnet.public_subnets.*.id[count.index]

  tags = {
    Name = "${var.service}-${var.environment}-nat-gateway-0${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "private_nat_gateway" {
  count                  = var.create-nat-gateways ? length(var.public-subnet-cidr-blocks) : 0
  route_table_id         = aws_route_table.private_route_tables.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateways.*.id[count.index]
}

resource "aws_route" "database_nat_gateway" {
  count                  = var.create-nat-gateways && var.create-database-subnets ? length(var.public-subnet-cidr-blocks) : 0
  route_table_id         = aws_route_table.database_route_tables.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateways.*.id[count.index]
}