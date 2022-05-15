resource "oci_core_default_security_list" "security_list" {
    display_name               = "Security list"
    compartment_id             = var.compartment_ocid
    manage_default_resource_id = oci_core_vcn.vcn.default_security_list_id

    egress_security_rules {
        protocol    = "all"
        destination = "0.0.0.0/0"
        
        description = "Allow all outbound traffic"
    }

    ingress_security_rules {
        protocol = 1 # ICMP
        source   = var.ip_whitelist[0]

        description = "Allow ICMP from ${var.ip_whitelist[0]}"
    }

    ingress_security_rules {
        protocol = 6 # TCP
        source   = var.ip_whitelist[0]

        tcp_options {
            min = 22
            max = 22
        }

        description = "Allow SSH from ${var.ip_whitelist[0]}"
    }

    ingress_security_rules {
        protocol = 6 # TCP
        source   = var.ip_whitelist[0]

        tcp_options {
            min = 6443
            max = 6443
        }

        description = "Allow Kubernetes API from ${var.ip_whitelist[0]}"
    }

    ingress_security_rules {
        protocol = 1 # ICMP
        source   = var.ip_whitelist[1]

        description = "Allow ICMP from ${var.ip_whitelist[1]}"
    }

    ingress_security_rules {
        protocol = 6 # TCP
        source   = var.ip_whitelist[1]

        tcp_options {
            min = 22
            max = 22
        }

        description = "Allow SSH from ${var.ip_whitelist[1]}"
    }

    ingress_security_rules {
        protocol = 6 # TCP
        source   = var.ip_whitelist[1]

        tcp_options {
            min = 6443
            max = 6443
        }

        description = "Allow Kubernetes API from ${var.ip_whitelist[1]}"
    }

    ingress_security_rules {
        protocol = "all"
        source   = "10.0.0.0/16"

        description = "Allow all from VCN subnet"
    }

    freeform_tags = local.tags
}

resource "oci_core_network_security_group" "public_load_balancer" {
    display_name   = "Public Load Balancer NSG"
    compartment_id = var.compartment_ocid

    vcn_id = oci_core_vcn.vcn.id

    freeform_tags = local.tags
}

resource "oci_core_network_security_group_security_rule" "allow_http_from_all" {
    network_security_group_id = oci_core_network_security_group.public_load_balancer.id
    direction                 = "INGRESS"
    protocol                  = 6 # TCP

    description = "Allow HTTP from all"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
        destination_port_range {
            max = "80"
            min = "80"
        }
    }
}

resource "oci_core_network_security_group_security_rule" "allow_https_from_all" {
    network_security_group_id = oci_core_network_security_group.public_load_balancer.id
    direction                 = "INGRESS"
    protocol                  = 6 # TCP

    description = "Allow HTTPS from all"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
        destination_port_range {
            max = "443"
            min = "443"
        }
    }
}

resource "oci_bastion_bastion" "bastion" {
    name           = "Bastion"
    bastion_type   = "STANDARD"
    compartment_id = var.compartment_ocid

    target_subnet_id             = oci_core_subnet.subnet.id
    client_cidr_block_allow_list = var.ip_whitelist

    freeform_tags = local.tags
}