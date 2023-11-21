variable "vpc_id" {
  description = "vpc id"
  type        = string
}
variable "rds_subnet_ids" {
  description = "value of the rds subnet ids"
  type        = list(string)
}
variable "lb_id" {
  description = "value of the lb id"
  type        = string
  
}
variable "security_group_id" {
  description = "value of the security group id"
  type        = string
  
}