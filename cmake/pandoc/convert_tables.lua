local footnote_map = {}
local footnote_counter = 0
local footnotes_collected = {}

function printTable(tbl, indent)
    indent = indent or ""
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            print(indent .. tostring(k) .. ": {")
            printTable(v, indent .. "  ") -- Recurse for nested tables
            print(indent .. "}")
        else
            print(indent .. tostring(k) .. ": " .. tostring(v))
        end
    end
end


local function inlines_to_latex(inlines)
	local latex_string = {}
	for _, inline in ipairs(inlines) do
		table.insert(latex_string, pandoc.write(pandoc.Pandoc(inline), 'latex'))
	end
	return table.concat(latex_string, "")
end


local function collect_footnotes_and_replace(elem)
	if elem.t == "Note" then
		local content_as_json = pandoc.json.encode(elem.content) -- Use JSON for consistent hashing
		if not footnote_map[content_as_json] then
			footnote_counter = footnote_counter + 1
			footnote_map[content_as_json] = footnote_counter
			table.insert(footnotes_collected, {number = footnote_counter, content = elem.content})
		end
		return pandoc.RawInline('tex', '\\footnotemark[\\numexpr\\value{originalfootnotevalue}+' .. footnote_map[content_as_json] .. ']')
	else
		return elem
	end
end

function convert_Table(elem)
	local latex_output = {}

	local caption = inlines_to_latex(elem.caption)
	-- Determine column alignments and widths
	local col_format_string = ""
	for _, spec in ipairs(elem.colspecs) do
		local align = spec[1].t
		local width = spec[2] or nil -- ColWidth is optional

		local latex_align
		if align == "AlignLeft" then
			latex_align = "l"
		elseif align == "AlignRight" then
			latex_align = "r"
		elseif align == "AlignCenter" then
			latex_align = "c"
		else -- AlignDefault
			latex_align = "l" -- Default to left for consistency with Pandoc's default
		end

		if width then
			-- Convert Pandoc's relative width to LaTeX's absolute width (e.g., \linewidth)
			-- This assumes the table will fill the text width, adjust as needed
			local actual_width = string.format("%.3f\\linewidth", width)
			col_format_string = col_format_string .. "p{" .. actual_width .. "}"
		else
			col_format_string = col_format_string .. latex_align
		end
	end

	table.insert(latex_output, "\\setcounter{originalfootnotevalue}{\\value{footnote}}\n")
	table.insert(latex_output, "\\begin{table}[h!]\n")
	table.insert(latex_output, "\\centering\n")
	table.insert(latex_output, "\\rowcolors{1}{table_even_row_color}{table_odd_row_color}\n")
	table.insert(latex_output, "\\caption{" .. caption .. "}\n")
	table.insert(latex_output, "\\begin{tabular}{" .. col_format_string .. "}\n")
	table.insert(latex_output, "\\toprule\n")
	table.insert(latex_output, "\\rowcolor{table_header_color}")

	local head = elem.head
	-- Table Head
	if #head.rows > 0 then
		for _, head_row in ipairs(head.rows) do
			local cells = head_row.cells
			local row_content = {}
			for _, cell_data in ipairs(cells) do
				local cell_contents = cell_data.contents
				table.insert(row_content, inlines_to_latex(cell_contents))
			end
			table.insert(latex_output, table.concat(row_content, " & ") .. " \\\\\n")
		end
		table.insert(latex_output, "\\midrule\n")
	end

	local bodies = elem.bodies
	-- Table Bodies
	for _, body_data in ipairs(bodies) do
		local body_rows = body_data.body
		for _, row_data in ipairs(body_rows) do
			local cells = row_data.cells
			local row_content = {}
			for _, cell_data in ipairs(cells) do
				local cell_blocks = cell_data.content
				local cell_content = {}
				for _, block in ipairs(cell_blocks) do
					local processed_contents = pandoc.walk_block(block, {Note = collect_footnotes_and_replace})
					table.insert(cell_content, processed_contents)
				end
				local cells_in_latex = inlines_to_latex(cell_content)
				table.insert(row_content, cells_in_latex)
			end
			table.insert(latex_output, table.concat(row_content, " & ") .. " \\\\\n")
		end
	end

	table.insert(latex_output, "\\bottomrule\n")
	table.insert(latex_output, "\\end{tabular}\n")

	table.insert(latex_output, "\\end{table}\n")
	if #footnotes_collected > 0 then
		for _, footnote in ipairs(footnotes_collected) do
			table.insert(latex_output, "\\footnotetext[\\numexpr\\value{originalfootnotevalue}+" .. footnote.number .. "]{" .. inlines_to_latex(footnote.content) .. "}\n")
		end
	end
	table.insert(latex_output, "\\setcounter{footnote}{\\numexpr\\value{originalfootnotevalue} + " .. footnote_counter .. "}\n")
	footnote_map = {}
	footnote_counter = 0
	footnotes_collected = {}

	return pandoc.RawBlock("latex", table.concat(latex_output))
end


function convert_BlockQuote(elem)
	if elem.content and elem.content[1].t == "Table" then
		return convert_Table(elem.content[1])
	end
	return elem
end


function Pandoc(doc)
	local meta = doc.meta

	local appName = meta['app_name']

	local handlers = {
		BlockQuote = convert_BlockQuote,
		Table = convert_Table
	}

	return doc:walk(handlers)
end