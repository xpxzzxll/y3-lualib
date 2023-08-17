---@class Command
local M = {}

---@type table<string, fun(...)>
M.commands = {}

-- 注册作弊指令（指令名称无视大小写）
---@param command string
---@param callback fun(...)
function M.register(command, callback)
    M.commands[command:lower()] = callback
end

---@param reload Reload
local function remove_all_triggers_in_include(reload)
    local event_manager = y3.game:get_event_manager()
    for trigger in event_manager:pairs() do
        local source = trigger:get_info_source()
        local path = source:match('^@(.+)$')
        if reload:isValidPath(path) then
            trigger:remove()
        end
    end
end

---@param reload Reload
local function remove_all_timers_in_include(reload)
    for timer in y3.timer.pairs() do
        local source = timer:get_info_source()
        local path = source:match('^@(.+)$')
        if reload:isValidPath(path) then
            timer:remove()
        end
    end
end

M.register('RD', function ()
    y3.reload.reload()
end)

y3.reload.onBeforeReload(function (reload, willReload)
    remove_all_triggers_in_include(reload)
    remove_all_timers_in_include(reload)
end)

y3.game:event('玩家-发送消息', function (trg, data)
    if not y3.config.debug then
        return
    end
    if not y3.util.stringStartWith(data.str1, '-') then
        return
    end

    local content = data.str1:sub(2)
    local strs = {}
    for str in content:gmatch('[^%s]+') do
        strs[#strs+1] = str
    end

    local command = table.remove(strs, 1):lower()
    local f = M.commands[command]
    if not f then
        return
    end
    f(table.unpack(strs))
end)

return M
