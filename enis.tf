
//resource "aws_network_interface" "public" {
//  count = length(var.additional_enis["public"])
//  subnet_id = var.additional_enis["public"][count.index]["subnet_id"][0]
//  security_groups = var.additional_enis["public"][count.index]["security_groups"]
//  source_dest_check = var.additional_enis["public"][count.index]["source_dest_check"][0]
//  tags = {
//    Name = var.additional_enis["public"][count.index]["name"][0]
//  }
//}

//resource "aws_eip" "eip_multi_eni" {
//  count = length(var.additional_enis["public"])
//  vpc   = true
//}
//
//resource "aws_eip_association" "eip_multi_eni_attach" {
//  count         = length(var.additional_enis["public"])
//  network_interface_id = aws_network_interface.public[count.index].id
//  allocation_id = aws_eip.eip_multi_eni[count.index].id
//}

//resource "aws_network_interface" "private" {
//  count = length(var.additional_enis["private"])
//  subnet_id = var.additional_enis["private"][count.index]["subnet_id"][0]
//  security_groups = var.additional_enis["private"][count.index]["security_groups"]
//  source_dest_check = var.additional_enis["private"][count.index]["source_dest_check"][0]
//  tags = {
//    Name = var.additional_enis["private"][count.index]["name"][0]
//  }
//}

//locals {
//  eni_ids = concat(aws_network_interface.public.*.id, aws_network_interface.private.*.id)
//}

resource "aws_network_interface_attachment" "eni_attachment" {
  count = length(var.additional_eni_ids)
  device_index = count.index + 1
  instance_id = aws_instance.this[0].id
  network_interface_id = var.additional_eni_ids[count.index]
}
