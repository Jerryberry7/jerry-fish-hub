-- Jerry Fish Hub - Roblox Auto Fishing Script
-- Created by Jerry User @Challegreger7

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- State Variables
local autoFishEnabled = false
local isClicking = false
local currentRod = nil

-- Settings
local clickDelay = 0.001 -- 1ms mellan clicks
local clicksPerBatch = 40 -- Standard: 40

-- Jerry Fish Hub Logo ID
local LOGO_ID = 86302991992117

-- Create GUI with Dark Theme (like image)
local Window = Rayfield:CreateWindow({
   Name = "Jerry Fish Hub",
   LoadingTitle = "Jerry Fish Hub",
   LoadingSubtitle = "by Jerry User @Challegreger7",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
   Theme = "DarkBlue"
})

-- Make GUI Draggable and Non-Blocking
local RayfieldUI = game:GetService("CoreGui"):FindFirstChild("Rayfield")
if RayfieldUI then
    local MainFrame = RayfieldUI:FindFirstChild("Main", true)
    if MainFrame then
        -- Enable dragging
        MainFrame.Draggable = true
        MainFrame.Active = true
        
        -- Make it non-modal (doesn't block game input)
        for _, descendant in pairs(RayfieldUI:GetDescendants()) do
            if descendant:IsA("GuiObject") then
                descendant.Modal = false
            end
        end
    end
end

-- Home Tab
local HomeTab = Window:CreateTab("🏠 HOME", LOGO_ID)

local HomeSection = HomeTab:CreateSection("Jerry Fish Hub v1.0")

HomeTab:CreateLabel("🐟 Welcome to Jerry Fish Hub!")
HomeTab:CreateLabel("👤 Created by: Jerry")
HomeTab:CreateLabel("🎮 Roblox User: @Challegreger7")
HomeTab:CreateLabel("🎣 Ultra Fast Auto Fishing System")

local HomeSection2 = HomeTab:CreateSection("Controls")

local CloseButton = HomeTab:CreateButton({
   Name = "📛 Close Script",
   Callback = function()
       Rayfield:Notify({
           Title = "Goodbye!",
           Content = "Jerry Fish Hub closing...",
           Duration = 2,
           Image = LOGO_ID,
       })
       task.wait(1)
       Rayfield:Destroy()
   end,
})

-- Main Tab (Fishing)
local MainTab = Window:CreateTab("✈️ MAIN", LOGO_ID)

local MainSection1 = MainTab:CreateSection("Auto Fishing")

-- Function: Find Fishing Rod
local function findFishingRod()
    local backpack = player:WaitForChild("Backpack")
    
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if string.find(tool.Name:lower(), "rod") or 
               string.find(tool.Name:lower(), "spö") or
               tool:GetAttribute("IsFishingRod") or 
               tool:GetAttribute("RodToken") then
                return tool
            end
        end
    end
    
    -- Check if already equipped
    local equippedTool = character:FindFirstChildOfClass("Tool")
    if equippedTool and (string.find(equippedTool.Name:lower(), "rod") or 
       string.find(equippedTool.Name:lower(), "spö") or
       equippedTool:GetAttribute("IsFishingRod")) then
        return equippedTool
    end
    
    return nil
end

-- Function: Equip Rod
local function equipRod()
    local rod = findFishingRod()
    if not rod then
        Rayfield:Notify({
            Title = "Error",
            Content = "No fishing rod found!",
            Duration = 3,
            Image = LOGO_ID,
        })
        return false
    end
    
    if rod.Parent == character then
        currentRod = rod
        return true
    end
    
    humanoid:EquipTool(rod)
    task.wait(0.2)
    currentRod = rod
    
    Rayfield:Notify({
        Title = "Success",
        Content = "Fishing rod equipped!",
        Duration = 2,
        Image = LOGO_ID,
    })
    return true
end

-- Function: Find Click GUI
local function findClickButton()
    local playerGui = player:WaitForChild("PlayerGui")
    
    for _, gui in pairs(playerGui:GetDescendants()) do
        if (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Visible then
            local text = gui.Text:lower()
            if string.find(text, "click") or string.find(text, "klicka") then
                return gui
            end
        end
    end
    
    return nil
end

-- Function: Auto Click Loop
local function autoFishLoop()
    while autoFishEnabled do
        task.wait(0.05)
        
        if not autoFishEnabled then break end
        
        local clickButton = findClickButton()
        
        if clickButton and clickButton.Visible then
            isClicking = true
            
            -- Spam clicks
            for i = 1, clicksPerBatch do
                if not autoFishEnabled or not clickButton.Visible then
                    break
                end
                
                task.spawn(function()
                    pcall(function()
                        -- Simulate mouse click
                        local pos = clickButton.AbsolutePosition + clickButton.AbsoluteSize / 2
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                        task.wait(0.001)
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                    end)
                end)
                
                task.wait(clickDelay)
            end
            
            isClicking = false
        end
    end
end

-- Anti-AFK
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local EquipButton = MainTab:CreateButton({
   Name = "🎣 Equip Fishing Rod",
   Callback = function()
       equipRod()
   end,
})

local AutoFishToggle = MainTab:CreateToggle({
   Name = "🐟 Auto Fish",
   CurrentValue = false,
   Flag = "AutoFishToggle",
   Callback = function(Value)
       autoFishEnabled = Value
       
       if Value then
           -- Auto-equip fishing rod when enabling
           if not currentRod or currentRod.Parent ~= character then
               equipRod()
               task.wait(0.3)
           end
           
           Rayfield:Notify({
               Title = "Auto Fish",
               Content = "Auto Fish enabled!",
               Duration = 3,
               Image = LOGO_ID,
           })
           task.spawn(autoFishLoop)
       else
           Rayfield:Notify({
               Title = "Auto Fish",
               Content = "Auto Fish disabled!",
               Duration = 3,
               Image = LOGO_ID,
           })
       end
   end,
})

-- Manual Keybind (without Rayfield's bugged keybind system)
local MainSection2 = MainTab:CreateSection("Keybind Settings")
local KeybindLabel = MainTab:CreateLabel("⌨️ Press 'F' to toggle Auto Fish")

-- Custom keybind handler
local keybindEnabled = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F and keybindEnabled then
        keybindEnabled = false
        
        autoFishEnabled = not autoFishEnabled
        AutoFishToggle:Set(autoFishEnabled)
        
        if autoFishEnabled then
            -- Auto-equip fishing rod when enabling
            if not currentRod or currentRod.Parent ~= character then
                equipRod()
                task.wait(0.3)
            end
            
            Rayfield:Notify({
                Title = "Auto Fish",
                Content = "Enabled with F key!",
                Duration = 2,
                Image = LOGO_ID,
            })
            task.spawn(autoFishLoop)
        else
            Rayfield:Notify({
                Title = "Auto Fish",
                Content = "Disabled with F key!",
                Duration = 2,
                Image = LOGO_ID,
            })
        end
        
        task.wait(0.5)
        keybindEnabled = true
    end
end)

-- Settings Tab
local SettingsTab = Window:CreateTab("⚙️ SETTINGS", LOGO_ID)

local SettingsSection = SettingsTab:CreateSection("Performance Settings")

local ClickSpeedSlider = SettingsTab:CreateSlider({
   Name = "⚡ Click Speed (ms)",
   Range = {1, 100},
   Increment = 1,
   CurrentValue = 1,
   Flag = "ClickSpeed",
   Callback = function(Value)
       clickDelay = Value / 1000
   end,
})

local BatchSizeSlider = SettingsTab:CreateSlider({
   Name = "📊 Clicks per Batch",
   Range = {10, 200},
   Increment = 10,
   CurrentValue = 40,
   Flag = "BatchSize",
   Callback = function(Value)
       clicksPerBatch = Value
   end,
})

local SettingsSection2 = SettingsTab:CreateSection("Anti-AFK")
SettingsTab:CreateLabel("🛡️ Anti-AFK is always enabled")

-- Teleport Tab
local TeleportTab = Window:CreateTab("📍 TELEPORT", LOGO_ID)

local TeleportSection = TeleportTab:CreateSection("Teleport Locations")

-- Teleport Function
local function teleportTo(position)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(position)
        Rayfield:Notify({
            Title = "Teleported!",
            Content = "Successfully teleported!",
            Duration = 2,
            Image = LOGO_ID,
        })
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "Character not found!",
            Duration = 3,
            Image = LOGO_ID,
        })
    end
