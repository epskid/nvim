require("kattis")

local function runMono()
  local tmp, err = vim.uv.fs_mkdtemp("/tmp/rm.XXXXXX")
  if not tmp then
    print("error: " + err)
    return
  end
  local fName = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t:r")
  vim.system({ "javac", "-d", tmp, fName .. ".java" }):wait()
  local newBuf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_current_buf(newBuf)
  vim.fn.jobstart({"java", "-classpath", tmp, fName}, {
    term = true,
    on_exit = function(_, _, _)
      vim.uv.fs_rmdir(tmp)
    end
  })
end

vim.keymap.set("n", "<leader>jr", runMono)
vim.keymap.set("n", "<leader>kt", "<Cmd>KattisTest<CR>")
vim.keymap.set("n", "<leader>ks", "<Cmd>KattisSubmit<CR>")
