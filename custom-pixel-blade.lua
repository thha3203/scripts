local UserInputService = game:GetService("UserInputService")
local spellArgs = {
	"lunarSpell"
}
local healArgs = {
	{
		char = game:GetService("Players").LocalPlayer.Character,
		name = "heal",
		amount = 1
	}
}
local buffArgs = {
	{
		char = game:GetService("Players").LocalPlayer.Character,
		name = "tempbuff",
		statBoosts = {
			Dmg = "5500000%",
			BaseSpeed = "45%",
			stunDur = 20
		},
		dur = 50000000
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("abilityEvent"):FireServer(unpack(buffArgs))
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.L then
        game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("useAbility"):FireServer(unpack(spellArgs))
    end
    if input.KeyCode == Enum.KeyCode.B then
        game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("abilityEvent"):FireServer(unpack(healArgs))
    end
end)
loadstring(game:HttpGet("https://raw.githubusercontent.com/TexRBLX/Roblox-stuff/refs/heads/main/pixel%20blade/final.lua"))()