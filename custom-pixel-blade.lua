local UserInputService = game:GetService("UserInputService")
local spellArgs = {
	"lunarSpell"
}
local buffArgs = {
    {
        char = game:GetService("Players").LocalPlayer.Character,
        dur = 50000,
        name = "shield",
        amount = 2
    }
}
local healArgs = {
	{
		char = game:GetService("Players").LocalPlayer.Character,
		name = "heal",
		amount = 1
	}
}
local stunArgs = {
	{
		char = game:GetService("Players").LocalPlayer.Character,
		name = "tempbuff",
		statBoosts = {
			BaseSpeed = "100%",
			stunDur = 10
		},
		dur = 50000
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("abilityEvent"):FireServer(unpack(stunArgs))
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.L then
        game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("useAbility"):FireServer(unpack(spellArgs))
    end
    if input.KeyCode == Enum.KeyCode.B then
        game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("abilityEvent"):FireServer(unpack(buffArgs))
        game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("abilityEvent"):FireServer(unpack(healArgs))
    end
end)