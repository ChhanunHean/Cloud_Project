variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name used for naming all resources"
  type        = string
  default     = "keypkey"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID for ap-southeast-1"
  type        = string
  default     = "ami-0df7a207adb9748c7" # Amazon Linux 2023 - Singapore
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro" # free tier in ap-southeast-1!
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
}

# ─── Database ───────────────────────────────
variable "db_name" {
  description = "MySQL database name"
  type        = string
  default     = "keypkey_db"
}

variable "db_username" {
  description = "MySQL master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "MySQL master password"
  type        = string
  sensitive   = true
}

# ─── App Secrets ────────────────────────────
variable "jwt_secret" {
  description = "JWT secret for backend auth"
  type        = string
  sensitive   = true
}

variable "vault_secret" {
  description = "Vault encryption secret"
  type        = string
  sensitive   = true
}

variable "frontend_url" {
  description = "Frontend URL allowed by CORS"
  type        = string
  default     = "http://localhost:5173"
}

# ─── Monitoring ─────────────────────────────
variable "alarm_email" {
  description = "Email to receive CloudWatch alarm notifications"
  type        = string
}
