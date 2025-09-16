vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.winborder = "rounded"
vim.opt.signcolumn = "yes"
vim.opt.number = true
vim.opt.mouse = ""
vim.opt.cursorline = true

vim.g.mapleader = " "

vim.pack.add({
  -- the essentials
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/tpope/vim-surround",
  "https://github.com/tpope/vim-vinegar",
  "https://github.com/romainl/vim-cool",
  "https://github.com/ggandor/leap.nvim",

  -- treesitter
  "https://github.com/ellisonleao/gruvbox.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",

  -- language specific funcionality
  "https://github.com/mattn/emmet-vim",
  "https://github.com/chomosuke/typst-preview.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/neovim/nvim-lspconfig",
})

require("leap").set_default_mappings()

local function get_telescope()
  -- lazy load telescope
  vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-telescope/telescope.nvim",
  })
  require("telescope").setup()
  local telescope = require("telescope.builtin")
  return telescope
end
vim.keymap.set("n", "<leader>f", function()
  get_telescope().find_files()
end)
vim.keymap.set("n", "<leader>h", function()
  get_telescope().help_tags()
end)
vim.keymap.set("n", "<leader>F", function()
  get_telescope().live_grep()
end)

require("gruvbox").setup({ contrast = "soft" })
require("nvim-treesitter.configs").setup({
  ensure_installed = { "rust", "c", "lua", "python", "svelte", "typescript", "css", "typst" },
  sync_install = false,
  auto_install = false,
  ignore_install = {},
  highlight = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = false,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["as"] = "@local.scope"
      },
      include_surrounding_whitespace = true
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    }
  }
})

-- setup processing
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.pde",
  callback = function()
    vim.bo.filetype = "processing"
    vim.cmd("TSBufEnable highlight")
    vim.treesitter.start(0, "java")
  end
})

require("typst-preview").setup({
  open_cmd = "firefox %s -P typst-preview --class typst-preview",
  dependencies_bin = { ['tinymist'] = 'tinymist' }
})
require("mason").setup()
vim.lsp.enable({ "rust_analyzer", "clangd", "pyright", "lua_ls", "svelte", "jdtls", "tinymist" })
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.lsp.completion.enable(true, args.data.client_id, args.buf)

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
});
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true)
      },
      diagnostics = {
        disable = { "missing-fields" }
      }
    }
  }
})
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)

vim.keymap.set("n", "<leader>c", "1z=")

vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
  pattern = { "*" },
  callback = function()
    if vim.opt.buftype:get() == "terminal" then
      vim.cmd(":startinsert")
    end
  end
})

vim.keymap.set("n", "<leader>=", vim.cmd.split)
vim.keymap.set("n", "<leader>\\", vim.cmd.vsplit)

vim.keymap.set("n", "<leader>e", vim.cmd.Explore)

vim.keymap.set("n", "<leader>q", vim.cmd.bdelete)

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.cmd.colorscheme("gruvbox")
