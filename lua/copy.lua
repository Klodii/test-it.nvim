local M = {}
--- Copy text in the clipboard
---@param text string text to copy to the clipboard
M.copy_to_clipboard = function(text)
  if not text then
    vim.notify("No text to copy", vim.log.levels.WARN)
    return
  end

  if vim.fn.has('clipboard') == 1 then
    vim.fn.setreg('+', text)
    vim.notify("'" .. text .. "' copied")
  else
    vim.notify("Clipboard not available", vim.log.levels.ERROR)
  end
end

return M
