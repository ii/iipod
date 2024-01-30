resource "template_dir" "persistent" {
  source_dir      = "${path.module}/persistent_manifests"
  destination_dir = "${path.cwd}/persistent"
  vars = {
    namespace    = local.namespace
    coder_domain = var.coder_domain
    username     = local.username
    spacename    = local.spacename
  }
}

resource "template_dir" "ephemeral" {
  source_dir      = "${path.module}/ephemeral_manifests"
  destination_dir = "${path.cwd}/ephemeral"
  vars = {
    namespace    = local.namespace
    coder_domain = var.coder_domain
    username     = local.username
    spacename    = local.spacename
  }
}

# TODO look at https://registry.terraform.io/providers/kbst/kustomization/latest/docs/resources/resource
resource "null_resource" "namespace" {
  depends_on = [
    template_dir.persistent,
    template_dir.ephemeral
  ]
  # We want a per user domain USERNAME.DOMAIN.COM
  # We provision wildcard DNS01 certs for *.USERNAME.DOMAIN.COM
  #                         and *.WORKSPACE.USERNAME.DOMAIN.COM
  provisioner "local-exec" {
    quiet = true
    command = <<COMMAND
curl -L -s \
  -H 'X-API-Key: ${var.pdns_api_key}' -H 'Content-Type: application/json' \
  -D - \
  -d '${templatefile("./create_domain.tpl.json", {
    DOMAIN = "${local.user_domain}.",
    NS1    = "ns.ii.nz",
    NS2    = "ns2.ii.nz",
    ACCOUNTNAME : "${var.pdns_account}",
    KEYNAME : "${var.dns_update_keyname}",
    INGRESS_IP : "${var.ingress_ip}"
})}' ${var.pdns_api_url}/api/v1/servers/localhost/zones
COMMAND
}
provisioner "local-exec" {
  quiet   = true
  command = <<COMMAND
curl -L -s \
  -H 'X-API-Key: ${var.pdns_api_key}' -H 'Content-Type: application/json' \
  -D - \
  -d '{"kind": "TSIG-ALLOW-DNSUPDATE", "metadata": ["${var.dns_update_keyname}"]}' \
  ${var.pdns_api_url}/api/v1/servers/localhost/zones/${local.user_domain}/metadata
COMMAND
}

##### this creates a DNS zone per namespace.... this isn't needed yet, but might be useful later on
provisioner "local-exec" {
  quiet = true
  command = <<COMMAND
curl -L -s \
  -H 'X-API-Key: ${var.pdns_api_key}' -H 'Content-Type: application/json' \
  -D - \
  -d '${templatefile("./create_domain.tpl.json", {
  DOMAIN = "${local.spacename}.${local.user_domain}.",
  NS1    = "ns.ii.nz",
  NS2    = "ns2.ii.nz",
  ACCOUNTNAME : "${var.pdns_account}",
  KEYNAME : "${var.dns_update_keyname}",
  INGRESS_IP : "${var.ingress_ip}"
})}' ${var.pdns_api_url}/api/v1/servers/localhost/zones
COMMAND
}
provisioner "local-exec" {
  quiet   = true
  command = <<COMMAND
curl -L -s \
  -H 'X-API-Key: ${var.pdns_api_key}' -H 'Content-Type: application/json' \
  -D - \
  -d '{"kind": "TSIG-ALLOW-DNSUPDATE", "metadata": ["${var.dns_update_keyname}"]}' \
  ${var.pdns_api_url}/api/v1/servers/localhost/zones/${local.spacename}.${local.user_domain}/metadata
COMMAND
}
# I want to apply a bunch of manifests at once
# HELP WANTED to find a better way
provisioner "local-exec" {
  command = <<COMMAND
../../kubectl version --client || (
  echo installing kubectl:
  curl -s -L https://dl.k8s.io/release/v1.29.1/bin/linux/amd64/kubectl -o ../../kubectl \
  && chmod +x ../../kubectl
)
COMMAND
}
# HELP WANTED to find a better way
# ensure jq is available
provisioner "local-exec" {
  command = <<COMMAND
../../jq --version || (
  echo installing jq:
  curl -s -L https://github.com/jqlang/jq/releases/download/jq-1.6/jq-linux64 -o ../../jq \
  && chmod +x ../../jq
)
COMMAND
}
# We have manifests to create the namespace and persist a few things
provisioner "local-exec" {
  # unsure the user has a namespace
  command = "../../kubectl create ns ${local.namespace} || true"
}
# We have manifests to create the namespace and persist a few things
provisioner "local-exec" {
  # - the main *.user.DOMAIN cert
  command = "../../kubectl apply -f persistent"
}
# We have manifests to create the namespace
provisioner "local-exec" {
  command = "../../kubectl apply -f ephemeral"
}
# On the way down, just want to use kubectl to remove the epherical k8s objects
provisioner "local-exec" {
  when    = destroy
  command = <<COMMAND
../../kubectl version --client || (
  echo installing kubectl:
  curl -s -L https://dl.k8s.io/release/v1.29.1/bin/linux/amd64/kubectl -o ../../kubectl \
  && chmod +x ../../kubectl
)
COMMAND
}
provisioner "local-exec" {
  when    = destroy
  command = <<COMMAND
../../jq --version || (
  echo installing jq:
  curl -s -L https://github.com/jqlang/jq/releases/download/jq-1.6/jq-linux64 -o ../../jq \
  && chmod +x ../../jq
)
COMMAND
}
# We have manifests to create the namespace
provisioner "local-exec" {
  when = destroy
  # Destroy provisioners can't depend on anything els
  # But we just want to delete ephemeral resources
  # while retaining our namespace and certs
  command = <<COMMAND
  # This won't work because the template_dir output does not exist
  # ../../kubectl delete -f ephemeral
  # So we delete specific objects with spacename=$SPACENAME label
  SPACENAME=$(cat terraform.tfstate  | ../../jq -r '.resources[0].instances[0].attributes.name')
  OWNER=$(cat terraform.tfstate  | ../../jq -r '.resources[0].instances[0].attributes.owner')
  ../../kubectl delete -n $OWNER svc,deployments,ingress -l spacename=$SPACENAME
COMMAND
}
# We could also deloy logstream-kube to show the pod coming up...
provisioner "local-exec" {
  command = <<COMMAND
~/helm version --short || (
  echo installing helm:
  curl -L https://get.helm.sh/helm-v3.12.1-linux-amd64.tar.gz | tar xvz --strip-components=1 \
  && mv helm ~/helm \
  && chmod +x ~/helm
)
COMMAND
}
# provisioner "local-exec" {
#   command = "~/kubectl -n ${local.namespace} apply -f ${path.module}/manifests/admin-sa.yaml"
# }
provisioner "local-exec" {
  command = <<COMMAND
~/helm upgrade --install \
  --repo https://helm.coder.com/logstream-kube \
  --namespace ${local.namespace} \
  --set url=${var.coder_url} \
  coder-logstream-kube coder-logstream-kube
COMMAND
}
}
resource "coder_metadata" "namespace" {
  resource_id = null_resource.namespace.id
  count       = data.coder_workspace.ii.start_count
  icon        = "/icon/k8s.png"
  # hide        = true
}
