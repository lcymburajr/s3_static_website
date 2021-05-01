# S3 Static Website CI/CD

## Overview
1. Developer pushes code to GitHub.
1. When code is merged CircleCI kicks off a deploy to S3.
1. From Web Browser vist S3 endpoint.  

![S3 CI/CD](diagram/s3_cicd.png)  
***Diagram made with draw.io***

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
1. Create and IAM User with Admin permissions.
1. Download Access keys and configure AWS on computer:
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
    profile = <profile_name>
}

```