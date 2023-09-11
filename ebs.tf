resource "aws_ebs_volume" "this" {
  count = length(local.additional_ebs_volumes)

  availability_zone    = local.additional_ebs_volumes[count.index][0]
  encrypted            = true
  size                 = local.additional_ebs_volumes[count.index][1].size
  type                 = local.additional_ebs_volumes[count.index][1].type
  throughput           = local.additional_ebs_volumes[count.index][1].throughput
  kms_key_id           = var.ebs_kms_key_arn
  iops                 = local.additional_ebs_volumes[count.index][1].iops
  multi_attach_enabled = local.additional_ebs_volumes[count.index][1].multi_attach_enabled
  final_snapshot       = local.additional_ebs_volumes[count.index][1].final_snapshot
  snapshot_id          = local.additional_ebs_volumes[count.index][1].snapshot_id
  outpost_arn          = local.additional_ebs_volumes[count.index][1].outpost_arn
  tags = merge(
    {
      Name = var.instance_count == 1 ? var.name : "${var.name}${count.index / var.instance_count + 1}"
    },
    local.additional_ebs_volumes[count.index][1].tags,
    var.global_tags
  )
}

resource "aws_volume_attachment" "this" {
  for_each = local.additional_ebs_volumes

  device_name                    = each.value.device_name
  instance_id                    = each.key.device_name
  volume_id                      = each.value.device_name
  force_detach                   = local.additional_ebs_volumes[count.index][1].force_detach
  skip_destroy                   = local.additional_ebs_volumes[count.index][1].skip_destroy
  stop_instance_before_detaching = local.additional_ebs_volumes[count.index][1].stop_instance_before_detaching
}
