
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Permite trafego HTTP/HTTPS para o ALB"
  vpc_id      = var.vpc_id

  ingress{
    from_port = 0 
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}