resource "oci_load_balancer_load_balancer" "public" {
    display_name   = "Public Load Balancer"
    compartment_id = var.compartment_ocid
    
    subnet_ids                 = [oci_core_subnet.subnet.id]
    network_security_group_ids = [oci_core_network_security_group.public_load_balancer.id]

    ip_mode    = "IPV4"
    is_private = false
    shape      = "flexible"

    shape_details {
        maximum_bandwidth_in_mbps = 10
        minimum_bandwidth_in_mbps = 10
    }

    freeform_tags = local.tags
}

# HTTP 
resource "oci_load_balancer_listener" "http" {
    default_backend_set_name = oci_load_balancer_backend_set.http.name
    load_balancer_id         = oci_load_balancer_load_balancer.public.id
    name                     = "http_listener"
    protocol                 = "HTTP"
    port                     = 80
}

resource "oci_load_balancer_backend_set" "http" {
    load_balancer_id = oci_load_balancer_load_balancer.public.id
    name             = "http_backend_set"
    policy           = "ROUND_ROBIN"

    health_checker {
        protocol    = "HTTP"
        port        = 80
        url_path    = "/healthz"
        return_code = 200
    }
}

resource "oci_load_balancer_backend" "http" {
    depends_on = [
        oci_core_instance.k3s_worker,
    ]

    count            = var.k3s_workers
    backendset_name  = oci_load_balancer_backend_set.http.name
    ip_address       = oci_core_instance.k3s_worker[count.index].private_ip
    load_balancer_id = oci_load_balancer_load_balancer.public.id
    port             = 80
}

# HTTPS
# # resource "oci_load_balancer_certificate" "https" {
# #     certificate_name = "lb_https_cert"
# #     load_balancer_id = oci_load_balancer_load_balancer.public.id
# #
# #     lifecycle {
# #         create_before_destroy = true
# #     }
# # }

# resource "oci_load_balancer_listener" "https" {
#     default_backend_set_name = oci_load_balancer_backend_set.https.name
#     load_balancer_id         = oci_load_balancer_load_balancer.public.id
#     name                     = "https_listener"
#     protocol                 = "HTTP"
#     port                     = 443

#     # ssl_configuration {
#     #     certificate_name        = oci_load_balancer_certificate.https.certificate_name
#     #     cipher_suite_name       = "oci-default-ssl-cipher-suite-v1"
#     #     verify_peer_certificate = false
#     #     verify_depth            = 1
#     # }
# }

# resource "oci_load_balancer_backend_set" "https" {
#     load_balancer_id = oci_load_balancer_load_balancer.public.id
#     name             = "https_backend_set"
#     policy           = "ROUND_ROBIN"

#     health_checker {
#         protocol    = "HTTP"
#         port        = 443
#         url_path    = "/healthz"
#         return_code = 200
#     }
# }

# resource "oci_load_balancer_backend" "https" {
#     depends_on = [
#         oci_core_instance.k3s_worker,
#     ]

#     count            = var.k3s_workers
#     backendset_name  = oci_load_balancer_backend_set.https.name
#     ip_address       = oci_core_instance.k3s_worker[count.index].private_ip
#     load_balancer_id = oci_load_balancer_load_balancer.public.id
#     port             = 443
# }