resource "tls_private_key" "private_key" {
    algorithm = "RSA"
}

resource "acme_registration" "registration" {
    account_key_pem = tls_private_key.private_key.private_key_pem
    email_address   = "rjvdelst@gmail.com"
}

resource "random_password" "cert" {
    length  = 24
    special = true
}

resource "acme_certificate" "certificate" {
    depends_on = [
        acme_registration.registration
    ]

    account_key_pem          = acme_registration.registration.account_key_pem
    certificate_p12_password = random_password.cert.result
    
    common_name = "*.robert-jan.me"

    dns_challenge {
        provider = "transip"

        config = {
            TRANSIP_ACCOUNT_NAME     = var.transip_account
            TRANSIP_PRIVATE_KEY_PATH = var.transip_key_path
            TRANSIP_TTL              = 60
        }
    }
}