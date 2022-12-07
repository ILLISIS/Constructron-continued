local gui_event_type = {
    [defines.events.on_gui_click] = "on_gui_click",
    [defines.events.on_gui_selection_state_changed] = "on_gui_selection_state_changed"
}

local gui = {}
local gui_handler = {}
local handlers = {}

---@param player LuaPlayer
---@param _ LuaGuiElement
function handlers.toggle_main(player, _)
    gui.toggleMain(player)
end

---@param player LuaPlayer
---@param _ LuaGuiElement
function handlers.toggle_preferences(player, _)
    gui.togglePreferences(player)
end

---@param player LuaPlayer
---@param dropdown LuaGuiElement
function handlers.selected_new_surface(player, dropdown)
    gui.selectedNewSurface(player, dropdown)
end

function gui_handler.init(guiInstance)
    gui = guiInstance
end

function gui_handler.register()
    for ev, _ in pairs(gui_event_type) do
        script.on_event(ev, gui_handler.gui_event)
    end
end

---@param event 
---| EventData.on_gui_click 
---| EventData.on_gui_selection_state_changed
function gui_handler.gui_event(event)
    if not event.element then return end

    local tags = event.element.tags
    if tags.mod ~= "constructron" then return end

    -- GUI events always have an associated player
    local player = game.get_player(event.player_index)
    if not player then return end

    local event_name = gui_event_type[event.name]
    local action_name = tags[event_name]

    if not action_name then return end

    local event_handler = handlers[action_name]

    if not event_handler then return end

    event_handler(player, event.element)
end

return gui_handler