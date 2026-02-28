# AWS Infrastructure Automation with Terraform 🚀

This repository contains **Infrastructure as Code (IaC)** using Terraform to automate a scalable web architecture on AWS. The project demonstrates a custom VPC setup, EC2 instances running different web servers, and an Application Load Balancer with **Path-Based Routing**.

---

##  Architecture Overview

The infrastructure includes:
- **Custom VPC:** A dedicated networking environment with Public Subnets and an Internet Gateway.
- **Compute (EC2):** - `rimi-islam-apache-server`: Running Apache Web Server.
  - `rimi-islam-nginx-server`: Running Nginx Web Server.
- **Load Balancing (ALB):** An Application Load Balancer that routes traffic based on URL paths.
- **Security Groups:** Configured to allow HTTP (Port 80) traffic.

---

##  Path-Based Routing Logic

| URL Path | Target Server | Service |
| :--- | :--- | :--- |
| `http://<ALB-DNS>/apache` | Apache EC2 Instance | Apache Web Server |
| `http://<ALB-DNS>/nginx` | Nginx EC2 Instance | Nginx Web Server |
| `Any other path` | Default Action | 404 Not Found |

---

##  Project Structure

```text
├── main.tf        # Main infrastructure configuration (VPC, EC2, ALB, SG)
├── variables.tf   # Variable definitions (Region, AMI IDs, Instance names)
├── outputs.tf     # Output values (ALB DNS Link, Server URLs)
├── .gitignore     # Files to ignore (tfstate, .terraform folder)
└── README.md      # Project documentation

#How to Run This Project

Terraform installed.
AWS Account and CLI configured with appropriate permissions.

2. Initialization
Initialize the project to download necessary providers:
terraform init
3. Plan
Review the infrastructure changes:
terraform plan
4. Apply
Provision the infrastructure on AWS:
terraform apply -auto-approve
