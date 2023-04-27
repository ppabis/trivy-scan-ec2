resource "aws_key_pair" "ssh" {
  key_name   = "ssh-ubuntu"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_instance" "ubuntu" {
  ami                  = data.aws_ami.ubuntu-arm.id
  instance_type        = "t4g.micro"
  key_name             = aws_key_pair.ssh.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2-trivy.name
  tags = {
    Name = "Ubuntu-Trivy"
  }

  vpc_security_group_ids = [
    aws_security_group.ssh.id
  ]
}

output "ubuntu" {
  value = aws_instance.ubuntu.public_ip
}

resource "aws_security_group" "ssh" {
  name = "SSH-trivy"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh-subnet]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu-arm" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*20.04*server*"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}