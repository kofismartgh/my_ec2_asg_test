data "aws_instance" "ussd_api_image" {
    #instance_id = "i-061c09e2fe587d6fb" or you can just use the instance id
  filter {
    name   = "tag:Name"
    values = ["ussdapi*"]
  }
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

output "ussdapiip" {
  value = data.aws_instance.ussd_api_image.subnet_id
}

output "ussdapstate" {
  value = data.aws_instance.ussd_api_image.instance_state
}

output "ussdapid" {
  value = data.aws_instance.ussd_api_image.id
}

output "ussdapi_SG" {
  value = data.aws_instance.ussd_api_image.security_groups
}

output "ussdapi_VPSG" {
  value = data.aws_instance.ussd_api_image.vpc_security_group_ids
}

data "aws_instance" "ussd_api_image-Instance" {
  instance_id = "${data.aws_instance.ussd_api_image.id}"
}


resource "aws_ami_from_instance" "ussd_api_lt" {
  name               = "ussd_api_lt${formatdate("YYYY-MM-DD_hh-mm", timestamp())}"
  source_instance_id = data.aws_instance.ussd_api_image.id #ot you can just set you instance varible 
  snapshot_without_reboot = true
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name            = "ussd_api_lt${formatdate("YYYY-MM-DD_hh-mm", timestamp())}"
  }
}

output "ussdapi_lt_id" {
  value = aws_ami_from_instance.ussd_api_lt.id
}

###### nOW to create the LT

# data "aws_ami" "ussd_api_launch_t_recent" {
#   most_recent      = true
#   owners           = ["self"]
#   filter {
#     name   = "name"
#     values = ["ussd_api_lt*"]
#   }
# }

resource "aws_launch_template" "ussd_api_launch_t" {
  #image_id = aws_ami_from_instance.ussd_api_lt.id #does not cosider most recent
  name = "ussd_api_launch_t${formatdate("YYYY-MM-DD_hh-mm", timestamp())}"
  image_id = aws_ami_from_instance.ussd_api_lt.id
  instance_type = "t2.micro"
  #security_group_names = [data.aws_instance.ussd_api_image.security_groups]
  #vpc_security_group_ids = tolist(data.aws_instance.ussd_api_image.vpc_security_group_ids) ##uses IDs
  vpc_security_group_ids = ["sg-049767b202091b1b7"]
  user_data = filebase64("asguserdata.sh")
  update_default_version=true
# placement {
#     availability_zone = "us-east-1b"
#   }
  iam_instance_profile {
    name = data.aws_instance.ussd_api_image.iam_instance_profile
  }
    tags = {
    Name            = "ussd_api_launch_t${formatdate("YYYY-MM-DD_hh-mm", timestamp())}"
    ManagedBy ="asgterraform"
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      ManagedBy ="asgterraform"
    }
  }
    lifecycle {
    create_before_destroy = true
  }
}
output "launchTempID" {
  value = aws_launch_template.ussd_api_launch_t.id
}

# output "knowreecntami" {
#   value = data.aws_ami.ussd_api_launch_t_recent.id
# }