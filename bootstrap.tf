###
# User data.
###
data "template_file" "user-data" {
    template = "${file("bootstrap/user-data.sh")}"
}

data "template_cloudinit_config" "cloudinit" {
    gzip          = false
    base64_encode = false

    part {
        content_type = "text/x-shellscript"
        content      = "${data.template_file.user-data.rendered}"
    }
}
