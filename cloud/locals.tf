locals {
    tags = {
        "provisioner" = "terraform"
        "module"      = "cluster"
        "environment" = "${var.environment}"
    }

    k3s_server_fqdn     = format("%s.%s.%s.oraclevcn.com", "k3s-server", oci_core_subnet.subnet.dns_label, oci_core_vcn.vcn.dns_label)
}