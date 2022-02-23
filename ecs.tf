#data "template_file" "cluster-conf" {
#  template = <<EOF
#    #!/bin/bash
#    ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
#
#    yum install -y awslogs jq aws-cli
#
#    {
#      echo "ECS_CLUSTER=${aws_ecs_cluster.cluster-hello-world.name}"
#    } >> /etc/ecs/ecs.config
# EOF
#}
data "template_file" "cluster-conf" {
  template = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.cluster-hello-world.name} >> /etc/ecs/ecs.config
EOF
}

resource "aws_launch_template" "lt-hello-world" {
  name_prefix = "test"
  image_id = data.aws_ami.ami-ecs-latest.id
  instance_type = "t3.micro"
  depends_on = [aws_ecs_cluster.cluster-hello-world]
  user_data = "${base64encode(data.template_file.cluster-conf.rendered)}"
}

resource "aws_autoscaling_group" "asg-hello-world" {
  name = "name-asg-hello-world"
  max_size = 6
  min_size = 2
  desired_capacity = 2
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

  vpc_zone_identifier = [
    aws_subnet.subnet-hello-world-A.id,
    aws_subnet.subnet-hello-world-B.id
  ]
}

resource aws_autoscaling_lifecycle_hook alh-hello-world {
  autoscaling_group_name = aws_autoscaling_group.asg-hello-world.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
  name                   = "name-alh-hello-world"
}

resource "aws_ecs_capacity_provider" "cp-hello-world" {
  name = "name-cp-hello-world"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.asg-hello-world.arn
    managed_termination_protection = "DISABLED"
    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status = "ENABLED"
      target_capacity = 100
      instance_warmup_period = 200
    }
  }
}

resource aws_ecs_cluster "cluster-hello-world" {
  name = "name-cluster-hello-world"
}

resource aws_ecs_cluster_capacity_providers "cluster-cp-hello-world" {
  cluster_name = aws_ecs_cluster.cluster-hello-world.name
  capacity_providers = [aws_ecs_capacity_provider.cp-hello-world.name]
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.cp-hello-world.name
    weight = 100
  }
}