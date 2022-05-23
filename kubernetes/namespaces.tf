resource "kubernetes_namespace" "ingress-nginx" {
    metadata {
        name = "ingress-nginx"
    }
}

resource "kubernetes_namespace" "longhorn" {
    metadata {
        name = "longhorn"
    }
}

resource "kubernetes_namespace" "argocd" {
    metadata {
        name = "argocd"
    }
}