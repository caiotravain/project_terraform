output "postgres_url" {
  description = "postgres connection string with all info"
  value = "postgresql://${aws_db_instance.example_rds.username}:${aws_db_instance.example_rds.password}@${aws_db_instance.example_rds.address}:${aws_db_instance.example_rds.port}/${aws_db_instance.example_rds.db_name}?sslmode=require"
}


