local Artworks = script.Parent.Parent
local Types = require(Artworks.Types)

type Retries = number
type Success = boolean
type Message = string

return function(func : Types.Function<(Retries, Message?), (Success, ...any)>)
	local success
	local results
	local retries = 0

	repeat
		results = {pcall(func, retries, table.unpack(results))}
		success = table.remove(results, 1)

		if not success then
			retries += 1
		end
	until success

	return table.unpack(results) 
end
