# Apply the services stack in the cluster.
resource "null_resource" "apply-stack" {
  # Trigger definition to execute.
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "./applyStack.sh ${linode_instance.manager.ip_address}"
  }

  depends_on = [ linode_instance.manager, linode_instance.worker ]
}