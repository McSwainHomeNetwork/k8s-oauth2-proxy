variable "k8s_host" {
  type        = string
  description = "Address of the k8s host."
  sensitive   = true
}

variable "k8s_client_key" {
  type        = string
  default     = ""
  description = "Private key by which to auth with the k8s host."
  sensitive   = true
}

variable "k8s_cluster_ca_cert" {
  type        = string
  default     = ""
  description = "CA cert of the k8s host."
  sensitive   = true
}

variable "k8s_client_certificate" {
  type        = string
  default     = ""
  description = "CA cert of the k8s host."
  sensitive   = true
}

variable "oauth_proxy_cookie_secret" {
  type        = string
  description = "Oauth2-proxy Cookie secret"
  sensitive   = true
}

variable "oauth_proxy_client_secret" {
  type        = string
  description = "Oauth2-proxy OIDC client secret"
  sensitive   = true
}