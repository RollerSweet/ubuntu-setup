local function convert_date(epoch_time_start, epoch_time_end)
  if tonumber(epoch_time_end) == nil or tonumber(epoch_time_start) == nil then
    return 0, 0
  end
  local time_passed = tonumber(epoch_time_end) - tonumber(epoch_time_start)
  local hours_passed = time_passed / 3600
  local postfix = "hour"

  if hours_passed > 1 and hours_passed <= 24 then
    postfix = "hours"
  elseif hours_passed > 24 and hours_passed <= 48 then
    hours_passed = hours_passed / 24
    postfix = "day"
  elseif hours_passed > 48 then
    hours_passed = hours_passed / 24
    postfix = "days"
  end
  return string.format("%d", hours_passed), postfix
end

local function read_all()
  local data = {}
  local file = io.open(os.getenv("HOME") .. "/notes.txt", "r")

  if not file then
    return nil
  end

  for line in file:lines() do
    table.insert(data, line)
  end

  file:close()
  return data
end

local function get_epoch_key(epochTime)
  -- Convert epoch to a formatted date
  local formattedDate = os.date("*t", epochTime)
  local formattedDateWeek = os.date("%U", epochTime)

  -- Extract year, month, and day
  local year = formattedDate.year

  local maz = string.format("%s-%s", year, formattedDateWeek)
  return maz
end


local function format_note(notes, filter, fields_to_include, formatting, format_date)
  local mapping_table = {}
  local final_mapping_table = {}

  for idx, note in pairs(notes) do
    local iterfunc = string.gmatch(note, "([^:]+)")
    local fields = {}
    local kaz = {}
    fields["date"] = iterfunc()
    fields["date_done"] = iterfunc()
    local ak, bk = convert_date(fields["date"], fields["date_done"])
    fields["fdate_done"] = string.format("%s %s", ak, bk)
    fields["type"] = iterfunc()
    fields["value"] = iterfunc()
    fields["id"] = idx

    if fields["type"] ~= nil then
      if mapping_table[fields["type"]] == nil then
        mapping_table[fields["type"]] = {}
      end
      if format_date then
        fields["date"] = os.date("%d-%m-%Y %H:%M:%S", tonumber(fields["date"]))
      end
      if fields_to_include[fields["type"]] ~= nil then
        for _, v in pairs(fields_to_include[fields["type"]]) do
          table.insert(kaz, fields[v])
        end
        fields["formatted_value"] = string.format(formatting[fields["type"]], unpack(kaz))
        if fields["type"] == "DONE" then
          local epoch_key = get_epoch_key(fields["date_done"])
          if mapping_table[fields["type"]][epoch_key] == nil then
            mapping_table[fields["type"]][epoch_key] = {}
          end
          table.insert(mapping_table[fields["type"]][epoch_key], fields)
        else
          table.insert(mapping_table[fields["type"]], fields)
        end
      end
    end
  end

  for _, val in pairs(filter) do
    local splitter = "====================" .. val .. "==============="
    local splitter2 = "-----------------------------------------------"
    table.insert(final_mapping_table,
      { date = -1, type = "NOTYPE", value = splitter, id = -1, formatted_value = splitter })
    if mapping_table[val] ~= nil then
      if val == "DONE" then
        for idx, val2 in pairs(mapping_table[val]) do
          table.insert(final_mapping_table,
            { date = -1, type = "NOTYPE", value = splitter2, id = -1, formatted_value = splitter2 })
          table.insert(final_mapping_table,
            { date = -1, type = "NOTYPE", value = string.format("[ %s ]", idx), id = -1, formatted_value = string.format(
            "[ %s ]", idx) })
          table.insert(final_mapping_table,
            { date = -1, type = "NOTYPE", value = splitter2, id = -1, formatted_value = splitter2 })
          for _, val3 in pairs(val2) do
            table.insert(final_mapping_table, val3)
          end
        end
      else
        for _, val2 in pairs(mapping_table[val]) do
          table.insert(final_mapping_table, val2)
        end
      end
    end
  end
  return final_mapping_table
end

local function format_table(data_table)
  local res = {}
  for _, val in pairs(data_table) do
    table.insert(res, val["formatted_value"])
  end
  return res
end

