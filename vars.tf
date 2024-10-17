data "coder_provisioner" "ii" {
}

data "coder_workspace" "ii" {
}

# Warning: Deprecated Resource
# on vars.tf line 7, in data "coder_git_auth" "github":
# data "coder_git_auth" "github" {
#   # Matches the ID of the git auth provider in Coder.
#   id = "github"
# }

# data "coder_external_auth" "github" {
#   id = "github"
# }

# Can be set via TF_VAR_variable_name in the coder process ENV
# But can also be set via a file similar var/space.sharing.io.yaml
# And deployed with coder template push --variables-file ./vars/space.sharing.io.yaml or similar

locals {
  username          = lower(data.coder_workspace.ii.owner)
  namespace         = lower(data.coder_workspace.ii.owner)
  spacename         = lower(data.coder_workspace.ii.name)
  user_domain       = "${local.namespace}.${var.coder_domain}"
  space_domain      = "${local.spacename}.${local.user_domain}"
  iipod_agent_init  = coder_agent.iipod.init_script
  iipod_agent_token = coder_agent.iipod.token
  # public_ip         = var.public_ip
  # coder_url         = var.coder_url
  # metal_ip          = equinix_metal_device.iibox.access_public_ipv4
  # iibox_agent_init  = coder_agent.iibox.init_script
  # iibox_agent_token = coder_agent.iibox.token
}

variable "coder_url" {
  type        = string
  description = "URL you login into coder with"
  nullable    = false
  validation {
    condition     = can(regex("(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]", var.coder_url))
    error_message = "Invalid input, must include a valid domain name."
  }
}

variable "coder_domain" {
  type        = string
  description = "Domain to create NS records and TLS certs within as USER.$${coder_domain}"
  nullable    = false
  validation {
    condition     = can(regex("(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]", var.coder_domain))
    error_message = "Invalid input, must be a valid domain name."
  }
}

variable "openai_api_token" {
  type        = string
  description = "OpenAI API Token"
  # default     = "example.com"
  nullable = true
}

variable "pdns_api_key" {
  type        = string
  description = "PowerDNS API Key for Powerdns Domain Creation"
  # default     = "example.com"
  nullable = false
}

variable "pdns_api_url" {
  type        = string
  description = "PowerDNS API URL for Powerdns Domain Creation"
  # default     = "https://pdns.ii.nz/"
  nullable = false
}

# variable "dns_update_account" {
#   type        = string
#   description = "PowerDNS Account to associate user domain to"
#   nullable    = false
# }

variable "dns_update_server" {
  type        = string
  description = "Nameserver for RFC2136 Updates"
  # default     = "123.253.176.253"
  nullable = false
  validation {
    condition     = can(regex("(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]", var.dns_update_server))
    error_message = "Invalid input, must be a valid domain name."
  }
}

variable "dns_update_keyname" {
  type        = string
  description = "TSIG Key Name for RFC2136 Updates"
  nullable    = false
}

variable "dns_update_keyalgorithm" {
  type        = string
  description = "TSIG Algorithm for RFC2136 Updates"
  nullable    = false
  # default     = "hmac-sha256"
}

variable "dns_update_keysecret" {
  type        = string
  description = "TSIG Key Secret for RFC2136 Updates"
  nullable    = false
  # sensitive   = true
}
variable "container_resource_cpu" {
  type        = number
  description = "the strict amount of CPU to provide"
  default     = "4"
  nullable    = false
  # sensitive   = true
}
variable "container_resource_memory" {
  type        = number
  description = "the strict amount of memory to provide in gigabytes"
  default     = "8"
  nullable    = false
  # sensitive   = true
}

variable "default_container_image" {
  type        = string
  description = "Default container image to use for the workspace"
  nullable    = false
  validation {
    condition = can(
      regex("(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]",
    var.default_container_image))
    error_message = "Invalid input, must contain a valid domain name."
  }
}

variable "default_git_url" {
  type        = string
  description = "Default container image to use for the workspace"
  nullable    = false
  validation {
    condition = can(
      regex("(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]",
    var.default_git_url))
    error_message = "Invalid input, must contain a valid domain name."
  }
}

variable "default_org_url" {
  type        = string
  description = "Default container image to use for the workspace"
  nullable    = false
  validation {
    condition = can(
      regex("(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]",
    var.default_org_url))
    error_message = "Invalid input, must contain a valid domain name."
  }
}

# variable "ingress_ip" {
#   type        = string
#   description = "Local LB IP"
#   nullable    = false
#   validation {
#     condition     = can(cidrhost("${var.ingress_ip}/32", 0))
#     error_message = "Must be valid IP Address"
#   }

# }
variable "public_ip" {
  type        = string
  description = "Public IP"
  nullable    = false
  validation {
    condition     = can(cidrhost("${var.public_ip}/32", 0))
    error_message = "Must be valid IP Address"
  }
}
