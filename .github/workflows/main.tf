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


resource "aws_instance" "testing_vm" {
  ami                         = data.aws_ami.windows_server_latest_AMI.id
  associate_public_ip_address = true
  key_name                    = var.ami_key_pair_name # This is the key as known in the ec2 key_pairs
  instance_type               = var.instance_type
  tags                        = var.instance_tags
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  get_password_data           = true
  user_data                   = file("ansibleuserdata.ps1")
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
        ansible_password: |
          $ANSIBLE_VAULT;1.1;AES256
          36376432656364386136316636376563386665636139366166393634303061346466663966316163
          3533326435313037623230306263633764313963346132350a353363663635376430613238363533
          65646265356166633634313538353738646661616239326330363830663364383234303566666232
          3734653734383365340a396134633339366630643036343933616331393965353064373461333336
          39333333353565613766363162303637393735653135353166376565646266613163
EOF
}
