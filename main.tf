module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "sandbox"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  create_security_group = true
  security_group_rules = {
    egress = {
      type = "egress"
      cidr_blocks = ["0.0.0.0/0"]
      to_port   = 0
      from_port = 0
      protocol  = "-1"
    }
    ingress = {
      type = "ingress"
      to_port   = 0
      from_port = 0
      protocol  = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  endpoints = {
    appsync = {
      service = "appstream.streaming"
    }
  }
}

resource "aws_security_group" "db" {
  name_prefix = "demo-db"
    vpc_id      = module.vpc.vpc_id
    ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "demo"

  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"         # DB option group
  instance_class       = "db.t4g.micro"
  allocated_storage    = 20

  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 1
  vpc_security_group_ids = [aws_security_group.db.id]
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets
  manage_master_user_password = false
  username = "demo"
  password = "Password1234"
}
