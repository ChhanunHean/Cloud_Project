terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ─────────────────────────────────────────────
# VPC — our isolated private network
# ─────────────────────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  azs          = var.availability_zones
}

# ─────────────────────────────────────────────
# Security Groups — who can talk to who
# ─────────────────────────────────────────────
module "security_groups" {
  source = "./modules/security_groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

# ─────────────────────────────────────────────
# IAM — roles & permissions for EC2
# ─────────────────────────────────────────────
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
}

# ─────────────────────────────────────────────
# S3 — frontend static hosting + file storage
# ─────────────────────────────────────────────
module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
}

# ─────────────────────────────────────────────
# RDS — MySQL database (replaces Aiven!)
# ─────────────────────────────────────────────
module "rds" {
  source = "./modules/rds"

  project_name       = var.project_name
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  subnet_ids         = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_id  = module.security_groups.rds_sg_id
}

# ─────────────────────────────────────────────
# ALB — Application Load Balancer
# ─────────────────────────────────────────────
module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_sg_id
}

# ─────────────────────────────────────────────
# ASG — Auto Scaling Group with EC2 (Node.js backend)
# ─────────────────────────────────────────────
module "asg" {
  source = "./modules/asg"

  project_name        = var.project_name
  ami_id              = var.ami_id
  instance_type       = var.instance_type
  key_name            = var.key_name
  security_group_id   = module.security_groups.ec2_sg_id
  iam_instance_profile = module.iam.instance_profile_name
  public_subnet_ids   = module.vpc.public_subnet_ids
  target_group_arn    = module.alb.target_group_arn

  # Pass DB + App config to EC2 user_data
  db_host     = module.rds.db_endpoint
  db_port     = "3306"
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  jwt_secret  = var.jwt_secret
  vault_secret = var.vault_secret
  frontend_url = var.frontend_url
}

# ─────────────────────────────────────────────
# CloudWatch — monitoring, logs & alarms
# ─────────────────────────────────────────────
module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name   = var.project_name
  asg_name       = module.asg.asg_name
  alarm_email    = var.alarm_email
}
