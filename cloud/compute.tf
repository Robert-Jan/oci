data "oci_core_image" "ubuntu" {
    image_id = var.os_image_id
}

resource "oci_core_instance" "k3s_server" {
    display_name = "K3S Server"

    depends_on = [
        oci_identity_dynamic_group.compute_dynamic_group,
        oci_identity_policy.compute_dynamic_group_policy
    ]

    availability_domain = var.availability_domain
    compartment_id      = var.compartment_ocid
    fault_domain        = "FAULT-DOMAIN-1"

    shape = "VM.Standard.A1.Flex"
    shape_config {
        memory_in_gbs = "6"
        ocpus         = "1"
    }

    source_details {
        source_id   = data.oci_core_image.ubuntu.id
        source_type = "image"
    }

    create_vnic_details {
        display_name     = "K3S Server VLAN"
        hostname_label   = "k3s-server"
        subnet_id        = oci_core_subnet.subnet.id
        assign_public_ip = true
        freeform_tags    = local.tags
    }

    agent_config {
        plugins_config {
            name          = "Compute Instance Monitoring"
            desired_state = "ENABLED"
        }
        plugins_config {
            name          = "Bastion"
            desired_state = "ENABLED"
        }
        plugins_config {
            name          = "Vulnerability Scanning"
            desired_state = "ENABLED"
        }
    }

    metadata = {
        "ssh_authorized_keys" = var.ssh_authorized_keys
        "user_data"           = data.template_cloudinit_config.install_k3s_server.rendered
    }

    freeform_tags = local.tags

    lifecycle {
        ignore_changes = [
            metadata # Ignore changes to metadata because they are unchangeable
        ]
    }
}

resource "oci_core_instance" "k3s_worker" {
    count        = 3
    display_name = "K3S Worker ${count.index}"

    depends_on = [
        oci_core_instance.k3s_server,
        oci_identity_dynamic_group.compute_dynamic_group,
        oci_identity_policy.compute_dynamic_group_policy
    ]

    availability_domain = var.availability_domain
    compartment_id      = var.compartment_ocid
    fault_domain        = "FAULT-DOMAIN-${count.index + 1}"

    shape = "VM.Standard.A1.Flex"
    shape_config {
        memory_in_gbs = "6"
        ocpus         = "1"
    }

    source_details {
        source_id   = var.os_image_id
        source_type = "image"
    }

    create_vnic_details {
        display_name     = "K3S Worker ${count.index} VLAN"
        hostname_label   = "k3s-worker-${count.index}"
        subnet_id        = oci_core_subnet.subnet.id
        assign_public_ip = true
        freeform_tags    = local.tags
    }

    agent_config {
        plugins_config {
            name          = "Compute Instance Monitoring"
            desired_state = "ENABLED"
        }
        plugins_config {
            name          = "Bastion"
            desired_state = "ENABLED"
        }
        plugins_config {
            name          = "Vulnerability Scanning"
            desired_state = "ENABLED"
        }
    }

    metadata = {
        "ssh_authorized_keys" = var.ssh_authorized_keys
        "user_data"           = data.template_cloudinit_config.install_k3s_node.rendered
    }

    freeform_tags = local.tags

    lifecycle {
        ignore_changes = [
            metadata # Ignore changes to metadata because they are unchangeable
        ]
    }
}