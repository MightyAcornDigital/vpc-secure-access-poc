data "aws_ami" "jump" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}
resource "aws_security_group" "jump" {
  count  = var.create_jump ? 1 : 0
  name   = "jump"
  vpc_id = module.vpc.vpc_id
  egress {
    from_port   = 0
    protocol    = "ALL"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
data "aws_iam_policy_document" "assume_by_ec2" {
  count = var.create_jump ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}
resource "aws_iam_role" "jump" {
  count              = var.create_jump ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.assume_by_ec2[count.index].json
  name               = "jump"
}
resource "aws_iam_role_policy_attachment" "jump_ssm_managed" {
  count      = var.create_jump ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.jump[count.index].id
}
resource "aws_iam_role_policy_attachment" "jump_ssm" {
  count      = var.create_jump ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.jump[count.index].id
}
resource "aws_iam_instance_profile" "jump_profile" {
  count = var.create_jump ? 1 : 0
  name  = "jump"
  role  = aws_iam_role.jump[count.index].id
}
module "jump" {
  count                  = var.create_jump ? 1 : 0
  source                 = "terraform-aws-modules/ec2-instance/aws"
  name                   = "jump"
  iam_instance_profile   = aws_iam_instance_profile.jump_profile[count.index].id
  ami                    = data.aws_ami.jump.id
  instance_type          = "t4g.nano"
  vpc_security_group_ids = [aws_security_group.jump[count.index].id]
  subnet_id              = module.vpc.private_subnets[0]
#  user_data              = file("./jump-install-ssm.sh")
  root_block_device = [{
    encrypted = true
  }]
}
