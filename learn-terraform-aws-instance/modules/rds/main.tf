

resource "aws_db_subnet_group" "rds_subnet2" {
  name       = "rds-subnet2"
  subnet_ids = [var.rds_subnet_ids[0], var.rds_subnet_ids[1]]
}


resource "aws_db_instance" "example_rds" {
  db_name =  "example_db"  # Change this to your desired database name
  identifier           = "example-rds-instance"
  allocated_storage    = 20  # Specify the storage size in GB
  storage_type         = "gp2"  # Change this if you need a different storage type
  engine               = "postgres"  # Specify PostgreSQL as the database engine
  instance_class       = "db.t3.micro"  # Specify the RDS instance type
  username             = "db_user"  # Change this to your desired database username
  password             = "db_password"  # Change this to your desired database password
  skip_final_snapshot = true  # Avoids creating a snapshot when the DB instance is deleted
  
  # Attach the newly created security group
  vpc_security_group_ids = [var.security_group_id]

  # Subnet Group (replace subnet-group-name with your actual subnet group name)
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet2.name

  

  # Backup settings
  backup_retention_period = 7  # Specify the number of days to retain backups
  backup_window           = "03:00-04:00"  # Specify the preferred backup window in UTC
  maintenance_window =  "Mon:05:00-Mon:06:00" # Specify the preferred maintenance window in UTC

  # Multi-AZ deployment for high availability
  multi_az = true


  # Tags (optional but recommended)
  tags = {
    Name        = "CAIO-rds-instance"
    Environment = "production"
  }
}

# Example Output (optional)
output "rds_endpoint" {
  value = aws_db_instance.example_rds.endpoint
}

# --------------------------------------------------------------------------------------------- gateway
