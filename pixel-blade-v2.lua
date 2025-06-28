-- loadstring(game:HttpGet("https://raw.githubusercontent.com/thha3203/scripts/refs/heads/main/pixel-blade-v2.lua"))()

--[[
    Pixel Blade Auto Farm Script v2.0
    Organized and optimized version
    
    Features:
    - Auto Farm (Multiple modes)
    - Portal Management
    - Anti-AFK
    - Auto Chest Opening
    - Auto Upgrade Selection
]]

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local MarketplaceService = game:GetService("MarketplaceService")
local Workspace = game:GetService("Workspace")

-- ==================== VARIABLES ====================
local LocalPlayer = Players.LocalPlayer
local PlayerStats = require(LocalPlayer:FindFirstChild("plrStats"))

-- Cached Remotes for Performance
local Remotes = ReplicatedStorage:WaitForChild("remotes")
local SwingRemote = Remotes:WaitForChild("swing")
local OnHitRemote = Remotes:WaitForChild("onHit")
local AbilityEventRemote = Remotes:WaitForChild("abilityEvent")

-- Script State Variables
local GotoClosest = false
local TransitionDelay = 2

-- ==================== UTILITY FUNCTIONS ====================

-- Get current damage from player stats
local function GetCurrentDamage()
    local damage = 0
    for stat, value in pairs(PlayerStats.wpnStats) do
        if stat == "Dmg" and value > damage then
            damage = value
        end
    end
    return damage
end

-- Disable character collision
local function DisableCollision(character)
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Apply damage buff to character
local function ApplyDamageBuff(damageMultiplier, speedBoost, duration)
    local args = {
        {
            char = LocalPlayer.Character,
            name = "tempbuff",
            statBoosts = {
                Dmg = damageMultiplier or "550000000%",
                BaseSpeed = speedBoost or "45%"
            },
            dur = duration or 50000000
        }
    }
    AbilityEventRemote:FireServer(unpack(args))
end

-- Apply healing
local function ApplyHealing()
    local healArgs = {
        {
            char = LocalPlayer.Character,
            name = "heal",
            amount = 1
        }
    }
    AbilityEventRemote:FireServer(unpack(healArgs))
end

-- Optimized mob finder with priority system
local function FindClosestMob()
    local priorityKeywords = { "Archer", "Mage" }
    local maxPriorityDistance = 80
    
    local wormBoss = nil
    local closestPriorityMob = nil
    local closestMob = nil
    
    local closestPriorityDistance = math.huge
    local closestDistance = math.huge
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local playerPosition = LocalPlayer.Character.HumanoidRootPart.Position

    for _, mob in pairs(Workspace:GetChildren()) do
        if mob == LocalPlayer.Character then continue end
        
        local hasHadEntrance = mob:GetAttribute("hadEntrance") ~= nil
        if not (mob:IsA("Model") and hasHadEntrance) then continue end
        
        -- Check for worm boss (highest priority)
        local wormChild = mob:FindFirstChild("worm")
        if wormChild and wormChild:FindFirstChild("Health") and wormChild.Health.Value > 0 then
            wormBoss = mob
            break
        end
        
        -- Check for regular mobs
        local humanoid = mob:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local distance = (mob:GetPivot().Position - playerPosition).Magnitude
            local mobName = mob.Name
            
            -- Check for priority mobs
            for _, keyword in ipairs(priorityKeywords) do
                if string.find(mobName, keyword) and distance <= maxPriorityDistance then
                    if distance < closestPriorityDistance then
                        closestPriorityDistance = distance
                        closestPriorityMob = mob
                    end
                    break
                end
            end
            
            -- Track closest mob overall
            if distance < closestDistance then
                closestDistance = distance
                closestMob = mob
            end
        end
    end
    
    return wormBoss or closestPriorityMob or closestMob
end

-- Get appropriate wave target based on difficulty
local function GetWaveTarget()
    local difficulty = Workspace.difficulty.Value
    local waveTargets = {
        Normal = Workspace:FindFirstChild("7"),
        Heroic = Workspace:FindFirstChild("8"),
        Nightmare = Workspace:FindFirstChild("9")
    }
    return waveTargets[difficulty]
end

-- Teleport to wave position
local function TeleportToWave()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local target = GetWaveTarget()
    local kingslayer = Workspace:FindFirstChild("LumberJack")
    
    if target and not kingslayer and target:IsA("Model") then
        local success, result = pcall(function()
            local position = target:GetPivot().Position + Vector3.new(0, 5, 0)
            character.HumanoidRootPart.CFrame = CFrame.new(position)
        end)
        if not success then
            warn("[Teleport Error]:", result)
        end
        task.wait(TransitionDelay)
    end
end

