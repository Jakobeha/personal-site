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
  local result = content
  local did_change = true
  while did_change do
    did_change = false

    -- Substitute a <!--for key,value in expr -->...<!--end --> block
    local _, for_head_start = result:find("<!--for ");
    if for_head_start then
      local for_head_end = result:find(" -->", for_head_start);
      local for_head_raw = result:sub(for_head_start + 1, for_head_end - 1);
      local for_end = result:find("<!--end -->", for_head_end);
      local for_body_raw = result:sub(for_head_end + 1, for_end - 1);
      local for_body = run_for(for_head_raw, for_body_raw, bindings)
      result = result:sub(1, for_head_start - 1) .. for_body .. result:sub(for_end + 1)
    end

    if not did_change then
      -- Substitute a $ (not $$)
      local _, start_index = result:find("$")
      if start_index and result:sub(start_index + 1, start_index + 1) ~= "$" then
        local end_index = result:find(result, " ", start_index)
        local expr_raw = result:sub(result, start_index + 1, end_index - 1)
        local expr = run_expr(expr_raw, bindings)
        result = result:sub(1, start_index - 1) .. expr .. result:sub(end_index + 1)
        did_change = true
      end
    end

    if not did_change then
      -- Substitute a @ (not @@)
      local _, start_index = result:find("@")
      if start_index and result:sub(start_index + 1, start_index + 1) ~= "@" then
        local end_index = result:find(result, " ", start_index)
        local load_raw = result:sub(result, start_index + 1, end_index - 1)
        local load = run_load(load_raw, bindings)
        result = result:sub(1, start_index - 1) .. load .. result:sub(end_index + 1)
        did_change = true
      end
    end
  end
end


function run_for(for_head_raw, for_body_raw, bindings)
  todo
end

function run_expr(expr_raw, bindings)
  todo

  for key, value in pairs(bindings) do
    local key_start, key_end = string.find(result, "{" .. key .. "}")
    if key_start then
      result = string.sub(result, 1, key_start - 1) .. value .. string.sub(result, key_end + 1)
      did_change = true
    end
  end
end

function run_load(load_raw, bindings)
  todo
end
