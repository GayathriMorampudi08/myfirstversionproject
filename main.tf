terraform {
  backend "s3" {
    bucket = "backendbucket05"
    region = "ap-south-1"
    key = "terraform_backend/terraform.tfstate"
    
  }
  required_providers {
    aws={
        source="hashicorp/aws"
        version="~> 3.0"
    }
    
  }
}
provider "github" {
    token=var.token
  
}
resource "github_repository" "myproject1" {
  name="myproject1"
  description="This is my first project using jenkins terraform ansible"
  visibility="private"
  
}
provider "aws" {
    region = "ap-south-1"
    access_key = var.access_key
    secret_key = var.secret_key   
}
resource "aws_instance" "terraformserver" {
    ami = "ami-08718895af4dfa033"
    instance_type = "t2.micro"
    key_name = "terrkeys"  
    hibernation = true
    
    root_block_device {
    volume_size = 8             
    encrypted   = true           
    }
    ebs_block_device {
    device_name             = "/dev/sdb"
    volume_size             = 1
    encrypted               = true
    delete_on_termination   = true
    }
    tags = {
      Name="myec21server"
    }
    provisioner "local-exec" {
      command = <<EOT
      sudo mkdir -p /var/root/.ssh
      sudo sleep 120
      sudo ssh-keygen -R ${self.public_ip}
      sudo ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${self.public_ip}, playbook.yaml -u ec2-user --private-key /Users/gayathrimorampudi/Downloads/terrkeys.pem
    EOT
      
    }
}
# Declare the AWS Access Key variable
variable "access_key" {
  description = "AWS Access Key"
  type        = string
}
# Declare the AWS Secret Key variable
variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}
# Declare the GitHub token variable
variable "token" {
  description = "GitHub Token"
  type        = string
  sensitive   = true
}
output "aws_attributes" {
  value = aws_instance.terraformserver
}
# Output GitHub repository URL
output "github_repository_url" {
  value = github_repository.myproject1.html_url
}
