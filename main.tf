terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.4.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.7.1"
    }
  }
}

data "terraform_remote_state" "k8s_user_pki" {
  backend = "remote"

  count = (length(var.k8s_client_certificate) > 0 && length(var.k8s_client_key) > 0 && length(var.k8s_cluster_ca_cert) > 0) ? 0 : 1

  config = {
    organization = "McSwainHomeNetwork"
    workspaces = {
      name = "k8s-user-pki"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = var.k8s_host
    client_certificate     = length(var.k8s_client_certificate) > 0 ? var.k8s_client_certificate : data.terraform_remote_state.k8s_user_pki[0].outputs.ci_user_cert_pem
    client_key             = length(var.k8s_client_key) > 0 ? var.k8s_client_key : data.terraform_remote_state.k8s_user_pki[0].outputs.ci_user_key_pem
    cluster_ca_certificate = length(var.k8s_cluster_ca_cert) > 0 ? var.k8s_cluster_ca_cert : data.terraform_remote_state.k8s_user_pki[0].outputs.ca_cert_pem
  }
}

provider "kubernetes" {
  host                   = var.k8s_host
  client_certificate     = length(var.k8s_client_certificate) > 0 ? var.k8s_client_certificate : data.terraform_remote_state.k8s_user_pki[0].outputs.ci_user_cert_pem
  client_key             = length(var.k8s_client_key) > 0 ? var.k8s_client_key : data.terraform_remote_state.k8s_user_pki[0].outputs.ci_user_key_pem
  cluster_ca_certificate = length(var.k8s_cluster_ca_cert) > 0 ? var.k8s_cluster_ca_cert : data.terraform_remote_state.k8s_user_pki[0].outputs.ca_cert_pem
}

resource "helm_release" "oauth2_proxy" {
  name       = "oauth2-proxy"
  repository = "https://usa-reddragon.github.io/helm-charts"
  chart      = "app"
  version    = "0.1.7"
  namespace = "keycloak"

  set {
    name  = "image.repository"
    value = "quay.io/oauth2-proxy/oauth2-proxy"
    type  = "string"
  }

  set {
    name  = "image.tag"
    value = "latest"
    type  = "string"
  }

  set {
    name  = "ingress.hosts[0].host"
    value = "auth.mcswain.dev"
    type  = "string"
  }

  set {
    name  = "ingress.hosts[0].paths[0].port"
    value = "4180"
  }

  set {
    name  = "ingress.hosts[0].paths[0].path"
    value = "/"
    type  = "string"
  }

  set {
    name  = "ingress.hosts[0].paths[0].pathType"
    value = "Prefix"
    type  = "string"
  }

  set {
    name  = "ingress.tls[0].secretName"
    value = "auth-mcswain-dev-tls"
    type  = "string"
  }

  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "auth.mcswain.dev"
    type  = "string"
  }

  set {
    name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
    type  = "string"
  }

  set {
    name  = "ingress.annotations.kubernetes\\.io/tls-acme"
    value = "true"
    type  = "string"
  }

  set {
    name  = "ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = "cloudflare"
    type  = "string"
  }

  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/ssl-redirect"
    value = "true"
    type  = "string"
  }

  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/proxy-buffer-size"
    value = "8k"
    type  = "string"
  }

  set {
    name  = "service.ports[0].name"
    value = "http"
    type  = "string"
  }

  set {
    name  = "service.ports[0].port"
    value = "4180"
  }

  set {
    name  = "env[0].name"
    value = "OAUTH2_PROXY_PROVIDER"
    type  = "string"
  }

  set {
    name  = "env[0].value"
    value = "keycloak-oidc"
    type  = "string"
  }

  set {
    name  = "env[1].name"
    value = "OAUTH2_PROXY_OIDC_ISSUER_URL"
    type  = "string"
  }

  set {
    name  = "env[1].value"
    value = "https://keycloak.mcswain.dev/auth/realms/network"
    type  = "string"
  }

  set {
    name  = "env[2].name"
    value = "OAUTH2_PROXY_COOKIE_SECURE"
    type  = "string"
  }

  set {
    name  = "env[2].value"
    value = "true"
    type  = "string"
  }

  set {
    name  = "env[3].name"
    value = "OAUTH2_PROXY_COOKIE_DOMAINS"
    type  = "string"
  }

  set {
    name  = "env[3].value"
    value = ".mcswain.dev"
    type  = "string"
  }

  set {
    name  = "env[4].name"
    value = "OAUTH2_PROXY_WHITELIST_DOMAINS"
    type  = "string"
  }

  set {
    name  = "env[4].value"
    value = ".mcswain.dev"
    type  = "string"
  }

  set {
    name  = "env[5].name"
    value = "OAUTH2_PROXY_EMAIL_DOMAINS"
    type  = "string"
  }

  set {
    name  = "env[5].value"
    value = "mcswain.dev"
    type  = "string"
  }

  set {
    name  = "env[6].name"
    value = "OAUTH2_PROXY_UPSTREAM"
    type  = "string"
  }

  set {
    name  = "env[6].value"
    value = "file:///dev/null"
    type  = "string"
  }

  set {
    name  = "env[7].name"
    value = "OAUTH2_PROXY_HTTP_ADDRESS"
    type  = "string"
  }

  set {
    name  = "env[7].value"
    value = "0.0.0.0:4180"
    type  = "string"
  }

  set {
    name  = "env[8].name"
    value = "OAUTH2_PROXY_REDIS_CONNECTION_URL"
    type  = "string"
  }

  set {
    name  = "env[8].value"
    value = "redis://redis-app.redis.svc.cluster.local"
    type  = "string"
  }

  set {
    name  = "env[9].name"
    value = "OAUTH2_PROXY_CLIENT_ID"
    type  = "string"
  }

  set {
    name  = "env[9].value"
    value = "auth"
    type  = "string"
  }

  set {
    name  = "env[10].name"
    value = "OAUTH2_PROXY_CLIENT_SECRET"
    type  = "string"
  }

  set {
    name  = "env[10].valueFrom.secretKeyRef.name"
    value = "oauth2-proxy-creds"
    type  = "string"
  }

  set {
    name  = "env[10].valueFrom.secretKeyRef.key"
    value = "client-secret"
    type  = "string"
  }

  set {
    name  = "env[11].name"
    value = "OAUTH2_PROXY_COOKIE_SECRET"
    type  = "string"
  }

  set {
    name  = "env[11].valueFrom.secretKeyRef.name"
    value = "oauth2-proxy-creds"
    type  = "string"
  }

  set {
    name  = "env[11].valueFrom.secretKeyRef.key"
    value = "cookie-secret"
    type  = "string"
  }

  set {
    name  = "env[12].name"
    value = "OAUTH2_PROXY_REDIRECT_URL"
    type  = "string"
  }

  set {
    name  = "env[12].value"
    value = "https://auth.mcswain.dev/oauth2/callback"
    type  = "string"
  }

  set {
    name  = "env[13].name"
    value = "OAUTH2_PROXY_SESSION_STORE_TYPE"
    type  = "string"
  }

  set {
    name  = "env[13].value"
    value = "redis"
    type  = "string"
  }

  set {
    name  = "secrets[0].name"
    value = "oauth2-proxy-creds"
    type  = "string"
  }

  set {
    name  = "secrets[0].data.cookie-secret"
    value = var.oauth_proxy_cookie_secret
    type  = "string"
  }

  set {
    name  = "secrets[0].data.client-secret"
    value = var.oauth_proxy_client_secret
    type  = "string"
  }

}
