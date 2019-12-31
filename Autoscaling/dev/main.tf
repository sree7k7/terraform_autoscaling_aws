provider "aws" {
  region  = "us-west-1"
  version = "~> 2.7"
}
module "my_vpc" {
  source = "../modules/vpc"
}

module "ec2" {
  source = "../modules/ec2"
}

module "alb" {
  source = "../modules/alb"
  vpc_id = "${module.my_vpc.vpc_id}"
  public1_subnet  = "${module.my_vpc.public1_subnet}"
  public2_subnet = "${module.my_vpc.public2_subnet}"
}

module "asg" {
  source           = "../modules/autoscaling"
  vpc_id           = "${module.my_vpc.vpc_id}"
  public1_subnet    = "${module.my_vpc.public1_subnet}"
  public2_subnet   = "${module.my_vpc.public2_subnet}"
  security_group   = "${module.my_vpc.security_group}"
  target_group_arn = "${module.alb.my-target-group-arn}"
  image_id         = "${module.ec2.clone_ami_id}"
 asg_key    = "asg_key.pub"

}

