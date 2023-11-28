# Create Internet Gateway


resource "aws_internet_gateway" "example_igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "CAIO - IGW"
  }
}

resource "aws_eip" "nat" {
depends_on = [aws_internet_gateway.example_igw]
  tags = {
    Name = "CAIO - EIP  "
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.rds_subnet_ids[2]  # Specify the subnet ID of the public subnet

  tags = {
    Name = "CAIO - NAT"
  }

  depends_on = [aws_internet_gateway.example_igw]
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }

  tags = {
    Name = "public"
  }
}


resource "aws_route_table_association" "private_us_east_1a" {
  subnet_id      = var.rds_subnet_ids[0]
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_us_east_1b" {
  subnet_id      = var.rds_subnet_ids[1]
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public_us_east_1a" {
  subnet_id      = var.rds_subnet_ids[2]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_us_east_1b" {
  subnet_id      = var.rds_subnet_ids[3]
  route_table_id = aws_route_table.public.id
}

resource "aws_vpc_dhcp_options" "teste_dhcp" {
  domain_name         = "teste"
  domain_name_servers = ["AmazonProvidedDNS"]


}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = var.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.teste_dhcp.id
}


