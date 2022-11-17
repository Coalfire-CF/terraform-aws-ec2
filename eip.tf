resource "aws_eip" "eip" {
  count = var.associate_eip ? 1 * var.instance_count : 0
  vpc   = true
}

resource "aws_eip_association" "eip_attach" {
  count         = var.associate_eip ? 1 * var. instance_count : 0
  instance_id   = aws_instance.this[count.index].id
  allocation_id = aws_eip.eip[count.index].id
}