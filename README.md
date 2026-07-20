# KeypKey Cloud Infrastructure 🔐

> A secure, scalable, and highly available password manager deployed on AWS using Terraform (Infrastructure as Code) and version-controlled on GitHub.

## Architecture

```
[Users]
   │
   ▼
[S3 Static Website] ── (React Frontend Hosting)
   │ (API Calls)
   ▼
[Application Load Balancer (ALB)] ── (Public-facing traffic router)
   │
   ▼
[Auto Scaling Group (ASG)] ── (EC2 instances running Node.js backend under PM2)
   │
   ▼
[RDS MySQL Instance] ── (Securely hidden in private subnets, no public routing)
```

## AWS Services & Architecture Details

| Service | Purpose | Architecture Detail |
|---|---|---|
| **VPC** | Network isolation | Splits network into public (ALB, EC2) and private (RDS) subnets across 2 Availability Zones. |
| **EC2** | App hosting | Runs Node.js backend on Ubuntu virtual machines. |
| **ALB** | Traffic distribution | Listens on port 80 and load balances requests across active EC2 servers. |
| **ASG** | High availability | Auto-scales EC2 instance count from 1 to 4 based on CPU alarms. |
| **RDS MySQL** | Data persistence | Multi-AZ ready managed database hidden in private subnets. |
| **S3** | Web hosting | Serves frontend static React build assets to users. |
| **IAM** | Access policies | Secure instance profiles mapping S3, SSM, and CloudWatch policies to EC2. |
| **CloudWatch** | Observability | Visualizes system load metrics on a dashboard and sends SNS email alerts. |

---

## Live Endpoints

* 🔗 **Frontend Web App:** [S3 Website URL](http://keypkey-frontend-e98ebcc1.s3-website-ap-southeast-1.amazonaws.com/)
* ⚙️ **Backend API:** [ALB API DNS URL](http://keypkey-alb-1353945873.ap-southeast-1.elb.amazonaws.com/)
* 🗄️ **Database Instance:** `keypkey-mysql.cheea42m407n.ap-southeast-1.rds.amazonaws.com`
* 📊 **Metrics Dashboard:** [CloudWatch Dashboard Link](https://console.aws.amazon.com/cloudwatch/home?region=ap-southeast-1#dashboards/dashboard/keypkey-dashboard)

---

## Project Structure

```
cloud_project/
├── main.tf               # Root configuration wiring modules together
├── variables.tf          # Input variable schemas
├── outputs.tf            # Output parameters (URLs, DB endpoints)
├── terraform.tfvars      # Environment values (git-ignored)
├── keypkey-backend/      # Express backend source files
└── modules/              # Individual IaC module folders
```

## Deployment Walkthrough

```bash
# 1. Clone this repository
git clone https://github.com/ChhanunHean/Cloud_Project.git
cd Cloud_Project

# 2. Add your credentials (never push this file!)
# Create terraform.tfvars and fill in your passwords and keys

# 3. Initialize & Deploy
terraform init
terraform plan
terraform apply
```

---

## 🛠️ Management & Operations Guide

### A. How to Manage the Private Database (SSH Tunneling)
Because the RDS instance is locked inside private subnets, open an SSH tunnel from your local Mac to access it through DBeaver or TablePlus:

```bash
ssh -i ~/.ssh/keypkey-key.pem -N -L 3306:keypkey-mysql.cheea42m407n.ap-southeast-1.rds.amazonaws.com:3306 ubuntu@<instance-public-ip>
```
*Connect your client to `127.0.0.1:3306` with your master database password.*

### B. Checking Server Application Logs (PM2)
SSH into one of your active EC2 servers:
```bash
ssh -i ~/.ssh/keypkey-key.pem ubuntu@<instance-public-ip>
```
Manage the running Node.js process using PM2 (runs under administrator context):
```bash
sudo pm2 list       # Show running API servers
sudo pm2 log        # Stream server console output in real-time
sudo pm2 restart 0  # Restart Node.js backend
```

---

## Simulating EC2 Failure & Recovery

To test self-healing (HA) capabilities, terminate one of the active instances:
```bash
aws ec2 terminate-instances --instance-ids <instance-id> --region ap-southeast-1
```
The Auto Scaling Group will immediately detect the unhealthy capacity and automatically launch a replacement instance. Traffic continues to route to the healthy instance via the ALB with zero downtime.

---

## Cleanup

To destroy all provisioned cloud resources:
```bash
terraform destroy
```

