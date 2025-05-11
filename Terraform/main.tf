
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



resource "aws_instance" "Windows_Gateway" {
  ami = "ami-0d188df7cedce7d90"
  instance_type = "t3.micro"
  subnet_id  = "subnet-0523303f286361516"
  key_name = "access_key"

  tags = {
        "Name" = "Windows Server to act as gateway"
    }
}

resource "aws_instance" "Linux_Host" {
  ami = "ami-08f78cb3cc8a4578e"
  instance_type = "t3.micro"
  subnet_id  = "subnet-0523303f286361516"
  key_name = "access_key" 

  tags = {
        "Name" = "Linux server that hosts website"
    }
}

