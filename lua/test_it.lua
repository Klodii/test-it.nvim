local utils = require 'utils'
local ci = require 'cursor_info'

-- run tests of the current file
local M = {}

---@class Options
---@field path_prefix_to_remove string: prefix to remove from the file path
---@field test_command string: command used to execute the test

local options = {
  path_prefix_to_remove = '',
  test_command = 'pytest'
}

---Setup the packages
---@param opts Options
M.setup = function(opts)
  opts = opts or {}
  opts.path_prefix_to_remove = opts.path_prefix_to_remove or ''
  opts.test_command = opts.test_command or 'pytest'
  options = opts
end

local buf = nil
local job_id = nil

---@class TestPath
---@field file_path string: relative path to of the file
---@field class_ string: name fo the class in which the cursor is
---@field function_ string: name fo the function in which the cursor is
---@field full_test_path string: relative path to file :: class name :: function name

---Return all the information related to the cursor position
---@param prefix_to_remove string: prefix to remove from the file path, it may be necessary when executing tests through docker
---@return TestPath
M.build_test_path = function(prefix_to_remove)
  local file_path = ci.get_relative_file_path()
  if string.sub(file_path, 0, #prefix_to_remove) == prefix_to_remove then
    file_path = string.sub(file_path, #prefix_to_remove + 1)
  end

  local names = ci.get_class_and_function_name("python")
  local full_test_path = file_path
  if names then
    if names.class_name then
      full_test_path = full_test_path .. "::" .. names.class_name
      if names.function_name then
        full_test_path = full_test_path .. "::" .. names.function_name
      end
    end
  end

  return {
    file_path = file_path,
    class_ = names.class_name,
    function_ = names.function_name,
    full_test_path = full_test_path,
  }
end


local open_floating_window = function()
  local width = vim.api.nvim_get_option_value('columns', {})
  local height = vim.api.nvim_get_option_value('lines', {})
  utils.open_floating_window(buf, {
    row = math.floor(height * 0.1),
    col = math.floor(width * 0.1),
    width = math.floor(width * 0.8),
    height = math.floor(height * 0.8)
  })
end

M.open_floating_terminal = function()
  if not buf then
    buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].swapfile = false -- do not create a swap file

    open_floating_window()
    vim.cmd.term()
    job_id = vim.bo.channel
  else
    open_floating_window()
  end
end

---Open a terminal and execute the commands passed
---@param commands string[] list of commands to execute
local run_commands = function(commands)
  M.open_floating_terminal()
  for i = 1, #commands do
    vim.fn.chansend(job_id, { commands[i] })
  end
end

---Run the python test of the current file
---@param cursor_specific? boolean if true run the specific test in which the cursor is on
M.run = function(cursor_specific)
  cursor_specific = cursor_specific or false

  local test_path = M.build_test_path(options.path_prefix_to_remove)
  local path_to_execute = test_path.file_path
  if cursor_specific == true then
    path_to_execute = test_path.full_test_path
  end

  local enter = "\r\n"
  local commands = { options.test_command .. " " .. path_to_execute .. enter }
  run_commands(commands)
end

return M
