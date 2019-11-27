local Options = ToD.loaded_options
function ToD:Save()
	local fileName = ToD.save_path .. "ToDOptions.txt"
	local file = io.open(fileName, "w+")
	file:write(json.encode(Options))
	file:close()
end

function ToD:Load_options()
	local file = io.open(ToD.save_path .. "ToDOptions.txt", 'r')
	if file == nil then
		return
	end
	local file_contents = file:read("*all")
	local data = json.decode( file_contents )
	file:close()
	if data then
		for p, d in pairs(data) do
			Options[p] = d
		end
	end
end