-- Teleport to mob with delay
local function TeleportToMob(mob)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not mob then return end
    
    local hrp = character.HumanoidRootPart
    local mobPosition = mob.HumanoidRootPart.Position
    local targetPosition = mobPosition + mob:GetPivot().LookVector * -8
    
    hrp.CFrame = CFrame.lookAt(targetPosition, mobPosition)
    task.wait(2)  -- Always wait 2 seconds after teleporting to a mob
end

-- ==================== LOADING SCREEN ====================
local function CreateLoadingScreen()
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 0
    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()

    local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    screenGui.Name = "QueueLoader"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1

    local bg = Instance.new("Frame", frame)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    bg.BackgroundTransparency = 1
    bg.ZIndex = 0
    TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()

    local word = "QUEUE"
    local letters = {}

    local function tweenOutAndDestroy()
        for _, label in ipairs(letters) do
            TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1, TextSize = 20}):Play()
        end
        TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
        task.wait(0.6)
        screenGui:Destroy()
        blur:Destroy()
    end

    -- Create animated letters
    for i = 1, #word do
        local char = word:sub(i, i)
        local label = Instance.new("TextLabel")
        label.Text = char
        label.Font = Enum.Font.GothamBlack
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 1 
        label.TextTransparency = 1
        label.TextScaled = false
        label.TextSize = 30 
        label.Size = UDim2.new(0, 60, 0, 60)
        label.AnchorPoint = Vector2.new(0.5, 0.5)
        label.Position = UDim2.new(0.5, (i - (#word / 2 + 0.5)) * 65, 0.5, 0)
        label.BackgroundTransparency = 1
        label.Parent = frame

        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 170, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 160))
        })
        gradient.Rotation = 90
        gradient.Parent = label

        local tweenIn = TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 0, TextSize = 60})
        tweenIn:Play()

        table.insert(letters, label)
        task.wait(0.25)
    end

    task.wait(2)
    tweenOutAndDestroy()
end

-- ==================== AUTO FARM FUNCTIONS ====================

