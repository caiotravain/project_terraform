output "security_group_id" {
  description = "value of the security group id"
  value = aws_security_group.rds_sg.id 
}

output "rds_subnet_private_1" {
  description = "value of the rds subnet ids"
  value = aws_subnet.my_subnet.id
}
output "rds_subnet_private_2" {
  description = "value of the rds subnet ids"
  value = aws_subnet.my_subnet2.id
  
}
output "rds_subnet_public_1" {
  description = "value of the rds subnet ids"
  value = aws_subnet.public_us_east_1a.id
  
}
output "rds_subnet_public_2" {
  description = "value of the rds subnet ids"
  value = aws_subnet.public_us_east_1b.id
  
}