local function write_all_to_file(notes)
  local file = io.open(os.getenv("HOME") .. "/notes.txt", "w")
  if not file then
    return nil
  end
  local content = table.concat(notes, "\n")

  file:write(content .. "\n")
  file:close()
end

local function update_todo(notes, id)
  local iterfunc = string.gmatch(notes[id], "([^:]+)")
  local date, _, type, value = iterfunc(), iterfunc(), iterfunc(), iterfunc()
  type = "DONE"
  notes[id] = string.format("%s:%s:%s:%s", date, os.time(), type, value)
  write_all_to_file(notes)
end

local function refresh_color(data_table, row)
  vim.api.nvim_buf_clear_highlight(0, 0, 0, -1)
  vim.api.nvim_set_hl(0, 'MyGreenHighlight', { fg = '#00FF00' })
  vim.api.nvim_set_hl(0, 'MyYellowHighlight', { fg = '#FFFF00' })
  vim.api.nvim_set_hl(0, 'MyBlueHighlight', { fg = '#FF9C00' })

  for idx, val in pairs(data_table) do
    local col_start, col_end = 0, 4
    local cursor = 0
    if idx == row then
      cursor = 1
    end

    if val["type"] == "TODO" then
      vim.api.nvim_buf_add_highlight(0, 0, 'MyYellowHighlight', idx - 1, col_start + cursor, col_end + cursor)
    elseif val["type"] == "DONE" then
      vim.api.nvim_buf_add_highlight(0, 0, 'MyGreenHighlight', idx - 1, col_start + cursor, col_end + cursor)
      local s_index, e_index = string.find(val["formatted_value"], val["fdate_done"])
      vim.api.nvim_buf_add_highlight(0, 0, 'MyBlueHighlight', idx - 1, s_index - 1 + cursor, e_index + cursor)
    end
  end
end

local function refresh_buffer(bufnr, state, row)
  vim.api.nvim_buf_set_option(bufnr, 'readonly', false)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
  local all_table = read_all()
  local formatted_table, curr_table = {}, {}

  -- Clear buffer
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})

  if state == "view_notes" then
    curr_table = format_note(all_table, { "TODO", "DONE" },
      { TODO = { "type", "value" }, DONE = { "type", "fdate_done", "value" } }, { TODO = "%s: %s", DONE = "%s:%s: %s" })
    formatted_table = format_table(curr_table)
  elseif state == "view_weekly" then
    curr_table = format_note(all_table, { "WEEKLY" }, { WEEKLY = { "date", "value" } }, { WEEKLY = "%s -> %s" }, true)
    formatted_table = format_table(curr_table)
  end

  -- Set buffer Content
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_table)
  refresh_color(curr_table, row)

  if row ~= nil then
    local theline = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
    vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { ">" .. theline[1] })
  end

  vim.api.nvim_buf_set_option(bufnr, 'readonly', false)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
  return curr_table
end

