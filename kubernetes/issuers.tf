resource "kubectl_manifest" "letsencrypt_issuer" {
  yaml_body  = <<-EOF
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
        name: letsencrypt-prod
    spec:
        acme:
            server: https://acme-v02.api.letsencrypt.org/directory
            email: rjvdelst+letsencrypt@gmail.com
            privateKeySecretRef:
                name: letsencrypt-prod
            solvers:
                - http01:
                    ingress:
                        class: nginx
                        podTemplate:
                            spec:
                                nodeSelector:
                                    "kubernetes.io/os": linux
    EOF
}