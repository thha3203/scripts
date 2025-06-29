-- loadstring(game:HttpGet("https://raw.githubusercontent.com/thha3203/scripts/refs/heads/main/pixel-blade-v2.lua"))()

-- =================================================================================================
-- Service Initialization
-- =================================================================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- =================================================================================================
-- UI Module
-- Manages the loading screen, main window, and draggable icon.
-- =================================================================================================
local UI = {}

function UI.showLoadingAnimation()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local blur = Instance.new("BlurEffect", Lighting)
	blur.Size = 0
	TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()

	local screenGui = Instance.new("ScreenGui", playerGui)
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
			ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 170, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 160))
		})
		gradient.Rotation = 90
		gradient.Parent = label

		TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 0, TextSize = 60}):Play()
		table.insert(letters, label)
		wait(0.25)
	end

	wait(2)
	tweenOutAndDestroy()
end

function UI.createMainWindow(Fluent)
	local windowTitle = "Pixel Blade Hub"
	pcall(function()
		windowTitle = MarketplaceService:GetProductInfo(18172550962).Name .. " 〢 Queue"
	end)

	local window = Fluent:CreateWindow({
		Title = windowTitle,
		SubTitle = "",
		TabWidth = 160,
		Size = UDim2.fromOffset(520, 400),
		Acrylic = false,
		Theme = "Viow Arabian Mix",
		MinimizeKey = Enum.KeyCode.LeftControl
	})

	local tabs = {
		DevUpd = window:AddTab({ Title = "Information", Icon = "circle-alert"}),
		Main = window:AddTab({ Title = "Farm", Icon = "star" }),
		Portal = window:AddTab({ Title = "Portal", Icon = "play" }),
		AntiAfk = window:AddTab({ Title = "Anti-Afk", Icon = "clock" }),
		Settings = window:AddTab({ Title = "Settings", Icon = "settings" })
	}
	
	window:SelectTab(1)
	
	return window, tabs
end

function UI.createDraggableIcon(window)
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local gui = Instance.new("ScreenGui", playerGui)
	gui.Name = "QueueHubMini"
	gui.ResetOnSpawn = false

	local icon = Instance.new("ImageButton")
	icon.Name = "QueueIcon"
	icon.Size = UDim2.new(0, 55, 0, 50)
	icon.Position = UDim2.new(0, 200, 0, 150)
	icon.BackgroundTransparency = 1
	icon.Image = "rbxassetid://105059922903197"
	icon.Parent = gui

	local corner = Instance.new("UICorner", icon)
	corner.CornerRadius = UDim.new(0, 8)

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
		window:Minimize(isMinimized)
	end)
end

-- =================================================================================================
-- Feature Modules
-- Each module initializes its own UI and logic.
-- =================================================================================================
local Features = {}

function Features.initInfoTab(tab, Fluent)
	tab:CreateParagraph("Aligned Paragraph", {
		Title = "Queue Hub",
		Content = "Thank you for using the script! Join the discord if you have problems and suggestions with the script",
		TitleAlignment = "Middle",
		ContentAlignment = Enum.TextXAlignment.Center
	})
	tab:CreateParagraph("Aligned Paragraph", {
		Title = "Information",
		Content = "If you found this script requiring a key, it's not the official version. Join our Discord to get the keyless version!",
		TitleAlignment = "Middle",
		ContentAlignment = Enum.TextXAlignment.Center
	})
	tab:AddSection("Discord")
	tab:AddButton({
		Title = "Discord",
		Description = "Copy the link to join the discord!",
		Callback = function()
			setclipboard("https://discord.gg/FmMuvkaWvG")
			Fluent:Notify({
				Title = "Notification",
				Content = "Successfully copied to the clipboard!",
				SubContent = "",
				Duration = 3 
			})
		end
	})
end

