-- loadstring(game:HttpGet("https://raw.githubusercontent.com/thha3203/scripts/refs/heads/main/pixel-blade-v3.lua"))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
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
	wait(0.6)
	screenGui:Destroy()
	blur:Destroy()
end

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
		ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 170, 255)), -- biru muda cerah
		ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 160))   -- biru muda gelap
	})
	gradient.Rotation = 90
	gradient.Parent = label

	local tweenIn = TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 0, TextSize = 60})
	tweenIn:Play()

	table.insert(letters, label)
	wait(0.25)
end

wait(2)

tweenOutAndDestroy()
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Fluent = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/InterfaceManager.luau"))()


local Window = Fluent:CreateWindow({
    Title = game:GetService("MarketplaceService"):GetProductInfo(18172550962).Name .. " 〢 Queue",
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(520, 400),
    Acrylic = false,
    Theme = "Viow Arabian Mix",
    MinimizeKey = Enum.KeyCode.LeftControl
})
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "QueueHubMini"
gui.ResetOnSpawn = false

local icon = Instance.new("ImageButton")
icon.Name = "QueueIcon"
icon.Size = UDim2.new(0, 55, 0, 50)
icon.Position = UDim2.new(0, 200, 0, 150)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://105059922903197" -- replace with your real asset ID
icon.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8) -- You can tweak the '8' for more or less rounding
corner.Parent = icon

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

