resource "aws_vpc" "vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet1a" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.5.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a"
}

resource "aws_subnet" "subnet1c" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.6.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1c"
}

resource "aws_route_table" "route" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "route_association1a" {
    subnet_id      = aws_subnet.subnet1a.id
    route_table_id = aws_route_table.route.id
}

resource "aws_route_table_association" "route_association1c" {
    subnet_id      = aws_subnet.subnet1c.id
    route_table_id = aws_route_table.route.id
}

resource "aws_security_group" "sglb" {
    vpc_id = aws_vpc.vpc.id
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
        cidr_blocks = ["10.0.0.0/16"]
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
    vpc_id = aws_vpc.vpc.id
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
        cidr_blocks = ["10.0.0.0/16"]
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
    template = "${file("./scripts/user_data.sh")}"
}

resource "aws_instance" "instance01" {
    ami                    = "ami-00a929b66ed6e0de6"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.subnet1a.id
    vpc_security_group_ids = [aws_security_group.sgec2.id]
    key_name               = "vockey"
    user_data_base64       = "${base64encode(data.template_file.user_data.rendered)}"
}

resource "aws_instance" "instance02" {
    ami                    = "ami-00a929b66ed6e0de6"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.subnet1a.id
    vpc_security_group_ids = [aws_security_group.sgec2.id]
    key_name               = "vockey"
    user_data_base64       = "${base64encode(data.template_file.user_data.rendered)}"
}

resource "aws_instance" "instance03" {
    ami                    = "ami-00a929b66ed6e0de6"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.subnet1c.id
    vpc_security_group_ids = [aws_security_group.sgec2.id]
    key_name               = "vockey"
    user_data_base64       = "${base64encode(data.template_file.user_data.rendered)}"
}

resource "aws_instance" "instance04" {
    ami                    = "ami-00a929b66ed6e0de6"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.subnet1c.id
    vpc_security_group_ids = [aws_security_group.sgec2.id]
    key_name               = "vockey"
    user_data_base64       = "${base64encode(data.template_file.user_data.rendered)}"
}

resource "aws_elb" "elb" {
    name            = "staticsite-lb-aws-kledson"
    security_groups = [aws_security_group.sglb.id]
    subnets         = [aws_subnet.subnet1a.id, aws_subnet.subnet1c.id]
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

output "elb_dns_name" {
    value = aws_elb.elb.dns_name
}