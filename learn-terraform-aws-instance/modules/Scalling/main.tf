
#create caio personal key
resource "tls_private_key" "caio_personal_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}


resource "aws_launch_template" "ec2_example" {
  name_prefix   = "EXEMPLO"
  image_id      = "ami-0e783882a19958fff"
  instance_type = "t2.micro"
  user_data     = data.template_cloudinit_config.ec2_application.rendered

  lifecycle {
    create_before_destroy = true
  }

  key_name = "caio personal key"

  network_interfaces {
    security_groups = [
      var.security_group_id
    ]
    associate_public_ip_address = true
  }
  depends_on = [ tls_private_key.caio_personal_key ]
}



# # Create an Auto Scaling Group (ASG)
# resource "aws_launch_configuration" "example_launch_config" {
#   name               = "example-launch-config"
#   image_id           = "ami-0fc5d935ebf8bc3bc"  # Specify your desired AMI ID
#   instance_type      = "t2.micro"  # Specify the instance type
#   key_name = "caio personal key"
#   associate_public_ip_address = true
#   security_groups    = [aws_security_group.rds_sg.id]  # Attach the security group created earlier

#   user_data = var.template
    
#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "aws_autoscaling_group" "example_asg" {
  name                 = "teste"
  desired_capacity     = 4
  max_size             = 8
  min_size             = 2
  vpc_zone_identifier  = [var.rds_subnet_ids[0], var.rds_subnet_ids[1]] # Specify the subnets where the EC2 instances should be deployed
  target_group_arns = [var.id_arn]

  health_check_type          = "EC2"  # Use EC2 for health checks
  health_check_grace_period  = 300    # Wait for 300 seconds before checking the health of a newly launched instance
  force_delete               = true   # Terminate instances in the Auto Scaling Group when the ASG is destroyed
  #add tag to the autoscaling group
  tag {
    key                 = "Name"
    value               = "caio"
    propagate_at_launch = true
  }
mixed_instances_policy {
  launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.ec2_example.id
        version            = "$Latest"
      }
    }
    
}

}
#create a log bucket for the autoscaling group
# resource "aws_s3_bucket" "autoscaling_log" {
#   bucket = "travas-bucket-log"
#   tags = {
#     Name = "caio-autoscaling-log"
#   }
# }



#connect the log group to the log bucket
# resource "aws_cloudwatch_log_subscription_filter" "autoscaling_log" {
#   name            = "travas-bucket-log"
#   log_group_name  = aws_cloudwatch_log_group.autoscaling_log.name
#   filter_pattern  = ""
#   destination_arn = "arn:aws:s3:::travas-bucket-log"
#   #add role arn without using the data source
#   role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/terraform"
# }


resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "Caio_HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example_asg.name
  }

  alarm_description = "This alarm monitors high CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_up_policy.arn]

  tags = {
    Name = "HighCPUUtilization"
  }
}

resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "Aumenta"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.example_asg.name
}


resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "LowCPUAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 20  # Adjust this threshold based on your requirements

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example_asg.name
  }

   alarm_actions     = [aws_autoscaling_policy.scale_down_policy.arn]
}


resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "Diminui"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.example_asg.name
}

# Attach the Auto Scaling Group to the Elastic Load Balancer
resource "aws_autoscaling_attachment" "example_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.example_asg.name
  lb_target_group_arn    = var.id_arn
}


resource "aws_autoscaling_policy" "scale_up_down" {
  policy_type = "TargetTrackingScaling"
  name = "scale-up-down-request-count"
  autoscaling_group_name = aws_autoscaling_group.example_asg.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = "${split("/", var.lb_id)[1]}/${split("/", var.lb_id)[2]}/${split("/", var.lb_id)[3]}/targetgroup/${split("/", var.id_arn )[1]}/${split("/", var.id_arn )[2]}"
    }
    target_value = 176
    
  }

  lifecycle {
    create_before_destroy = true 
  }
}