Features.Farming = {}
function Features.Farming.init(tab, options, shared)
	local replicated_storage = shared.replicated_storage
	local local_player = shared.local_player
	local run_service = shared.run_service
	local workspace = shared.workspace
	local player_stats = shared.player_stats

	local function current_damage()
		local damage = 0
		for i, v in next, player_stats.wpnStats do
			if i == "Dmg" and v > damage then
				damage = v
			end
		end
		return damage
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

	local function closest_mob()
		local character = local_player.Character
		if not character then return nil end

		local priority_keywords = { "Archer", "Mage" }
		local closest_priority_mob = nil
		local closest_priority_distance = math.huge
		local closest_mob = nil
		local closest_distance = math.huge
		local max_priority_distance = 80
		
		local is_ancient_sands = workspace:FindFirstChild("worldType") and workspace.worldType.Value == "AncientSands"

		for _, v in next, workspace:GetChildren() do
			local has_hadEntrance = v:GetAttribute("hadEntrance") ~= nil
			if v ~= character and v:IsA("Model") and has_hadEntrance then
				local is_regular_mob = v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0
				local is_maneater_boss = is_ancient_sands and v:FindFirstChild("worm") and v.worm:FindFirstChild("Health") and v.worm.Health.Value > 0
				
				if is_regular_mob or is_maneater_boss then
					local dist = (v:GetPivot().Position - character:GetPivot().Position).Magnitude
					local name = v.Name
					local hum = v:FindFirstChild("HumanoidRootPart")
					if hum then hum.Anchored = true end

					local is_priority_target = false
					if is_maneater_boss then
						is_priority_target = true
					else
						for _, keyword in ipairs(priority_keywords) do
							if string.find(name, keyword) and dist <= max_priority_distance then
								is_priority_target = true
								break
							end
						end
					end
					
					if is_priority_target then
						if dist < closest_priority_distance then
							closest_priority_distance = dist
							closest_priority_mob = v
						end
					else
						if dist < closest_distance then
							closest_distance = dist
							closest_mob = v
						end
					end
				end
			end
		end
		return closest_priority_mob or closest_mob
	end

	local goto_closest = false
	local transdelay = 2
	local farmingConnection = nil
	local shouldZeroVelocity = false

	local autoFarmToggle = tab:AddToggle("AutoFarm", {
		Title = "Auto Farm (Kill Aura)",
		Description = "Use this for kill aura version without swing.",
		Default = false
	})
	autoFarmToggle:OnChanged(function(value)
		goto_closest = value
		if value then
			shouldZeroVelocity = false
			farmingConnection = run_service.Heartbeat:Connect(function()
				if shouldZeroVelocity and local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart") then
					local_player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					local_player.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				end
			end)

			local args = {{ char = LocalPlayer.Character, name = "tempbuff", statBoosts = { Dmg = "550000000%", BaseSpeed = "45%" }, dur = 50000000 }}
			local healArgs = {{ char = LocalPlayer.Character, name = "heal", amount = 1 }}
			replicated_storage:WaitForChild("remotes"):WaitForChild("abilityEvent"):FireServer(unpack(args))
			
			task.spawn(function()
				while goto_closest do
					local char = local_player.Character
					if char then
						for _, part in ipairs(char:GetDescendants()) do
							if part:IsA("BasePart") then part.CanCollide = false end
						end
					
						if workspace.difficulty.Value == "Normal" and workspace:FindFirstChild("7") and not workspace:FindFirstChild("LumberJack") then
							task.wait(2)
							char.HumanoidRootPart.CFrame = CFrame.new(workspace:FindFirstChild("7"):GetPivot().Position + Vector3.new(0, 5, 0))
						elseif workspace.difficulty.Value == "Heroic" and workspace:FindFirstChild("8") and not workspace:FindFirstChild("LumberJack") then
							task.wait(2)
							char.HumanoidRootPart.CFrame = CFrame.new(workspace:FindFirstChild("8"):GetPivot().Position + Vector3.new(0, 5, 0))
						elseif workspace.difficulty.Value == "Nightmare" and workspace:FindFirstChild("9") and not workspace:FindFirstChild("LumberJack") then
							task.wait(2)
							char.HumanoidRootPart.CFrame = CFrame.new(workspace:FindFirstChild("9"):GetPivot().Position + Vector3.new(0, 5, 0))
						end

						local cutscene = workspace:FindFirstChild("inCutscene")
						local mob = closest_mob()

						if cutscene and cutscene.Value == false and mob then
							local hrp = char:FindFirstChild("HumanoidRootPart")
							if hrp then
								local mob_position = mob:GetPivot().Position
								local total_distance = (mob_position - hrp.Position).Magnitude
								if total_distance > 70 then task.wait(transdelay) end

								shouldZeroVelocity = true 
								local mob_targetable_part = get_mob_targetable_object(mob)
								while mob and mob_targetable_part and is_mob_alive(mob) and goto_closest do
									mob_position = mob:GetPivot().Position
									if (mob_position - hrp.Position).Magnitude < 10 then
										replicated_storage:WaitForChild("remotes"):WaitForChild("swing"):FireServer()
										replicated_storage:WaitForChild("remotes"):WaitForChild("onHit"):FireServer(mob_targetable_part, current_damage(), {}, 0)
									else
										local target_position = mob_position + mob:GetPivot().LookVector * -8
										hrp.CFrame = CFrame.lookAt(target_position, mob_position)
									end
									task.wait(0.5)
									replicated_storage:WaitForChild("remotes"):WaitForChild("abilityEvent"):FireServer(unpack(healArgs))
								end
								shouldZeroVelocity = false
							end
						end
					end
					task.wait(0.1)
				end
			end)
		else
			if farmingConnection then
				farmingConnection:Disconnect()
				farmingConnection = nil
			end
			shouldZeroVelocity = false
		end
	end)

	tab:AddInput("nextroomdelayinput", {
		Title = "Next Room Delay", Default = "2", Numeric = true, Finished = false, 
		Callback = function(value) transdelay = tonumber(value) or 2 end
	})

	local autoPickUpgradesToggle = tab:AddToggle("AutoPlayAgain", { Title = "Auto Pick Upgrades", Default = false })
	autoPickUpgradesToggle:OnChanged(function(value)
		if value then
			task.spawn(function()
				while options.AutoPlayAgain.Value do
					VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
					task.wait(0.05)
					VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
					task.wait(0.1)
				end
			end)
		end
	end)
	options.AutoPlayAgain:SetValue(false)

	local autoOpenChestToggle = tab:AddToggle("autoopenchest", {Title = "Open All Chest", Default = false })
	autoOpenChestToggle:OnChanged(function(value)
		if value then
			task.spawn(function()
				while options.autoopenchest.Value do
					local chest = LocalPlayer.PlayerGui.gameUI.armory.inventory.clip.Loot
					for _, loot in pairs(chest:GetChildren()) do
						if string.find(loot.Name, "Chest") then
							replicated_storage:WaitForChild("remotes"):WaitForChild("openLoot"):InvokeServer(loot.Name)
						end
					end
					task.wait(0.1)
				end
			end)
		end
	end)
	options.autoopenchest:SetValue(false)
