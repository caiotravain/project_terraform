variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}

# -EOF
#               #!/bin/bash
#               sudo apt-get update
#               sudo apt-get install apache2 -y
#               sudo systemctl start apache2
#               sudo systemctl enable apache2
#               sudo echo "Day 65 from 90 Days of DevOps." > /var/www/html/index.html
#               EOF