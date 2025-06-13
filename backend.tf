  terraform {
  backend "s3" {
    bucket = "terraform-remote-st"
    key    = "uc9-new/terraform.tfstate"
    region = "us-east-1" 
    use_lockfile = true    
  } 
  } 