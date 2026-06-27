--[[
	Signal — 가벼운 신호 객체.
	latching=true면 한 번 Fire된 뒤 늦게 Connect/Wait해도 즉시 처리(Loaded용).
]]
local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

function Connection.new(signal, fn)
	return setmetatable({ _signal = signal, _fn = fn, Connected = true }, Connection)
end

function Connection:Disconnect()
	if not self.Connected then return end
	self.Connected = false
	local conns = self._signal._connections
	local i = table.find(conns, self)
	if i then table.remove(conns, i) end
end

function Signal.new(latching)
	return setmetatable({
		_connections = {},
		_latching = latching or false,
		_fired = false,
		_args = nil,
	}, Signal)
end

function Signal:Connect(fn)
	local conn = Connection.new(self, fn)
	table.insert(self._connections, conn)
	if self._latching and self._fired then
		task.spawn(fn, table.unpack(self._args, 1, self._args.n))
	end
	return conn
end

function Signal:Once(fn)
	local conn
	conn = self:Connect(function(...)
		conn:Disconnect()
		fn(...)
	end)
	return conn
end

function Signal:Wait()
	if self._latching and self._fired then
		return table.unpack(self._args, 1, self._args.n)
	end
	local thread = coroutine.running()
	local conn
	conn = self:Connect(function(...)
		conn:Disconnect()
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

function Signal:Fire(...)
	if self._latching then
		self._fired = true
		self._args = table.pack(...)
	end
	local snapshot = table.clone(self._connections)
	for _, conn in ipairs(snapshot) do
		if conn.Connected then
			task.spawn(conn._fn, ...)
		end
	end
end

function Signal:Destroy()
	for _, conn in ipairs(self._connections) do
		conn.Connected = false
	end
	table.clear(self._connections)
	self._fired = false
	self._args = nil
end

return Signal
