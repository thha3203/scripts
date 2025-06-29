loadstring(game:HttpGet("https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau"))()

local args = {
	workspace:WaitForChild("Maneater"):WaitForChild("worm"):WaitForChild("RootPart"),
	vector.create(-19.847299575805664, 0, 22.496326446533203),
	0.1
}
game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("kb"):FireServer(unpack(args))


local args = {
	workspace:WaitForChild("Maneater"):WaitForChild("worm"):WaitForChild("Humanoid"),
	282.15,
	{},
	0
}
game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("onHit"):FireServer(unpack(args))
