//Output of the ECR Repository URI to be used in Jenkins pipeline for pushing images
output "ecr_repository_uri" {
    description = "The URI of the ECR repository to push images to"
    value       = aws_ecr_repository.ecr_repository.repository_url
}

//Output Jenkins server public IP address to access Jenkins web interface
output "jenkins_server_public_ip" {
    description = "The public IP address of the Jenkins build server"
    value       = "http://${aws_instance.jenkins_build_server.public_ip}:8080"
}