mod_gui = require("mod-gui")

---@class GUIBuilder
local gui_builder = {}

-- CONSTANTS
gui_builder.flowButtonName = "CT_toggle_gui"
gui_builder.mainFrameName = "CT_main_guiFrame"
gui_builder.preferencesFrameName = "CT_preferences_guiFrame"

---@param frame LuaGuiElement
---@param isMainFrame boolean
local function titleBar(frame, isMainFrame)
    local bar = frame.add{
        type = "flow",
        name = "title_bar"
    }
    bar.drag_target = frame
    bar.style.horizontal_spacing = 8
    bar.style.height = 28

    local title
    local close_callback
    if isMainFrame then
        title = {"gui.main-title"}
        close_callback = "toggle_main"
    else
        title = {"gui.preferences-title"}
        close_callback = "toggle_preferences"
    end

    -- title
    bar.add{
        type = "label",
        style = "frame_title",
        caption = title,
        ignored_by_interaction = true
    }

    -- drag area
    bar.add{
        type = "empty-widget",
        style = "ct_title_dragbar",
        ignored_by_interaction = true
    }

    if isMainFrame then

        -- surface selection
        local surfaces = {}

        for _, surface in pairs(game.surfaces) do
            surfaces[#surfaces+1] = surface.name
        end

        bar.add{
            type = "drop-down",
            name = "surface_select",
            style = "ct_frame_dropdown",
            selected_index = 1,
            visible = (#surfaces > 1),
            items = surfaces,
            tags = {
                mod = "constructron",
                on_gui_selection_state_changed = "selected_new_surface"
            }
        }

        -- preference button
        bar.add{
            type = "button",
            style = "ct_frame_button",
            name = "preference_button",
            caption = {"gui.preferences"},
            mouse_button_filter = {"left"},
            tags = {
                mod = "constructron",
                on_gui_click = "toggle_preferences"
            }
        }

        -- seperator line
        local seperator = bar.add{
            type = "line",
            direction = "vertical",
            ignored_by_interaction = true
        }
        seperator.style.height = 24
    end

    -- close button
    bar.add{
        type = "sprite-button",
        name = "close_button",
        style = "frame_action_button",
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        mouse_button_filter = {"left"},
        tags = {
            mod = "constructron",
            on_gui_click = close_callback
        }
    }
end

---@param name string
---@param tab_flow LuaGuiElement
local function buildTabContent(name, tab_flow)
    local entityListFrame = tab_flow.add{
        type = "frame",
        name = "frame",
        direction = "vertical",
        style = "deep_frame_in_shallow_frame"
    }
    --entityListFrame.style.maximal_height = 750
    --entityListFrame.style.horizontally_stretchable = true
    --entityListFrame.style.vertically_stretchable = true

    local noEntityFrame = entityListFrame.add{
        type = "frame",
        name = "no_entity",
        style = "negative_subheader_frame"
    }
    noEntityFrame.style.bottom_margin = -36

    local noEntityFlow = noEntityFrame.add{
        type = "flow",
        name = "flow",
        direction = "horizontal",
        style = "centering_horizontal_flow"
    }
    noEntityFlow.style.horizontally_stretchable = true

    noEntityFlow.add{
        type = "label",
        name = "label",
        caption = {"gui.tab-empty-warn", {"gui." .. name}, "nauvis"}
    }

    local entityScroll = entityListFrame.add{
        type = "scroll-pane",
        name = "scroll",
        --style = "technology_list_scroll_pane"
    }
    --entityScroll.style.vertically_stretchable = true
    --entityScroll.style.horizontally_stretchable = true
    entityScroll.style.height = 710
    entityScroll.horizontal_scroll_policy = "never"
    entityScroll.vertical_scroll_policy = "auto-and-reserve-space"
    entityScroll.style.extra_padding_when_activated = 0

    local entityTable = entityScroll.add{
        type = "table",
        name = "table",
        column_count = 4,
        --style = "technology_slot_table"
    }
    entityTable.style.vertically_stretchable = true
    entityTable.style.horizontally_stretchable = true
    entityTable.style.horizontal_spacing = 0
    entityTable.style.vertical_spacing = 0
    entityTable.style.width = 1136
end

---@param name string
---@param count uint
---@param tabbed_pane LuaGuiElement
local function buildTab(name, count, tabbed_pane)
    local tab = tabbed_pane.add{
        type = "tab",
        name = name .. "_tab",
        caption = {"gui.tab-" .. name},
        tags = {
            tab_type = name
        }
    }
    if count < 1000 then
        tab.badge_text = count
    else
        tab.badge_text = "999+"
    end

    local tabFlow = tabbed_pane.add{
        type = "flow",
        name = name .. "_flow",
        direction = "horizontal",
        style = "inset_frame_container_horizontal_flow_in_tabbed_pane"
    }
    tabFlow.style.horizontally_stretchable = true
    tabFlow.style.vertically_stretchable = true

    tabbed_pane.add_tab(tab, tabFlow)

    buildTabContent(name, tabFlow)
end

---@param frame LuaGuiElement
local function buildMainContent(frame)
    local tabPaneFrame = frame.add{
        type = "frame",
        name = "main",
        style = "inside_deep_frame_for_tabs"
    }
    --tabPaneFrame.style.height = 350
    tabPaneFrame.style.vertically_stretchable = true
    tabPaneFrame.style.horizontally_stretchable = true

    local tabbedPane = tabPaneFrame.add{
        type = "tabbed-pane",
        name = "tab_pane",
        tags = {
            mod = "constructron",
            on_gui_selected_tab_changed  = "update_tab_content"
        }
    }
    tabbedPane.style.vertically_stretchable = true
    tabbedPane.style.horizontally_stretchable = true

    buildTab("idle", 0, tabbedPane)
    buildTab("construct", 420, tabbedPane)
    buildTab("deconstruct", 1337, tabbedPane)
    buildTab("upgrade", 69, tabbedPane)
    buildTab("repair", 42, tabbedPane)

    tabbedPane.selected_tab_index = 1
end

---@param player LuaPlayer
function gui_builder.buildMainGui(player)
    local frame = player.gui.screen.add{
        type = "frame",
        name = gui_builder.mainFrameName,
        direction = "vertical"
    }
    frame.auto_center = true
    frame.style.horizontally_stretchable = true
    frame.style.vertically_stretchable = true

    titleBar(frame, true)
    buildMainContent(frame)
end

---@param player LuaPlayer
function gui_builder.buildPreferencesGui(player)
    local frame = player.gui.screen.add{
        type = "frame",
        name = gui_builder.preferencesFrameName,
        direction = "vertical"
    }
    frame.auto_center = true

    titleBar(frame, false)
end

---@param buttonFlow LuaGuiElement
function gui_builder.buildModGuiButton(buttonFlow)
    buttonFlow.add{
        type = "button",
        name = gui_builder.flowButtonName,
        caption = "CT",
        tooltip = "Toggle the Constructron interface",
        mouse_button_filter = {"left"},
        visibility = true,
        style = mod_gui.button_style,
        tags = {
            mod = "constructron",
            on_gui_click = "toggle_main"
        }
    }
end

return gui_builder
