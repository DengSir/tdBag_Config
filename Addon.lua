--[[
Addon.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]
local Addon = tdBag
local L = LibStub('AceLocale-3.0'):GetLocale('tdBag_Config')

local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')

local Option = {}
Addon.Option = Option

Option.frameID = 'inventory'

local function OrderFactory()
    local order = 0
    return function()
        order = order + 1
        return order
    end
end

local order = OrderFactory()

local function merge(dest, src)
    if type(src) == 'table' then
        for k, v in pairs(src) do
            dest[k] = v
        end
    end
    return dest
end

local function toggle(name, more)
    return merge(
        {
            type = 'toggle',
            name = name,
            order = order()
        },
        more
    )
end

local function fullToggle(name)
    return {
        type = 'toggle',
        width = 'full',
        name = name,
        order = order()
    }
end

local function color(name)
    return {
        type = 'color',
        name = name,
        order = order()
    }
end

local function range(name, min, max, step)
    return {
        type = 'range',
        order = order(),
        name = name,
        min = min,
        max = max,
        step = step
    }
end

local function fullRange(name, min, max, step)
    return {
        type = 'range',
        width = 'full',
        order = order(),
        name = name,
        min = min,
        max = max,
        step = step
    }
end

local function header(name)
    return {
        type = 'header',
        order = order(),
        name = name
    }
end

local function desc(name)
    return {
        type = 'description',
        order = order(),
        name = name .. '\n'
    }
end

local function drop(opts)
    local old = {}
    local new = {}

    local get, set = opts.get, opts.set
    if opts.values and set then
        opts.set = function(item, value)
            return set(item, old[value])
        end
    end
    if opts.values and get then
        opts.get = function(item)
            return new[get(item)]
        end
    end

    if opts.values then
        local values = {}
        local len = #opts.values
        local F = format('%%%dd\001%%s', len)

        for i, v in ipairs(opts.values) do
            local f = format(F, i, v.value)
            values[f] = v.name
            old[f] = v.value
            new[v.value] = f
        end

        opts.values = values
    end

    opts.type = 'select'
    opts.order = order()

    return opts
end

local general = {
    type = 'group',
    get = function(item)
        return Addon.sets[item[#item]]
    end,
    set = function(item, value)
        Addon.sets[item[#item]] = value
        Addon:UpdateFrames()
    end,
    args = {
        desc = desc(L.GeneralDesc),
        locked = fullToggle(L.Locked),
        tipCount = fullToggle(L.TipCount),
        flashFind = fullToggle(L.FlashFind),
        emptySlots = fullToggle(L.EmptySlots)
    }
}

local frame = {
    type = 'group',
    childGroups = 'tab',
    set = function(item, value)
        Addon.profile[Option.frameID][item[#item]] = value
        Addon:UpdateFrames()
    end,
    get = function(item)
        return Addon.profile[Option.frameID][item[#item]]
    end,
    args = {
        desc = desc(L.FrameSettingsDesc),
        header = header(L.Frame),
        frame = drop(
            {
                name = L.Frame,
                values = {
                    {name = INVENTORY_TOOLTIP, value = 'inventory'},
                    {name = BANK, value = 'bank'}
                },
                get = function()
                    return Option.frameID
                end,
                set = function(_, value)
                    Option.frameID = value
                end
            }
        ),
        display = {
            type = 'group',
            name = DISPLAY,
            inline = true,
            order = order(),
            args = {
                showBags = toggle(L.BagFrame),
                bagToggle = toggle(L.BagToggle),
                sort = toggle(L.Sort),
                money = toggle(L.Money),
                broker = toggle(L.Token),
                exclusiveReagent = toggle(
                    L.ExclusiveReagent,
                    {
                        hidden = function()
                            return Option.frameID ~= 'bank'
                        end
                    }
                )
            }
        },
        appearance = {
            type = 'group',
            name = L.Appearance,
            inline = true,
            order = order(),
            args = {
                managed = toggle(L.ActPanel),
                reverseBags = toggle(L.ReverseBags),
                reverseSlots = toggle(L.ReverseSlots),
                columns = range(L.Columns, 6, 36, 1),
                alpha = range(L.Alpha, 0, 1),
                scale = range(L.Scale, 0.2, 3),
                itemScale = range(L.ItemScale, 0.2, 3),
                strata = drop(
                    {
                        name = L.Strata,
                        values = {
                            {name = LOW, value = 'LOW'},
                            {name = AUCTION_TIME_LEFT2, value = 'MEDIUM'},
                            {name = HIGH, value = 'HIGH'}
                        },
                        get = function()
                            return Addon.profile[Option.frameID].strata
                        end,
                        set = function(_, value)
                            Addon.profile[Option.frameID].strata = value
                            Addon:UpdateFrames()
                        end
                    }
                )
            }
        }
    }
}

local events = {
    type = 'group',
    get = general.get,
    set = general.set,
    args = {
        desc = desc(L.DisplaySettingsDesc),
        display = header(L.DisplayInventory),
        displayBank = fullToggle(L.DisplayBank),
        displayAuction = fullToggle(L.DisplayAuction),
        displayGuildbank = fullToggle(L.DisplayGuildbank),
        displayMail = fullToggle(L.DisplayMail),
        displayPlayer = fullToggle(L.DisplayPlayer),
        displayTrade = fullToggle(L.DisplayTrade),
        displayGems = fullToggle(L.DisplayGems),
        displayCraft = fullToggle(L.DisplayCraft),
        close = header(L.CloseInventory),
        closeBank = fullToggle(L.CloseBank),
        closeCombat = fullToggle(L.CloseCombat),
        closeVehicle = fullToggle(L.CloseVehicle),
        closeVendor = fullToggle(L.CloseVendor),
        closeMap = fullToggle(L.CloseMap)
    }
}

local colored = {
    type = 'group',
    get = general.get,
    set = general.set,
    args = {
        desc = desc(L.ColorSettingsDesc),
        glowQuality = fullToggle(L.GlowQuality),
        glowNew = fullToggle(L.GlowNew),
        glowQuest = fullToggle(L.GlowQuest),
        glowUnusable = fullToggle(L.GlowUnusable),
        glowSets = fullToggle(L.GlowSets),
        colorSlots = fullToggle(L.ColorSlots),
        iconJunk = fullToggle(L.IconJunk),
        colors = {
            type = 'group',
            name = L.ColorSlots,
            order = order(),
            inline = true,
            get = function(item)
                local color = Addon.sets[item[#item]]
                return color[1], color[2], color[3]
            end,
            set = function(item, ...)
                local color = Addon.sets[item[#item]]
                color[1], color[2], color[3] = ...
                Addon:UpdateFrames()
            end,
            args = {}
        },
        glowAlpha = fullRange(L.GlowAlpha, 0, 1)
    }
}

do
    local SLOT_COLOR_TYPES = {}
    for id, name in pairs(Addon.BAG_TYPES) do
        tinsert(SLOT_COLOR_TYPES, name)
    end

    sort(SLOT_COLOR_TYPES)
    tinsert(SLOT_COLOR_TYPES, 1, 'normal')

    for i, name in ipairs(SLOT_COLOR_TYPES) do
        local key = name .. 'Color'
        colored.args.colors.args[key] = color(L[key:gsub('^.', strupper)])
    end
end

AceConfigRegistry:RegisterOptionsTable('tdBag', general)
AceConfigRegistry:RegisterOptionsTable('tdBag - ' .. L.FrameSettings, frame)
AceConfigRegistry:RegisterOptionsTable('tdBag - ' .. L.DisplaySettings, events)
AceConfigRegistry:RegisterOptionsTable('tdBag - ' .. L.ColorSettings, colored)

local general = AceConfigDialog:AddToBlizOptions('tdBag', 'tdBag')
local frame = AceConfigDialog:AddToBlizOptions('tdBag - ' .. L.FrameSettings, L.FrameSettings, 'tdBag')
local events = AceConfigDialog:AddToBlizOptions('tdBag - ' .. L.DisplaySettings, L.DisplaySettings, 'tdBag')
local colored = AceConfigDialog:AddToBlizOptions('tdBag - ' .. L.ColorSettings, L.ColorSettings, 'tdBag')

function Option:Open(frameID)
    if frameID then
        self.frameID = frameID
        InterfaceOptionsFrame_OpenToCategory(frame)
    else
        InterfaceOptionsFrame_OpenToCategory(general)
    end
end
