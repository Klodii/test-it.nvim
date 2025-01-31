--- Execute all the tests in the file
vim.api.nvim_create_user_command("TestFile", function()
  require "test-it".run()
end, {})

--- Test the exact test in which the cursor is on
vim.api.nvim_create_user_command("TestIt", function()
  require "test-it".run(true)
end, {})

--- Open the window wich the tests are running
vim.api.nvim_create_user_command("OpenTestTerm", function()
  require "test-it".open_floating_terminal()
end, {})

--- Copy full test path, related to the cursor position
vim.api.nvim_create_user_command("CopyTestPath", function()
  local utils = require 'utils'
  local full_test_path = require "test-it".build_test_path().full_test_path
  utils.copy_to_clipboard(full_test_path)
end, {})
