
resource "time_sleep" "wait_30_sec" {
  depends_on = [aws_instance.web-api]
  create_duration = "30s"
}

resource "null_resource" "install_env" {

  provisioner "local-exec" {
    command = "( ansible-playbook main.yml --vault-password-file pass.txt --private-key A4L.pem )"
  }

  depends_on = [time_sleep.wait_30_sec]

}
