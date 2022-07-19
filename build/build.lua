#! /usr/bin/env lua

local utils = require("utils")

local site_dir = utils.get_site_dir()
local dist_dir = utils.get_dist_dir()
-- now we don't have to prefix paths with site_dir ..

local execute, run_template_file, run_template, try_substitute_splice, try_substitute_for, run_for, run_expr, run_load

function execute()
  -- Clear old dist
  os.execute("rm -rf " .. dist_dir)
  os.execute("mkdir " .. dist_dir)

  -- Copy static files into dist
  os.execute("cp -r " .. site_dir .. "/static " .. dist_dir);

  local root = utils.read_json(site_dir .. "/root.json")
  local pages = utils.read_json(site_dir .. "/pages.json")

  -- Render pages, they'll recursively load other files
  for page_name, page_path in ipairs(pages) do
    page_path = site_dir .. "/pages/" .. page_path
    local output_path = dist_dir .. "/" .. page_name .. ".html"
    local page = run_template_file(page_path, {
      root = root
    })
    utils.write_file(output_path, page)
  end
end

function run_template_file(path, bindings)
  if path:find("..") then
    error("load path cannot contain .. (security issue)")
  end

  local before_extension, _ = path:find("%..+$")
  local extension = path:sub(before_extension + 1)

  local content = utils.read_file(path)
  return run_template(extension, content, bindings)
end

function run_template(extension, content, bindings)
  if extension == "html" then
    -- Already translated
  elseif extension == "md" then
    content = utils.markdown_to_html(content)
  elseif extension == "txt" then
    -- Already translated
  elseif extension == "json" then
    -- JSON = don't check inputs or substitutions, just parse
    if #bindings > 1 then
      error("passing query params to JSON is unsupported")
    end
    return utils.parse_json(content)
  else
    error("Unhandled template extension: " .. extension)
  end
  -- Get expected inputs, and translate if necessary
  local _, input_start = string.find(content, "<!--input ");
  local input_end, _ = string.find(content, " -->", input_start);
  local expected_inputs = utils.split_string(string.sub(content, input_start + 1, input_end - 1), ",")
  table.insert(expected_inputs, "root")

  -- Check inputs match expected
  for _, expected_input in expected_inputs do
    if not bindings[expected_input] then
      error("Missing input " .. expected_input)
    end
  end
  for actual_input, _ in ipairs(bindings) do
    if not expected_inputs[actual_input] then
      error("Extra input " .. actual_input)
    end
  end

  -- Substitute
  local result = nil
  local new_result = result
  while new_result do
    result = new_result
    new_result = nil

    -- Substitute a <!--for key,value in expr -->...<!--end --> block
    new_result = try_substitute_for(result, bindings)

    if not new_result then
      -- Substitute a {...} block
      new_result = try_substitute_splice(result, bindings)
    end
  end
  return result
end

function try_substitute_for(result, bindings)
  local _, block_head_start = result:find("<!--for ");
  if not block_head_start then
    return nil
  end

  local block_head_end = result:find(" -->", block_head_start);
  local block_head_raw = result:sub(block_head_start + 1, block_head_end - 1);
  local block_end = result:find("<!--end -->", block_head_end);
  local block_body_raw = result:sub(block_head_end + 1, block_end - 1);
  local block_body = run_for(block_head_raw, block_body_raw, bindings)

  return result:sub(1, block_head_start - 1) .. block_body .. result:sub(block_end + 1)
end

function try_substitute_splice(result, bindings)
  local start_index = result:find("{[^{]");
  if not start_index then
    return nil
  end

  local end_index = result:find(result, "}", start_index + 1)

  local expr_raw = result:sub(result, start_index + 1, end_index - 1)
  local expr = run_expr(expr_raw, bindings)

  return result:sub(1, start_index - 1) .. expr .. result:sub(end_index + 1)
end