-- Kill aura auto farm
local function KillAuraAutoFarm()
    task.spawn(function()
        while GotoClosest do
            local character = LocalPlayer.Character
            if character then
                DisableCollision(character)
            end
            
            TeleportToWave()

            local cutscene = Workspace:FindFirstChild("inCutscene")
            local mob = FindClosestMob()

            if cutscene and cutscene.Value == false and mob then
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    local velocityConnection = RunService.Heartbeat:Connect(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                            LocalPlayer.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                        end
                    end)

                    -- Teleport to mob (includes 2 second delay)
                    TeleportToMob(mob)
                    
                    -- Attack the mob until it's dead
                    while mob 
                        and mob:FindFirstChild("Humanoid") 
                        and mob.Humanoid.Health > 0 
                        and GotoClosest
                    do
                        local mobPosition = mob.HumanoidRootPart.Position
                        local distance = (mobPosition - hrp.Position).Magnitude
                        
                        if distance < 10 then
                            SwingRemote:FireServer()
                            OnHitRemote:FireServer(
                                mob.Humanoid, 
                                GetCurrentDamage(), 
                                {}, 
                                0
                            )
                        end
                        
                        task.wait(0.5)
                        ApplyHealing()
                    end
                    
                    if velocityConnection then
                        velocityConnection:Disconnect()
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end



-- ==================== GUI CREATION ====================

-- Wait for game to load
repeat task.wait() until LocalPlayer and LocalPlayer.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Show loading screen
CreateLoadingScreen()

-- Load external libraries
local Fluent = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/InterfaceManager.luau"))()

-- Create main window
local Window = Fluent:CreateWindow({
    Title = MarketplaceService:GetProductInfo(18172550962).Name .. " 〢 Queue v2.0",
    SubTitle = "Optimized Version",
    TabWidth = 160,
    Size = UDim2.fromOffset(520, 400),
    Acrylic = false,
    Theme = "Viow Arabian Mix",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Create minimize icon
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "QueueHubMini"
gui.ResetOnSpawn = false

local icon = Instance.new("ImageButton")
icon.Name = "QueueIcon"
icon.Size = UDim2.new(0, 55, 0, 50)
icon.Position = UDim2.new(0, 200, 0, 150)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://105059922903197"
icon.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = icon

-- Icon dragging functionality
local dragging, dragInput, dragStart, startPos

icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = icon.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

icon.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        icon.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local isMinimized = false
icon.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Window:Minimize(isMinimized)
end)

-- Create tabs
local Tabs = {
    Info = Window:AddTab({ Title = "Information", Icon = "circle-alert"}),
    Farm = Window:AddTab({ Title = "Farm", Icon = "star" }),
    Portal = Window:AddTab({ Title = "Portal", Icon = "play" }),
    AntiAfk = Window:AddTab({ Title = "Anti-Afk", Icon = "clock" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

Window:SelectTab(1)
local Options = Fluent.Options

-- ==================== TAB CONTENT ====================

-- Information Tab
Tabs.Info:CreateParagraph("Welcome", {
    Title = "Queue Hub v2.0",
    Content = "Optimized and organized version. Thank you for using the script! Join the discord if you have problems and suggestions.",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Center
})

Tabs.Info:CreateParagraph("Notice", {
    Title = "Important Notice",
    Content = "If you found this script requiring a key, it's not the official version. Join our Discord to get the keyless version!",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Center
})

Tabs.Info:AddSection("Discord")
Tabs.Info:AddButton({
    Title = "Discord",
    Description = "Copy the link to join the discord!",
    Callback = function()
        setclipboard("https://discord.gg/FmMuvkaWvG")
        Fluent:Notify({
            Title = "Notification",
            Content = "Successfully copied to the clipboard!",
            Duration = 3 
        })
    end
})

-- Farm Tab
Tabs.Farm:AddSection("Auto Farm Options")

local KillAuraToggle = Tabs.Farm:AddToggle("KillAura", {
    Title = "Auto Farm (Kill Aura)",
    Description = "Safer kill aura version without swing spam.",
    Default = false
})

KillAuraToggle:OnChanged(function(Value)
    GotoClosest = Value
    if Value then
        ApplyDamageBuff("550000000%", "45%", 50000000)
        KillAuraAutoFarm()
    end
end)

Tabs.Farm:AddSection("Farm Settings")

local DelayInput = Tabs.Farm:AddInput("TransitionDelay", {
    Title = "Next Room Delay",
    Default = "2",
    Numeric = true,
    Callback = function(Value)
        TransitionDelay = tonumber(Value) or 2
    end
})

local AutoUpgradeToggle = Tabs.Farm:AddToggle("AutoUpgrade", {
    Title = "Auto Pick Upgrades",
    Default = false
})

AutoUpgradeToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while Options.AutoUpgrade.Value do
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
                task.wait(0.1)
            end
        end)
    end
end)

local AutoChestToggle = Tabs.Farm:AddToggle("AutoChest", {
    Title = "Auto Open Chests",
    Default = false
})

AutoChestToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while Options.AutoChest.Value do
                local chest = LocalPlayer.PlayerGui.gameUI.armory.inventory.clip.Loot
                for _, loot in pairs(chest:GetChildren()) do
                    if string.find(loot.Name, "Chest") then
                        local openLootRemote = Remotes:FindFirstChild("openLoot")
                        if openLootRemote then
                            local args = { loot.Name }
                            openLootRemote:InvokeServer(unpack(args))
                        else
                            warn("OpenLoot remote not found - chest opening not available")
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- Portal Tab
Tabs.Portal:AddSection("Portal Management")

local selectedDungeon = "Grasslands"
local dungeonDropdown = Tabs.Portal:AddDropdown("Dungeons", {
    Title = "Select Portal",
    Values = {"Grasslands"},
    Multi = false,
    Default = 1,
})

dungeonDropdown:OnChanged(function(Value)
    selectedDungeon = Value
end)

local selectedDifficulty = "Normal"
local difficultyDropdown = Tabs.Portal:AddDropdown("Difficulties", {
    Title = "Choose Difficulty",
    Values = {"Normal", "Heroic", "Nightmare"},
    Multi = false,
    Default = 1,
})

difficultyDropdown:OnChanged(function(Value)
    selectedDifficulty = Value
end)

local AutoPortalToggle = Tabs.Portal:AddToggle("AutoPortal", {
    Title = "Auto Join Portal",
    Default = false
})

AutoPortalToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while Options.AutoPortal.Value do
                local playerTPRemote = Remotes:FindFirstChild("playerTP")
                if playerTPRemote then
                    local args = {
                        selectedDungeon,
                        selectedDifficulty,
                        true
                    }
                    playerTPRemote:FireServer(unpack(args))
                else
                    warn("PlayerTP remote not found - auto portal joining not available")
                end
                task.wait(5)
            end
        end)
    end
end)

Tabs.Portal:AddButton({
    Title = "Return To Lobby",
    Description = "Kills your character to return to lobby",
    Callback = function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    end
})

-- Anti-AFK Tab
Tabs.AntiAfk:AddSection("Anti-AFK System")

local AntiAfkToggle = Tabs.AntiAfk:AddToggle("AntiAfk", {
    Title = "Anti-AFK", 
    Description = "Prevents being kicked when AFK", 
    Default = false 
})

AntiAfkToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while Options.AntiAfk.Value do
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                task.wait(10)
            end
        end)
    end
end)

-- ==================== SAVE SYSTEM ====================

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/Pixel Blade v2")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- ==================== NOTIFICATIONS ====================

Fluent:Notify({
    Title = "Queue Hub v2.0",
    Content = "Script loaded successfully!",
    Duration = 3
})

task.wait(3)

Fluent:Notify({
    Title = "Queue Hub v2.0",
    Content = "Join the discord for updates and keyless scripts",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
task.wait(2)
Window:Minimize(true) 