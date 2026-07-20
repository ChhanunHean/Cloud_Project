# KeypKey Cloud Infrastructure 🔐

> A secure, scalable password manager deployed on AWS using Terraform

## Architecture

```
[Users]
   ↓
[S3 Static Website] ← React Frontend
   
[ALB - Load Balancer] ← Public DNS entry point
   ↓
[ASG → EC2 Instances] ← Node.js Express Backend (Auto Scaling: 1-4)
   ↓
[RDS MySQL] ← Database (Private subnet, no public access)

[CloudWatch] ← Monitoring, Alarms, Logs
[IAM]        ← Roles & permissions
[VPC]        ← Isolated network
```

## AWS Services Used

| Service | Purpose |
|---|---|
| VPC | Isolated network with public/private subnets |
| EC2 | Node.js backend servers |
| ALB | Load balancer — distributes traffic |
| ASG | Auto Scaling — 1 min, 4 max instances |
| RDS MySQL | Managed database (replaces Aiven) |
| S3 | Frontend static file hosting |
| IAM | EC2 roles with least-privilege access |
| CloudWatch | CPU alarms, dashboard, logs |

## Prerequisites

- [Terraform](https://terraform.io) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured
- AWS Key Pair created in ap-southeast-1

## Quick Start

```bash
# 1. Clone this repo
git clone https://github.com/YOUR_USERNAME/keypkey-cloud-infra.git
cd keypkey-cloud-infra

# 2. Fill in your values
cp terraform.tfvars terraform.tfvars  # edit the values inside

# 3. Initialize Terraform
terraform init

# 4. Preview what will be created
terraform plan

# 5. Deploy!
terraform apply

# 6. Get your app URL
terraform output alb_dns_name
```

## Outputs After Deployment

- `alb_dns_name` — Your backend API URL
- `s3_website_url` — Your frontend URL  
- `rds_endpoint` — MySQL host (for DB_HOST)
- `cloudwatch_dashboard_url` — Monitoring dashboard

## Simulating EC2 Failure (for assignment)

```bash
# Terminate an instance — ASG will auto-recover it!
aws autoscaling terminate-instance-in-auto-scaling-group \
  --instance-id <instance-id> \
  --no-should-decrement-desired-capacity
```

Watch ASG spin up a replacement in ~2 minutes.

## Cleanup

```bash
terraform destroy
```

## Cost Estimate

| Service | Type | Monthly Cost |
|---|---|---|
| EC2 x2 | t2.micro | ~$0 (free tier) |
| RDS | db.t3.micro | ~$0 (free tier) |
| ALB | - | ~$16 |
| S3 | - | ~$0 |
| **Total** | | **~$16/mo** |
