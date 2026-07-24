local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local ESP = {}
ESP.__index = ESP

ESP.Settings = {
	BoxColor = Color3.fromRGB(255, 0, 0),
	BoxThickness = 1,
	OutlineColor = Color3.fromRGB(0, 0, 0),
	OutlineThickness = 2,
	HealthBarColor = Color3.fromRGB(0, 255, 0),
	HealthBarWidth = 4,
	NameColor = Color3.fromRGB(255, 255, 255),
	NameSize = 14,
	HealthTextColor = Color3.fromRGB(255, 255, 255),
	HealthTextSize = 12,
	SkeletonColor = Color3.fromRGB(255, 255, 255),
	SkeletonThickness = 1,
	DistanceColor = Color3.fromRGB(255, 255, 255),

	ShowBox = true,
	ShowOutline = true,
	ShowHealth = true,
	ShowName = true,
	ShowSkeleton = false,
	ShowDistance = false,
}

ESP.Cache = {}
ESP.PlayersData = {}

local function NewDrawing(type, properties)
	local obj = Drawing.new(type)
	if type == "Square" then
		obj.Thickness = 1
		obj.Filled = false
		obj.Color = Color3.fromRGB(255, 255, 255)
	elseif type == "Line" then
		obj.Thickness = 1
		obj.Color = Color3.fromRGB(255, 255, 255)
	elseif type == "Text" then
		obj.Center = true
		obj.Outline = true
		obj.OutlineColor = Color3.fromRGB(0, 0, 0)
		obj.Size = 14
		obj.Color = Color3.fromRGB(255, 255, 255)
	end
	for k, v in pairs(properties) do
		obj[k] = v
	end
	return obj
end

local PART_NAMES = {
	"Head",
	"UpperTorso",
	"LowerTorso",
	"Torso",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",
}

local SKELETON_CONNECTIONS_R6 = {
	{
		"Head",
		"Torso"
	},
	{
		"Torso",
		"Left Arm"
	},
	{
		"Torso",
		"Right Arm"
	},
	{
		"Torso",
		"Left Leg"
	},
	{
		"Torso",
		"Right Leg"
	},
}
local SKELETON_CONNECTIONS_R15 = {
	{
		"Head",
		"UpperTorso"
	},
	{
		"UpperTorso",
		"LowerTorso"
	},
	{
		"UpperTorso",
		"LeftUpperArm"
	},
	{
		"LeftUpperArm",
		"LeftLowerArm"
	},
	{
		"LeftLowerArm",
		"LeftHand"
	},
	{
		"UpperTorso",
		"RightUpperArm"
	},
	{
		"RightUpperArm",
		"RightLowerArm"
	},
	{
		"RightLowerArm",
		"RightHand"
	},
	{
		"LowerTorso",
		"LeftUpperLeg"
	},
	{
		"LeftUpperLeg",
		"LeftLowerLeg"
	},
	{
		"LeftLowerLeg",
		"LeftFoot"
	},
	{
		"LowerTorso",
		"RightUpperLeg"
	},
	{
		"RightUpperLeg",
		"RightLowerLeg"
	},
	{
		"RightLowerLeg",
		"RightFoot"
	},
}

local function GetCharacterParts(character)
	local parts = {}
	for _, name in ipairs(PART_NAMES) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			parts[name] = part
		end
	end

	local isR15 = parts.UpperTorso and parts.LowerTorso
	local connections
	if isR15 then
		connections = SKELETON_CONNECTIONS_R15
	else
		connections = SKELETON_CONNECTIONS_R6
	end

	local skeleton = {}
	for _, conn in ipairs(connections) do
		local from = parts[conn[1]]
		local to = parts[conn[2]]
		if from and to then
			table.insert(skeleton, {
				from,
				to
			})
		end
	end

	return parts, skeleton, isR15
end

function ESP:Create(player)
	if self.Cache[player] then
		return
	end

	local objects = {
		OutlineBox = NewDrawing("Square", {
			Color = self.Settings.OutlineColor,
			Thickness = self.Settings.OutlineThickness,
			Filled = false,
			Visible = false,
		}),
		Box = NewDrawing("Square", {
			Color = self.Settings.BoxColor,
			Thickness = self.Settings.BoxThickness,
			Filled = false,
			Visible = false,
		}),
		HealthBg = NewDrawing("Square", {
			Color = Color3.fromRGB(0, 0, 0),
			Filled = true,
			Visible = false,
		}),
		HealthBar = NewDrawing("Square", {
			Color = self.Settings.HealthBarColor,
			Filled = true,
			Visible = false,
		}),
		HealthText = NewDrawing("Text", {
			Color = self.Settings.HealthTextColor,
			Size = self.Settings.HealthTextSize,
			Visible = false,
			Text = "",
		}),
		NameText = NewDrawing("Text", {
			Color = self.Settings.NameColor,
			Size = self.Settings.NameSize,
			Visible = false,
			Text = "",
		}),
		DistanceText = NewDrawing("Text", {
			Color = Color3.fromRGB(255, 255, 255),
			Size = 12,
			Visible = false,
			Text = "",
		}),
		Bones = {},
	}

	for i = 1, 20 do
		objects.Bones[i] = NewDrawing("Line", {
			Color = self.Settings.SkeletonColor,
			Thickness = self.Settings.SkeletonThickness,
			Visible = false,
		})
	end

	self.Cache[player] = objects
