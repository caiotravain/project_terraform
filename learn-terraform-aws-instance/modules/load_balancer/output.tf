output "lb_id" {
  description = "value of the lb id"
  value = aws_lb.example_lb.id
  
}

output "id_arn" {
  description = "value of the arn target group"
  value = aws_lb_target_group.example_target_group.arn
}