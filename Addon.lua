--[[
Addon.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local Addon = tdBag
local L = LibStub('AceLocale-3.0'):GetLocale('tdBag_Config')

local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')
local AceConfigDialog   = LibStub('AceConfigDialog-3.0')

local function OrderFactory()
    local order = 0
    return function()
        order = order + 1
        return order
    end
end

local order = OrderFactory()

local function MakeFill()
    return {
        type  = 'description',
        name  = '',
        order = order(),
    }
end

local function MakeToggle(name)
    return {
        type  = 'toggle',
        name  = name,
        order = order()
    }
end

local function MakeFullToggle(name)
    return {
        type  = 'toggle',
        width = 'full',
        name  = name,
        order = order(),
    }
end

local function MakeColor(name)
    return {
        type  = 'color',
        name  = name,
        order = order(),
    }
end

local function MakeRange(name, min, max, step)
    return {
        type  = 'range',
        order = order(),
        name  = name,
        min   = min,
        max   = max,
        step  = step,
    }
end

local function MakeFullRange(name, min, max, step)
    return {
        type  = 'range',
        width = 'full',
        order = order(),
        name  = name,
        min   = min,
        max   = max,
        step  = step,
    }
end

local function MakeHeader(name)
    return {
        type  = 'header',
        order = order(),
        name  = name,
    }
end

local function MakeDesc(name)
    return {
        type  = 'description',
        order = order(),
        name  = name .. '\n',
    }
end

local function MakeBagOption(id, o)
    local sets = tdBag.profile[id]

    return {
        type  = 'group',
        name  = id,
        order = o,
        set   = function(item, value)
            sets[item[#item]] = value
            tdBag:UpdateFrames()
        end,
        get = function(item)
            return sets[item[#item]]
        end,
        args = {
            show         = MakeHeader(DISPLAY),
            sort         = MakeToggle(L.Sort),
            money        = MakeToggle(L.Money),
            broker       = MakeToggle(L.Token),
            appearance   = MakeHeader(L.Appearance),
            reverseBags  = MakeToggle(L.ReverseBags),
            reverseSlots = MakeToggle(L.ReverseSlots),
            bagBreak     = MakeToggle(L.BagBreak),
            __fill1      = MakeFill(),
            columns      = MakeRange(L.Columns, 6, 36, 1),
            alpha        = MakeRange(L.Alpha, 0, 1),
            __fill2      = MakeFill(),
            scale        = MakeRange(L.Scale, 0.2, 3),
            itemScale    = MakeRange(L.ItemScale, 0.2, 3),
            __fill3      = MakeFill(),
            strata       = {
                type   = 'select',
                name   = L.Strata,
                order  = order(),
                values = {
                    ['LOW']    = LOW,
                    ['MEDIUM'] = AUCTION_TIME_LEFT2,
                    ['HIGH']   = HIGH,
                }
            }
        }
    }
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
        desc       = MakeDesc(L.GeneralDesc),
        locked     = MakeFullToggle(L.Locked),
        tipCount   = MakeFullToggle(L.TipCount),
        flashFind  = MakeFullToggle(L.FlashFind),
        emptySlots = MakeFullToggle(L.EmptySlots)
    }
}

local show = {
    type        = 'group',
    childGroups = 'tab',
    args        = {
        desc      = MakeDesc(L.FrameSettingsDesc),
        inventory = MakeBagOption('inventory', order()),
        bank      = MakeBagOption('bank', order()),
    }
}

local events = {
    type = 'group',
    get = general.get,
    set = general.set,
    args = {
        desc             = MakeDesc(L.DisplaySettingsDesc),
        display          = MakeHeader(L.DisplayInventory),
        displayBank      = MakeFullToggle(L.DisplayBank),
        displayAuction   = MakeFullToggle(L.DisplayAuction),
        displayGuildbank = MakeFullToggle(L.DisplayGuildbank),
        displayMail      = MakeFullToggle(L.DisplayMail),
        displayPlayer    = MakeFullToggle(L.DisplayPlayer),
        displayTrade     = MakeFullToggle(L.DisplayTrade),
        displayGems      = MakeFullToggle(L.DisplayGems),
        displayCraft     = MakeFullToggle(L.DisplayCraft),
        close            = MakeHeader(L.CloseInventory),
        closeBank        = MakeFullToggle(L.CloseBank),
        closeCombat      = MakeFullToggle(L.CloseCombat),
        closeVehicle     = MakeFullToggle(L.CloseVehicle),
        closeVendor      = MakeFullToggle(L.CloseVendor),
    }
}

local colored = {
    type = 'group',
    get  = general.get,
    set  = general.set,
    args = {
        desc         = MakeDesc(L.ColorSettingsDesc),
        glowQuality  = MakeFullToggle(L.GlowQuality),
        glowNew      = MakeFullToggle(L.GlowNew),
        glowQuest    = MakeFullToggle(L.GlowQuest),
        glowUnusable = MakeFullToggle(L.GlowUnusable),
        glowSets     = MakeFullToggle(L.GlowSets),
        colorSlots   = MakeFullToggle(L.ColorSlots),
        colors       = {
            type  = 'group',
            name  = 'colors',
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
            args  = {
            }
        },
        glowAlpha = MakeFullRange(L.GlowAlpha, 0, 1)
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
        colored.args.colors.args[key] = MakeColor(L[key:gsub('^.', strupper)])
    end
end

AceConfigRegistry:RegisterOptionsTable('tdBag', general)
AceConfigRegistry:RegisterOptionsTable('tdBag Frame', show)
AceConfigRegistry:RegisterOptionsTable('tdBag Display', events)
AceConfigRegistry:RegisterOptionsTable('tdBag Color', colored)

AceConfigDialog:AddToBlizOptions('tdBag', 'tdBag')
AceConfigDialog:AddToBlizOptions('tdBag Frame', L.FrameSettings, 'tdBag')
AceConfigDialog:AddToBlizOptions('tdBag Display', L.DisplaySettings, 'tdBag')
AceConfigDialog:AddToBlizOptions('tdBag Color', L.ColorSettings, 'tdBag')

tdBag.GeneralOptions = {
    Open = nop
}

tdBag.FrameOptions = {
    Open = nop
}

print(1)


dump(Addon.sets)
