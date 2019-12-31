resource "aws_lb_target_group" "my-target-group" {
    health_check{
        interval =10
        path ="/"
        protocol ="HTTP"
        timeout =5
        healthy_threshold =5
        unhealthy_threshold =2
    }
  name        = "examplevpc-terraform-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_lb" "my_alb_vpctest" {
  name               = "test-alb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.my_albvpc_sg.id}"]
  subnets            = ["${var.public1_subnet}","${var.public2_subnet}"]

  enable_deletion_protection = false

  tags = {
      name="my_albvpc"
    Environment = "production"
  }
}

resource "aws_lb_listener" "my_albvpc_listner" {
  load_balancer_arn = "${aws_lb.my_alb_vpctest.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
  }
}

resource "aws_security_group" "my_albvpc_sg" {
  name= "alb-sG"
  vpc_id="${var.vpc_id}"
}

resource "aws_security_group_rule" "inbound_http" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.my_albvpc_sg.id}"
  
}

resource "aws_security_group_rule" "outbound_all" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = "${aws_security_group.my_albvpc_sg.id}"
  cidr_blocks=["0.0.0.0/0"]
}