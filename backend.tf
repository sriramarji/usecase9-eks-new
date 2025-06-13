  terraform {
  backend "s3" {
    bucket = "tf-bucket-prod1"
    key    = "uc9-new/terraform.tfstate"
    region = "us-east-1" 
    use_lockfile = true    
  } 
  } 