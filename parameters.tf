# I'd like to be able to turn off/on DNS+TLS
# as necessary to speed deployment when iterating
# data "coder_parameter" "dns" {
#   name         = "dns"
#   display_name = "dns"
#   description  = "Create a DNS wildcard + TLS Certificate (adds 30-40 seconds)"
#   default      = true
#   type         = "bool"
#   icon         = "https://github.com/cncf/artwork/blob/master/projects/coredns/icon/solid-color/coredns-icon-solid-color.png?raw=true"
#   # option {
#   #   name  = "True"
#   #   value = true
#   # }
#   # option {
#   #   name  = "False"
#   #   value = false
#   # }
# }

data "coder_parameter" "container-image" {
  name         = "container-image"
  display_name = "Container Image"
  description  = "The container image to use for the workspace"
  default      = var.default_container_image
  icon         = "https://raw.githubusercontent.com/matifali/logos/main/docker.svg"
}

data "coder_parameter" "git-url" {
  name         = "git-url"
  display_name = "Git URL"
  description  = "The Git URL to checkout for this workspace"
  default      = var.default_git_url
  # icon         = "https://raw.githubusercontent.com/matifali/logos/main/docker.svg"
}

data "coder_parameter" "org-url" {
  name         = "org-url"
  display_name = "Orgfile url"
  description  = "The Orgfile URL to load into emacs"
  default      = var.default_org_url
  # icon         = "https://raw.githubusercontent.com/matifali/logos/main/docker.svg"
}

data "coder_parameter" "cpu" {
  name         = "cpu"
  display_name = "CPU"
  description  = "The number of CPU cores"
  default      = "4"
  icon         = "/icon/memory.svg"
  mutable      = true
  option {
    name  = "4 Cores"
    value = "4"
  }
  option {
    name  = "8 Cores"
    value = "8"
  }
  option {
    name  = "16 Cores"
    value = "16"
  }
  option {
    name  = "32 Cores"
    value = "32"
  }
}

data "coder_parameter" "memory" {
  name         = "memory"
  display_name = "Memory"
  description  = "The amount of memory in GB"
  default      = "8"
  icon         = "/icon/memory.svg"
  mutable      = true
  option {
    name  = "8 GB"
    value = "8"
  }
  option {
    name  = "16 GB"
    value = "16"
  }
  option {
    name  = "32 GB"
    value = "32"
  }
  option {
    name  = "64 GB"
    value = "64"
  }
}
