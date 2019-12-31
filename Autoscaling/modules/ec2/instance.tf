resource "aws_ami_copy" "aim_linux_server" {

  name              = "Clone_ami_server"
  description       = "A copy of ami-00e6fd13b76d9e976"
  source_ami_id     = "ami-00e6fd13b76d9e976"
  source_ami_region = "us-east-2"
  tags = {
    Name = "copy demo-1-site"
  }
}

output "clone_ami_id" {
  value = "${aws_ami_copy.aim_linux_server.id}"
}