end

-- Teleport Buttons
local FishingSellButton = TeleportTab:CreateButton({
   Name = "🎣 Fishing & Sell Area",
   Callback = function()
       teleportTo(Vector3.new(-276.72, 3.25, 219.15))
   end,
})

local VIPButton = TeleportTab:CreateButton({
   Name = "👑 VIP Area",
   Callback = function()
       teleportTo(Vector3.new(-1192.17, -21.63, -79.43))
   end,
})

local SpawnButton = TeleportTab:CreateButton({
   Name = "🏠 Spawn",
   Callback = function()
       teleportTo(Vector3.new(2.40, 3.25, -0.61))
   end,
})

-- Update Tab
local UpdateTab = Window:CreateTab("❓ UPDATE", LOGO_ID)

local UpdateSection = UpdateTab:CreateSection("Current Version")
UpdateTab:CreateLabel("Version: 1.0.0")
UpdateTab:CreateLabel("Last Updated: 2024")
UpdateTab:CreateLabel("✅ All features working")
UpdateTab:CreateLabel("⚡ Optimized performance")
UpdateTab:CreateLabel("🐟 Automatic rod detection")

-- Status Label
local StatusSection = MainTab:CreateSection("Status")
local StatusLabel = MainTab:CreateLabel("💤 Status: Waiting...")

task.spawn(function()
    while true do
        task.wait(0.5)
        if autoFishEnabled then
            if isClicking then
                StatusLabel:Set("🔥 Status: Auto Fishing Active!")
            else
                StatusLabel:Set("🔍 Status: Searching for fish...")
            end
        else
            StatusLabel:Set("💤 Status: Inactive")
        end
    end
end)

Rayfield:Notify({
   Title = "Jerry Fish Hub",
   Content = "Loaded! Created by @Challegreger7",
   Duration = 5,
   Image = LOGO_ID,
})

print("🐟 Jerry Fish Hub - Auto Fishing Script Loaded!")
print("👤 Created by Jerry User @Challegreger7")
