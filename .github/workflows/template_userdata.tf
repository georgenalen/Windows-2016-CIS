data "template_file" "template_userdata" {
  vars = {
    new_admin_pass  = "${var.NEW_ADMIN_PASSWORD}"
  }
  template = <<EOF
<powershell>
$admin = [adsi]("WinNT://./administrator, user")
$admin.PSBase.Invoke("SetPassword", "${new_admin_pass}")
</powershell>
}