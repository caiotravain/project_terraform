variable "id_arn" {
  description = "value of the arn target group"
    type        = string
}
variable "rds_subnet_ids" {
  description = "value of the rds subnet ids"
  type        = list(string)
}
variable "security_group_id" {
  description = "value of the security group id"
  type        = string
}
variable "postgres_url" {
    description = "postgres connection string with all info"
    type        = string
  
}
variable "lb_id" {
  description = "value of the lb id"
  type        = string
  
}