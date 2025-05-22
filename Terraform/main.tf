
terraform{
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "6.0.0-beta1"
      }
    }

    backend "s3" {
      bucket = "state28246tera82920bucket28109"
      dynamodb_table = "state-lock"
      key = "global/mystatefile/terraform.tfstate" #file path to terrastate
      region = "eu-north-1"
      encrypt = true
    }
}

provider "aws" {
    #profile = "default"
    region = "eu-north-1"
}

#EC2
resource "aws_key_pair" "main_key" {
  key_name   = "access_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDM0a08XcI6zKbE/gqHbCHdTVErkMHjLkwb9zvcbaJjGl1qjpm1yP7P+Tq4Vpgk6duvNRd+qd5weEegf4BpqdfTtlKHkPIUlPilO7EBmXkFokADvixqxUGwMcn9NVh9cXfmUzh14A+1C7Zuw7RZFSEN6o/tVLPo8n5MhJpeJxJuV9ZHUMkYlx2VuK57vL2XhgNpz+2cJvmQBEIRlBG4V9EGZ0V2sCgJLKMOM0ZqBahaE2S3rwUkGO2eCUaxhHZ548wEQkzICFC3GNxC9cPYTWAHsk1VnKUvoKFI7J1Gxt8fKAxd3RoXfhUE7NYKwg4yh++6/cXUiVINKjYL+9Z5stWZ"

lifecycle {
    prevent_destroy = false #true
  }
}

#reference to default vpc
data "aws_vpc" "default" {
  default = true
}

#IAM role for transfer of the AppCode(via S3) to the EC2
resource "aws_iam_instance_profile" "code_deply_role" {
  name = "LinuxInstanceProfile"
  role = "EC2_DeployCodeService"  # Name of your existing IAM role
}


resource "aws_instance" "Windows_Gateway" {
  ami = "ami-0d188df7cedce7d90"
  instance_type = "t3.micro"
  subnet_id  = "subnet-0523303f286361516"
  key_name = "access_key"
  vpc_security_group_ids = [aws_security_group.windows_sec.id]

  tags = {
        "Name" = "Windows Server to act as gateway"
    }
}

resource "aws_instance" "Linux_Host" {
  ami = "ami-08f78cb3cc8a4578e"
  instance_type = "t3.micro"
  subnet_id  = "subnet-0523303f286361516"
  key_name = "access_key" 
  vpc_security_group_ids = [aws_security_group.linux_sec.id]

  iam_instance_profile = aws_iam_instance_profile.code_deply_role.name

  //user_data = file("init_linux.sh")

  tags = {
        "Name" = "Linux server hosts the website"
    }
}

#WINDOWS SECURITY GROUP
resource "aws_security_group" "windows_sec" {
  name = "windows-security"
  description = "Allow RDP traffic" 
  vpc_id      = data.aws_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ssh_windows" {
  type              = "ingress"
  cidr_blocks  = var.ssh_allowed_ips
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  description      = "Users IPs"
  security_group_id = aws_security_group.windows_sec.id
}


resource "aws_security_group_rule" "egress_windows" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.windows_sec.id
}

#LINUX SECURITY GROUP
resource "aws_security_group" "linux_sec" {
  name        = "linux-security"
  description = "Allow HTTP (from windows machine only) and SSH traffic (from our IPs only)"
  vpc_id      = data.aws_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group_rule" "ssh_linux" {
  type              = "ingress"
  cidr_blocks  = var.ssh_allowed_ips
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  description      = "Users IPs"
  security_group_id = aws_security_group.linux_sec.id
}

resource "aws_security_group_rule" "http_linux" {  #not really needed since we use port3000
  type              = "ingress"
  cidr_blocks  = var.windows_ip  #concat(var.windows_ip, var.ssh_allowed_ips)
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  description      = "Windows VM IP"
  security_group_id = aws_security_group.linux_sec.id
}

resource "aws_security_group_rule" "port3000_linux" {
  type              = "ingress"
  cidr_blocks  =  var.windows_ip   #concat(var.windows_ip, var.ssh_allowed_ips) 
  from_port   = 3000
  to_port     = 3000
  protocol    = "tcp"
  description      = "Windows VM IP for port of the website"
  security_group_id = aws_security_group.linux_sec.id
}


resource "aws_security_group_rule" "egress_linux" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.linux_sec.id
}