-- Function to open a popup with a text field
local function open_popup()
  -- Create a new window using Neovim's API for floating windows
  local opts = {
    relative = 'editor', -- Popup relative to the entire editor
    width = 40,          -- Popup width
    height = 5,          -- Popup height
    row = 10,            -- Row position in the editor
    col = 10,            -- Column position in the editor
    style = 'minimal',   -- Minimalistic window style (no border)
    border = 'single',   -- Single border around the window
    focusable = true,    -- The popup is focusable (user can type)
  }

  -- Create the floating window
  local bufnr = vim.api.nvim_create_buf(false, true)      -- Create an empty buffer
  local win_id = vim.api.nvim_open_win(bufnr, true, opts) -- Open the popup window
  local state = 'main'
  local curr_table = nil
  vim.api.nvim_create_augroup("CursorMoveGroup", { clear = true })
  vim.api.nvim_set_hl(0, 'MyGreenHighlight', { fg = '#00FF00' })
  vim.api.nvim_set_hl(0, 'MyYellowHighlight', { fg = '#FFFF00' })


  -- Set some text inside the buffer (optional)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "1. Notes", "2. Weekly", "3. View Notes", "4. View Weekly" })
  vim.api.nvim_buf_set_option(bufnr, 'readonly', true)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
  vim.api.nvim_buf_set_option(bufnr, 'wrap', true)

  vim.api.nvim_buf_set_keymap(bufnr, 'n', '1', '', {
    noremap = true,
    callback = function()
      vim.api.nvim_buf_set_option(bufnr, 'readonly', false)
      vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "" })
      vim.api.nvim_win_set_cursor(win_id, { 1, 0 })
      vim.api.nvim_command("startinsert")
      state = 'notes'
    end
  })

  vim.api.nvim_buf_set_keymap(bufnr, 'n', '2', '', {
    noremap = true,
    callback = function()
      vim.api.nvim_buf_set_option(bufnr, 'readonly', false)
      vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "" })
      vim.api.nvim_win_set_cursor(win_id, { 1, 0 })
      vim.api.nvim_command("startinsert")
      state = 'weekly'
    end
  })

  vim.api.nvim_buf_set_keymap(bufnr, 'n', '3', '', {
    noremap = true,
    callback = function()
      vim.api.nvim_buf_set_option(bufnr, 'readonly', false)
      vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
      state = "view_notes"
      vim.api.nvim_win_set_config(win_id, { width = 100, height = 20 })

      curr_table = refresh_buffer(bufnr, "view_notes")

      vim.api.nvim_buf_set_option(bufnr, 'readonly', true)
      vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
    end
  })

  vim.api.nvim_buf_set_keymap(bufnr, 'n', '4', '', {
    noremap = true,
    callback = function()
      vim.api.nvim_buf_set_option(bufnr, 'readonly', false)
      vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
      state = "view_weekly"
      vim.api.nvim_win_set_config(win_id, { width = 100, height = 20 })

      curr_table = refresh_buffer(bufnr, "view_weekly")

      vim.api.nvim_buf_set_option(bufnr, 'readonly', true)
      vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
    end
  })

  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '', {
    noremap = true,
    callback = function()
      vim.api.nvim_win_close(win_id, true)
      vim.api.nvim_input("<Esc>")
    end
  })

  vim.api.nvim_buf_set_keymap(bufnr, 'i', '<CR>', '', {
    noremap = true,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      local file = io.open(os.getenv("HOME") .. "/notes.txt", "a")

      if file then
        for _, val in pairs(lines) do
          if state == "notes" then
            file:write(os.time() .. ":NONE:TODO:" .. val .. "\n")
          elseif state == "weekly" then
            file:write(os.time() .. ":NONE:WEEKLY:" .. val .. "\n")
          end
        end
        file:close()
      else
        print("Error")
      end

      vim.api.nvim_win_close(win_id, true)
      vim.api.nvim_input("<Esc>")
    end
  })

  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<CR>', '', {
    noremap = true,
    callback = function()
      local cursor = vim.api.nvim_win_get_cursor(win_id)
      if state ~= "view_notes" then
        return nil
      end

      local all_table = read_all()
      local a, _ = unpack(cursor)
      if curr_table == nil or curr_table[a] == nil or curr_table[a]["id"] == -1 or curr_table[a]["type"] == "DONE" then
        return nil
      end

      update_todo(all_table, curr_table[a]["id"])
      curr_table = refresh_buffer(bufnr, "view_notes", a)
      vim.api.nvim_win_set_cursor(win_id, cursor)
    end
  })

  local last_row = nil

  -- Register the autocommand for CursorMoved event
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = "CursorMoveGroup", -- Use the group we created
    callback = function()
      if state == 'main' then
        return
      end
      vim.api.nvim_buf_set_option(bufnr, 'readonly', false)
      vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)

      local cursor = vim.api.nvim_win_get_cursor(win_id)
      local row, _ = unpack(cursor)
      local theline = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
      vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { ">" .. theline[1] })


      if last_row ~= nil then
        local prevline = vim.api.nvim_buf_get_lines(bufnr, last_row - 1, last_row, false)
        vim.api.nvim_buf_set_lines(bufnr, last_row - 1, last_row, false, { string.sub(prevline[1], 2) })
      end
      last_row = row

      refresh_color(curr_table, row)
      vim.api.nvim_buf_set_option(bufnr, 'readonly', true)
      vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
    end, -- Call the on_cursor_move function
    buffer = bufnr,
  })
end

-- Create a Neovim command to trigger the popup
vim.api.nvim_create_user_command('OpenPopup', open_popup, {})

return {
  config = open_popup
}
