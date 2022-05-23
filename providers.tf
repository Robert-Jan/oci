terraform {
    required_providers {
        oci = {
            source  = "oracle/oci"
            version = ">= 4.68"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.0.0"
        }
        kubectl = {
            source  = "gavinbunney/kubectl"
            version = ">= 1.14.0"
        }
        acme = {
            source  = "vancluever/acme"
            version = ">= 2.8.0"
        }
    }
}

provider "oci" {
    tenancy_ocid = var.tenancy_ocid
    user_ocid    = var.user_ocid
    private_key  = var.private_key
    fingerprint  = var.fingerprint
    region       = var.region
}

provider "kubernetes" {
    config_path    = "~/.kube/config"
    config_context = "default"
}

provider "kubectl" {
    config_path    = "~/.kube/config"
    config_context = "default"
}

provider "acme" {
    #server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
    server_url = "https://acme-v02.api.letsencrypt.org/directory"
}