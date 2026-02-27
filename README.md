Strapi Blue/Green Deployment on AWS ECS Fargate
This repository contains the infrastructure as code (Terraform) and the CI/CD pipeline (GitHub Actions) to deploy a production-grade Strapi CMS application on AWS ECS Fargate.

🏗️ Architecture Overview
The deployment follows a highly available and secure architecture:

Compute: AWS ECS Fargate running Strapi containers.

Database: Amazon RDS instance running PostgreSQL for Strapi data persistence.

Network: Application Load Balancer (ALB) managing traffic across private subnets.

Deployment: Blue/Green strategy managed by AWS CodeDeploy for zero-downtime updates.

Storage & Registry: Amazon ECR for Docker images and S3/RDS for application state.

📂 Repository Structure
Plaintext
├── .github/workflows/deploy.yml  # GitHub Actions pipeline for build and deploy
├── terraform/                    # Infrastructure as Code (Terraform)
│   ├── main.tf                   # Provider setup and Role ARNs (Locals)
│   ├── ecs.tf                    # ECS Cluster, Service, and Task Definitions
│   ├── CodeDeploy.tf             # Blue/Green deployment group settings
│   └── rds.tf                    # PostgreSQL Database configuration
├── appspec.yaml                  # Instructions for CodeDeploy traffic shifting
├── task-definition.json          # Template for ECS Task revisions
├── Dockerfile                    # Multi-stage production build for Strapi
└── .gitignore                    # Prevents provider binaries from being uploaded
🚀 Getting Started
1. Prerequisites
An AWS Account (Account ID: 811738710312).

Existing IAM Roles: ecsTaskExecutionRole, ecs_fargate_taskRole, and CodeDeployECSRole.

Manually created CloudWatch Log Group: /ecs/strapi-prod.

2. Infrastructure Deployment
Navigate to the terraform/ directory:

Bash
terraform init
terraform apply -auto-approve
Note: This project uses a Locals strategy to reference existing IAM roles, bypassing common 403 Access Denied errors.

3. GitHub Actions Setup
Configure the following Secrets in your GitHub Repository:

AWS_ACCESS_KEY_ID: Your IAM user access key.

AWS_SECRET_ACCESS_KEY: Your IAM user secret key.

🛠️ Deployment Workflow
Code Push: Developers push code to the main branch.

Docker Build: GitHub Actions builds the Strapi image using a multi-stage Dockerfile.

ECR Push: The image is pushed to Amazon ECR (task11-prod-repo).

Traffic Shift: CodeDeploy creates a new "Green" deployment. Once healthy, it shifts traffic from port 80 (Blue) to the new version.
