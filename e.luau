local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local DEFAULT_OPTIONS = {
	BoxColor = Color3.new(1, 0, 0),      -- Red
	BoxThickness = 2,
	NameColor = Color3.new(1, 1, 1),
	HealthColor = Color3.new(0, 1, 0),   -- Green
	ShowDistance = true,
	DistanceColor = Color3.new(1, 1, 1),
	Font = Enum.Font.GothamBold,
	TextSize = 14,
}

function ESP.new(character, options)
	assert(character:IsA("Model") and character:FindFirstChild("Humanoid"), "ESP needs a character model with a Humanoid.")

	local self = setmetatable({}, ESP)
	self.Character = character
	self.Humanoid = character:FindFirstChild("Humanoid")
	self.Options = table.clone(DEFAULT_OPTIONS)
	if options then
		for k, v in pairs(options) do
			self.Options[k] = v
		end
	end

	self.Player = Players:GetPlayerFromCharacter(character)
	self.NameText = self.Player and self.Player.DisplayName or "Unknown"

	self.Gui = Instance.new("ScreenGui")
	self.Gui.Name = "ESP_" .. (self.Player and self.Player.Name or "Unknown")
	self.Gui.ResetOnSpawn = false
	self.Gui.IgnoreGuiInset = true
	self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	self.Objects = {}

	self:_buildUI()

	self.Connection = RunService.Heartbeat:Connect(function()
		self:_update()
	end)

	self.CharacterRemovingConnection = character.AncestryChanged:Connect(function()
		if not character.Parent then
			self:Destroy()
		end
	end)

	return self
end

function ESP:_buildUI()
	local gui = self.Gui
	local opts = self.Options

	local box = Instance.new("Frame")
	box.BackgroundTransparency = 1
	box.BorderSizePixel = opts.BoxThickness
	box.BorderColor3 = opts.BoxColor
	box.Size = UDim2.new(0, 1, 0, 1)
	box.Position = UDim2.new(0, 0, 0, 0)
	box.BackgroundColor3 = Color3.new(1, 1, 1)
	box.Parent = gui
	self.Objects.Box = box

	local name = Instance.new("TextLabel")
	name.BackgroundTransparency = 1
	name.TextColor3 = opts.NameColor
	name.Text = self.NameText
	name.Font = opts.Font
	name.TextSize = opts.TextSize
	name.TextStrokeTransparency = 0.5
	name.TextStrokeColor3 = Color3.new(0, 0, 0)
	name.Size = UDim2.new(0, 200, 0, 20)
	name.Position = UDim2.new(0.5, -100, 0, -20)
	name.Parent = gui
	self.Objects.Name = name

	local healthBg = Instance.new("Frame")
	healthBg.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	healthBg.BackgroundTransparency = 0.3
	healthBg.BorderSizePixel = 0
	healthBg.Size = UDim2.new(0, 100, 0, 8)
	healthBg.Position = UDim2.new(0.5, -50, 0, 5)
	healthBg.Parent = gui
	self.Objects.HealthBg = healthBg

	local healthBar = Instance.new("Frame")
	healthBar.BackgroundColor3 = opts.HealthColor
	healthBar.BackgroundTransparency = 0
	healthBar.BorderSizePixel = 0
	healthBar.Size = UDim2.new(1, 0, 1, 0)
	healthBar.Parent = healthBg
	self.Objects.HealthBar = healthBar

	if opts.ShowDistance then
		local dist = Instance.new("TextLabel")
		dist.BackgroundTransparency = 1
		dist.TextColor3 = opts.DistanceColor
		dist.Text = ""
		dist.Font = opts.Font
		dist.TextSize = opts.TextSize - 2
		dist.TextStrokeTransparency = 0.5
		dist.TextStrokeColor3 = Color3.new(0, 0, 0)
		dist.Size = UDim2.new(0, 100, 0, 16)
		dist.Position = UDim2.new(0.5, -50, 0, 16)
		dist.Parent = gui
		self.Objects.Distance = dist
	end

	local player = Players.LocalPlayer
	if player then
		local playerGui = player:FindFirstChild("PlayerGui")
		if playerGui then
			gui.Parent = playerGui
		else
			player.CharacterAdded:Wait()
			playerGui = player:FindFirstChild("PlayerGui")
			if playerGui then
				gui.Parent = playerGui
			end
		end
	end
end

function ESP:_update()
	local char = self.Character
	if not char or not char.Parent then
		self:Destroy()
		return
	end

	local humanoid = self.Humanoid
	if not humanoid or humanoid.Health <= 0 then
		for _, obj in pairs(self.Objects) do
			if obj:IsA("BaseGuiObject") then
				obj.Visible = false
			end
		end
		return
	end

	local cf, size = char:GetBoundingBox()
	if not cf then return end

	local camera = workspace.CurrentCamera
	if not camera then return end

	local topLeft, onScreen = camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, size.Y/2, 0)).Position)
	local bottomRight = camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, -size.Y/2, 0)).Position)

	if not onScreen then
		for _, obj in pairs(self.Objects) do
			if obj:IsA("BaseGuiObject") then
				obj.Visible = false
			end
		end
		return
	end

	for _, obj in pairs(self.Objects) do
		if obj:IsA("BaseGuiObject") then
			obj.Visible = true
		end
	end

	local x1, y1 = topLeft.X, topLeft.Y
	local x2, y2 = bottomRight.X, bottomRight.Y
	local width = math.abs(x2 - x1)
	local height = math.abs(y2 - y1)

	local box = self.Objects.Box
	box.Position = UDim2.new(0, x1 - width/2, 0, y1 - height/2)
	box.Size = UDim2.new(0, width, 0, height)

	local name = self.Objects.Name
	name.Position = UDim2.new(0, x1 + width/2 - 100, 0, y1 - height/2 - 22)
	name.Text = self.NameText

	local health = humanoid.Health
	local maxHealth = humanoid.MaxHealth
	local healthPercent = math.clamp(health / maxHealth, 0, 1)

	local healthBg = self.Objects.HealthBg
	healthBg.Position = UDim2.new(0, x1 + width/2 - 50, 0, y1 - height/2 - 8)
	healthBg.Size = UDim2.new(0, 100, 0, 8)
	healthBg.Visible = maxHealth > 0

	local healthBar = self.Objects.HealthBar
	healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
	if healthPercent > 0.5 then
		healthBar.BackgroundColor3 = Color3.new(1 - (healthPercent - 0.5) * 2, 1, 0)
	else
		healthBar.BackgroundColor3 = Color3.new(1, healthPercent * 2, 0)
	end

	local distObj = self.Objects.Distance
	if distObj then
		local distance = (char.PrimaryPart and char.PrimaryPart.Position - camera.CFrame.Position).Magnitude or 0
		distObj.Text = string.format("%.0f m", distance)
		distObj.Position = UDim2.new(0, x1 + width/2 - 50, 0, y1 + height/2 + 2)
	end
end

function ESP:Destroy()
	if self.Destroyed then return end
	self.Destroyed = true

	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end
	if self.CharacterRemovingConnection then
		self.CharacterRemovingConnection:Disconnect()
		self.CharacterRemovingConnection = nil
	end
	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end
	self.Objects = {}
end

return ESP
