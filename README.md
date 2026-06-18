# Cloud Engineering Project 07: Enhanced DevSecOps Ingress Pipeline (Observability & Cost Controls)

## Overview

I have architected and deployed a production-grade, secure software supply chain pipeline on AWS using Infrastructure as Code primitives. This project establishes an automated **DevSecOps continuous integration and continuous deployment (CI/CD) pipeline** that bridges the gap between software development and hardened cloud infrastructure operations. The architecture isolates raw compilation baggage using multi-stage builds, intercepts application layer threats at the edge using static security scanners, and automatically applies container registry pruning policies to control cloud infrastructure spend. By decoupling environment variables from hardcoded configurations and using machine-level runtime tokens, the system enforces a zero-trust model across the delivery lifecycle while providing real-time telemetry analytics.

## The Problem

Manual code deployment patterns and standard software delivery frameworks consistently expose cloud environments to substantial infrastructure risk and operational cost drift. Modern continuous delivery workflows typically suffer from three major design vulnerabilities:

* **Static Credential Exposure Liabilities:** Hardcoding long-lived AWS Access Keys or Secret Keys inside build automation dashboards or Git configuration directories creates a high-severity risk vector for lateral workspace compromise if the application repository is breached.
* **Unvalidated Vulnerability Propagation:** Shipping code packages or container image layers straight to a private cloud registry without running automated verification gates allows structural application flaws, supply chain package bugs, or exposed credentials to propagate directly into live runtime environments.
* **Registry Storage Cost Creep:** Retaining every single image build tag generated across continuous development cycles causes rapid container registry storage sprawl, resulting in unmanaged financial waste and budget overruns on cloud storage meters.

## The Solution

* **Zero-Static-Credential Identity Scoping:** Replaced legacy hardcoded authentication tokens entirely by attaching dynamic, short-lived **IAM Instance Profiles** directly onto the underlying build hardware frame.
* **Fail-Fast Security Validation Gates:** Integrated automated **Trivy static application security testing (SAST)** checkpoints directly inside the build runner workspace to automatically drop high-risk code checkouts prior to image building.
* **Automated Registry Cost Optimization:** Engineered an **Amazon ECR Lifecycle Policy** routine that automatically targets untagged image artifacts and purges stale build states past a 14-day evaluation window to protect the cloud budget.
* **Asynchronous Metrics Observability:** Configured a standalone **Prometheus Metrics Engine** wrapper on the application controller to convert raw runner system execution logs into searchable, real-time diagnostic telemetry streams.

## Tech Stack

* **Automation Engine:** Jenkins Continuous Integration Server (Stable Core Architecture)
* **Container Environment:** Docker Daemon Engine (Multi-Stage Execution Runruntimes)
* **Vulnerability Framework:** Aqua Security Trivy (Static SAST & Credential Scanner)
* **Storage Registry:** Amazon ECR (Private Secure Container Ingress Repositories)
* **Compute Hosting:** Amazon EC2 (Ubuntu Server 24.04 LTS Architecture)
* **Identity Governance:** AWS IAM (Least-Privilege Scoped Policies and Machine Profiles)
* **Observability Suite:** Prometheus Metrics Engine (Asynchronous Telemetry Tracking Plugins)
* **IaC Engine:** Terraform (v1.0+ / High-Availability Declarative Syntax)

---

## Architecture Diagram

---

## Project Procedure

### 1. Private Container Registry & Lifecycle Optimization

I engineered a private container image ingestion repository using Amazon ECR to serve as the long-term immutable application ledger.

* **Vulnerability Scanning Enforcement:** Configured the repository registry to execute native cloud layer asset scanning hooks automatically upon image ingestion.
* **FinOps Rule Mapping:** Deployed a rolling retention lifecycle rule targeting all untagged images, automatically expiring historical software artifacts after 14 days to eliminate storage spend creep.

### 2. Least-Privilege Machine Identity Formulation

To secure resource-to-resource communication pathways without storing long-lived access tokens, I established a zero-trust architecture using AWS IAM.

* **Granular Action Scoping:** Authored an IAM permission document restricting programmatic capabilities exclusively to `ecr:GetAuthorizationToken` alongside localized image upload routines mapped strictly to the repository ARN.
* **Instance Profile Binding:** Tied the security role to an intermediate **IAM Instance Profile** container, allowing the compute hardware executor to dynamically fetch cryptographic access tokens directly from the AWS metadata service endpoint.

### 3. Compute Host Deployment & Firewall Hardening

I provisioned a dedicated, scaled compute environment on Amazon EC2 to act as the primary pipeline orchestration container cluster.

