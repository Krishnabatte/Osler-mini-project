provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "jenkins_server" {
  ami                         = "ami-0ddc798b3f1a5117e" # Amazon Linux 2 AMI
  instance_type               = var.instance_type
  key_name                    = var.key_name
 # vpc_security_group_ids      = var.vpc_security_group_ids

  user_data = <<-EOF
    #!/bin/bash
    # Install Docker
    yum update -y
    amazon-linux-extras install docker -y
    service docker start
    usermod -a -G docker ec2-user

    # Start Jenkins in Docker
    docker run -d -p 8080:8080 -p 50000:50000 \
      -v jenkins_home:/var/jenkins_home \
      --name jenkins-server jenkins/jenkins:lts

    # Wait for Jenkins to start
    sleep 60

    # Install Jenkins CLI and TestNG Plugin
    JENKINS_URL="http://localhost:8080"
    CLI_JAR="/var/jenkins_home/war/WEB-INF/jenkins-cli.jar"
    
    wget "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -P /var/jenkins_home/war/WEB-INF

    ADMIN_PASSWORD=$(cat /var/jenkins_home/secrets/initialAdminPassword)

    java -jar "$CLI_JAR" -s "$JENKINS_URL" -auth admin:"$ADMIN_PASSWORD" install-plugin testng-plugin
    java -jar "$CLI_JAR" -s "$JENKINS_URL" -auth admin:"$ADMIN_PASSWORD" restart

    # Wait for Jenkins to restart
    sleep 60

    # Create Jenkins pipeline job
    cat << 'EOF2' > jenkins-pipeline-job.groovy
    ${file("jenkins-pipeline-job.groovy")}
    EOF2

    java -jar "$CLI_JAR" -s "$JENKINS_URL" -auth admin:"$ADMIN_PASSWORD" groovy = < jenkins-pipeline-job.groovy
  EOF

  tags = {
    Name = "Jenkins-Server"
  }
}

#output "jenkins_url" {
#value = "http://${aws_instance.jenkins_server.public_ip}:8080"
#description = "Jenkins Server URL"
#}
