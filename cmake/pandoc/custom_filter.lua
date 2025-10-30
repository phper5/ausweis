-- globals
local toctree_seen = false

function transform_colored_box(elem, tex_environment, skip_first_elem)
	-- table.unpack with an index eats the contents of the block after the first paragraph, create list without title manually
	local new_content = {}
	for i, e in ipairs(elem.content) do
		if (not (i == 1 and skip_first_elem)) then
			table.insert(new_content, e)
		end
	end

	table.insert(new_content, 1, pandoc.RawBlock("tex", '\\begin{' .. tex_environment .. '}'))
	table.insert(new_content, pandoc.RawBlock("tex", '\\end{' .. tex_environment .. '}'))
	return new_content
end

function string_concat(current_string, new_string)
	if current_string == '' then
		return new_string
	else
		return current_string .. '\n' .. new_string
	end
end

function Pandoc(doc)
	local handlers = {
		Div = function (elem)
			if elem.attr and elem.attr.classes then
				if elem.attr.classes[1] == 'only' then
					if (elem.content[1].content.text == 'latex') then
						return elem
					else
						return pandoc.RawBlock('tex', '')
					end
				elseif elem.attr.classes[1] == 'important' then
					return transform_colored_box(elem, 'ImportantBox', true)
				elseif elem.attr.classes[1] == 'seealso' then
					return transform_colored_box(elem, 'SeeAlsoBox', false)
				elseif elem.attr.classes[1] == 'note' then
					return transform_colored_box(elem, 'NoteBox', true)
				end
			else
				return elem
			end
		end,
		Code = function (elem)
			if elem.attr.classes[1] == 'interpreted-text' then
				if elem.attr.attributes['role'] == 'doc' or elem.attr.attributes['role'] == 'ref' or elem.attr.attributes['role'] == 'numref' then
					local label = elem.text
					local content = elem.text
					local start_index, end_index, before_brackets, inside_brackets = string.find(elem.text, "(.*) <([^<>]+)>")
					local latex_output = ''
					if (start_index) then
						label = inside_brackets
						content = before_brackets
						latex_output = '\\hyperref[' .. label .. ']{' .. content .. '} (\\pagename{} \\pageref*{' .. label .. '})'
					else
						latex_output = '\\hyperref[' .. label .. ']{\\nameref{' .. content .. '}} (\\pagename{} \\pageref*{' .. label .. '})'
					end
					return pandoc.RawInline('tex', latex_output)
				else
					return elem
				end
			else
				return elem
			end
		end,
		CodeBlock = function (elem)
			-- These changes to CodeBlock are not ideal as it breaks pandocs automatic syntax highlighting.
			-- In most cases it works and a11y can be achieved, we therefore keep it this way until pdftag supports vfextra linebreaks or the listings package.

			-- Don't color json CodeBlocks as they are often broken up over multiple pages, leading to broken syntax highlighting.
			if elem.attr.classes[1] == 'json' then
				elem.attr.classes[1] = ''
			end

			-- Split long lines in CodeBlocks, Split CodeBlocks
			local output = ''
			for token in string.gmatch(elem.text, "[^\n]+") do
				local chunk_size = 80
				local str_len = string.len(token)
				local chunks = {}
				local separator = "␣\n→"

				if str_len <= chunk_size then
					output = string_concat(output, token)
				else
					for i = 1, str_len, chunk_size do
						local chunk = string.sub(token, i, math.min(i + chunk_size - 1, str_len))
						table.insert(chunks, chunk)
					end

					output = string_concat(output, table.concat(chunks, separator))
				end
			end

			-- Split too many lines into multiple code blocks.
			local blocks = {}
			local current_output = ''
			local count = 0
			local count_limit = 46
			for token in string.gmatch(output, "[^\n]+") do
				current_output = string_concat(current_output, token)
				count = count + 1
				if count >= count_limit then
					table.insert(blocks, pandoc.CodeBlock(current_output, elem.attr))
					table.insert(blocks, pandoc.RawBlock('tex', '\\continuesname\n'))
					table.insert(blocks, pandoc.RawBlock('tex', '\\clearpage\n'))
					table.insert(blocks, pandoc.RawBlock('tex', '\\continuedname\n'))
					count = 0
					current_output = ''
				end
			end

			if current_output ~= '' then
				table.insert(blocks, pandoc.CodeBlock(current_output, elem.attr))
				current_output = ''
			end

			-- End paragraph before code block. Fixes problems with `\paragraph` preceding CodeBlocks.
			table.insert(blocks, 1, pandoc.RawBlock('tex', '\n\n\\noindent\n'))
			-- End paragraph after code block. Fixes problems with sections following CodeBlocks.
			table.insert(blocks, pandoc.RawBlock('tex', '\n\n\\noindent\n'))

			return blocks
		end,
	}

	return doc:walk(handlers)
end
