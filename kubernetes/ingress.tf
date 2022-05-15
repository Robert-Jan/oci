##
## ArgoCD Ingress
##
resource "kubernetes_ingress_v1" "argocd" {
    metadata {
        name      = "argocd-server-ingress"
        namespace = "argocd"

        annotations = {
            "kubernetes.io/ingress.class"                    = "nginx"
            "kubernetes.io/tls-acme"                         = "true"
            "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
            "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTPS"
            "nginx.ingress.kubernetes.io/ssl-passthrough"    = "true"
        }
    }

    spec {
        #ingress_class_name = "nginx"

        rule {
            host = "argocd.robert-jan.me"

            http {
                path {
                    path      = "/"
                    path_type = "Prefix"

                    backend {
                        service {
                            name = "argocd-server"

                            port {
                                number = 443
                            }
                        }
                    }
                }
            }
        }

        tls {
            hosts = [
                "argocd.robert-jan.me"
            ]
            secret_name = "argocd-secret"
        }
    }
}

##
## Longhorn UI Ingress 
##
resource "kubernetes_secret_v1" "example" {
    metadata {
        name      = "basic-auth"
        namespace = "longhorn-system"
    }

    data = {
        auth     = "rjvdelst:$apr1$V06psHC/$k/6qoxsjIIonXw8xzff850"
        username = "admin"
        password = "iD72CgorY2WO6TdRRJv3"
    }

    type = "kubernetes.io/basic-auth"
}

resource "kubernetes_ingress_v1" "longhorn" {
    metadata {
        name      = "longhorn-ingress"
        namespace = "longhorn-system"

        annotations = {
            "kubernetes.io/ingress.class"                 = "nginx"
            "nginx.ingress.kubernetes.io/ssl-redirect"    = "false"
            "nginx.ingress.kubernetes.io/auth-type"       = "basic"
            "nginx.ingress.kubernetes.io/auth-secret"     = "basic-auth"
            "nginx.ingress.kubernetes.io/auth-realm"      = "Authentication Required"
            "nginx.ingress.kubernetes.io/proxy-body-size" = "10000m"

            # TLS
            "kubernetes.io/tls-acme"                       = "true"
            "cert-manager.io/cluster-issuer"               = "letsencrypt-prod"
            "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"

        }
    }

    spec {
        rule {
            host = "longhorn.robert-jan.me"

            http {
                path {
                    path      = "/"
                    path_type = "Prefix"

                    backend {
                        service {
                            name = "longhorn-frontend"

                            port {
                                number = 80
                            }
                        }
                    }
                }
            }
        }

        tls {
            hosts = [
                "longhorn.robert-jan.me"
            ]
            secret_name = "longhorn-cert"
        }
    }
}