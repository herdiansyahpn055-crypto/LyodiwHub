--[[
    LYODIW HUB X - PREMIER (FINAL REPAIR - VERSION 1.74)
    STATUS: FIXED TAB RENDERING & ELEMENT VISIBILITY
    DEVELOPER: HERDIANSYAH PERMANA N.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 1. CONFIGURATION (Lengkap & Utuh sesuai permintaan)
local Config = {
    AutoFish = false,
    DelayCatch = 0.5,
    AutoSell = false,
    AutoEquip = true,
    CustomLuck = 999999,
    AdminLuckLoop = false,
    VisualVFX = false,
    AutoFavSecret = true,
    EventBuff = true,
    Stats = {Caught = 0}
}

local player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

-- 2. CREATE WINDOW
local Window = Rayfield:CreateWindow({
   Name = "LYODIW HUB X",
   Icon = "layout-grid", -- Menggunakan Lucide Icon String agar tidak terblokir
   LoadingTitle = "LYODIW INTERFACE",
   LoadingSubtitle = "by Herdiansyah Permana N.",
   Theme = "AmberGlow",
   ConfigurationSaving = { Enabled = false }
})

-- ======================================================
-- TABS & SECTIONS (DIJAMIN MUNCUL DENGAN STRUKTUR INI)
-- ======================================================

-- --- MAIN TAB ---
local M = Window:CreateTab("MAIN", "fish")
local MainSection = M:CreateSection("Auto Fishing", false) -- Wajib Section
M:CreateToggle({
   Name = "Auto Fishing (Super Fast)",
   CurrentValue = false,
   Flag = "Lyodiw_MainFish",
   Callback = function(v) Config.AutoFish = v end,
})
M:CreateSlider({
   Name = "Catch Delay",
   Min = 0.1, Max = 2, CurrentValue = 0.5,
   Flag = "Lyodiw_MainDelay",
   Callback = function(v) Config.DelayCatch = v end,
})
M:CreateToggle({
   Name = "Event & Secret Buff",
   CurrentValue = true,
   Flag = "Lyodiw_MainBuff",
   Callback = function(v) Config.EventBuff = v end,
})

-- --- SELL TAB ---
local S = Window:CreateTab("SELL", "banknote")
local SellSection = S:CreateSection("Sell Settings", false)
S:CreateToggle({
   Name = "Auto Sell All (After Catch)",
   CurrentValue = false,
   Flag = "Lyodiw_SellAuto",
   Callback = function(v) Config.AutoSell = v end,
})
local manualSellBtn = S:CreateButton({
   Name = "Manual Sell All Inventory",
   Callback = function() end, -- Diisi di engine
})
S:CreateToggle({
   Name = "Auto Favorite Secret/Event",
   CurrentValue = true,
   Flag = "Lyodiw_SellFav",
   Callback = function(v) Config.AutoFavSecret = v end,
})

-- --- LUCK TAB ---
local L = Window:CreateTab("LUCK", "sparkles")
local LuckSection = L:CreateSection("Luck Boosters", false)
L:CreateSlider({
   Name = "Custom Luck Multiplier",
   Min = 1, Max = 999999, CurrentValue = 999999,
   Flag = "Lyodiw_LuckVal",
   Callback = function(v) Config.CustomLuck = v end,
})
L:CreateToggle({
   Name = "Infinite Admin Luck",
   CurrentValue = false,
   Flag = "Lyodiw_LuckAdmin",
   Callback = function(v) Config.AdminLuckLoop = v end,
})

-- --- TELEPORT TAB ---
local T = Window:CreateTab("TELE", "map-pin")
local TeleSection = T:CreateSection("World Locations", false)
local Locations = {
    ["Merapi"] = Vector3.new(2794.06, 158.44, -823.93),
    ["Base"] = Vector3.new(888.91, 145.79, -801.38),
    ["Pulau Es"] = Vector3.new(510.91, 135.40, -243.08),
    ["Enchant"] = Vector3.new(1557.66, 143.69, -2965.51),
    ["Crismis"] = Vector3.new(534.43, 139.02, -2639.08),
    ["Pasir"] = Vector3.new(-585.36, 138.65, -1850.34),
    ["Esotrea"] = Vector3.new(-1205.72, 143.58, -546.76),
    ["Rantau"] = Vector3.new(-1151.12, 140.07, 750.76),
    ["Baretam"] = Vector3.new(369.80, 135.68, 867.16),
    ["Megalodon Core"] = Vector3.new(548.60, 130.58, -1078.13),
    ["Leviathan Core"] = Vector3.new(740.38, 130.58, -443.73),
    ["Sea Eater"] = Vector3.new(857.32, 131.95, -1037.80),
    ["King Eleking"] = Vector3.new(923.94, 131.68, -1295.80)
}
for Name, Cord in pairs(Locations) do
    T:CreateButton({
        Name = "Tele to " .. Name,
        Callback = function() 
            pcall(function() player.Character.HumanoidRootPart.CFrame = CFrame.new(Cord) + Vector3.new(0,5,0) end)
        end
    })
end

-- --- MISC TAB ---
local MISC = Window:CreateTab("MISC", "wrench")
local MiscSection = MISC:CreateSection("Other Scripts", false)
MISC:CreateToggle({
    Name = "Auto Equip Rod",
    CurrentValue = true,
    Flag = "Lyodiw_MiscEquip",
    Callback = function(v) Config.AutoEquip = v end
})
local favAllAction = nil
MISC:CreateButton({
    Name = "Toggle Favorite All",
    Callback = function() if favAllAction then favAllAction() end end,
})
MISC:CreateDropdown({
   Name = "Force Purchase Shop",
   Options = {"Lightning", "Purple Saber Skin", "Manifest", "Abyssal Rod", "Pinked Bobber", "Lucky Bobber"},
   CurrentOption = {"Lightning"},
   Flag = "Lyodiw_MiscShop",
   Callback = function(Option) _G.SelectedTool = Option[1] end,
})
local buyAction = nil
MISC:CreateButton({
    Name = "Confirm Purchase",
    Callback = function() if buyAction then buyAction() end end,
})

-- --- STATS TAB ---
local STATS = Window:CreateTab("STATS", "line-chart")
local StatSection = STATS:CreateSection("Tracking", false)
local FishLabel = STATS:CreateLabel("Ikan Didapat: 0")
STATS:CreateButton({
    Name = "Reset Stats",
    Callback = function()
        Config.Stats.Caught = 0
        FishLabel:Set("Ikan Didapat: 0")
    end
})

-- ======================================================
-- ENGINE & REMOTE LOGIC
-- ======================================================

task.spawn(function()
    local FishingSystem = RS:WaitForChild("FishingSystem", 20)
    local remotes = {}
    
    if FishingSystem then
        remotes = {
            castRep = FishingSystem:FindFirstChild("CastReplication"),
            rollFish = FishingSystem:FindFirstChild("RollFishEvent"),
            catchSuccess = FishingSystem:FindFirstChild("FishingCatchSuccess"),
            sellRem = FishingSystem:FindFirstChild("SellFish"),
            buyRodRem = FishingSystem:FindFirstChild("RodShopEvents") and FishingSystem.RodShopEvents:FindFirstChild("RequestPurchase"),
            luckRem = FishingSystem:FindFirstChild("LuckBoost") or RS:FindFirstChild("AdminLuckBoostEvent"),
            favRem = FishingSystem:FindFirstChild("Inventory_ToggleFavorite")
        }
    end

    -- Integrasi Engine ke UI
    manualSellBtn.Callback = function() pcall(function() if remotes.sellRem then remotes.sellRem:FireServer("SellAll") end end) end
    favAllAction = function() pcall(function() if remotes.favRem then remotes.favRem:FireServer("All") end end) end
    buyAction = function() pcall(function() if _G.SelectedTool and remotes.buyRodRem then remotes.buyRodRem:FireServer(_G.SelectedTool) end end) end
    
    while true do
        task.wait(0.1)
        if Config.AutoFish and remotes.castRep then
            pcall(function()
                remotes.castRep:FireServer()
                task.wait(Config.EventBuff and 0.4 or Config.DelayCatch)
                if remotes.rollFish then remotes.rollFish:FireServer() end
                
                local success = false
                if remotes.catchSuccess then
                    success = remotes.catchSuccess:InvokeServer(true, Config.CustomLuck)
                end
                
                if success then
                    Config.Stats.Caught = Config.Stats.Caught + 1
                    FishLabel:Set("Ikan Didapat: " .. Config.Stats.Caught)
                    if Config.AutoSell and remotes.sellRem then
                        task.wait(0.2)
                        remotes.sellRem:FireServer("SellAll")
                    end
                end
            end)
        end
        
        if Config.AdminLuckLoop and remotes.luckRem then
            pcall(function() remotes.luckRem:FireServer(Config.CustomLuck) end)
        end
        if Config.AutoEquip and player.Character and player.Character:FindFirstChild("Humanoid") then
            pcall(function()
                for _, t in pairs(player.Backpack:GetChildren()) do
                    if t:IsA("Tool") and (t.Name:find("Rod") or t.Name:find("Saber")) then
                        player.Character.Humanoid:EquipTool(t)
                    end
                end
            end)
        end
    end
end)

-- Tombol Floating (Minimalkan/Tampilkan)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0, 45, 0, 45)
Btn.Position = UDim2.new(0, 10, 0.45, 0)
Btn.Text = "L"
Btn.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
Btn.TextColor3 = Color3.new(1,1,1)
Btn.Draggable = true
Btn.Active = true
Btn.MouseButton1Click:Connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
end)

Rayfield:Notify({
   Title = "LYODIW HUB X",
   Content = "Tab & Fitur Berhasil Diperbaiki!",
   Duration = 5,
   Image = "check",
}
