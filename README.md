# S3 Static Website CI/CD

- [Overview](#overview)
- [Dependencies](#dependencies)
- [Step 1. Create Project](#step-1-create-project)
- [Step 2. Github](#step-2-github)
- [Step 3. AWS](#step-3-aws)
- [Step 4. Terraform](#step-4-terraform)
- [Step 5. CircleCI](#step-5-circleci)

## Overview
1. Developer pushes code to GitHub.
1. When code is merged CircleCI kicks off a deploy to S3.
1. From Web Browser vist S3 endpoint.  

![S3 CI/CD](diagram/s3_cicd.png)  
***Diagram made with [draw.io](https://app.diagrams.net/)***

# Dependencies 
- Git
- Github Account
- Terraform
- CircleCI Account
- AWS Account
- AWS CLI

## Installing Dependencies
Install Homebrew for Dependencies:
```
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Install Terraform:
```
$ brew install terraform
```  
Install AWS CLI:
```
$ brew install aws_cli
```

# Step 1. Create Project
Create project folder on computer:
```
$ mkdir s3_static_website
```
Open project in code editor:
```
$ code s3_static_website 
```

# Step 2. Github
1. Go to [Github](https://github.com/) and create an account.
1. Create a new repo.
1. Inside project on computer init and commit a Readme to github:
```
$ echo "# s3_static_website" >> README.md
$ git init
$ git add README.md
$ git commit -m "first commit"
$ git branch -M main
$ git remote add origin https://github.com/<username>/s3_static_website.git
$ git push -u origin main
```

# Step 3. AWS
1. Create an AWS account.
1. Create IAM user with admin permissions.
1. Download user's access keys and configure AWS on computer:
```
$ aws configure --profile <profile_name>
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-east-1
Default output format [None]: json
```

# Step 4. Terraform
1. Create provider and use aws profile:
```
provider.tf 

provider "aws" {
    region = "us-east-1"
    profile = "<profile_name>"
}

```
2. Create state bucket:
```
state.tf 

resource "aws_s3_bucket" "terraform-state" {
  bucket = "terraform-state-static-website"
  acl    = "private"
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "Terraform state"
  }
}
```
3. Init terraform:
```
$ terraform init
```
4. Check terraform:
```
$ terraform plan
```
5. Create the state bucket:
```
$ terraform apply
```
6. Create Terraform backend and use state bucket:
```
backend.tf

terraform {
 backend "s3" {
   bucket  = "terraform-state-static-website"
   key     = "terraform.tfstate"
   region  = "us-east-1"
   profile = "<profile_name>"
 }
}

```
7. Create S3 static website bucket:
```
s3_static_website.tf

resource "aws_s3_bucket" "site" {
  bucket = "s3-static-website.test.com"
  acl    = "public-read"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          "arn:aws:s3:::s3-static-website.test.com",
          "arn:aws:s3:::s3-static-website.test.com/*",
        ]
      },
    ]
  })

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = {
    Name = "S3 Static Website"
  }
}
```
***Reference: [Static Website](https://learn.hashicorp.com/tutorials/terraform/cloudflare-static-website)***

8. Init terraform:
```
$ terraform init
```
9. Check terraform:
```
$ terraform plan
```
10. Create the S3 static website bucket:
```
$ terraform apply
```

# Step 5. CircleCI
