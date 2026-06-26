local Table = {}

function Table.deepClone<T>(original : T) : T
	local clone = {}
	for key, value in original
	do
		local typeOfValue = typeof(value)
		if typeOfValue == "table"
		then
			clone[key] = Table.deepClone(value)
		elseif typeOfValue == "Instance"
		then
			clone[key] = value:Clone()
		else
			clone[key] = value
		end
	end
	return clone
end

function Table.merge<T1, T2>(t1 : T1, t2 : T2) : T1&T2
	for key, value in t2
	do
		t1[key] = value
	end
	return t1
end

local DEFAULT_INDENT = 4
function Table.toString(t, indent : number?)
	local indent = indent or 1
	local result = "{"
	local isEmpty = true
	
	for key, value in t
	do
		isEmpty = false
		key = if type(key) == "string" then string.format("%q", key)
			elseif type(key) == "userdata" or type(key) == "vector" then typeof(key) .. "(" .. tostring(key) .. ")"
			else tostring(key)
		value = if type(value) == "table" then Table.toString(value, indent + 1)
			elseif type(value) == "string" then string.format("%q", value)
			else tostring(value)
		
		result ..= "\n"
		for i = 1, DEFAULT_INDENT + indent do
			result ..= "\t"
		end
		result ..= "[" .. key .. "] = "
		result ..= value
		result ..= ","
	end
	
	if not isEmpty then
		result ..= "\n"
		for i = 1, DEFAULT_INDENT + indent - 1 do
			result ..= "\t"
		end
	end
	
	result ..= "}"
	
	return result
end

return Table