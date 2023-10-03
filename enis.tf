resource "aws_network_interface_attachment" "eni_attachment" {
  count                = length(var.additional_eni_ids)
  device_index         = count.index + 1
  instance_id          = aws_instance.this[0].id
  network_interface_id = var.additional_eni_ids[count.index]
}
