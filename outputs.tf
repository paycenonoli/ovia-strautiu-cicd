# Define output
output "jenkins_public_ip"{
    description = "Public IP of Jenkins instance"
    value = aws_instance.ovia-Jenkins.public_ip
}

output "sonarqube_public_ip"{
    description = "Public IP of SonarQube instance"
    value = aws_instance.ovia-SonarQube.public_ip
}

output "ansible_public_ip"{
    description = "Public IP of Ansible instance"
    value = aws_instance.ovia-Ansible.public_ip
}