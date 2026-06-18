//declare provider for AWS Region
variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}


//declare variables for ECR Repository
variable "repository_name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "devsecops-secure-app"
}


//declare variables for ECR Repository mutability
variable "repository_mutability" {
  description = "The mutability setting for the ECR repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

//declare ec2 instance type variable 
variable "instance_type" {
  description = "The EC2 instance type for the Jenkins build server"
  type        = string
  default     = "t3.medium"
}

//declare EC2 security group variable named "jenkins-build-sg"
variable "jenkins_build_sg" {
  description = "The security group for the Jenkins build server"
  type        = string
  default     = "jenkins-build-sg"
}



