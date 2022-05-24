local vim_utils = require "ros-nvim.vim-utils"
local action_state = require "telescope.actions.state"
local package = require"ros-nvim.package"
local M = {}

ROS_CONFIG = {
    catkin_ws_path = "~/catkin_ws",
    -- vim_utils.open_new_buffer or custom function
    open_terminal_method = function()
        vim_utils.open_split()
    end,
    terminal_height = 8, -- only for split terminal
    -- Picker mappings
    node_picker_mappings = function(map)
        map("n", "<c-k>", vim_utils.open_terminal_with_format_cmd_entry("rosnode kill %s"))
        map("i", "<c-k>", vim_utils.open_terminal_with_format_cmd_entry("rosnode kill %s"))
    end,
    topic_picker_mappings = function(map)
        local cycle_previewers = function(prompt_bufnr)
            local picker = action_state.get_current_picker(prompt_bufnr)
            picker:cycle_previewers(1)
        end
        map("n", "<c-b>", vim_utils.open_terminal_with_format_cmd_entry("rostopic pub %s"))
        map("i", "<c-b>", vim_utils.open_terminal_with_format_cmd_entry("rostopic pub %s"))
        map("n", "<c-e>", cycle_previewers)
        map("i", "<c-e>", cycle_previewers)
    end,
    service_picker_mappings = function(map)
        map("n", "<c-e>", vim_utils.open_terminal_with_format_cmd_entry("rosservice call %s"))
        map("i", "<c-e>", vim_utils.open_terminal_with_format_cmd_entry("rosservice call %s"))
    end,
    param_picker_mappings = function(map)
        map("n", "<c-e>", vim_utils.open_terminal_with_format_cmd_entry("rosparam set %s"))
        map("i", "<c-e>", vim_utils.open_terminal_with_format_cmd_entry("rosparam set %s"))
    end,
    -- line of clangd argument. initialized to empty
    cmd = "",
}

function M.setup(config)
    for key, value in pairs(config) do
        if value ~= nil then
            ROS_CONFIG[key] = value
        end
    end
end


-- returns true if file open succeeds, so it exists
function M.file_exists(name)
  local f=io.open(name,"r")
  if f~=nil then
    io.close(f)
    return true
  else
    return false
  end
end

-- local in_ros = false
--
-- local function ros_package()
--   if package.get_current_package_name() == nil then
--     in_ros = false
--   else
--     in_ros = true
--   end
-- end

-- notification is file is not found
local no_file = "compile_commands.json does not exist in build dir"
local not_package = "not in a ROS package"

function M.set_clangd_arg()
  local name = package.get_current_package_name()

  -- name is not nil also when rospkg python is not found
  if name ~= nil or name ~= 'no_ros_on_system' then
    local db_path = "/home/davide/catkin_ws/build/" .. name
    local db_file = "/home/davide/catkin_ws/build/" .. name .. "/compile_commands.json"
    -- check if file exists but then pass path
    if M.file_exists(db_file) then
      ROS_CONFIG.cmd = "--compile-commands-dir=".. db_path
      -- return true
    else
      vim.notify(no_file, "warn")
      -- return false
    end
  else
    vim.notify(not_package, "warn")
    -- return false
  end
end

function M.get_clangd_cmd()
  return ROS_CONFIG.cmd
end


local ros_nvim = vim.api.nvim_create_augroup("ros-nvim", {clear = true})
vim.api.nvim_create_autocmd({"BufAdd"}, {pattern={"*.cpp","*.cc"}, callback=M.set_clangd_arg, group = ros_nvim})



return M
