###
# Security group.
###
resource "aws_security_group" "sg_bastion" {
    name        = "sg_ec2-bastion"
    vpc_id      = aws_vpc.projet_annuel.id
    description = "Managed by Terraform"

    ingress {
        from_port   = 22
        to_port     = 22
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

###
# ASG.
###
resource "aws_autoscaling_group" "asg-bastion" {
    name                      = "asg-bastion"
    max_size                  = 1
    min_size                  = 1
    desired_capacity          = 1
    health_check_grace_period = 300
    health_check_type         = "EC2"
    force_delete              = true
    launch_configuration      = aws_launch_configuration.lc-bastion.name
    vpc_zone_identifier       = [aws_subnet.public1.id, aws_subnet.public2.id]
    
    lifecycle {
        create_before_destroy = true
    }
}

###
# LC.
###
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "lc-bastion" {
    name_prefix     = "lc-bastion"
    image_id        = data.aws_ami.ubuntu.id
    instance_type   = "t2.micro"
    key_name        = "ec2-bastion"
    security_groups = [aws_security_group.sg_bastion.id]

    lifecycle {
        create_before_destroy = true
    }

    root_block_device{
        volume_type           = "gp2"
        volume_size           = 8
        delete_on_termination = true
    }
}

