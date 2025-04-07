data "aws_ec2_instance_type" "this" {
  instance_type = var.ec2_instance_type
}

resource "aws_instance" "this" {
  ###  BASICS  ###
  ami                         = var.ami
  instance_type               = var.ec2_instance_type
  count                       = var.instance_count
  key_name                    = var.ec2_key_pair
  monitoring                  = true
  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change
  get_password_data           = var.get_password_data
  metadata_options {
    http_endpoint               = var.http_endpoint
    http_put_response_hop_limit = var.http_put_response_hop_limit
    http_tokens                 = var.http_tokens
    instance_metadata_tags      = var.instance_metadata_tags
  }

  ###  NETWORKING  ###
  subnet_id = element(var.subnet_ids, count.index)
  private_ip = (
    var.instance_count == 1 && var.private_ip != null ? var.private_ip :
    var.instance_count > 1 && length(var.private_ips) > count.index ? var.private_ips[count.index] :
    null
  )
  associate_public_ip_address = var.associate_public_ip || var.associate_eip
  source_dest_check           = var.source_dest_check
  vpc_security_group_ids = var.create_security_group ? (
    length(var.additional_security_groups) > 0 ? concat([module.security_group[0].id], var.additional_security_groups) : [module.security_group[0].id]
  ) : var.additional_security_groups

  ###  STORAGE  ###
  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    encrypted   = true
    kms_key_id  = var.ebs_kms_key_arn
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value["device_name"]
      volume_size           = ebs_block_device.value["volume_size"]
      volume_type           = ebs_block_device.value["volume_type"]
      iops                  = lookup(ebs_block_device.value, "iops", 3000)
      encrypted             = true
      delete_on_termination = var.volume_delete_on_termination
      kms_key_id            = var.ebs_kms_key_arn
    }
  }

  ebs_optimized = var.ebs_optimized


  ###  IAM  ###
  iam_instance_profile = local.iam_profile


  ###  TAGS  ###
  tags = merge(
    {
      Name       = var.instance_count == 1 ? var.name : "${var.name}${count.index + 1}",
      CNAME      = var.instance_count == 1 ? var.name : "${var.name}${count.index + 1}",
      PatchGroup = tostring(count.index % 2 + 1) # Default PatchGroup tag increments in range 1-2
    },
    var.tags,
    var.global_tags
  )

  lifecycle {
    ignore_changes = [root_block_device, ebs_block_device, user_data, ami]
    precondition {
      condition     = (data.aws_ec2_instance_type.this.ebs_optimized_support == "unsupported" && var.ebs_optimized == false) || (data.aws_ec2_instance_type.this.ebs_optimized_support == "supported" && var.ebs_optimized == true) || (data.aws_ec2_instance_type.this.ebs_optimized_support == "default" && var.ebs_optimized == true)
      error_message = <<-EOT
  The instance type (${var.ec2_instance_type}) has an EBS Optimized value of (${data.aws_ec2_instance_type.this.ebs_optimized_support}), 
  but variable ebs_optimized is set to (${var.ebs_optimized}) (default is 'true').
  Please ensure the ebs_optimized variable matches the EBS Optimized support of the instance type.
  EOT
    }
  }
}