* **Hardware Sizing Allocation:** Selected the `t3.medium` architecture node size to ensure the host possesses the 2 vCPUs and 4GB RAM required to run heavy container compilation and security scanning threads simultaneously without freezing.
* **Perimeter Access Control:** Constructed a stateful Security Group that explicitly blocks all public ingress, exposing Custom TCP Port 8080 exclusively to verified administrative IP ranges to protect the pipeline dashboard against public internet scanning bots.

### 4. Automated Environment Bootstrapping & Telemetry Hooking

I connected to the secure operating system shell via AWS Systems Manager Session Manager and executed the configuration runlists to bootstrap the development utilities.

* **Package Management Execution:** Updated system repositories, configured trusted repository signing certificates, and deployed Java 21, the Docker engine, the Trivy scanning CLI, and the Jenkins server core.
* **Service Runtime Initialization:** Assigned the Jenkins service user to the local Docker socket security group, wrote custom systemd Java path configurations, and started the automation daemon processes using these exact platform instructions:

```bash
# Update base repositories and install modern Java 21 OpenJDK
sudo apt-get update && sudo apt-get install -y openjdk-21-jdk gnupg curl apt-transport-https

# --- INSTALL DOCKER ENGINE ---
sudo apt-get install -y docker.io

# --- INSTALL TRIVY SECURITY SCANNER ---
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update && sudo apt-get install -y trivy

# --- INSTALL JENKINS AUTOMATION SERVER (WITH 2026 KEYS) ---
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt-get update && sudo apt-get install -y jenkins

# Bind user permissions and start service runtimes
sudo usermod -aG docker jenkins
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
echo -e "[Service]\nEnvironment=\"JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64\"" | sudo tee /etc/systemd/system/jenkins.service.d/override.conf
sudo systemctl daemon-reload && sudo systemctl restart docker
sudo systemctl enable jenkins && sudo systemctl start jenkins
```

* **Telemetry Hook Integration:** Initialized the primary desktop web portal using the generated setup token, navigated to the plugin configuration registry, and deployed the **Prometheus Metrics Plugin** to expose active pipeline execution metrics over a secure data tracking endpoint.

---

## Infrastructure as Code (IaC) Architecture

To preserve absolute repeatability, environment portability, and prevent infrastructure state drift, the entire system layout is provisioned using version-locked Terraform configurations. The infrastructure codebase is separated into flat, single-responsibility files:

### Directory Layout & Modular Structure

```text
devsecops-ingress-pipeline/
├── provider.tf          # Core initialization and global provider tag constraints
├── variables.tf         # Abstracted input variable types and default parameters
├── ecr.tf               # Private registry definitions and lifecycle cost rules
├── iam.tf               # Machine profiles, trust relationships, and scoped keys
├── ec2.tf               # Compute node sizing, perimeters, and bootstrap scripts
└── outputs.tf           # Interactive connection strings and tracking endpoints
```

---

## Detailed File-by-File Technical Breakdown

### 1. System Provider Scoping (`provider.tf`)

* **Plugin Constraints Enforcement:** Restricts the compilation environment strictly to the standard **AWS Provider v5.0+** module tree to leverage advanced lifecycle rules.
* **Global Resource Tagging:** Embeds a centralized `default_tags` definition within the provider scope, ensuring that every compute block, security group, and storage asset automatically inherits standard ownership parameters.

### 2. Variable Abstractions & Metadata Metrics (`variables.tf` & `outputs.tf`)

* **Environment Portability Mapping:** Parameterizes target location metrics, registry tags, and virtual machine sizes into strongly typed variables, keeping code decoupled from hardcoded strings.
* **Programmatic Endpoint Assembly:** Combines server networking attributes to output clean, clickable connection URLs (`http://<EC2-PUBLIC-IP>:8080`) directly onto the terminal dashboard upon execution success.

### 3. Container Image Warehouse Engineering (`ecr.tf`)

* **Supply Chain Security Controls:** Provisions the central `devsecops-secure-app` repository with a forced `scan_on_push = true` property statement block.
* **FinOps Storage Expiration:** Maps an explicit `aws_ecr_lifecycle_policy` block containing an untagged asset retention limit, automatically purging intermediate development artifacts after 14 days to preserve storage budgets.

### 4. Zero-Trust Access Control Architecture (`iam.tf`)

* **Cryptographic Machine Handshakes:** Establishes an un-aliased execution role container restricted strictly to the `ec2.amazonaws.com` service principal.
* **Hardware Profile Abstraction:** Compiles granular ECR capabilities and attaches them directly to an **`aws_iam_instance_profile`** block, enabling secure credential injection onto the compute host instance without static key storage.

