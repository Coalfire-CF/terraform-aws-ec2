# Gathers user data from maps listed in module calls
locals {
    user_data = var.user_data == null ? null : [
      for script in var.user_data : templatefile(
      "${path.module}/${script["path"]["folder_name"]}/${script["path"]["file_name"]}",
      script["vars"]
    )
  ]
}

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