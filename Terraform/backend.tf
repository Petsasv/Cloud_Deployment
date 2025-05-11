#create s3
#BucketforStoring
resource "aws_s3_bucket" "terraform_state" {
  bucket  = "state28246tera82920bucket28109"  #globally unique


  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Dev"
  }
}


#enable versioning and encryption
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#dynamic lock with DynamoDB
resource "aws_dynamodb_table" "state_lock" {
    name = "state-lock"
    billing_mode = "PAY_PER_REQUEST" 
    hash_key = "LockID"

    attribute {
      name = "LockID"
      type = "S"
    }
  
   tags = {
    Environment = "Dev"
    Name        = "Terraform State Lock Table"
   }
}