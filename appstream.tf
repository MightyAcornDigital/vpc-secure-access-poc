
resource "aws_appstream_stack" "demo" {
  name = "demo-stack"
  display_name       = "Demo Stack"

  application_settings {
    enabled = false
  }
  streaming_experience_settings {
    preferred_protocol = "TCP"
  }
  user_settings {
    action     = "CLIPBOARD_COPY_FROM_LOCAL_DEVICE"
    permission = "ENABLED"
  }
  user_settings {
    action     = "CLIPBOARD_COPY_TO_LOCAL_DEVICE"
    permission = "ENABLED"
  }
  user_settings {
    action     = "DOMAIN_PASSWORD_SIGNIN"
    permission = "ENABLED"
  }
  user_settings {
    action     = "DOMAIN_SMART_CARD_SIGNIN"
    permission = "DISABLED"
  }
  user_settings {
    action     = "FILE_DOWNLOAD"
    permission = "ENABLED"
  }
  user_settings {
    action     = "FILE_UPLOAD"
    permission = "ENABLED"
  }
}

resource "aws_appstream_fleet" "demo" {
  name = "demo-fleet"

  compute_capacity {
    desired_instances = 1
  }
  idle_disconnect_timeout_in_seconds = 60
  display_name                       = "demo-fleet"
  enable_default_internet_access     = false
  fleet_type                         = "ON_DEMAND"
  image_name                         = "AppStream-AmazonLinux2-11-13-2023"
  instance_type                      = "stream.standard.small"
  max_user_duration_in_seconds       = 7200
  disconnect_timeout_in_seconds      = 900
  stream_view = "DESKTOP"

  vpc_config {
    subnet_ids = module.vpc.private_subnets
  }

  tags = {
    TagName = "tag-value"
  }
}

# Associate the fleet with the stack
resource "aws_appstream_fleet_stack_association" "demo" {
  fleet_name = aws_appstream_fleet.demo.name
  stack_name = aws_appstream_stack.demo.name
}
