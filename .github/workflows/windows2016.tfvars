ami_os        = "win2016"
ami_username  = "Administrator"
instance_tags = {
  Name        = "win2016_testing"
  Environment = "Benchmark Pipeline Testing"
}
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
ami_id        = data.aws_ami.windows_server_latest_AMI.id
instance_type = "c5.large"


