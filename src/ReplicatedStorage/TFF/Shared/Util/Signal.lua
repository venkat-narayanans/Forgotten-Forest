--!strict
--[[
    Signal.lua
    Lightweight, fast, typed custom event implementation.
]]

type Connection = {
    Disconnect: (self: Connection) -> (),
    Connected: boolean,
}

export type Signal<T...> = {
    Connect: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
    Once: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
    Fire: (self: Signal<T...>, T...) -> (),
    Wait: (self: Signal<T...>) -> T...,
    Destroy: (self: Signal<T...>) -> (),
}

local Signal = {}
Signal.__index = Signal

function Signal.new<T...>(): Signal<T...>
    local self = setmetatable({}, Signal)
    self._listeners = {}
    return (self :: any) :: Signal<T...>
end

function Signal:Connect(fn: (...any) -> ()): Connection
    local listeners = self._listeners
    if not listeners then
        return { Disconnect = function() end, Connected = false }
    end

    local connection = {
        _fn = fn,
        Connected = true,
    }

    function connection:Disconnect()
        if not self.Connected then return end
        self.Connected = false
        for i, conn in ipairs(listeners) do
            if conn == self then
                table.remove(listeners, i)
                break
            end
        end
    end

    table.insert(listeners, connection)
    return connection
end

function Signal:Once(fn: (...any) -> ()): Connection
    local conn
    conn = self:Connect(function(...)
        conn:Disconnect()
        fn(...)
    end)
    return conn
end

function Signal:Fire(...: any)
    local listeners = self._listeners
    if not listeners then return end

    -- Clone listeners table so handlers that disconnect during fire don't affect iteration
    local copy = table.clone(listeners)
    for _, conn in ipairs(copy) do
        if conn.Connected then
            task.spawn(conn._fn, ...)
        end
    end
end

function Signal:Wait(): ...any
    local thread = coroutine.running()
    local conn
    conn = self:Connect(function(...)
        conn:Disconnect()
        task.spawn(thread, ...)
    end)
    return coroutine.yield()
end

function Signal:Destroy()
    if self._listeners then
        table.clear(self._listeners)
        self._listeners = nil
    end
end

return Signal
