output "alb_dns_name" {
  description = "Public DNS of the Load Balancer — this is your app URL!"
  value       = module.alb.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = module.rds.db_endpoint
}

output "s3_frontend_bucket" {
  description = "S3 bucket for frontend static files"
  value       = module.s3.bucket_name
}

output "s3_website_url" {
  description = "S3 static website URL"
  value       = module.s3.website_url
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.asg.asg_name
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch Dashboard URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=ap-southeast-1#dashboards/dashboard/${var.project_name}-dashboard"
}
