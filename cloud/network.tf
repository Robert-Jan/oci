resource "oci_core_vcn" "vcn" {
    display_name   = "VCN"
    dns_label      = "vcn"
    compartment_id = var.compartment_ocid

    cidr_blocks = ["10.0.0.0/16"]

    freeform_tags = local.tags
}

resource "oci_core_subnet" "subnet" {
    display_name   = "Subnet"
    dns_label      = "subnet"
    compartment_id = var.compartment_ocid

    cidr_block     = "10.0.0.0/24"
    vcn_id         = oci_core_vcn.vcn.id
    route_table_id = oci_core_vcn.vcn.default_route_table_id

    freeform_tags = local.tags
}

resource "oci_core_internet_gateway" "internet" {
    display_name   = "Internet Gateway"
    compartment_id = var.compartment_ocid

    vcn_id  = oci_core_vcn.vcn.id
    enabled = "true"

    freeform_tags = local.tags
}

resource "oci_core_default_route_table" "default" {
    manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id

    route_rules {
        network_entity_id = oci_core_internet_gateway.internet.id

        description      = "Internet Route"
        destination      = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
    }
}