game:GetService("UserInputService").InputChanged:Connect(function(input)
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

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    DevUpd = Window:AddTab({ Title = "Information", Icon = "circle-alert"}),
    Main = Window:AddTab({ Title = "Farm", Icon = "star" }),
    Portal = Window:AddTab({ Title = "Portal", Icon = "play" }),
    AntiAfk = Window:AddTab({ Title = "Anti-Afk", Icon = "clock" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

Window:SelectTab(1)
local Options = Fluent.Options

do
    Tabs.DevUpd:CreateParagraph("Aligned Paragraph", {
    Title = "Queue Hub",
    Content = "Thank you for using the script! Join the discord if you have problems and suggestions with the script",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Center
})
    Tabs.DevUpd:CreateParagraph("Aligned Paragraph", {
    Title = "Information",
    Content = "If you found this script requiring a key, it's not the official version. Join our Discord to get the keyless version!",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Center
})

    Tabs.DevUpd:AddSection("Discord")
    Tabs.DevUpd:AddButton({
        Title = "Discord",
        Description = "Copy the link to join the discord!",
        Callback = function()
            setclipboard("https://discord.gg/FmMuvkaWvG")
            Fluent:Notify({
                Title = "Notification",
                Content = "Successfully copied to the clipboard!",
                SubContent = "", -- Optional
                Duration = 3 
            })
        end
    })

    local replicated_storage = cloneref(game:GetService("ReplicatedStorage"))
    local user_input_service = cloneref(game:GetService("UserInputService"))
    local local_player = cloneref(game:GetService("Players").LocalPlayer)
    local tween_service = cloneref(game:GetService("TweenService"))
    local run_service = cloneref(game:GetService("RunService"))
    local workspace = cloneref(game:GetService("Workspace"))

    local player_stats = require(local_player:FindFirstChild("plrStats"))

    -- Damage function
    local function current_damage()
        local damage = 0
        for i, v in next, player_stats.wpnStats do
            if i == "Dmg" and v > damage then
                damage = v
            end
        end
        return damage
    end

    -- Closest mob finder
    local function closest_mob()
        local closest_priority_mob = nil
        local closest_priority_distance = math.huge

        local closest_mob = nil
        local closest_distance = math.huge

        local max_priority_distance = 80

        for _, v in next, workspace:GetChildren() do
            local has_hadEntrance = v:GetAttribute("hadEntrance") ~= nil

            if v ~= local_player.Character 
                and v:IsA("Model") 
                and v:FindFirstChild("Humanoid") 
                and v.Humanoid.Health > 0 
                and has_hadEntrance 
            then
                local dist = (v:GetPivot().Position - local_player.Character:GetPivot().Position).Magnitude
                local name = v.Name

                -- OPTIONAL: Anchor the mob
                local hum = v:FindFirstChild("HumanoidRootPart")
                if hum then
                    hum.Anchored = true
                end

                -- Always consider closest mob (any type)
                if dist < closest_distance then
                    closest_distance = dist
                    closest_mob = v
                end
            elseif v:FindFirstChild("worm") and v.worm:FindFirstChild("Health") and v.worm.Health.Value > 0 and has_hadEntrance then
                local dist = (v:GetPivot().Position - local_player.Character:GetPivot().Position).Magnitude
                if dist < closest_distance then
                    closest_distance = dist
                    closest_mob = v
                end
            end
        end

        return closest_priority_mob or closest_mob
    end
    
    local function get_mob_targetable_object(mob)
		if not mob then return nil end
		local is_ancient_sands = workspace:FindFirstChild("worldType") and workspace.worldType.Value == "AncientSands"
		if is_ancient_sands and mob:FindFirstChild("worm") and mob.worm:FindFirstChild("Health") then
			return mob.worm
		elseif mob:FindFirstChild("Humanoid") then
			return mob.Humanoid
		end
		return nil
	end

    local function is_mob_alive(mob)
		if not mob then return false end
		local is_ancient_sands = workspace:FindFirstChild("worldType") and workspace.worldType.Value == "AncientSands"
		if is_ancient_sands and mob:FindFirstChild("worm") and mob.worm:FindFirstChild("Health") then
			return mob.worm.Health.Value > 0
		elseif mob:FindFirstChild("Humanoid") then
			return mob.Humanoid.Health > 0
		end
		return false
	end


-- Auto Farm toggle
    local goto_closest = false
    local entered_bossroom = false
    local transdelay = 2

    local Toggle3 = Tabs.Main:AddToggle("AutoFarm", {
        Title = "Auto Farm (Kill Aura)",
        Description = "Use this for kill aura version without swing.",
        Default = false
    })

    Toggle3:OnChanged(function(Value)
        goto_closest = Value
        if Value then
            local args = {
                {
                    char = game:GetService("Players").LocalPlayer.Character,
                    name = "tempbuff",
                    statBoosts = {
                        Dmg = "550000000%",
                        BaseSpeed = "45%"
                    },
                    dur = 50000000
                }
            }
            local healArgs = {
                {
                    char = game:GetService("Players").LocalPlayer.Character,
                    name = "heal",
                    amount = 1
                }
            }
            local abilityArgs = {
                "lunarSpell"
            }
            replicated_storage:WaitForChild("remotes"):WaitForChild("abilityEvent"):FireServer(unpack(args))

            task.spawn(function()
                while goto_closest do
                    local char = local_player.Character
                    if char then
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                    
                    local six = workspace:FindFirstChild("6")
                    local seven = workspace:FindFirstChild("7")
                    local eight = workspace:FindFirstChild("8")
                    local nine = workspace:FindFirstChild("9")
                    -- local kingslayer = workspace:FindFirstChild("LumberJack")

                    if workspace.difficulty.Value == "Normal" and six and seven then
                        task.wait(2)
                        char.HumanoidRootPart.CFrame = CFrame.new(seven:GetPivot().Position + Vector3.new(0, 5, 0))
                    elseif workspace.difficulty.Value == "Heroic" and seven and eight then
                        task.wait(2)
                        char.HumanoidRootPart.CFrame = CFrame.new(eight:GetPivot().Position + Vector3.new(0, 5, 0))
                    elseif workspace.difficulty.Value == "Nightmare" and eight and nine then
                        task.wait(2)
                        char.HumanoidRootPart.CFrame = CFrame.new(nine:GetPivot().Position + Vector3.new(0, 5, 0))
                    end

                    -- Auto Farm + Kill Aura logic
                    local cutscene = workspace:FindFirstChild("inCutscene")
                    local mob = closest_mob()

                    if cutscene and cutscene.Value == false and mob then
                        
                        local character = local_player.Character
                        local hrp = character and character:FindFirstChild("HumanoidRootPart")
                        local velocity_connection = run_service.Heartbeat:Connect(function()
                            if local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart") then
                                local_player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                                local_player.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                            end
                        end)
                        if hrp then
                            if mob.Name == "Atticus" and not entered_bossroom then
                                hrp.CFrame = CFrame.lookAt(mob.HumanoidRootPart.Position + mob.HumanoidRootPart.CFrame.LookVector, mob.HumanoidRootPart.Position)
                                task.wait(5)
                                local room_position = workspace:FindFirstChild("Vault"):GetPivot().Position
                                hrp.CFrame = CFrame.new(room_position)
                                entered_bossroom = true
                                task.wait(1)
                            end

                            local mob_position = nil
                            local mob_look_vector = nil
                            if mob.Name == "Maneater" then
                                mob_position = Vector3.new(mob.Root.Position.X, 35, mob.Root.Position.Z)
                                mob_look_vector = mob.Root.CFrame.LookVector
                            else
                                mob_position = mob.HumanoidRootPart.Position
                                mob_look_vector = mob.HumanoidRootPart.CFrame.LookVector
                            end


                            local target_position = mob_position + mob_look_vector * -8
                            if mob.Name == "Nekros" then
                                target_position = mob_position - mob_look_vector    
                                task.wait(0.5)
                                -- Send virtual input to press the Q key
                                local VirtualInputManager = game:GetService("VirtualInputManager")
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                                task.wait(0.1)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                            end
                            local target_cframe = CFrame.lookAt(target_position, mob_position)
                            
                            local total_distance = (mob_position - hrp.Position).Magnitude
                            if total_distance > 70 then
                                task.wait(transdelay)
                            end

                            -- Engage in combat
                            local mob_targetable_part = get_mob_targetable_object(mob)
                            while mob 
                                and mob_targetable_part
                                and is_mob_alive(mob)
                                and goto_closest
                            do
                                if mob.Name == "Maneater" then
                                    mob_position = Vector3.new(mob.Root.Position.X, 35, mob.Root.Position.Z)
                                else
                                    mob_position = mob.HumanoidRootPart.Position
                                end

                                local dist = (mob_position - hrp.Position).Magnitude
                                if dist < 10 then
                                    if mob.Name == "Maneater" then
                                        task.wait(0.1)
                                        replicated_storage:WaitForChild("remotes"):WaitForChild("useAbility"):FireServer(unpack(abilityArgs))
                                    elseif mob.Name == "Atticus" then
                                        task.wait(0.1)
                                        local VirtualInputManager = game:GetService("VirtualInputManager")
                                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                                    else
                                        replicated_storage:WaitForChild("remotes"):WaitForChild("swing"):FireServer()
                                        replicated_storage:WaitForChild("remotes"):WaitForChild("onHit"):FireServer(mob.Humanoid, current_damage(), {}, 0)
                                    end
                                else
                                    hrp.CFrame = CFrame.lookAt(target_position, mob_position)
                                end
                                task.wait(0.5)
                                replicated_storage:WaitForChild("remotes"):WaitForChild("abilityEvent"):FireServer(unpack(healArgs))
                            end
                        end
                        if velocity_connection then
                            velocity_connection:Disconnect()
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end)

    local nextroomdelayinput = Tabs.Main:AddInput("nextroomdelayinput", {
        Title = "Next Room Delay",
        Default = "2",
        Numeric = true, 
        Finished = false, 
        Callback = function(Value)
            transdelay = Value
        end
    })

    local VirtualInputManager = game:GetService("VirtualInputManager")

    local Toggle4 = Tabs.Main:AddToggle("AutoPlayAgain", {
        Title = "Auto Pick Upgrades",
        Default = false
    })

    Toggle4:OnChanged(function()
        if Options.AutoPlayAgain.Value then
            task.spawn(function()
                while Options.AutoPlayAgain.Value do
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
                    task.wait(0.1)
                end
            end)
        end
    end)

    Options.AutoPlayAgain:SetValue(false)

    local autoopenchest = Tabs.Main:AddToggle("autoopenchest", {Title = "Open All Chest", Default = false })

    autoopenchest:OnChanged(function()
        while Options.autoopenchest.Value do
            local chest = game:GetService("Players").LocalPlayer.PlayerGui.gameUI.armory.inventory.clip.Loot
            for _, loot in pairs(chest:GetChildren()) do
                if string.find(loot.Name, "Chest") then
                    local args = { loot.Name }
                    game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("openLoot"):InvokeServer(unpack(args))
                end
            end
            task.wait(0.1)
        end
    end)
    
    Options.autoopenchest:SetValue(false)

    local selected_dungeon = "Grasslands"
    local dungeons = Tabs.Portal:AddDropdown("dungeons", {
        Title = "Select Portal",
        Values = {"Grasslands", "AncientSands"},
        Multi = false,
        Default = 1,
    })

    dungeons:SetValue("Grasslands")

    dungeons:OnChanged(function(Value)
        selected_dungeon = Value
    end)

    local selected_difficulties = "Normal"

    local difficulties = Tabs.Portal:AddDropdown("difficulties", {
        Title = "Choose Difficulty",
        Values = {"Normal", "Heroic", "Nightmare"},
        Multi = false,
        Default = 1,
    })

    difficulties:SetValue("Normal") 

    difficulties:OnChanged(function(Value)
        selected_difficulties = Value
    end)


    local AutoJoinPortal = Tabs.Portal:AddToggle("AutoJoinPortal", {Title = "Auto Join Portal", Default = false })

    AutoJoinPortal:OnChanged(function()
        while Options.AutoJoinPortal.Value do
            local args = {
                selected_dungeon,
                selected_difficulties,
                true
            }
            game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("playerTP"):FireServer(unpack(args))
            task.wait(5)
        end
    end)
    
    Options.AutoJoinPortal:SetValue(false)

    Tabs.Portal:AddButton({
        Title = "Return To Lobby",
        Callback = function()
            local player = game.Players.LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    })


    -- Auto Anti-Afk
    local Toggle4 = Tabs.AntiAfk:AddToggle("AntiAfk", {
        Title = "Anti-Afk", 
        Description = "This will prevent you from being kicked when AFK", 
        Default = false 
    })


    Toggle4:OnChanged(function()
        task.spawn(function()
            while Options.AntiAfk.Value do
                -- Simulate player activity to prevent AFK kick
                local VirtualUser = game:GetService("VirtualUser")
                
                -- Move the mouse slightly to simulate activity
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                
                print("Anti-AFK activated")
                task.wait(10)
            end
        end)
    end)
    Options.AntiAfk:SetValue(false)
end  

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)

SaveManager:IgnoreThemeSettings()
-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/Pixel Blade")



InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Fluent:Notify({
    Title = "Queue Hub",
    Content = "The script has been loaded.",
    Duration = 3
})
task.wait(3)
Fluent:Notify({
    Title = "Queue Hub",
    Content = "Join the discord for more updates and keyless scripts",
    Duration = 8
})
-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()

wait(2)
Window:Minimize(true)