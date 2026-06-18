// Create Data block for aws_ami for Ubuntu 24.04 LTS or newer standard images
data "aws_ami" "ubuntu_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

// Create EC2 instance named "Jenkins-CI-CD-Orchestrator"
resource "aws_instance" "jenkins_build_server" {
  ami                    = data.aws_ami.ubuntu_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.jenkins_build_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_build_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              # Update base repositories and install modern Java 21 OpenJDK
              sudo apt-get update && sudo apt-get install -y openjdk-21-jdk gnupg curl apt-transport-https

              # --- INSTALL DOCKER ---
              sudo apt-get install -y docker.io

              # --- INSTALL TRIVY (Vulnerability & Credential Scanner) ---
              wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
              echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee /etc/apt/sources.list.d/trivy.list
              sudo apt-get update && sudo apt-get install -y trivy

              # --- INSTALL JENKINS (WITH WORKING 2026 KEYS AND STABLE BINARY PATH) ---
              curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
              sudo apt-get update && sudo apt-get install -y jenkins

              # Bind user permissions and inject systemd Java Home Environment variables
              sudo usermod -aG docker jenkins
              sudo mkdir -p /etc/systemd/system/jenkins.service.d/
              echo -e "[Service]\nEnvironment=\"JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64\"" | sudo tee /etc/systemd/system/jenkins.service.d/override.conf

              # Reload and boot service runtimes cleanly
              sudo systemctl daemon-reload && sudo systemctl restart docker
              sudo systemctl enable jenkins && sudo systemctl start jenkins
              EOF

  tags = {
    Name        = "Jenkins-CI-CD-Orchestrator"
    Environment = "Production"
    Project     = "Jenkins Build Server"
  }
}

// Create security group named "jenkins-build-sg"
resource "aws_security_group" "jenkins_build_sg" {
  name        = var.jenkins_build_sg
  description = "Security group for Jenkins build server"
  
  ingress {
    description = "Allow Jenkins access from My IP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${chomp(file("my_ip.txt"))}/32"] # Modern string interpolation pattern
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Associate IAM profile container with the EC2 instance
resource "aws_iam_instance_profile" "jenkins_build_instance_profile" {
  name = "JenkinsBuildServerInstanceProfile"
  role = aws_iam_role.jenkins_build_server_role.name
}