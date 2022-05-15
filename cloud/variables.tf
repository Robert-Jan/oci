variable "compartment_ocid" {}

variable "availability_domain" {}

variable "user_ocid" {}

variable "k3s_workers" {
    default = 3
}

variable "ssh_authorized_keys" {}

variable "ip_whitelist" {
    type = list(string)
}

variable "os_image_id" {
    default = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaabondrhagq6m5lis4sfdcgj4mpaozxawx6anqtvm3klcdlis2vbxa"
}

variable "region" {
    default = "eu-amsterdam-1"
}

variable "environment" {
    default = "production"
}