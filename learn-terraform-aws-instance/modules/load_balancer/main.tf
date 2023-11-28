# --------------------------------------------------------------------------------------------- Load Balancer

# Create an Elastic Load Balancer (ELB)
resource "aws_lb" "example_lb" {
  name               = "caio-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]  # Attach the security group created earlier
  subnets            = [ var.rds_subnet_ids[2],   var.rds_subnet_ids[3]] # Specify the subnets where the ELB should be deployed

  enable_deletion_protection = false  # Set to true if you want to enable deletion protection
}



resource "aws_lb_listener" "example_listener" {
  load_balancer_arn = aws_lb.example_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_target_group.arn
  }
}


# Create a target group for the ELB
resource "aws_lb_target_group" "example_target_group" {
  name     = "caio-target-group"
  port     = 3000  # Specify the port where your application is running (adjust if needed)
  protocol = "HTTP"
  vpc_id   = var.vpc_id

}