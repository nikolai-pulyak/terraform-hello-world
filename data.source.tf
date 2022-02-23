data "aws_availability_zones" "current" {}
data "aws_region" "current" {}

data "aws_ami" "ami-ecs-latest" {
  owners = ["591542846629"]
  name_regex = "amzn2-ami-ecs-hvm-2.0.202\\d+-x86_64-ebs"
  most_recent = true
}