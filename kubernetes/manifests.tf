##
## Longhorn
##
data "kubectl_file_documents" "longhorn" {
    # Version: 1.2.4
    content = file("${path.module}/manifests/longhorn.yaml")
}

resource "kubectl_manifest" "longhorn" {
    depends_on = [
        data.kubectl_file_documents.longhorn,
        kubernetes_namespace.longhorn,
    ]

    count     = length(data.kubectl_file_documents.longhorn.documents)
    yaml_body = element(data.kubectl_file_documents.longhorn.documents, count.index)
}

##
## ArgoCD
##
data "kubectl_file_documents" "argocd" {
    # Version: v2.4.0-rc1
    content = file("${path.module}/manifests/argocd.yaml")
}

resource "kubectl_manifest" "argocd" {
    depends_on = [
        data.kubectl_file_documents.argocd,
        kubernetes_namespace.argocd,
    ]

    override_namespace = "argocd"

    count     = length(data.kubectl_file_documents.argocd.documents)
    yaml_body = element(data.kubectl_file_documents.argocd.documents, count.index)
}