end

Features.Portal = {}
function Features.Portal.init(tab, options, shared)
	local replicated_storage = shared.replicated_storage
	local selected_dungeon = "Grasslands"
	local selected_difficulties = "Normal"
	local all_difficulties = {"Normal", "Heroic", "Nightmare"}
	local sands_difficulties = {"Normal", "Heroic"}

	local difficultyDropdown = tab:AddDropdown("difficulties", {
		Title = "Choose Difficulty", Values = all_difficulties, Multi = false, Default = 1,
		Callback = function(value) selected_difficulties = value end
	})
	difficultyDropdown:SetValue("Normal")

	tab:AddDropdown("dungeons", {
		Title = "Select Portal", Values = {"Grasslands", "AncientSands"}, Multi = false, Default = 1,
		Callback = function(value) 
			selected_dungeon = value 
			if value == "AncientSands" then
				difficultyDropdown:SetValues(sands_difficulties)
				difficultyDropdown:SetValue("Normal")
			else
				difficultyDropdown:SetValues(all_difficulties)
			end
		end
	}):SetValue("Grasslands")

	local autoJoinPortalToggle = tab:AddToggle("AutoJoinPortal", {Title = "Auto Join Portal", Default = false })
	autoJoinPortalToggle:OnChanged(function(value)
		if value then
			task.spawn(function()
				while options.AutoJoinPortal.Value do
					local args = { selected_dungeon, selected_difficulties, true }
					replicated_storage:WaitForChild("remotes"):WaitForChild("playerTP"):FireServer(unpack(args))
					task.wait(5)
				end
			end)
		end
	end)
	options.AutoJoinPortal:SetValue(false)

	tab:AddButton({
		Title = "Return To Lobby",
		Callback = function()
			local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid.Health = 0 end
		end
	})
