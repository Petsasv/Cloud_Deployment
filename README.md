Cloud Deployment
End-to-end Infrastructure-as-Code project provisioning a multi-tier AWS environment and deploying a Node.js web application through a CI/CD pipeline.
Stack: Terraform · AWS (EC2, IAM, S3, DynamoDB, VPC) · GitHub Actions · AWS CodeDeploy · Node.js (Express) · MongoDB · pm2
Context: University coursework — project brief provided by Deloitte.

Overview
This project demonstrates a complete cloud deployment workflow built from scratch:

Infrastructure is declared as code with Terraform and provisioned in AWS eu-north-1.
Terraform state is managed remotely in S3 with versioning and AES-256 encryption; concurrent state changes are prevented by a DynamoDB lock table.
Infrastructure changes flow through a GitHub Actions pipeline that runs terraform init / validate / plan / apply on every push to Terraform/.
Application code ships to EC2 via AWS CodeDeploy, defined declaratively in appspec.yml.
A Windows EC2 gateway acts as the controlled entry point into the network, restricting access to the Linux application host on the application port.

Architecture
                  ┌─────────────────────────┐
                  │       GitHub Repo       │
                  └──────┬───────────┬──────┘
                         │           │
       push Terraform/** │           │ push Website/**
                         ▼           ▼
       ┌────────────────────────┐ ┌─────────────────────────┐
       │     GitHub Actions     │ │   AWS CodePipeline      │
       │ terraform plan / apply │ │   (console-configured)  │
       └───────────┬────────────┘ └────────────┬────────────┘
                   │ provisions                │ triggers AWS CodeDeploy
                   │                           │ (appspec.yml)
                   ▼                           ▼
┌──────────────────────────────────────────────────────────────────────┐
│                          AWS  eu-north-1                             │
│                                                                      │
│   ┌──────────────────────────┐       ┌──────────────────────────┐   │
│   │  Windows EC2 (gateway)   │       │  Linux EC2 (app host)    │   │
│   │  t3.micro                │ ────► │  t3.micro                │   │
│   │  SG: 3389 from user IPs  │ :3000 │  Node.js + Express       │   │
│   └──────────────────────────┘       │  MongoDB (local)         │   │
│              ▲                       │  pm2 + systemd           │   │
│              │ RDP from operators    │  SG: 22 from user IPs,   │   │
│                                      │      3000 from gateway   │   │
│                                      └──────────────────────────┘   │
│                                                                      │
│   ┌──────────────────────────┐       ┌──────────────────────────┐   │
│   │ S3 (terraform state)     │       │ DynamoDB (state lock)    │   │
│   │ versioned + encrypted    │       │ pay-per-request          │   │
│   └──────────────────────────┘       └──────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────┘
Repository layout
PathPurposeTerraform/All .tf files: EC2 instances, security groups, IAM, key pair, S3 state backend, DynamoDB lock table, variablesWebsite/Node.js / Express application — server.js, static HTML/CSS/JS frontend, MongoDB-backed login/register endpoints.github/workflows/GitHub Actions pipeline that runs Terraform on infrastructure changesscripts/Bootstrap script for the Linux host (installs Node, MongoDB, pm2, clones the repo, starts the app) and CodeDeploy lifecycle hooksappspec.ymlAWS CodeDeploy specification for application deployments
Infrastructure highlights

Remote state with locking — Terraform state stored in an S3 bucket with versioning and AES-256 server-side encryption; a DynamoDB table prevents concurrent state mutations across operators or CI runs.
Defense-in-depth networking — the Linux app host is not directly reachable from the public internet on its application port (3000); ingress is restricted to the Windows gateway and a whitelist of operator IPs. SSH is similarly restricted.
Separate security groups per role with explicit aws_security_group_rule resources (rather than inline rules) for clearer diff-tracking and lifecycle management.
IAM instance profile attached to the Linux host so CodeDeploy can pull artifacts from S3 without long-lived credentials on the instance.
Whitelisted IPs externalised as variables (ssh_allowed_ips, windows_ip) — no hardcoded operator addresses in the resource definitions.

Application
Website/server.js is a small Express API serving a static frontend and exposing POST /register and POST /login endpoints backed by MongoDB. The Linux host is bootstrapped with Node.js 18, MongoDB 7.0, and pm2, with pm2 startup wiring the process manager into systemd so the application survives reboots.
CI/CD
The GitHub Actions workflow at .github/workflows/ triggers on pushes that modify Terraform/**:

Checkout
Set up Terraform (pinned to 1.11.4)
terraform init -reconfigure
terraform validate
terraform plan
terraform apply -auto-approve
terraform output

AWS credentials are injected from repository secrets (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY).
Application deployments are orchestrated by AWS CodePipeline, which watches the GitHub repository and triggers AWS CodeDeploy on changes to the application code. CodeDeploy follows appspec.yml to copy the Website/ folder onto the Linux EC2 and run a cleanup hook before each install. The CodePipeline and CodeDeploy resources were configured directly in the AWS console rather than codified in Terraform
