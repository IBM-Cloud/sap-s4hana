locals {
  folder_list = [
    "${var.KIT_S4HANA_EXPORT}"
  ]
}

resource "null_resource" "fail_if_no_folder" {
  count = length(local.folder_list)

  triggers = {
    folder_path = local.folder_list[count.index]
  }

    provisioner "local-exec" {
        command     = "if [ ! -d ${local.folder_list[count.index]} ] || [ -z \"$(ls -A ${local.folder_list[count.index]})\" ]; then exit 1; fi"
        on_failure = fail
  }
}
