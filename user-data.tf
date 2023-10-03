data "cloudinit_config" "user_data" {
  count         = length(var.user_data) > 0 ? 1 : 0
  gzip          = var.user_data_gzip
  base64_encode = var.user_data_gzip

  dynamic "part" {

    for_each = local.user_data
    content {
      content_type = "text/x-shellscript"
      content      = part.value
    }
  }
}
