resource "aws_instance" "this" {
  ###  BASICS  ###
  ami           = var.ami
  instance_type = var.ec2_instance_type
  count         = var.instance_count
  key_name      = var.ec2_key_pair
  monitoring    = true
  user_data     = length(local.user_data) > 0 ? data.cloudinit_config.user_data[0].rendered : var.simple_user_data

  ###  NETWORKING  ###
  subnet_id                   = element(var.subnet_ids, count.index)
  private_ip                  = var.private_ip
  associate_public_ip_address = var.associate_public_ip || var.associate_eip
  source_dest_check           = var.source_dest_check
  vpc_security_group_ids      = [module.security_group.id]

  ###  STORAGE  ###
  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    encrypted   = true
    kms_key_id  = var.ebs_kms_key_arn
  }

  ebs_optimized = var.ebs_optimized


  ###  IAM  ###
  iam_instance_profile = local.iam_profile


  ###  TAGS  ###
  tags = merge(
    {
      Name       = var.instance_count == 1 ? var.name : "${var.name}${count.index + 1}",
      PatchGroup = tostring(count.index % 2 + 1) # Default PatchGroup tag increments in range 1-2
    },
    var.tags,
    var.global_tags
  )

  volume_tags = merge(
    {
      Name = var.instance_count == 1 ? var.name : "${var.name}${count.index + 1}"
    },
    var.tags,
    var.global_tags
  )

  lifecycle {
    ignore_changes = [root_block_device, ebs_block_device, user_data, ami]
  }

  depends_on = [var.module_depends_on]
}