end

function ESP:Remove(player)
	local objects = self.Cache[player]
	if objects then
		for _, obj in pairs(objects) do
			if type(obj) == "table" then
				for _, line in ipairs(obj) do
					pcall(function()
						line:Remove()
					end)
				end
			else
				pcall(function()
					obj:Remove()
				end)
			end
		end
		self.Cache[player] = nil
	end
	self.PlayersData[player] = nil
end

function ESP:UpdatePlayerData()
	local active = {}

	local localPlayer = Players.LocalPlayer
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character and player.Character.Parent then
			local humanoid = player.Character:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				active[player] = true
			end
		end
	end

	for player in pairs(self.Cache) do
		if not active[player] then
			self:Remove(player)
		end
	end

	for player in pairs(active) do
		if not self.Cache[player] then
			self:Create(player)
		end
		local character = player.Character
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			local parts, skeleton, isR15 = GetCharacterParts(character)
			self.PlayersData[player] = {
				Character = character,
				Humanoid = humanoid,
				Parts = parts,
				Skeleton = skeleton,
				IsR15 = isR15,
			}
		end
	end
end

local cornerOffsets = table.create(8)

function ESP:Render()
	local settings = self.Settings
	local camera = Camera
	if not camera then
		return
	end

	for player, visuals in pairs(self.Cache) do
		local data = self.PlayersData[player]

		if not data or not data.Humanoid or data.Humanoid.Health <= 0 then
			visuals.Box.Visible = false
			visuals.OutlineBox.Visible = false
			visuals.HealthBar.Visible = false
			visuals.HealthBg.Visible = false
			visuals.HealthText.Visible = false
			visuals.NameText.Visible = false
			visuals.DistanceText.Visible = false
			for _, line in ipairs(visuals.Bones) do
				line.Visible = false
			end
		else
			local parts = data.Parts
			if not parts or next(parts) == nil then
				visuals.Box.Visible = false
				visuals.OutlineBox.Visible = false
				visuals.HealthBar.Visible = false
				visuals.HealthBg.Visible = false
				visuals.HealthText.Visible = false
				visuals.NameText.Visible = false
				visuals.DistanceText.Visible = false
				for _, line in ipairs(visuals.Bones) do
					line.Visible = false
				end
			else
				local minX, minY = math.huge, math.huge
				local maxX, maxY = - math.huge, - math.huge
				local onScreen = false

				for partName, part in pairs(parts) do
					if part:IsA("BasePart") then
						local size = part.Size
						local cframe = part.CFrame
						local ex, ey, ez = size.X / 2, size.Y / 2, size.Z / 2
						cornerOffsets[1] = cframe:PointToWorldSpace(Vector3.new(- ex, - ey, - ez))
						cornerOffsets[2] = cframe:PointToWorldSpace(Vector3.new( ex, - ey, - ez))
						cornerOffsets[3] = cframe:PointToWorldSpace(Vector3.new(- ex, ey, - ez))
						cornerOffsets[4] = cframe:PointToWorldSpace(Vector3.new( ex, ey, - ez))
						cornerOffsets[5] = cframe:PointToWorldSpace(Vector3.new(- ex, - ey, ez))
						cornerOffsets[6] = cframe:PointToWorldSpace(Vector3.new( ex, - ey, ez))
						cornerOffsets[7] = cframe:PointToWorldSpace(Vector3.new(- ex, ey, ez))
						cornerOffsets[8] = cframe:PointToWorldSpace(Vector3.new( ex, ey, ez))

						for i = 1, 8 do
							local screenPos, visible = camera:WorldToViewportPoint(cornerOffsets[i])
							if visible then
								onScreen = true
								minX = math.min(minX, screenPos.X)
								minY = math.min(minY, screenPos.Y)
								maxX = math.max(maxX, screenPos.X)
								maxY = math.max(maxY, screenPos.Y)
							end
						end
					end
				end

				if not onScreen then
					visuals.Box.Visible = false
					visuals.OutlineBox.Visible = false
					visuals.HealthBar.Visible = false
					visuals.HealthBg.Visible = false
					visuals.HealthText.Visible = false
					visuals.NameText.Visible = false
					visuals.DistanceText.Visible = false
					for _, line in ipairs(visuals.Bones) do
						line.Visible = false
					end
				else
					local height = maxY - minY
					local padding = math.clamp(height * 0.05, 1, 8)
					local boxX = minX - padding
					local boxY = minY - padding
					local boxW = (maxX - minX) + 2 * padding
					local boxH = (maxY - minY) + 2 * padding

					if settings.ShowBox then
						visuals.Box.Position = Vector2.new(boxX, boxY)
						visuals.Box.Size = Vector2.new(boxW, boxH)
						visuals.Box.Color = settings.BoxColor
						visuals.Box.Thickness = settings.BoxThickness
						visuals.Box.Visible = true
					else
						visuals.Box.Visible = false
					end

					if settings.ShowOutline then
						visuals.OutlineBox.Position = visuals.Box.Position
						visuals.OutlineBox.Size = visuals.Box.Size
						visuals.OutlineBox.Color = settings.OutlineColor
						visuals.OutlineBox.Thickness = settings.OutlineThickness
						visuals.OutlineBox.Visible = true
					else
						visuals.OutlineBox.Visible = false
					end

					if settings.ShowName then
						local nameSize = settings.NameSize
						visuals.NameText.Size = nameSize
						visuals.NameText.Position = Vector2.new(boxX + boxW / 2, boxY - nameSize - 2)
						local dispName = (type(player) == "userdata" or type(player) == "table" or type(player) == "Instance") and (player.DisplayName or player.Name) or tostring(player)
						visuals.NameText.Text = dispName
						visuals.NameText.Color = settings.NameColor
						visuals.NameText.Visible = true
					else
						visuals.NameText.Visible = false
					end

					if settings.ShowHealth and data and data.Humanoid then
						local health = data.Humanoid.Health
						local maxHealth = data.Humanoid.MaxHealth
						local healthPercent = math.clamp(health / maxHealth, 0, 1)
						local barWidth = math.clamp(boxW * 0.045, 2, 3)
						local gap = math.clamp(boxW * 0.015, 1, 4)
						local barHeight = boxH
						local barX = boxX - barWidth - gap
						local barY = boxY
						local fillHeight = barHeight * healthPercent
						visuals.HealthBg.Position = Vector2.new(barX - 1, barY - 1)
						visuals.HealthBg.Size = Vector2.new(barWidth + 2, barHeight + 2)
						visuals.HealthBg.Visible = true
						visuals.HealthBar.Position = Vector2.new(barX, barY + barHeight - fillHeight)
						visuals.HealthBar.Size = Vector2.new(barWidth, fillHeight)
						local color
						if healthPercent > 0.5 then
							color = Color3.fromRGB(255 * (1 - (healthPercent - 0.5) * 2), 255, 0)
						else
							color = Color3.fromRGB(255, 255 * (healthPercent * 2), 0)
						end
						visuals.HealthBar.Color = color
						visuals.HealthBar.Visible = true
						visuals.HealthText.Size = settings.HealthTextSize
						visuals.HealthText.Position = Vector2.new(barX + barWidth / 2, barY + barHeight + gap)
						visuals.HealthText.Text = tostring(math.floor(health))
						visuals.HealthText.Color = settings.HealthTextColor
						visuals.HealthText.Visible = true
					else
						visuals.HealthBar.Visible = false
						visuals.HealthBg.Visible = false
						visuals.HealthText.Visible = false
					end

					if settings.ShowDistance then
						local rootPart = data.Character:FindFirstChild("HumanoidRootPart") or data.Character.PrimaryPart
						if rootPart then
							local dist = (rootPart.Position - camera.CFrame.Position).Magnitude
							visuals.DistanceText.Size = 12
							visuals.DistanceText.Position = Vector2.new(boxX + boxW / 2, boxY + boxH + 2)
							visuals.DistanceText.Text = string.format("%.0fm", dist)
							visuals.DistanceText.Color = settings.DistanceColor or Color3.fromRGB(255, 255, 255)
							visuals.DistanceText.Visible = true
						else
							visuals.DistanceText.Visible = false
						end
					else
						visuals.DistanceText.Visible = false
					end

					if settings.ShowSkeleton and data.Skeleton then
						local skel = data.Skeleton
						local boneLines = visuals.Bones
						local count = 0
						for idx, conn in ipairs(skel) do
							local fromPart, toPart = conn[1], conn[2]
							if fromPart and toPart then
								local fromPos = fromPart.Position
								local toPos = toPart.Position
								local fromScreen, fromVis = camera:WorldToViewportPoint(fromPos)
								local toScreen, toVis = camera:WorldToViewportPoint(toPos)
								if fromVis and toVis then
									local line = boneLines[idx]
									if line then
										line.From = Vector2.new(fromScreen.X, fromScreen.Y)
										line.To = Vector2.new(toScreen.X, toScreen.Y)
										line.Color = settings.SkeletonColor
										line.Thickness = settings.SkeletonThickness
										line.Visible = true
										count = count + 1
									end
								end
							end
						end
						for i = count + 1, # boneLines do
							boneLines[i].Visible = false
						end
					else
						for _, line in ipairs(visuals.Bones) do
							line.Visible = false
						end
					end
				end
			end
		end
	end
end

function ESP:Start()
	if self._running then
		return
	end
	self._running = true

	self._heartbeat = RunService.RenderStepped:Connect(function()
		self:UpdatePlayerData()
		self:Render()
	end)
end

function ESP:Stop()
	if self._heartbeat then
		self._heartbeat:Disconnect()
		self._heartbeat = nil
	end
	self._running = false
	for player in pairs(self.Cache) do
		self:Remove(player)
	end
end
return ESP
