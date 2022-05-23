##
## Cluster
##
variable "user_ocid" {}
variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "availability_domain" {}
variable "region" {
    default = "eu-amsterdam-1"
}
variable "private_key" {}
variable "fingerprint" {}
variable "ssh_authorized_keys" {}
variable "transip_account" {}
variable "transip_key_path" {}
variable "ip_whitelist" {}

module "cloud" {
    source = "./cloud"
    
    compartment_ocid    = var.compartment_ocid
    user_ocid           = var.user_ocid
    availability_domain = var.availability_domain
    ssh_authorized_keys = var.ssh_authorized_keys
    transip_account     = var.transip_account
    transip_key_path    = var.transip_key_path
    ip_whitelist        = var.ip_whitelist
}

##
## Kubernetes
##
module "kubernetes" {
    source = "./kubernetes"

    depends_on = [module.cloud]
}