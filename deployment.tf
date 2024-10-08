resource "coder_metadata" "iipod" {
  resource_id = kubernetes_deployment.iipod[0].id
  count       = data.coder_workspace.ii.start_count
  icon        = "/icon/k8s.png"
  # item {
  #   key   = "ssh"
  #   value = "ssh -tA ii@${powerdns_record.a_record.name} kubectl exec -ti iipod-0 -- tmux at"
  # }
  # item {
  #   key   = "kubexec"
  #   value = "export KUBECONFIG=$(mktemp) ; scp ii@${powerdns_record.a_record.name}:.kube/config $KUBECONFIG ; kubectl exec -ti iipod-0 -- tmux at"
  # }
  # item {
  #   key   = "ssh"
  #   value = "ssh -tA ii@${powerdns_record.a_record.name} kubectl exec -ti iipod-0 -- tmux at"
  # }
  # These can now be markdown : https://github.com/coder/coder/pull/10521
  # but apparently only a limited set of markdown/html
  #       allowedElements={["p", "em", "strong", "a", "pre", "code"]}
  # https://github.com/coder/coder/pull/10521/files#diff-cbc535e52cef85ed2f3d7ec9ba042a35c692c7bb50a6077d9df1dd0e6d14a752R147
  item {
    key   = "emacs"
    value = "[emacs-${local.space_domain}](https://emacs-${local.space_domain}/)"
  }
  item {
    key   = "tmux"
    value = "[tmux-${local.space_domain}](https://tmux-${local.space_domain}/)"
  }
  item {
    key   = "vnc"
    value = "[vnc-${local.space_domain}](https://vnc-${local.space_domain}/?autoconnect=true&resize=remote)"
  }
  item {
    key   = "www"
    value = "[www-${local.space_domain}](https://tmux-${local.space_domain}/)"
  }
}

resource "kubernetes_deployment" "iipod" {
  wait_for_rollout = false # For use with https://github.com/coder/coder-logstream-kube
  count            = data.coder_workspace.ii.transition == "start" ? 1 : 0
  metadata {
    name = "iipod-${local.spacename}"
    # namespace = "spaces" #var.namespace
    # namespace = "coder" #var.namespace
    # namespace = "${data.coder_workspace.ii.name}-${data.coder_workspace.ii.owner}"
    namespace = local.namespace
    # namespace = "coder" #var.namespace
    labels = {
      "spacename" : local.spacename
      "spaceapp" : "iipod"
      "app.kubernetes.io/name"     = "coder-workspace"
      "app.kubernetes.io/instance" = "coder-workspace-${lower(data.coder_workspace.ii.owner)}-${lower(data.coder_workspace.ii.name)}"
      "app.kubernetes.io/part-of"  = "coder"
      "com.coder.resource"         = "true"
      "com.coder.workspace.id"     = data.coder_workspace.ii.id
      "com.coder.workspace.name"   = data.coder_workspace.ii.name
      "com.coder.user.id"          = data.coder_workspace.ii.owner_id
      "com.coder.user.username"    = data.coder_workspace.ii.owner
    }
    annotations = {
      "com.coder.user.email" = data.coder_workspace.ii.owner_email
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        spacename                = local.spacename
        "app.kubernetes.io/name" = "coder-workspace"
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          "spacename" : local.spacename
          "spaceapp" : "iipod"
          "app.kubernetes.io/name" = "coder-workspace"
        }
      }
      spec {
        # looks nicer than iipod-tues511-38a8euw3-3t3e8e83s
        hostname             = local.spacename
        service_account_name = "admin"
        security_context {
          run_as_user = "1001"
          fs_group    = "1001"
        }
        container {
          name    = "iipod"
          image   = data.coder_parameter.container-image.value
          command = ["sh", "-c", coder_agent.iipod.init_script]
          security_context {
            run_as_user = "1001"
          }
          resources {
            requests = {
              # "cpu"    = "250m"
              # "memory" = "512Mi"
              "cpu"    = "${var.container_resource_cpu / 2}"
              "memory" = "${var.container_resource_memory / 2}Gi"
            }
            limits = {
              "cpu"    = var.container_resource_cpu
              "memory" = "${var.container_resource_memory}Gi"
            }
          }
          env {
            name  = "CODER_AGENT_TOKEN"
            value = coder_agent.iipod.token
          }
          env {
            name  = "SPACENAME"
            value = local.spacename
          }
        }
      }
    }
  }
  depends_on = [
    null_resource.namespace
    # kubernetes_namespace.space,
    # kubernetes_role.space-admin,
    # kubernetes_role_binding.space-admin,
    # kubernetes_service_account.space-admin
  ]
}