function run_for(for_head_raw, for_body_raw, bindings)
  local before_for_in, after_for_in = for_head_raw:find(" in ")
  local for_bindings = for_head_raw:sub(1, before_for_in - 1)
  for_bindings = utils.split_string(for_bindings, ",")
  local key_binding = for_bindings[1]
  local value_binding = for_bindings[2]
  if not key_binding then
    value_binding = key_binding
    key_binding = nil
  end
  if not value_binding then
    error("Missing value in for")
  end
  local for_expr_raw = for_head_raw:sub(after_for_in + 1)
  local for_expr = run_expr(for_expr_raw, bindings)

  local result = ""
  for key, value in ipairs(for_expr) do
    local item_bindings = utils.clone_table(bindings)
    if key_binding then
      item_bindings[key_binding] = key
    end
    item_bindings[value_binding] = value
    result = result .. run_template("html", for_body_raw, item_bindings)
  end
end

function run_expr(expr_raw, bindings)
  local first = expr_raw:sub(1, 1)
  local semicolon_pos = expr_raw:find(";")
  if not first then
    error("expr is completely empty")
  elseif first == "\"" then
    -- Parse string
    if first ~= "\"" then
      error("unterminated string literal: " .. expr_raw)
    end
    return utils.unescape_string(expr_raw:sub(2, -2))
  elseif first:find("%d") then
    -- Parse number
    return tonumber(expr_raw)
  elseif first == "/" then
    -- Parse load
    return run_load(expr_raw, bindings)
  elseif semicolon_pos then
    -- Parse local binding
    local binding_name_and_value = utils.split_string(expr_raw:sub(1, semicolon_pos - 1), "=")
    if #binding_name_and_value ~= 2 then
      error("invalid local binding: " .. binding_name_and_value .. " in " .. expr_raw)
    end
    local binding_name = binding_name_and_value[1]
    local binding_value_raw = binding_name_and_value[2]
    local binding_value = run_expr(binding_value_raw, bindings)
    local new_bindings = utils.clone_table(bindings)
    new_bindings[binding_name] = binding_value
    local remaining = expr_raw:sub(semicolon_pos + 1)
    return run_expr(remaining, new_bindings)
  else
    -- Parse binding path
    local remaining = expr_raw
    local value = bindings
    while remaining:len() > 0 do
      local is_subscript = false
      if remaining:sub(1, 1):find(":") then
        is_subscript = true
        remaining = remaining:sub(2)
      end

      -- Parse identifier (includes numbers)

      -- Get id and check for next dot or subscript
      local id_end_dot, _ = remaining:find(".")
      local id_end_colon, _ = remaining:find(":")
      local id_end, remaining_start
      if id_end_dot and (not id_end_colon or id_end_dot < id_end_colon) then
        id_end = id_end_dot - 1
        remaining_start = id_end_dot + 1
      elseif id_end_colon then
        -- Preserve colon when we loop back
        id_end = id_end_colon - 1
        remaining_start = id_end_colon
      else
        id_end = remaining:len()
        remaining_start = remaining:len()
      end
      local id = remaining:sub(1, id_end)
      remaining = remaining.sub(remaining_start)

      -- Go down identifier
      if is_subscript then
        local subscript_expr = run_expr(id, bindings)

        value = value[subscript_expr]
        if not value then
          error("Failed to resolve binding: " .. expr_raw .. ", failed at :" .. id .. " (." .. subscript_expr .. ")")
        end
      else
        value = value[id]
        if not value then
          error("Failed to resolve binding: " .. expr_raw .. ", failed at " .. id)
        end
      end
    end

    return value
  end
end

function run_load(load_raw, bindings)
  local before_load_args, after_load_args = load_raw:find("?")
  local load_path
  local load_args = {}
  if before_load_args then
    load_path = load_raw:sub(1, before_load_args - 1)

    -- Fill load args
    local load_arg_kvs = utils.split_string(load_raw:sub(after_load_args + 1, -1), ",")
    for _, kv in ipairs(load_arg_kvs) do
      local kv_split = utils.split_string(kv, "=")
      if #kv_split ~= 2 then
        error("Invalid load argument: " .. kv)
      end
      local key = kv_split[1]
      local value_raw = kv_split[2]
      local value = run_expr(value_raw, bindings)
      load_args[key] = value
    end
  else
    load_path = load_raw
    -- No load args to fill
  end

  -- Prepend site_dir to load_path (already has the leading /)
  load_path = site_dir .. load_path

  return run_template_file(load_path, load_args)
end


execute()
