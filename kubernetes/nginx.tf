resource "kubernetes_service_v1" "ingress-nginx-controller-loadbalancer" {
    metadata {
        name      = "ingress-nginx-controller-loadbalancer"
        namespace = "ingress-nginx"
    }

    spec {
        selector = {
            "app.kubernetes.io/component" = "controller",
            "app.kubernetes.io/instance"  = "ingress-nginx",
            "app.kubernetes.io/name"      = "ingress-nginx"
        }

        port {
            name        = "http"
            protocol    = "TCP"
            port        = 80
            target_port = 80
        }

        port {
            name        = "https"
            protocol    = "TCP"
            port        = 443
            target_port = 80
        }
        
        type = "LoadBalancer"
    }
}

resource "kubernetes_config_map_v1" "ingress-nginx-controller" {
    metadata {
        name      = "ingress-nginx-controller"
        namespace = "ingress-nginx"
        
        labels = {
            "app.kubernetes.io/component"  = "controller",
            "app.kubernetes.io/instance"   = "ingress-nginx",
            "app.kubernetes.io/managed-by" = "Helm",
            "app.kubernetes.io/name"       = "ingress-nginx",
            "app.kubernetes.io/part-of"    = "ingress-nginx",
            "app.kubernetes.io/version"    = "1.2.0",
            "helm.sh/chart"                = "ingress-nginx-4.1.0"
        }
    }

    data = {
        "allow-snippet-annotations"  = true,
        "use-forwarded-headers"      = true,
        "compute-full-forwarded-for" = true,
        "enable-real-ip"             = true,
        "forwarded-for-header"       = "X-Forwarded-For",
        "proxy-real-ip-cidr"         = "0.0.0.0/0"
    }
}