provider "aws" {
  profile = ""
  region  = var.aws_region
}

// Create a security group with access to port 22 and port 80 open to serve HTTP traffic

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "allow_ssh" {
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// instance setup

# Logic to get latest Windows ami
data "aws_ami" "windows_server_latest_AMI" {
  most_recent = true
  owners      = ["801119661308"]

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "template_userdata" {
  vars = {
  new_admin_pass  = var.NEW_ADMIN_PASSWORD
  }
  template = <<EOF
<powershell>
$admin = [adsi]("WinNT://./administrator, user")
$admin.PSBase.Invoke("SetPassword", "$${new_admin_pass}")
</powershell>
EOF
}

resource "aws_instance" "testing_vm" {
  ami                         = data.aws_ami.windows_server_latest_AMI.id
  associate_public_ip_address = true
  key_name                    = var.ami_key_pair_name # This is the key as known in the ec2 key_pairs
  instance_type               = var.instance_type
  tags                        = var.instance_tags
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  get_password_data           = true
  user_data     = data.template_file.template_userdata.rendered
}

output "admin_password" {
  value = "${rsadecrypt(aws_instance.testing_vm.password_data, file("test_key.pem"))}"
}

output "showme_amdin" {
  value = var.NEW_ADMIN_PASSWORD
}
// generate inventory file
resource "local_file" "inventory" {
  filename = "./hosts.yml"
  content  = <<EOF
    # benchmark host
    all:
      hosts:
        ${var.ami_os}:
          ansible_host: ${aws_instance.testing_vm.public_ip}
          ansible_user: ${var.ami_username}
          ansible_connection: winrm
      vars:
        setup_audit: true
        run_audit: true
        # to keep ansible connections
        rule_9_2_1: false
        rule_18_3_1: false
        system_is_ec2: true
        ansible_winrm_server_cert_validation: ignore
        ansible_winrm_operation_timeout_sec: 120
        ansible_winrm_read_timeout_sec: 180
        ansible_psrp_cert_validation: ignore
        ansible_psrp_read_timeout: 180
        ansible_psrp_operation_timeout: 120
        ansible_password: "${rsadecrypt(aws_instance.testing_vm.password_data, file("test_key.pem"))}"
EOF
}
