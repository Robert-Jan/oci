##
## ArgoCD Ingress
##
resource "kubernetes_ingress_v1" "argocd" {
    metadata {
        name      = "argocd-server-ingress"
        namespace = "argocd"

        annotations = {
            "kubernetes.io/ingress.class"                    = "nginx"
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
        }
    }

    spec {
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
    }
}

##
## Longhorn UI Ingress 
##
resource "kubernetes_secret_v1" "longhorn_basic_auth" {
    metadata {
        name      = "basic-auth"
        namespace = "longhorn-system"
    }

    data = {
        auth     = "rjvdelst:$apr1$V06psHC/$k/6qoxsjIIonXw8xzff850"
        username = ""
        password = ""
    }

    type = "kubernetes.io/basic-auth"
}

resource "kubernetes_ingress_v1" "longhorn" {
    metadata {
        name      = "longhorn-ingress"
        namespace = "longhorn-system"

        annotations = {
            "kubernetes.io/ingress.class"                    = "nginx"
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
            "nginx.ingress.kubernetes.io/auth-type"          = "basic"
            "nginx.ingress.kubernetes.io/auth-secret"        = "basic-auth"
            "nginx.ingress.kubernetes.io/auth-realm"         = "Authentication Required"
            "nginx.ingress.kubernetes.io/proxy-body-size"    = "10000m"
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
    }
}