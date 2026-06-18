// Configure ECR Repository named "devsecops-secure-app"
resource "aws_ecr_repository" "ecr_repository" {
  name                 = var.repository_name
  image_tag_mutability = var.repository_mutability

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.repository_name
    Environment = "Production"
    Project     = "ECR Repository"
  }
}

// Create ECR Repository lifecycle policy to Automatically expire untagged development builds after 14 days
resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  repository = aws_ecr_repository.ecr_repository.name

  policy = <<EOF
  {
      "rules": [
          {
              "rulePriority": 1,
              "description": "Expire untagged development builds after 14 days",
              "selection": {
                  "tagStatus": "untagged",
                  "countType": "sinceImagePushed",
                  "countUnit": "days",
                  "countNumber": 14
              },
              "action": {
                  "type": "expire"
              }
          }
      ]
  }
  EOF
}