-- Config reload
rex.bind("ctrl+cmd+r", "client.config.reload")

-- Session rename
rex.bind("cmd+shift+r", "session.rename")

-- Tab navigation (cmd to avoid Tmux conflict)
rex.bind("cmd+shift+left", "client.tab.previous")
rex.bind("cmd+shift+right", "client.tab.next")

-- Pane navigation
rex.bind("ctrl+cmd+left", "pane.focus.left")
rex.bind("ctrl+cmd+right", "pane.focus.right")
rex.bind("ctrl+cmd+up", "pane.focus.up")
rex.bind("ctrl+cmd+down", "pane.focus.down")

-- Pane split
rex.bind("alt+cmd+left", "pane.split.left")
rex.bind("alt+cmd+right", "pane.split.right")
rex.bind("alt+cmd+up", "pane.split.up")
rex.bind("alt+cmd+down", "pane.split.down")

-- Pane resize
rex.bind("alt+h", "pane.resize", { amount = 2, direction = "left" })
rex.bind("alt+l", "pane.resize", { amount = 2, direction = "right" })
rex.bind("alt+k", "pane.resize", { amount = 2, direction = "up" })
rex.bind("alt+j", "pane.resize", { amount = 2, direction = "down" })

-- Unbind sidebar toggle (conflicts with Nvim file explorer toggle)
rex.unbind("cmd+/")

