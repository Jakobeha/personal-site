#! /usr/bin/env lua

local utils = require("utils")

local site_dir = utils.get_site_dir()
local dist_dir = utils.get_dist_dir()
local fragments_dir = site_dir .. "/fragments"
-- now we don't have to prefix paths with site_dir ..

os.execute("rm -rf " .. dist_dir)
os.execute("mkdir " .. dist_dir)

local root = utils.read_json(site_dir .. "/root.json")
local pages = utils.read_json(site_dir .. "/pages.json")

local boilerplate_content = utils.read_file(fragments_dir .. "/boilerplate.html")

for page_name, page_path in ipairs(pages) do
  page_path = fragments_dir .. "/" .. page_path
  local output_path = dist_dir .. "/" .. page_name .. ".html"
  local page_content = utils.read_file(page_path)
  local page = run_template("html", boilerplate_content, {
    title = page_name,
    content = page_content
  })
  utils.write_file(output_path, page)
end

function run_template(extension, content, inputs)
  if extension == "html" then
    -- Already translated
  elseif extension == "md" then
    content = utils.markdown_to_html(content)
  elseif extension == "txt" then
    -- Already translated
  else
    error("Unhandled template extension: " .. extension)
  end
  -- Get expected inputs, and translate if necessary
  local _, input_start = string.find(content, "<!--input ");
  local input_end, _ = string.find(content, " -->", input_start);
  local expected_inputs = utils.split_string(string.sub(content, input_start + 1, input_end - 1), ",")

  -- Check inputs match expected
  for _, expected_input in expected_inputs do
    if not inputs[expected_input] then
      error("Missing input " .. expected_input)
    end
  end
  for actual_input, _ in ipairs(inputs) do
    if not expected_inputs[actual_input] then
      error("Extra input " .. actual_input)
    end
  end

  -- Get bindings (inputs + root)
  local bindings = utils.clone_table(inputs)
  bindings.root = root

  -- Substitute
  local result = nil
  local new_result = result
  while new_result do
    result = new_result
    new_result = nil

    -- Substitute a <!--for key,value in expr -->...<!--end --> block
    new_result = try_substitute_block("for", run_for, result, bindings)

    if not new_result then
      -- Substitute a $ (not $$)
      new_result = try_substitute("$", "$", run_expr, result, bindings)
    end

    if not new_result then
      -- Substitute a @ (not @@)
      new_result = try_substitute("@/", "@", run_load, result, bindings)
    end
  end
  return result
end

function try_substitute_block(pattern, run_block, result, bindings)
  local _, block_head_start = result:find("<!--" .. pattern .. " ");
  if not block_head_start then
    return nil
  end

  local block_head_end = result:find(" -->", block_head_start);
  local block_head_raw = result:sub(block_head_start + 1, block_head_end - 1);
  local block_end = result:find("<!--end -->", block_head_end);
  local block_body_raw = result:sub(block_head_end + 1, block_end - 1);
  local block_body = run_block(block_head_raw, block_body_raw, bindings)

  return result:sub(1, block_head_start - 1) .. block_body .. result:sub(block_end + 1)
end

function try_substitute(pattern, manual_end_pattern, run, result, bindings)
  local before_start_index, after_start_index = result:find(pattern)
  if not before_start_index or result:sub(after_start_index + 1, after_start_index + pattern:len()) == pattern then
    return nil
  end

  local end_index1 = result:find(result, " ", after_start_index + 1)
  local end_index2 = result:find(result, manual_end_pattern, after_start_index + 1)
  local before_end_index, after_end_index
  if end_index1 <= end_index2 then
    before_end_index = end_index1 - 1
    after_end_index = end_index1
  else
    before_end_index = end_index2 - 1
    after_end_index = end_index2 + 1
  end

  local expr_raw = result:sub(result, after_start_index + 1, before_end_index)
  local expr = run(expr_raw, bindings)

  return result:sub(1, before_start_index - 1) .. expr .. result:sub(after_end_index)
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
    item_bindings[key_binding] = key
    item_bindings[value_binding] = value
    result = result .. run_template("html", for_body_raw, item_bindings)
  end
end

function run_expr(expr_raw, bindings)
  if expr_raw:len() == 0 then
    error("expr is completely empty")
  elseif expr_raw:sub(1, 1) == "\"" then
    -- Parse string
    if expr_raw:sub(-1, -1) ~= "\"" then
      error("unterminated string literal: " .. expr_raw)
    end
    return utils.unescape_string(expr_raw:sub(2, -2))
  elseif expr_raw:sub(1, 1):find("%d") then
    -- Parse number
    return tonumber(expr_raw)
  else
    -- Parse binding path
    local remaining = expr_raw
    local value = bindings
    while remaining:len() > 0 do
      if remaining:sub(1, 1):find("%w") then
        -- Parse identifier

        -- Get id and check for dot or subscript
        local id_end_dot, _ = remaining:find(".")
        local id_end_subscript, _ = remaining:find("[")
        local id_end = remaining:len()
        local remaining_start = remaining:len()
        if id_end_dot and (not id_end_subscript or id_end_dot < id_end_subscript) then
          id_end = id_end_dot - 1
          remaining_start = id_end_dot + 1
        elseif id_end_subscript then
          id_end = id_end_subscript - 1
          remaining_start = id_end_subscript
        end
        local id = remaining:sub(1, id_end)
        remaining = remaining.sub(remaining_start)

        value = value[id]
        if not value then
          error("Failed to resolve binding: " .. expr_raw .. ", failed at " .. id)
        end
      elseif remaining:sub(1, 1):find("[") then
        -- Parse subscript
        local subscript_end, _ = remaining:find("]")
        local subscript = remaining:sub(1, subscript_end - 1)
        remaining = remaining:sub(subscript_end + 1)
        local subscript_expr = run_expr(subscript, bindings)

        value = value[subscript_expr]
        if not value then
          error("Failed to resolve binding: " .. expr_raw .. ", failed at [" .. subscript .. "] (" .. subscript_expr .. ")")
        end
      end
    end

    return value
  end
end

function run_load(load_raw, bindings)
  local before_load_args, after_load_args = load_raw:find("?")
  local load_path, load_args
  if before_load_args then
    load_path = load_raw:sub(1, before_load_args - 1)
    load_args = utils.split_string(load_raw:sub(after_load_args + 1, -1), ",")
  else
    load_path = load_raw
    load_args = {}
  end
  local before_load_extension, _ = load_path:find("%..+$")
  local load_extension = load_path:sub(before_load_extension + 1)

  if load_path:find("..") then
    error("load path cannot contain .. (security issue)")
  end

  local load_contents = utils.read_file(fragments_dir .. "/" .. load_path)
  if not load_contents then
    error("Failed to load fragment: " .. load_path)
  end

  local load_bindings = utils.clone_table(bindings)
  for key, arg_raw in ipairs(load_args) do
    local arg = run_expr(arg_raw, bindings)
    load_bindings[key] = arg
  end
  return run_template(load_extension, load_contents, load_bindings)
end
