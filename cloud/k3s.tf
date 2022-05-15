resource "random_password" "k3s_cluster_secret" {
    length  = 48
    special = false
}

data "template_cloudinit_config" "install_k3s_server" {
    gzip          = true
    base64_encode = true

    part {
        content_type = "text/x-shellscript"
        content      = templatefile("${path.module}/files/install-k3s-server.sh", {
            compartment_ocid    = var.compartment_ocid
            availability_domain = var.availability_domain
            k3s_url             = local.k3s_server_fqdn
            k3s_token           = random_password.k3s_cluster_secret.result
        })
  }
}

data "template_cloudinit_config" "install_k3s_node" {
    gzip          = true
    base64_encode = true

    part {
        content_type = "text/x-shellscript"
        content      = templatefile("${path.module}/files/install-k3s-node.sh", {
            k3s_url   = local.k3s_server_fqdn
            k3s_token = random_password.k3s_cluster_secret.result
        })
    }
}