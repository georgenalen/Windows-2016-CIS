data "template_file" "template_userdata" {
  filename = "george_userdata.txt"
  vars = {
    new_admin_password  = "${var.NEW_ADMIN_PASSWORD}"
  }
