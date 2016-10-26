--[[
cn.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]


local L = LibStub('AceLocale-3.0'):NewLocale('tdBag_Config', 'zhCN')
if not L then return end

L.GeneralDesc     = '通用偏好设置。'
L.Locked          = '锁定位置'
L.TipCount        = '鼠标提示物品统计'
L.FlashFind       = '闪烁搜索'
L.EmptySlots      = '空格背景材质'
L.DisplayBlizzard = 'Display Blizzard Frames for Hidden Bags'

L.FrameSettings     = '背包设置'
L.FrameSettingsDesc = '背包偏好设置。'
L.Frame             = '背包'
L.Enabled           = 'Enable Frame'
L.CharacterSpecific = '角色独立设置'
L.ExclusiveReagent  = '独立材料银行'

L.CharacterSpecificWarning = 'Are you sure you want to disable specific settings for this character? All specific settings will be lost.'

L.BagFrame  = '背包列表'
L.Money     = '金币'
L.Sort      = '整理按钮'
L.Token     = '货币'
L.Options   = 'Options Button'
L.BagToggle = '背包按钮'

L.Appearance   = '外观'
L.Layer        = '层级'
L.BagBreak     = '背包分散'
L.ReverseBags  = '反向背包排列'
L.ReverseSlots = '反向物品排列'
L.Strata       = '层级'
L.Columns      = '列数'
L.Scale        = '绽放'
L.ItemScale    = '物品绽放'
L.Alpha        = '不透明度'

L.DisplaySettings     = '自动显示'
L.DisplaySettingsDesc = '设置在哪些游戏事件下打开或关闭背包。'
L.DisplayInventory    = '打开背包'
L.CloseInventory      = '关闭背包'

L.DisplayBank      = '打开银行时'
L.DisplayAuction   = '打开拍卖行时'
L.DisplayTrade     = '与玩家交易时'
L.DisplayCraft     = '打开商业技能时'
L.DisplayMail      = '打开邮箱时'
L.DisplayGuildbank = '打开公会银行时'
L.DisplayPlayer    = '打开角色信息时'
L.DisplayGems      = '打开物品镶嵌时'

L.CloseCombat  = '进入战斗时'
L.CloseVehicle = '进入载具时'
L.CloseBank    = '关闭银行时'
L.CloseVendor  = '关闭商贩时'

L.ColorSettings     = '颜色设置'
L.ColorSettingsDesc = '物品边框着色设置。'
L.GlowQuality       = '根据物品品质着色'
L.GlowNew           = '对新物品着色'
L.GlowQuest         = '对任务物品着色'
L.GlowUnusable      = '对不可用物品着色'
L.GlowSets          = '对套装物品着色'
L.ColorSlots        = '根据容器类型对空格着色'

L.NormalColor   = '普通容器颜色'
L.LeatherColor  = '制皮材料包颜色'
L.InscribeColor = '铭文包颜色'
L.HerbColor     = '草药袋颜色'
L.EnchantColor  = '附魔材料袋颜色'
L.EngineerColor = '工程学材料袋颜色'
L.GemColor      = '宝石袋颜色'
L.MineColor     = '矿石袋颜色'
L.TackleColor   = '工具箱颜色'
L.RefrigeColor  = '烹饪包颜色'
L.ReagentColor  = '材料银行颜色'
L.GlowAlpha     = '边框着色亮度'
