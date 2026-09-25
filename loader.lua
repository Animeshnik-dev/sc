-- Ryzen Universal Loader
local PlaceId = game.PlaceId

local Scripts = {
    [155382109]       = "https://raw.githubusercontent.com/Animeshnik-dev/sc/refs/heads/hub/Zona%2051.lua", -- Zona 51
    [142823291]       = "https://raw.githubusercontent.com/Animeshnik-dev/sc/refs/heads/hub/Ryzen.lua",     -- MM2
    [537413528]       = "https://raw.githubusercontent.com/Animeshnik-dev/sc/refs/heads/hub/BABT.lua",      -- Build a Boat
    [136801880565837] = "https://raw.githubusercontent.com/Animeshnik-dev/sc/refs/heads/hub/flick.lua",     -- Flick FPS
    [17625359962]      = "https://raw.githubusercontent.com/Animeshnik-dev/sc/refs/heads/hub/rivals.lua",    -- Rivals (вставь PlaceId)
}

local ScriptURL = Scripts[PlaceId]

if ScriptURL == nil then
    warn("Игра не поддерживается. PlaceId: " .. PlaceId)
    return
end

local function fetch(url)
    if game.HttpGet then return game:HttpGet(url) end
    if syn and syn.request then return syn.request({Url=url, Method="GET"}).Body end
    if request then return request({Url=url, Method="GET"}).Body end
    if http_request then return http_request({Url=url, Method="GET"}).Body end
    error("Нет метода HTTP-запроса")
end

local body
for i = 1, 3 do
    local ok, res = pcall(fetch, ScriptURL)
    if ok and type(res) == "string" and #res > 100 and res:find("return setmetatable", 1, true) then
        body = res
        break
    end
    task.wait(0.5)
end

if not body then
    warn("Не удалось скачать валидный скрипт.")
    return
end

local fn, err = loadstring(body, "=Ryzen_" .. PlaceId)
if not fn then
    warn("Compile err: " .. tostring(err))
    return
end

local ok, e = pcall(fn)
if not ok then
    warn("Runtime err: " .. tostring(e))
end
