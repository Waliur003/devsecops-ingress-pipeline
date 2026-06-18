//Create IAM policy Document to grant ECR Access
data "aws_iam_policy_document" "ecr_access_policy" {
    statement {
        sid    = "ECRAuthTokenAcquisition"
        effect = "Allow"
        actions = ["ecr:GetAuthorizationToken"]
        resources = ["*"]
    }

    statement {
        sid    = "TargetedECRImagePushAccess"
        effect = "Allow"
        actions = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:PutImage",
        ]
        resources = ["arn:aws:ecr:*:*:repository/devsecops-secure-app"]
    }
}

//Create IAM role named "JenkinsBuildServerRole" to be assumed by EC2 instance for Jenkins build server
resource "aws_iam_role" "jenkins_build_server_role" {
  name = "JenkinsBuildServerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}



//Attach this Iam policy document to policy named "JenkinsECRAccessPolicy"
resource "aws_iam_policy" "ecr_access_policy" {
    name        = "JenkinsECRAccessPolicy"
    description = "IAM policy to allow Jenkins to access ECR repository for pushing images"
    policy      = data.aws_iam_policy_document.ecr_access_policy.json
}

//Attach the "JenkinsECRAccessPolicy" to the IAM role named "JenkinsBuildServerRole"
resource "aws_iam_role_policy_attachment" "ecr_access_policy_attachment" {
    role       = aws_iam_role.jenkins_build_server_role.name
    policy_arn = aws_iam_policy.ecr_access_policy.arn
}

//Attach AWS managed policy AmazonSSManangedInstanceCore to the IAM role named "JenkinsBuildServerRole" to allow SSM access for Jenkins build server
resource "aws_iam_role_policy_attachment" "ssm_access_policy_attachment" {
    role       = aws_iam_role.jenkins_build_server_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}




