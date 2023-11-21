data "template_cloudinit_config" "ec2_application" {
  gzip          = true
  base64_encode = true

  part {
    filename = "install.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/app/install.sh", {
      POSTGRES_CONNECTION_STRING = var.postgres_url,
    })
  }
}