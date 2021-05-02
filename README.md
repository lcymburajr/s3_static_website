# S3 Static Website CI/CD

- [Overview](#overview)
- [Dependencies](#dependencies)
- [Step 1. Create Project](#step-1-create-project)
- [Step 2. Github](#step-2-github)
- [Step 3. AWS](#step-3-aws)
- [Step 4. Terraform](#step-4-terraform)
- [Step 5. CircleCI](#step-5-circleci)
- [Step 5. HTML](#step-6-html)

## Overview
1. Developer pushes code to GitHub.
1. When code is merged CircleCI kicks off a deploy to S3.
1. From Web Browser visit S3 endpoint.  

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
Open project in VS Code editor:
```
$ code s3_static_website 
```

# Step 2. Github
1. Go to [Github](https://github.com/) and create an account.
1. Create a new repo.
1. Inside project on computer init and commit a "readme" to github:
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
1. In project folder create provider and use aws profile:
```
provider.tf 

provider "aws" {
    region = "<region>"
    profile = "<profile_name>"
}

```
2. Create state bucket:
```
state.tf 

resource "aws_s3_bucket" "terraform-state" {
  bucket = "<bucket_name>"
  acl    = "private"
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "Terraform State"
  }
}
```
3. Init Terraform:
```
$ terraform init
```
4. Check Terraform:
```
$ terraform plan
```
5. Deploy the state bucket:
```
$ terraform apply
```

6. Create Terraform backend and use state bucket:
```
backend.tf

terraform {
 backend "s3" {
   bucket  = "<bucket_name>"
   key     = "terraform.tfstate"
   region  = "<region>"
   profile = "<profile_name>"
 }
}

```
7. Create S3 static website bucket:
```
s3_static_website.tf

resource "aws_s3_bucket" "site" {
  bucket = "<bucket_name>"
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
          "arn:aws:s3:::<bucket_name>",
          "arn:aws:s3:::<bucket_name>/*",
        ]
      },
    ]
  })

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name = "S3 Static Website"
  }
}
```
***Reference: [Static Website](https://learn.hashicorp.com/tutorials/terraform/cloudflare-static-website)***

8. Init Terraform:
```
$ terraform init
```
9. Check Terraform:
```
$ terraform plan
```
10. Deploy the S3 static website bucket:
```
$ terraform apply
```
11. Add Git ignore:
```
.gitignore

terraform.*
.terraform/
.terraform.*
```

# Step 5. CircleCI
1. Create [CircleCI](https://circleci.com/) account sign in with Github account.
1. Go to projects and click "Set Up Project" on "s3_static_website" repo.
1. In project folder create CircleCI config.yml in .circleci directory:
```
.circleci/config.yml
```
4. Use CircleCI S3 Orb and create config:
```
config.yml

version: 2.1

orbs:
  aws-s3: circleci/aws-s3@2.0.0

jobs:
  build:
    machine: true
    steps:
      - checkout
      - aws-s3/copy:
          from: index.html
          to: 's3://<bucket_name>/index.html'

```
***Reference: [S3 Orb](https://circleci.com/developer/orbs/orb/circleci/aws-s3)***

5. In "Project Settings" add AWS user access keys and region to CircleCI environment variables:
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
```

# Step 6. HTML

1. In project create a new Git branch:
```
git checkout -b feature/html
```

2. Create index page:
```
index.html

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello World</title>
</head>
<body>
    <h1>Hello World</h1>
</body>
</html>
```

3. Git track, commit and push:
```
git add .
git commit -m "website"
git push
```

4. Go to Github, create a pull request, review and merge.
1. Wait for CircleCI finish build.
1. Go to bucket website endpoint and you should see your site:
```
http://<bucket_name>.s3-website-<region>.amazonaws.com
```