end

Features.AntiAFK = {}
function Features.AntiAFK.init(tab, options)
	local antiAfkToggle = tab:AddToggle("AntiAfk", {
		Title = "Anti-Afk", Description = "This will prevent you from being kicked when AFK", Default = false 
	})
	antiAfkToggle:OnChanged(function(value)
		if value then
			task.spawn(function()
				while options.AntiAfk.Value do
					VirtualUser:CaptureController()
					VirtualUser:ClickButton2(Vector2.new())
					print("Anti-AFK activated")
					task.wait(10)
				end
			end)
		end
	end)
	options.AntiAfk:SetValue(false)
end

Features.Settings = {}
function Features.Settings.init(tab, SaveManager, InterfaceManager)
	InterfaceManager:BuildInterfaceSection(tab)
	SaveManager:BuildConfigSection(tab)
end


-- =================================================================================================
-- Main Script Execution
-- =================================================================================================
local function main()
	UI.showLoadingAnimation()
	
	repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	local Fluent = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
	local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/SaveManager.luau"))()
	local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/InterfaceManager.luau"))()

	local window, tabs = UI.createMainWindow(Fluent)
	UI.createDraggableIcon(window)

	local sharedDependencies = {
		replicated_storage = cloneref(game:GetService("ReplicatedStorage")),
		user_input_service = cloneref(game:GetService("UserInputService")),
		local_player = cloneref(game:GetService("Players").LocalPlayer),
		tween_service = cloneref(game:GetService("TweenService")),
		run_service = cloneref(game:GetService("RunService")),
		workspace = cloneref(game:GetService("Workspace")),
		player_stats = require(LocalPlayer:FindFirstChild("plrStats")),
	}
	
	Features.initInfoTab(tabs.DevUpd, Fluent)
	Features.Farming.init(tabs.Main, Fluent.Options, sharedDependencies)
	Features.Portal.init(tabs.Portal, Fluent.Options, sharedDependencies)
	Features.AntiAFK.init(tabs.AntiAfk, Fluent.Options)

	SaveManager:SetLibrary(Fluent)
	InterfaceManager:SetLibrary(Fluent)
	SaveManager:IgnoreThemeSettings()
	SaveManager:SetIgnoreIndexes({})
	InterfaceManager:SetFolder("FluentScriptHub")
	SaveManager:SetFolder("FluentScriptHub/Pixel Blade")
	
	Features.Settings.init(tabs.Settings, SaveManager, InterfaceManager)
	
	Fluent:Notify({ Title = "Queue Hub", Content = "The script has been loaded.", Duration = 3 })
	task.wait(3)
	Fluent:Notify({ Title = "Queue Hub", Content = "Join the discord for more updates and keyless scripts", Duration = 8 })
	
	SaveManager:LoadAutoloadConfig()
	wait(2)
	window:Minimize(true)
end

main()