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

local function OrderFactory()
    local order = 0
    return function()
        order = order + 1
        return order
    end
end

local order = OrderFactory()

local function merge(dest, ...)
    for i = 1, select('#', ...) do
        local src = select(i, ...)
        if type(src) == 'table' then
            for k, v in pairs(src) do
                dest[k] = v
            end
        end
    end
    return dest
end

local function toggle(name)
    return {
        type = 'toggle',
        name = name,
        order = order()
    }
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
        -- name = '\n' .. name .. '\n',
        name = name,
        fontSize = 'medium',
        image = [[Interface\Common\help-i]],
        imageWidth = 32,
        imageHeight = 32,
        imageCoords = {.2, .8, .2, .8}
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

local function group(name, args)
    return {
        type = 'group',
        name = name,
        order = order(),
        get = function(item)
            return Addon.sets[item[#item]]
        end,
        set = function(item, value)
            Addon.sets[item[#item]] = value
            Addon:UpdateFrames()
        end,
        args = args
    }
end

local function frame(frameId, name)
    return {
        type = 'group',
        name = name or frameId,
        set = function(item, value)
            Addon.profile[frameId][item[#item]] = value
            Addon:UpdateFrames()
        end,
        get = function(item)
            return Addon.profile[frameId][item[#item]]
        end,
        args = {
            display = header(DISPLAY),
            showBags = toggle(L.BagFrame),
            bagToggle = toggle(L.BagToggle),
            sort = toggle(L.Sort),
            money = toggle(L.Money),
            broker = toggle(L.Token),
            exclusiveReagent = merge(
                toggle(L.ExclusiveReagent),
                {
                    hidden = function()
                        return frameId ~= 'bank'
                    end
                }
            ),
            appearance = header(L.Appearance),
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
                        return Addon.profile[frameId].strata
                    end,
                    set = function(_, value)
                        Addon.profile[frameId].strata = value
                        Addon:UpdateFrames()
                    end
                }
            )
        }
    }
end

local function colors()
    local args = {}
    local types = {}
    do
        for id, name in pairs(Addon.BAG_TYPES) do
            tinsert(types, name)
        end

        sort(types)
        tinsert(types, 1, 'normal')
    end

    for i, name in ipairs(types) do
        local key = name .. 'Color'
        args[key] =
            merge(
            color(L[key:gsub('^.', strupper)]),
            {
                get = function(item)
                    local color = Addon.sets[key]
                    return color[1], color[2], color[3]
                end,
                set = function(item, ...)
                    local color = Addon.sets[key]
                    color[1], color[2], color[3] = ...
                    Addon:UpdateFrames()
                end
            }
        )
    end
    return args
end

local SetProfile = function(profile)
    Addon:SetCurrentProfile(profile)
    Addon:UpdateFrames()
end

local options = {
    type = 'group',
    args = {
        sp = merge(
            toggle(L.CharacterSpecific),
            {
                get = function()
                    return Addon.profile ~= Addon.sets.global
                end,
                set = function(_, value)
                    Addon:SetCurrentProfile(value and CopyTable(Addon.sets.global) or nil)
                    Addon:UpdateFrames()
                end,
                confirm = function()
                    return Addon.profile ~= Addon.sets.global
                end,
                confirmText = L.CharacterSpecificWarning
            }
        ),
        general = group(
            GENERAL,
            {
                desc = desc(L.GeneralDesc),
                locked = fullToggle(L.Locked),
                flashFind = fullToggle(L.FlashFind),
                emptySlots = fullToggle(L.EmptySlots),
                iconJunk = fullToggle(L.IconJunk),
                tipCount = fullToggle(L.TipCount),
                countGuild = merge(
                    fullToggle(L.CountGuild),
                    {
                        disabled = function(...)
                            return not Addon.sets.tipCount
                        end
                    }
                )
            }
        ),
        frame = {
            type = 'group',
            name = L.FrameSettings,
            order = order(),
            childGroups = 'tab',
            args = {
                desc = desc(L.FrameSettingsDesc),
                -- header = header(L.Frame),
                inventory = frame('inventory', INVENTORY_TOOLTIP),
                bank = frame('bank', BANK)
            }
        },
        events = group(
            L.DisplaySettings,
            {
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
        ),
        colored = group(
            L.ColorSettings,
            merge(
                {
                    desc = desc(L.ColorSettingsDesc),
                    color = header(L.ColorSettings),
                    glowQuality = fullToggle(L.GlowQuality),
                    glowNew = fullToggle(L.GlowNew),
                    glowQuest = fullToggle(L.GlowQuest),
                    glowUnusable = fullToggle(L.GlowUnusable),
                    glowSets = fullToggle(L.GlowSets),
                    colorSlots = fullToggle(L.ColorSlots),
                    slots = header(L.ColorSlots)
                },
                colors(),
                {
                    glowAlpha = fullRange(L.GlowAlpha, 0, 1)
                }
            )
        )
    }
}

AceConfigRegistry:RegisterOptionsTable('tdBag', options)

local options = AceConfigDialog:AddToBlizOptions('tdBag', 'tdBag')

function Option:Open(frameId)
    if frameId then
        InterfaceOptionsFrame_OpenToCategory(options)
        AceConfigDialog:SelectGroup('tdBag', 'frame', frameId)
    else
        InterfaceOptionsFrame_OpenToCategory(options)
    end
end
