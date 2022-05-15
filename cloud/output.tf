output "lb_ip" {
    depends_on = [
        oci_load_balancer_load_balancer.public,
    ]

    value = oci_load_balancer_load_balancer.public.ip_addresses
}

output "k3s_server_ip" {
    depends_on = [
        oci_core_instance.k3s_server,
    ]

    value = oci_core_instance.k3s_server.public_ip
}

output "k3s_worker_ips" {
    depends_on = [
        oci_core_instance.k3s_worker,
    ]

  value = oci_core_instance.k3s_worker.*.public_ip
}

