resource "template_file" "template_userdata" {
  filename = "george_userdata.txt"
  vars = {
    new_admin_pass  = "${var.NEW_ADMIN_PASSWORD}"
  }
}