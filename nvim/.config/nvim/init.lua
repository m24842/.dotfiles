-- General settings
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.updatetime = 400
vim.opt.guicursor:append("t-v:blinkon0")
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.VM_leader = ","
vim.g.VM_show_warnings = 0

-- Keymaps
vim.keymap.set("n", "<leader>/", ":let @+ = expand('%:p')<CR>", { desc = "Copy absolute file path" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
-- vim.keymap.set("n", "<leader>d", function() Snacks.dashboard() end, { desc = "Go to Dashboard" })
vim.keymap.set("n", "K", function()
    vim.lsp.buf.hover({ 
        border = "rounded",
        max_width = 80,
        max_height = 10,
    })
end, { desc = "Show docs" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
vim.keymap.set("n", "<D-S-L>", ":call vm#commands#find_all(0, 1)<CR>", { desc = "Select all matches" })
vim.keymap.set("n", "<C-S-L>", ":call vm#commands#find_all(0, 1)<CR>", { desc = "Select all matches" })

-- Terminal keymaps
vim.keymap.set("t", "<D-k>", [[<C-l>]], { noremap = true, silent = true, desc = "Clear terminal" })
vim.keymap.set("t", "<C-S-Up>", function() vim.cmd("resize +2") end, { desc = "Increase terminal height" })
vim.keymap.set("t", "<C-S-Down>", function() vim.cmd("resize -2") end, { desc = "Decrease terminal height" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { silent = true }, { desc = "Exit terminal mode" })

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        {
            "rose-pine/neovim",
            name = "rose-pine",
            priority = 1001,
            opts = {
                highlight_groups = {
                    SnacksDashboardHeader = { fg = "love", bold = true },
                    SnacksDashboardKey  = { fg = "love", bold = true },
                    SnacksDashboardFooter = { fg = "love", bold = true },
                },
            },
            config = function(_, opts)
                require("rose-pine").setup(opts)
                vim.cmd("colorscheme rose-pine")
            end
        },
        {
            "folke/snacks.nvim",
            priority = 1000,
            lazy = false,
            opts = {
                bigfile = { enabled = true },
                dashboard = {
                    enabled = true,
                    preset = {
                        header = [[
                                                                   
      ████ ██████           █████      ██                 btw
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████]],
                        keys = {
                            { icon = "", key = "f", desc = "find file", action = ":lua Snacks.dashboard.pick('files')", hidden = true },
                            { icon = "", key = "n", desc = "new file", action = ":ene | startinsert", hidden = true },
                            { icon = "", key = "g", desc = "grep text", action = ":lua Snacks.dashboard.pick('live_grep')", hidden = true },
                            { icon = "", key = "r", desc = "recent file", action = ":lua Snacks.dashboard.pick('oldfiles')", hidden = true },
                            { icon = "", key = "c", desc = "config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})", hidden = true },
                            { icon = "", key = "s", desc = "session", section = "session", hidden = true },
                            { icon = "", key = "L", desc= "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil, hidden = true },
                            { icon = "", key = "q", desc = "quit", action = ":qa", hidden = true  },
                        },
                    },
                    sections = {
                        { section = "header" },
                        {
                            align = "center",
                            padding = 1,
                            text = {
                                { "  Update ", hl = "@property" },
                                { "  Sessions ", hl = "@variable.builtin" },
                                { "  Last Session ", hl = "@property" },
                                { "  Files ", hl = "@variable.builtin" },
                                { "  Recent ", hl = "@property" },
                            },
                        },
                        {
                            text = {
                                { "󰏓 ", hl = "@variable.builtin" },
                                { "Projects", hl = "@variable.builtin" },
                            },
                        },
                        { section = "projects", indent = 2, padding = 1 },
                        {
                            text = {
                                { " ", hl = "@variable.builtin" },
                                { "Recent Files", hl = "@variable.builtin" },
                            },
                        },
                        { section = "recent_files", indent = 2, padding = 1 },
                        { section = "startup", icon = " ", padding = 1 },
                        { section = "keys" },
                    },
                },
                explorer = {
                    replace_netrw = true,
                    trash = true,
                },
                picker = {
                    enabled = true,
                    exclude = {
                        "**/.venv/**",
                        "**/__pycache__/**",
                        "**/.git/**",
                        "**/.DS_Store",
                    },
                    sources = {
                        explorer = {
                            hidden = true,
                            ignored = true,
                            exclude = {
                                "**/__pycache__",
                                "**/.git",
                                "**/.DS_Store",
                            },
                        },
                        files = {
                            hidden = true,
                            ignored = true,
                        },
                        grep = {
                            hidden = true,
                            ignored = true,
                        },
                    }
                },
                image = { backend = "kitty" },
                indent = { enabled = true },
                input = { enabled = true },
                notifier = { enabled = true },
                quickfile = { enabled = true },
                scope = { enabled = true },
                scroll = { enabled = true },
                statuscolumn = { enabled = true },
                words = { enabled = true },
            },
            keys = {
                { "<D-/>", function() Snacks.explorer() end, desc = "File Explorer" },
                { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
                { "<leader>fg", function() Snacks.picker.grep() end, desc = "Live Grep" },
                { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
                { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
                { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
                { "<leader>fl", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
            },
        },
        {
            "romus204/tree-sitter-manager.nvim",
            opts = {
                prefer_git = true,
                ensure_installed = {
                    "bash",
                    "c",
                    "cpp",
                    "css",
                    "dockerfile",
                    "go",
                    "html",
                    "javascript",
                    "json",
                    "lua",
                    "markdown",
                    "python",
                    "rust",
                    "sql",
                    "toml",
                    "typescript",
                    "vim",
                },
                auto_install = true,
                highlight = true,
            },
        },
        {
            "windwp/nvim-autopairs",
            event = "InsertEnter",
            config = true
        },
        {
            "folke/which-key.nvim",
            event = "VeryLazy",
            opts = {},
            keys = {
                {
                    "<leader>?",
                    function()
                        require("which-key").show({ global = false })
                    end,
                    desc = "Buffer Local Keymaps (which-key)",
                },
            },
        },
        {
            "akinsho/toggleterm.nvim",
            version = "*",
            config = true,
            opts = {
                size = 14,
                open_mapping = [[<D-\>]],
                hide_numbers = true,
                shade_terminals = true,
                shading_factor = 50,
                start_in_insert = true,
                insert_mappings = true,
                terminal_mappings = true,
                persist_size = true,
                direction = "horizontal",
                close_on_exit = true,
                shell = vim.o.shell,
                autochdir = true,
            },
        },
        {
            "williamboman/mason.nvim",
            config = true
        },
        {
            "neovim/nvim-lspconfig",
            dependencies = { "williamboman/mason-lspconfig.nvim", "saghen/blink.cmp" },
            config = function()
                vim.api.nvim_create_autocmd("LspAttach", {
                    callback = function(args)
                        local opts = { buffer = args.buf, silent = true }

                        opts.desc = "Go to Definition"
                        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                        
                        opts.desc = "Go to Declaration"
                        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                    end,
                })
                
                vim.lsp.config("*", {
                    capabilities = require("blink.cmp").get_lsp_capabilities(),
                })

                vim.lsp.config("basedpyright", {
                    cmd_env = {
                        NODE_OPTIONS = "--max-old-space-size=4096"
                    },
                    root_markers = {
                        ".git",
                    },
                    settings = {
                        basedpyright = {
                            analysis = {
                                useLibraryCodeForTypes = true,
                                diagnosticMode = "workspace",
                                exclude = {
                                    "**/node_modules",
                                    "**/__pycache__",
                                    "**/.venv",
                                    "**/venv",
                                    "**/.git"
                                },
                            }
                        }
                    }
                })

                vim.lsp.config("lua_ls", {})
                vim.lsp.config("ts_ls", {})
                vim.lsp.config("clangd", {})

                require("mason-lspconfig").setup({
                    ensure_installed = { "lua_ls", "basedpyright", "ts_ls", "clangd" },
                })
            end
        },
        {
            "zbirenbaum/copilot.lua",
            cmd = "Copilot",
            event = "InsertEnter",
            opts = {
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    debounce = 75,
                    keymap = {
                        accept = false,
                        next = false,
                        prev = false,
                        dismiss = false,
                    },
                },
                panel = { enabled = false },
                server_opts_overrides = {
                    trace = "off",
                    settings = {
                        advanced = {
                            indexingEnabled = false, 
                        }
                    }
                }
            },
            config = function(_, opts)
                require("copilot").setup(opts)
                local suggestion = require("copilot.suggestion")
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { silent = true, desc = "Copilot: " .. desc })
                end
                map("i", "<D-l>", function() suggestion.accept() end, "Accept")
                map("i", "<M-l>", function() suggestion.accept() end, "Accept")
                map("i", "<M-]>", function() suggestion.next() end, "Next")
                map("i", "<M-[>", function() suggestion.prev() end, "Prev")
                map("i", "<C-]>", function() suggestion.dismiss() end, "Dismiss")
            end,
        },
        { "mg979/vim-visual-multi", branch = "master" },
        {
            "saghen/blink.cmp",
            version = "*",
            opts = {
                keymap = { preset = "default" },
                sources = {
                    default = { "lsp", "path", "snippets" },
                },
                completion = {
                    menu = { border = "rounded" },
                    documentation = { auto_show = true, window = { border = "rounded" } },
                },
                signature = { enabled = true, window = { border = "rounded" } },
            },
        },
    },
    checker = { enabled = true },
})

-- Treesitter buffer autocommand
vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

-- Diagnostic filter
vim.diagnostic.config({
    virtual_text = false,
    severity_sort = true,
    underline = {
        severity = vim.diagnostic.severity.ERROR,
    },
    signs = {
        severity = vim.diagnostic.severity.ERROR,
    },
})

-- Auto refresh file changes
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    pattern = "*",
    command = [[if mode() !~ '\v[vV^V]' && getcmdwintype() == '' | checktime | endif]],
})
