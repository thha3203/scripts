local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "KillAuraGui"

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 250, 0, 60)
button.Position = UDim2.new(0, 30, 0, 30)
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 22
button.Text = "Kill Aura: OFF"
button.Parent = gui

-- Improved Settings
local settings = {
    enabled = false,
    max_distance = 50,        -- Increased max farming distance
    delay = 5,             -- Faster attack delay (20 attacks per second)
    tween_time = 0,        -- Faster tween duration for smoother movement
    priority = "Nearest",
    dodge_distance = 10,      -- Distance to move when dodging
    dodge_cooldown = 0,       -- Cooldown between dodges
    last_dodge = 0
}

button.MouseButton1Click:Connect(function()
    settings.enabled = not settings.enabled
    button.Text = "Kill Aura: " .. (settings.enabled and "ON" or "OFF")
    print("Aura Toggled: " .. tostring(settings.enabled))
end)

local function getTarget()
    local bestTarget = nil
    local bestValue = math.huge

    for _, model in pairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model ~= Character then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local dist = (HumanoidRootPart.Position - model:GetPivot().Position).Magnitude
                if dist <= settings.max_distance then
                    if settings.priority == "Nearest" and dist < bestValue then
                        bestTarget = model
                        bestValue = dist
                    elseif settings.priority == "Lowest Health" and humanoid.Health < bestValue then
                        bestTarget = model
                        bestValue = humanoid.Health
                    end
                end
            end
        end
    end

    return bestTarget
end

local function tweenTo(position, time)
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = { CFrame = CFrame.new(position + Vector3.new(0, 2, 0)) }
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()
end

task.spawn(function()
    while task.wait(settings.delay) do
        if not settings.enabled then continue end

        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        Humanoid = Character:WaitForChild("Humanoid")

        local target = getTarget()
        if target then
            local humanoid = target:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- tweenTo(target:GetPivot().Position, settings.tween_time)
                print(target:GetPivot().Position)
            end
        else
            -- No target, optionally move to a neutral position or idle
        end
    end
end)

-- -- Auto Farm loop with fast attack and dodge
-- task.spawn(function()
--     Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
--     HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
--     Humanoid = Character:WaitForChild("Humanoid")

--     local target = getTarget()
--     if target then
--         local humanoid = target:FindFirstChildOfClass("Humanoid")
--         if humanoid and humanoid.Health > 0 then
--             tweenTo(target:GetPivot().Position, settings.tween_time)
--         end
--     else
--         -- No target, optionally move to a neutral position or idle
--     end

--     print("finished")
-- end)