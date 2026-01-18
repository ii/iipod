# Claude Code Integration
# =======================
# Adds Claude Code AI agent to the workspace.
# Uses a shared OAuth token with optional user override.

# Template-level variable for shared OAuth token
variable "claude_oauth_token" {
  type        = string
  description = "Claude Code OAuth token (long-lived, shared across workspaces)"
  sensitive   = true
  default     = ""
}

# User-configurable parameter for custom token
data "coder_parameter" "claude_oauth_token" {
  name         = "claude_oauth_token"
  display_name = "Claude Code Token (optional)"
  description  = "Your own Claude OAuth token. Leave empty to use shared token."
  type         = "string"
  mutable      = true
  default      = ""
  order        = 50
}

# Resolve token: user-provided takes precedence, then template default
locals {
  claude_token = coalesce(
    data.coder_parameter.claude_oauth_token.value,
    var.claude_oauth_token
  )
}

# Claude Code module from Coder registry
module "claude-code" {
  count   = local.claude_token != "" ? 1 : 0
  source  = "registry.coder.com/modules/claude-code/coder"
  version = "1.2.1"

  agent_id = coder_agent.iipod.id
  folder   = "/home/coder"

  # Run in tmux for persistent background sessions
  experiment_use_tmux = true

  # Enable task reporting to Coder UI (requires Coder v2.21+)
  experiment_report_tasks = true
}
