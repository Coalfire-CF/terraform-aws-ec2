resource "aws_ebs_volume" "this" {
  count = length(local.additional_ebs_volumes)

  availability_zone    = local.additional_ebs_volumes[count.index][0].availability_zone
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
      Name                        = var.instance_count == 1 ? var.name : "${var.name}${floor(count.index / max(length(var.ebs_volumes), 1)) + 1}",
      AssociatedInstance          = local.additional_ebs_volumes[count.index][0].id
      ForceDetach                 = local.additional_ebs_volumes[count.index][1].force_detach
      SkipDestroy                 = local.additional_ebs_volumes[count.index][1].skip_destroy
      StopInstanceBeforeDetaching = local.additional_ebs_volumes[count.index][1].stop_instance_before_detaching
      DeviceName                  = local.additional_ebs_volumes[count.index][1].device_name
    },
    local.additional_ebs_volumes[count.index][1].tags,
    var.global_tags,
    {
      backup_policy = var.backup_policy
    }
  )
}

resource "aws_volume_attachment" "this" {
  count = length(aws_ebs_volume.this[*])

  device_name                    = aws_ebs_volume.this[count.index].tags.DeviceName
  instance_id                    = aws_ebs_volume.this[count.index].tags.AssociatedInstance
  volume_id                      = aws_ebs_volume.this[count.index].id
  force_detach                   = aws_ebs_volume.this[count.index].tags.ForceDetach
  skip_destroy                   = aws_ebs_volume.this[count.index].tags.SkipDestroy
  stop_instance_before_detaching = aws_ebs_volume.this[count.index].tags.StopInstanceBeforeDetaching
}
