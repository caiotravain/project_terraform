
resource "aws_subnet" "my_subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = "172.16.0.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-example"
  }
}
resource "aws_subnet" "my_subnet2" {
  vpc_id            = var.vpc_id
  cidr_block        = "172.16.32.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "public_us_east_1a" {
  vpc_id                  = var.vpc_id
  cidr_block              = "172.16.96.0/20"  # Adjusted CIDR block
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public-us-east-1a"
  }
}

resource "aws_subnet" "public_us_east_1b" {
  vpc_id                  = var.vpc_id
  cidr_block              = "172.16.64.0/20"  # Adjusted CIDR block
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public-us-east-1b"
  }
}