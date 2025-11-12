resource "aws_security_group" "sglb" {
  vpc_id = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    description = "TCP/80 from All"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sgec2" {
  vpc_id = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    description = "TCP/80 from All"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TCP/22 from All"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "user_data" {
  template = file("./modules/compute/scripts/user_data.sh")
}

resource "aws_instance" "instance01" {
  ami                    = "ami-00a929b66ed6e0de6"
  instance_type          = "t2.micro"
  subnet_id              = var.subnet1a_id
  vpc_security_group_ids = [aws_security_group.sgec2.id]
  key_name               = "vockey"
  user_data_base64       = base64encode(data.template_file.user_data.rendered)
}

resource "aws_instance" "instance02" {
  ami                    = "ami-00a929b66ed6e0de6"
  instance_type          = "t2.micro"
  subnet_id              = var.subnet1a_id
  vpc_security_group_ids = [aws_security_group.sgec2.id]
  key_name               = "vockey"
  user_data_base64       = base64encode(data.template_file.user_data.rendered)
}

resource "aws_instance" "instance03" {
  ami                    = "ami-00a929b66ed6e0de6"
  instance_type          = "t2.micro"
  subnet_id              = var.subnet1c_id
  vpc_security_group_ids = [aws_security_group.sgec2.id]
  key_name               = "vockey"
  user_data_base64       = base64encode(data.template_file.user_data.rendered)
}

resource "aws_instance" "instance04" {
  ami                    = "ami-00a929b66ed6e0de6"
  instance_type          = "t2.micro"
  subnet_id              = var.subnet1c_id
  vpc_security_group_ids = [aws_security_group.sgec2.id]
  key_name               = "vockey"
  user_data_base64       = base64encode(data.template_file.user_data.rendered)
}

resource "aws_elb" "elb" {
  name            = var.elb_name
  security_groups = [aws_security_group.sglb.id]
  subnets         = [var.subnet1a_id, var.subnet1c_id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  instances = [
    aws_instance.instance01.id,
    aws_instance.instance02.id,
    aws_instance.instance03.id,
    aws_instance.instance04.id
  ]
}