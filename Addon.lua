--[[
Addon.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]

local Addon = tdBag
local L = LibStub('AceLocale-3.0'):GetLocale('tdBag_Config')

local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')
local AceConfigDialog   = LibStub('AceConfigDialog-3.0')

local Option = {} Addon.Option = Option

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

local function MakeFill()
    return {
        type  = 'description',
        name  = '',
        order = order(),
    }
end

local function MakeToggle(name, more)
    return merge({
        type  = 'toggle',
        name  = name,
        order = order()
    }, more)
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

local function MakeSelect(opts)
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

    opts.type  = 'select'
    opts.order = order()

    return opts
end

local SetProfile = function(profile)
	Addon:SetProfile(profile)
	Addon.profile = Addon:GetProfile()
	Addon:UpdateFrames()
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

local displayDefine = {
    inventory = {
        showBags = true,
        bagFrame = true,
        sort     = true,
        money    = true,
        broker   = true,
        actPanel = true,
    },
    bank = {
        showBags         = true,
        bagFrame         = true,
        sort             = true,
        money            = true,
        broker           = true,
        exclusiveReagent = true,
        actPanel         = true,
    },
    guild = {
        money    = true,
        actPanel = true,
    },
    vault = {
        actPanel = true,
    },
}

local displayMore = {
    hidden = function(item)
        return not displayDefine[Option.frameID][item[#item]]
    end
}

local frame = {
    type        = 'group',
    childGroups = 'tab',
    set    = function(item, value)
        Addon.profile[Option.frameID][item[#item]] = value
        Addon:UpdateFrames()
    end,
    get = function(item)
        return Addon.profile[Option.frameID][item[#item]]
    end,
    args        = {
        desc      = MakeDesc(L.FrameSettingsDesc),
        specific = {
            type  = 'toggle',
            name  = L.CharacterSpecific,
            order = order(),
            width = 'full',
            confirm = function()
                return not not Addon:GetSpecificProfile()
            end,
            confirmText = L.CharacterSpecificWarning,
            get = function()
                return Addon:GetSpecificProfile()
            end,
            set = function(_, value)
                SetProfile(value and CopyTable(Addon.sets.global) or nil)
            end,
        },
        header = MakeHeader(L.Frame),
        frame  = MakeSelect({
            name = L.Frame,
            values = {
                { name = INVENTORY_TOOLTIP, value = 'inventory' },
                { name = BANK,              value = 'bank' },
                { name = GUILD_BANK,        value = 'guild' },
                { name = VOID_STORAGE,      value = 'vault' },
            },
            get = function() return  Option.frameID end,
            set = function(_, value) Option.frameID = value end,
        }),
        display = {
            type   = 'group',
            name   = DISPLAY,
            inline = true,
            order  = order(),
            args   = {
                showBags         = MakeToggle(L.BagFrame,         displayMore),
                bagFrame         = MakeToggle(L.BagToggle,        displayMore),
                sort             = MakeToggle(L.Sort,             displayMore),
                money            = MakeToggle(L.Money,            displayMore),
                broker           = MakeToggle(L.Token,            displayMore),
                exclusiveReagent = MakeToggle(L.ExclusiveReagent, displayMore),
                actPanel         = MakeToggle(L.ActPanel, {
                    hidden = displayMore.hidden,
                    set = function(item, value)
                        Addon.profile[Option.frameID][item[#item]] = value
                        Addon:GetFrame(Option.frameID):UpdateActPanel()
                    end,
                }),
            }
        },
        appearance = {
            type   = 'group',
            name   = L.Appearance,
            inline = true,
            order  = order(),
            args   = {
                reverseBags  = MakeToggle(L.ReverseBags),
                reverseSlots = MakeToggle(L.ReverseSlots),
                bagBreak     = MakeToggle(L.BagBreak),
                columns      = MakeRange(L.Columns, 6, 36, 1),
                alpha        = MakeRange(L.Alpha, 0, 1),
                scale        = MakeRange(L.Scale, 0.2, 3),
                itemScale    = MakeRange(L.ItemScale, 0.2, 3),
                strata       = MakeSelect({
                    name = L.Strata,
                    values = {
                        { name = LOW,                value = 'LOW' },
                        { name = AUCTION_TIME_LEFT2, value = 'MEDIUM' },
                        { name = HIGH,               value = 'HIGH' },
                    },
                    get = function() return  Addon.profile[Option.frameID].strata end,
                    set = function(_, value) Addon.profile[Option.frameID].strata = value end,
                })
            }
        },
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
            name  = L.ColorSlots,
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
AceConfigRegistry:RegisterOptionsTable('tdBag - ' .. L.FrameSettings, frame)
AceConfigRegistry:RegisterOptionsTable('tdBag - ' .. L.DisplaySettings, events)
AceConfigRegistry:RegisterOptionsTable('tdBag - ' .. L.ColorSettings, colored)

local general = AceConfigDialog:AddToBlizOptions('tdBag', 'tdBag')
local frame   = AceConfigDialog:AddToBlizOptions('tdBag - ' .. L.FrameSettings, L.FrameSettings, 'tdBag')
local events  = AceConfigDialog:AddToBlizOptions('tdBag - ' .. L.DisplaySettings, L.DisplaySettings, 'tdBag')
local colored = AceConfigDialog:AddToBlizOptions('tdBag - ' .. L.ColorSettings, L.ColorSettings, 'tdBag')

local function OpenToCategory(f)
    InterfaceOptionsFrame_OpenToCategory(f)
    InterfaceOptionsFrame_OpenToCategory(f)
    OpenToCategory = InterfaceOptionsFrame_OpenToCategory
end

function Option:Open(frameID)
    if frameID then
        self.frameID = frameID
        OpenToCategory(frame)
    else
        OpenToCategory(general)
    end
end