### 5. Automation Compute Architecture (`ec2.tf`)

* **Firewall Perimeter Hardening:** Provisions the network security group, configuring clear port 8080 ingestion limits while allowing comprehensive outwards data flow loops for tracking system package registries.
* **Automated Host Initialization:** Provisions the core EC2 instance, ties it to the IAM instance profile container, and injects the complete bash runlist into the `user_data` parameter to compile Java 21, Jenkins, Docker, and Trivy automatically upon server startup.

---

## Verification and Results

### Verified Successful Environment Bootstrapping

Inspected system execution profiles following the Terraform deployment plan. The automation script completed cleanly on the first execution run, successfully upgrading the machine platform to Java 21, initializing the local Docker socket, and launching the Jenkins server engine on port 8080 with a healthy active status code flag.

### Validated SAST Pipeline Containment

Injected a testing repository build containing an outdated package dependency and an exposed cloud credential block into the checkout workspace directory. Monitoring logs verified that the integrated Trivy security scanner immediately intercepted the security vulnerabilities, failed the build block parameters, and terminated the delivery workflow prior to container registry ingestion.

### Confirmed Lifecycle Cost Optimization

Executed automated image push test sequences to upload multiple temporary, untagged development container builds into the private storage registry. The built-in ECR lifecycle policy engine correctly matched the evaluation rules, isolating the staging blocks and successfully applying expiration commands to keep storage overhead spend inside budget metrics.

### Confirmed Asynchronous Telemetry Delivery

Queried the monitoring metrics interface endpoint following multiple successful pipeline execution runs. I confirmed total monitoring success, noting that the integrated Prometheus plugin cleanly gathered and exported raw execution telemetry parameters including build success/failure states and container generation speeds.

---

## Verification Screenshots

### Screenshot of Jenkins Build Dashboard Showing Prometheus Metrics

<img width="1095" height="986" alt="Screenshot 1" src="https://github.com/user-attachments/assets/c4609d2b-9871-4c61-82ba-f200d28c7b9e" />
<img width="1271" height="989" alt="Screenshot 2" src="https://github.com/user-attachments/assets/b89fa76b-1f8d-44ee-ac4a-a0332b91988f" />



### Screenshot of Trivy Security Scan Blocking Vulnerable Build

<img width="1254" height="1700" alt="Screenshot 3" src="https://github.com/user-attachments/assets/625ac37f-fa1a-48b5-b888-1867617c85e4" />


### Screenshot of Amazon ECR Repository with Active Lifecycle Policy

<img width="1919" height="905" alt="Screenshot 4" src="https://github.com/user-attachments/assets/cae631a0-d651-4ed4-8a9b-0e7be09ccd6c" />


### Screenshot of AWS IAM Instance Profile Attached to EC2

<img width="1919" height="907" alt="Screenshot 5" src="https://github.com/user-attachments/assets/a5813d16-625c-40d9-9792-8b91a44d6a68" />


---

## Future Improvements

* **Centralized Prometheus/Grafana Dashboarding:** Deploy an external, centralized Prometheus server linked to a visual Grafana dashboard to render pipeline build status metrics, resource consumption trends, and delivery velocities into interactive charts.
* **Webhook Event Trigger Automation:** Integrate secure HTTPS webhook triggers between the Jenkins server node and private Git source repositories to automatically launch the DevSecOps scanning loops upon every single new code push event.
* **Continuous Security Compliance Auditing:** Integrate open-source linting and static security scanning utilities like `tflint` and `checkov` into the Jenkins build block layout to check the underlying infrastructure code files for vulnerabilities before rolling out modifications.

---

## Notes

This architecture demonstrates a modern, end-to-end framework for building highly automated, secure software supply chain shipping lanes. It showcases specialized cloud core competencies in structuring edge security scanners, managing infrastructure parameters via version-locked IaC code templates, establishing zero-trust machine access perimeters, and enforcing active cost control tracking loops across corporate registry platforms.

---

**Bottom Line:** The Enhanced DevSecOps Ingress Pipeline transitions modern software packaging and delivery workflows into a completely automated, self-cleaning shipping lane. By forcing container layers through optimized multi-stage build routines, running fail-fast static vulnerability scanners at checkout, applying automated container lifecycle rules to eliminate storage spend creep, and tracking performance health with active Prometheus telemetry metrics, the architecture delivers absolute cloud supply chain security with zero reliance on dangerous static access credentials.
