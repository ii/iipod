resource "coder_agent" "iipod" {
  arch                    = data.coder_provisioner.ii.arch
  os                      = data.coder_provisioner.ii.os
  dir                     = "$HOME" # Could set to somewhere
  motd_file               = "/etc/motd"
  startup_script_behavior = "non-blocking" # blocking, non-blocking
  troubleshooting_url     = "http://ii.nz" # blocking, non-blocking
  connection_timeout      = 300
  startup_script          = file("./iipod-startup.sh")
  startup_script_timeout  = 300
  shutdown_script         = file("./iipod-shutdown.sh")
  shutdown_script_timeout = 300
  env = {
    # GITHUB_TOKEN = "$${data.coder_git_auth.github.access_token}"
    GITHUB_TOKEN = "${data.coder_external_auth.primary-github.access_token}"
    # Just a hidden feature for now to try out
    OPENAI_API_TOKEN    = "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"
    ORGFILE_URL         = "${data.coder_parameter.org-url.value}"
    SESSION_NAME        = "${lower(data.coder_workspace.ii.name)}"
    GIT_REPO            = "${data.coder_parameter.git-url.value}"
    SPACE_DOMAIN        = "${local.space_domain}"
    GIT_AUTHOR_NAME     = "${data.coder_workspace.ii.owner}"
    GIT_COMMITTER_NAME  = "${data.coder_workspace.ii.owner}"
    GIT_AUTHOR_EMAIL    = "${data.coder_workspace.ii.owner_email}"
    GIT_COMMITTER_EMAIL = "${data.coder_workspace.ii.owner_email}"
  }
  display_apps {
    port_forwarding_helper = true
    ssh_helper             = true
    vscode                 = true
    vscode_insiders        = true
    web_terminal           = true
  }
  # metadata {
  #   key          = "tmux-clients"
  #   display_name = "tmux clients"
  #   interval     = 5
  #   timeout      = 5
  #   script       = <<-EOT
  #     #!/bin/bash
  #     set -e
  #     tmux list-clients -F "#{client_session}:#{client_width}x#{client_height}" | xargs echo
  #   EOT
  # }
  # metadata {
  #   key          = "tmux-windows"
  #   display_name = "tmux windows"
  #   interval     = 5
  #   timeout      = 5
  #   script       = <<-EOT
  #     #!/bin/bash
  #     set -e
  #     tmux list-windows -F "#{window_index}:#{window_name}" | xargs echo
  #   EOT
  # }

  # The following metadata blocks are optional. They are used to display
  # information about your workspace in the dashboard. You can remove them
  # if you don't want to display any information.
  # For basic resources, you can use the `coder stat` command.
  # If you need more control, you can write your own script.
  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Home Disk"
    key          = "3_home_disk"
    script       = "coder stat disk --path $${HOME}"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "CPU Usage (Host)"
    key          = "4_cpu_usage_host"
    script       = "coder stat cpu --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Memory Usage (Host)"
    key          = "5_mem_usage_host"
    script       = "coder stat mem --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Load Average (Host)"
    key          = "6_load_host"
    # get load avg scaled by number of cores
    script   = <<EOT
      echo "`cat /proc/loadavg | awk '{ print $1 }'` `nproc`" | awk '{ printf "%0.2f", $1/$2 }'
    EOT
    interval = 60
    timeout  = 1
  }
}
