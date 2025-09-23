local function getProblemName()
  return string.gmatch(vim.fn.getline(1), "// https://open.kattis.com/problems/(%w+)")()
end

local function getCleanFileName()
  return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t:r")
end

local function getBufferContent()
  local content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
  return table.concat(content, "\n")
end

local function gimmeMyCookie()
  local cookieDat = vim.system({ "bash", "-c", "~/.config/nvim/lua/cookie.sh ~/.mozilla/firefox/*default*/cookies.sqlite" }):wait().stdout
  if not cookieDat then
    print("couldn't get cookie data")
    return
  end
  local fd, path = vim.uv.fs_mkstemp("/tmp/XXXXXX")
  if not fd then
    print("couldn't get temp file")
    return
  end

  vim.uv.fs_write(fd, cookieDat)

  return path
end

local function test(opts)
  local case = opts.fargs[1] or "1"

  local problemName = getProblemName()

  if not problemName then
    print("incorrectly formatted file!")
    return
  end

  local sampName = vim.fn.expand("$HOME/.local/state/nvim/kattis/" .. problemName)
  vim.system({ "mkdir", "-p", sampName }):wait()
  if not vim.uv.fs_stat(sampName .. "/samples.zip") then
    print("fetching samples...")
    vim.system({ "curl", "https://open.kattis.com/problems/" .. problemName .. "/file/statement/samples.zip", "-o",
      sampName .. "/samples.zip" }):wait()
    vim.system({ "unzip", sampName .. "/samples.zip", "-d", sampName }):wait()
  end

  local in_ = vim.system({ "cat", vim.fn.glob(sampName .. "/*" .. case .. ".in") },
    { text = true }):wait().stdout
  local ans = vim.system({ "cat", vim.fn.glob(sampName .. "/*" .. case .. ".ans") },
    { text = true }):wait().stdout

  local fileName = getCleanFileName()

  print("compiling...")
  vim.system({ "javac", fileName .. ".java" }):wait()
  print("running...")
  local t = vim.system({ "java", fileName }, { stdin = true, text = true })
  t:write(in_)
  local tAns = t:wait()

  vim.uv.fs_unlink(fileName .. ".class")

  for name in vim.iter(vim.fn.glob(fileName .. "\\$*.class", nil, true)) do
    vim.uv.fs_unlink(name)
  end

  if string.len(tAns.stderr) ~= 0 then
    print("testa erroreda outa: " .. tAns.stderr)
    return
  end

  if ans == tAns.stdout then
    print("testa pasta successfullay")
    return
  else
    print("testa not pasta. input:\n" .. in_ .. "expected:\n" .. ans .. "got:\n" .. tAns.stdout)
  end
end

local function submit()
  local pname = getProblemName()
  local submitURL = "https://open.kattis.com/problems/" .. pname .. "/submit"
  local name = getCleanFileName()
  local payload = vim.fn.json_encode({
    files = {
      {
        filename = name .. ".java",
        code = getBufferContent(),
        id = 0,
        session = vim.v.null,
      }
    },
    language = "Java",
    mainclass = name,
    problem = pname,
  })
  local chatAmICookiedSixSeven = gimmeMyCookie()
  if not chatAmICookiedSixSeven then
    print("couldn't get cookies")
    return
  end
  local res = vim.fn.json_decode(vim.system({
      "curl", "-H", "Content-Type: application/json", "--cookie", chatAmICookiedSixSeven, "--request", "POST", "--data", payload,
      submitURL })
    :wait().stdout)
  vim.uv.fs_unlink(chatAmICookiedSixSeven)
  if res.success then
    vim.ui.open("https://open.kattis.com" .. res.success_url)
  else
    print("unsuccessful =(")
  end
end

vim.api.nvim_create_user_command("KattisTest", test, { nargs = '?' })
vim.api.nvim_create_user_command("KattisSubmit", submit, {})
