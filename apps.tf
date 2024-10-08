# emacs
resource "coder_app" "Emacs" {
  subdomain    = true
  share        = "public"
  agent_id     = coder_agent.iipod.id
  slug         = "emacs"
  display_name = "Emacs"
  icon         = "https://upload.wikimedia.org/wikipedia/commons/0/08/EmacsIcon.svg" # let's maybe get an emacs.svg somehow
  url          = "http://localhost:8085"                                             # port 8080 + BROADWAY_DISPLAY
}

# ttyd
resource "coder_app" "left-tmux" {
  subdomain    = true
  share        = "public"
  slug         = "left-tmux"
  display_name = "left eye/tmux"
  icon         = "https://cdn.icon-icons.com/icons2/2148/PNG/512/tmux_icon_131831.png"
  agent_id     = coder_agent.iipod.id
  url          = "http://localhost:7680" # 7681 is the default ttyd port, which calls 'tmux at -s $SPACENAME'
}

# ttyd
resource "coder_app" "right-tmux" {
  subdomain    = true
  share        = "public"
  slug         = "right-tmux"
  display_name = "right eye/tmux"
  icon         = "https://cdn.icon-icons.com/icons2/2148/PNG/512/tmux_icon_131831.png"
  agent_id     = coder_agent.iipod.id
  url          = "http://localhost:7681" # 7681 is the default ttyd port, which calls 'tmux at -s $SPACENAME'
}

# vnc
resource "coder_app" "vnc" {
  subdomain    = true
  share        = "public"
  slug         = "vnc"
  display_name = "vnc"
  icon         = "/icon/novnc.svg"
  agent_id     = coder_agent.iipod.id
  url          = "http://localhost:6080?autoconnect=true&resize=remote" # 6080 port we chose for websockify
}

# web
resource "coder_app" "web" {
  subdomain    = true
  share        = "public"
  slug         = "web"
  display_name = "web"
  # icon         = "https://cdn.icon-icons.com/icons2/2148/PNG/512/tmux_icon_131831.png"
  agent_id = coder_agent.iipod.id
  url      = "http://localhost:8000" # port 8000 is the default 'python -m http.server' port
}

resource "coder_app" "code-server" {
  agent_id     = coder_agent.iipod.id
  slug         = "code-server"
  display_name = "code-server"
  # url          = "http://localhost:13337/?folder=/home/${local.username}"
  url       = "http://localhost:13337/?folder=/home/ii"
  icon      = "/icon/code.svg"
  subdomain = true
  share     = "public"
  # share     = "owner"

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 5
    threshold = 6
  }
}
