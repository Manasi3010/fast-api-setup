resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block               = "10.0.1.0/24"
  map_public_ip_on_launch  = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id

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
}

resource "aws_ecs_cluster" "this" {
  name = "${var.app_name}-cluster"
}

data "aws_ami" "ecs" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "ecs-launch-template"
  image_id      = data.aws_ami.ecs.id
  instance_type = "t2.micro"
  user_data     = base64encode("echo ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config")
}

resource "aws_autoscaling_group" "ecs" {
  vpc_zone_identifier = [aws_subnet.public.id]
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }
}

resource "aws_ecs_task_definition" "fastapi" {
  family                   = "${var.app_name}-task"
  network_mode              = "bridge"
  container_definitions     = jsonencode([
    {
      name      = "fastapi"
      image     = var.ecr_image
      memory    = 512
      cpu       = 256
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "fastapi" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.fastapi.arn
  launch_type     = "EC2"
  desired_count   = var.desired_count
}

resource "aws_lb" "alb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public.id]
  security_groups    = [aws_security_group.ecs_sg.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.app_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_api_gateway_v2_api" "api" {
  name          = "${var.app_name}-api"
  protocol_type = "HTTP"
}

resource "aws_api_gateway_v2_integration" "alb" {
  api_id           = aws_api_gateway_v2_api.api.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.listener.arn
}

resource "aws_api_gateway_v2_stage" "default" {
  api_id      = aws_api_gateway_v2_api.api.id
  name        = "$default"
  auto_deploy = true
}
