provider "aws" {
  region = "us-west-2"  # The region may cause availability issues for the chosen instance type
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  
  instance_type = "t2.micro"  
  
  iam_instance_profile = aws_iam_instance_profile.web_profile.name

  key_name = var.key_name

  tags = {
    Name = "WebServer"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80  
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_sg"
  }
}

resource "aws_s3_bucket" "static_content" {
  bucket = "my-static-content-bucket"
  acl    = "public-read"  

  tags = {
    Name = "StaticContent"
  }
}

resource "aws_s3_bucket_policy" "static_content_policy" {
  bucket = aws_s3_bucket.static_content.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.static_content.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "web_role" {
  name = "web_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "web_profile" {
  name = "web_profile"
  role = aws_iam_role.web_role.name
}

resource "aws_iam_role_policy" "web_policy" {
  name = "web_policy"
  role = aws_iam_role.web_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "${aws_s3_bucket.static_content.arn}"
    },
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.static_content.arn}/*"
    }
  ]
}
EOF
}
