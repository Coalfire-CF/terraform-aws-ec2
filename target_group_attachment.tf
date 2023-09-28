resource "aws_lb_target_group_attachment" "target_group_attachment" {
  count            = local.full_size
  target_group_arn = var.target_group_arns[floor(count.index / length(aws_instance.this.*.id))]
  target_id        = aws_instance.this[count.index % length(aws_instance.this.*.id)].id
}
