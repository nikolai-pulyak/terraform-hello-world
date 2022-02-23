resource "aws_launch_template" "lt-hello-world" {
  name_prefix = "test"
  image_id = data.aws_ami.ami-ecs-latest.id
  instance_type = "t3.micro"
}

resource "aws_autoscaling_group" "asg-hello-world" {
  max_size = 6
  min_size = 2
  force_delete = true

  launch_template {
    id = aws_launch_template.lt-hello-world.id
    version = "$Latest"
  }

  tag {
    key = "AmazonECSManaged"
    value = true
    propagate_at_launch = true
  }
}

resource aws_ecs_cluster "cluster-hello-world" {
  name = "name-cluster-hello-world"
}