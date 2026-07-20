# Launch Template — blueprint for every EC2 instance in the ASG
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group_id]
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  # user_data runs on first boot — installs Node.js and starts your backend!
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_host      = var.db_host
    db_port      = var.db_port
    db_name      = var.db_name
    db_username  = var.db_username
    db_password  = var.db_password
    jwt_secret   = var.jwt_secret
    vault_secret = var.vault_secret
    frontend_url = var.frontend_url
  }))

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.project_name}-backend" }
  }
}

# Auto Scaling Group — keeps 2 instances running, scales up to 4 under load
resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-asg"
  desired_capacity    = 2
  min_size            = 1
  max_size            = 4
  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }
}

# Scale UP policy — add instance when CPU > 70%
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-scale-up"
  autoscaling_group_name = aws_autoscaling_group.main.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

# Scale DOWN policy — remove instance when CPU < 20%
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-scale-down"
  autoscaling_group_name = aws_autoscaling_group.main.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}
