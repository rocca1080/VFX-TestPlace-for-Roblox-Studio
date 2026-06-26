--!native
local Array = {}

function Array.swapRemove(array : {any}, index : number) : any
	local lastIndex = #array
	array[index] = array[lastIndex]
	array[lastIndex] = nil
	return array[index]
end

function Array.insertLast(array : {any}, value : any) : number
	local lastIndex = #array + 1
	array[lastIndex] = value
	return lastIndex
end

function Array.insertUnique(array : {any}, value : any) : boolean
	local index = table.find(array, value)
	if index then
		return false
	end
	table.insert(array, value)
	return true
end

return Array
