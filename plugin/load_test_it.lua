--- Execute all the tests in the file
vim.api.nvim_create_user_command("TestFile", function()
  require "test_it".run()
end, {})

--- Test the exact test in which the cursor is on
vim.api.nvim_create_user_command("TestIt", function()
  require "test_it".run(true)
end, {})

--- Open the window wich the tests are running
vim.api.nvim_create_user_command("OpenTestTerm", function()
  require "test_it".open_floating_window()
end, {})

--- Copy full test path, related to the cursor position
vim.api.nvim_create_user_command("CopyTestPath", function()
  local copy = require 'copy'
  local full_test_path = require "test_it".build_test_path().full_test_path
  copy.to_clipboard(full_test_path)
end, {})
