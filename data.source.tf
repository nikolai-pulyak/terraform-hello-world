data "aws_availability_zones" "current" {}
data "aws_region" "current" {}

data "aws_ami" "ami-ecs-latest" {
  owners = ["137112412989"]
  name_regex = "^amzn2-ami-kernel.+x86_64-gp2$"
  most_recent = true
}