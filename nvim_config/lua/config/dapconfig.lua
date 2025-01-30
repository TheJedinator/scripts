-- lua/dap_config.lua
local dap = require("dap")

dap.adapters.python = {
  type = "executable",
  command = "/usr/bin/python", -- Adjust this path to your Python interpreter
  args = { "-m", "debugpy.adapter" },
}

dap.configurations.python = {
  {
    -- Configuration for Django tests
    type = "python",
    request = "launch",
    name = "Django Unittest",
    program = "${workspaceFolder}/manage.py",
    args = { "test", "--pattern", "*.py" },
    env = {
      DJANGO_SETTINGS_MODULE = "core_app.settings.native_test", -- Replace with your settings module
    },
  },
}
