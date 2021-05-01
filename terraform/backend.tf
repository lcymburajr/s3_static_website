terraform {
 backend "s3" {
   bucket  = "terraform-state-static-website"
   key     = "terraform.tfstate"
   region  = "us-east-1"
   profile = "terraform"
 }
}