local line1 = vim.api.nvim_call_function("getline", {1})
local problemName = string.gmatch(line1, "// https://open.kattis.com/problems/(%w+)")()

if problemName then
  local sampName = vim.fn.expand("$HOME/.local/state/nvim/kattis/" .. problemName)
  vim.system({"mkdir", "-p", sampName}):wait()
  if not vim.uv.fs_stat(sampName .. "/samples.zip") then
    print("fetching samples...")
    vim.system({"wget", "https://open.kattis.com/problems/" .. problemName .. "/file/statement/samples.zip", "-O", sampName .. "/samples.zip"}):wait()
    vim.system({"unzip", sampName .. "/samples.zip", "-d", sampName}):wait()
  end

  local outDir = problemName .. "JOUT"
  vim.o.makeprg = "bash -c \"javac " .. problemName .. ".java -d " .. outDir .. " && cd " .. outDir .. " && echo == input == && cat " .. sampName .. "/*1.in && echo == output == && (cat " .. sampName .. "/*1.in \\| java " .. "kattis/" .. problemName .. "); echo -e == expected output ==; cat " .. sampName .. "/*1.ans; cd .. && rm -r " .. outDir .. "\""
end
