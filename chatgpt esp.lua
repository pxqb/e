-- ESPModule.lua
local ESP = {}

-- State
local Cache = {}          -- player -> drawing objects
local PlayersData = {}    -- player -> {Parts, Health, MaxHealth, etc.}
local CornerOffsets = table.create(8)

-- Dependencies (set via Init)
local Players
local Workspace
local Camera
local Drawing
local Settings
local RagebotFlags
local Aimbot
local math_min, math_max, math_huge, table_clear, table_insert

-- Constants (mapping from your ANATOMY to ESP part names)
local PART_MAP = {
    -- R6
    Head = "Head",
    Torso = "Torso",
    ["Left Arm"] = "Left Arm",
    ["Right Arm"] = "Right Arm",
    ["Left Leg"] = "Left Leg",
    ["Right Leg"] = "Right Leg",
    -- R15 (maps to common ESP names)
    UpperTorso = "Torso",
    LowerTorso = "Torso",
    LeftUpperArm = "Left Arm",
    LeftLowerArm = "Left Arm",
    LeftHand = "Left Arm",
    RightUpperArm = "Right Arm",
    RightLowerArm = "Right Arm",
    RightHand = "Right Arm",
    LeftUpperLeg = "Left Leg",
    LeftLowerLeg = "Left Leg",
    LeftFoot = "Left Leg",
    RightUpperLeg = "Right Leg",
    RightLowerLeg = "Right Leg",
    RightFoot = "Right Leg",
}

-- Body part sizes (used for bounding box)
local BodyPartSizes = {
    Head = Vector3.new(2, 1, 1),
    Torso = Vector3.new(2, 2, 1),
    ["Left Arm"] = Vector3.new(1, 2, 1),
    ["Right Arm"] = Vector3.new(1, 2, 1),
    ["Left Leg"] = Vector3.new(1, 2, 1),
    ["Right Leg"] = Vector3.new(1, 2, 1),
}

-- Attachment joints (simplified for skeleton, adjust as needed)
local AttachmentJoints = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

function ESP:Init(Dependencies)
    Players = Dependencies.Players
    Workspace = Dependencies.Workspace
    Camera = Dependencies.Camera
    Drawing = Dependencies.Drawing
    Settings = Dependencies.Settings
    RagebotFlags = Dependencies.RagebotFlags
    Aimbot = Dependencies.Aimbot
    math_min = Dependencies.math_min or math.min
    math_max = Dependencies.math_max or math.max
    math_huge = Dependencies.math_huge or math.huge
    table_clear = Dependencies.table_clear or table.clear
    table_insert = Dependencies.table_insert or table.insert
    -- You'll pass your registry here
    self.Registry = Dependencies.Registry
    self.LocalPlayer = Dependencies.LocalPlayer
end

-- Helper to get enemy status (customize as needed)
local function isEnemy(player)
    if player == ESP.LocalPlayer then return false end
    local localTeam = ESP.LocalPlayer.Team
    local playerTeam = player.Team
    if localTeam and playerTeam then
        return localTeam ~= playerTeam
    end
    -- Fallback: compare TeamColor
    return ESP.LocalPlayer.TeamColor ~= player.TeamColor
end

local function EspRender(Type, Properties)
    local Render = Drawing.new(Type)
    if Type == "Line" then
        Render.Thickness = 1
        Render.Color = Color3.fromRGB(255, 255, 255)
    elseif Type == "Text" then
        Render.Center = true
        Render.Outline = true
        Render.OutlineColor = Color3.fromRGB(0, 0, 0)
        Render.Size = 14
        Render.Color = Color3.fromRGB(255, 255, 255)
    end
    for Index, Value in next, Properties do
        Render[Index] = Value
    end
    return Render
end

function ESP:Create(player)
    if Cache[player] then return end
    local Objects = {
        OutlineBox = EspRender("Square", { Color = Settings.OutlineColor, Thickness = Settings.OutlineThickness, Filled = false, Visible = false }),
        Box = EspRender("Square", { Color = Settings.BoxColor, Thickness = Settings.BoxThickness, Filled = false, Visible = false }),
        HealthBg = EspRender("Square", { Color = Color3.fromRGB(0, 0, 0), Filled = true, Visible = false }),
        HealthBar = EspRender("Square", { Color = Settings.HealthBarColor, Filled = true, Visible = false }),
        HealthText = EspRender("Text", { Visible = false, Text = "" }),
        NameText = EspRender("Text", { Color = Settings.NameColor, Size = Settings.NameSize, Visible = false, Text = "" }),
        Bones = {}
    }
    for i = 1, #AttachmentJoints do
        Objects.Bones[i] = EspRender("Line", { Color = Settings.SkeletonColor, Thickness = Settings.SkeletonThickness, Visible = false })
    end
    Cache[player] = Objects
end

function ESP:Remove(player)
    if not player then return end
    local Objects = Cache[player]
    if Objects then
        local function safeRemove(obj)
            if obj then
                pcall(function() obj:Remove() end)
            end
        end
        safeRemove(Objects.OutlineBox)
        safeRemove(Objects.Box)
        safeRemove(Objects.HealthBar)
        safeRemove(Objects.HealthBg)
        safeRemove(Objects.HealthText)
        safeRemove(Objects.NameText)
        if type(Objects.Bones) == "table" then
            for _, BoneLine in ipairs(Objects.Bones) do
                safeRemove(BoneLine)
            end
        end
        Cache[player] = nil
    end
    PlayersData[player] = nil
    if Aimbot and Aimbot.CurrentLockedPlayer == player then
        Aimbot.CurrentLockedPlayer = nil
    end
end

function ESP:buildPlayerData(player)
    local record = self.Registry[player]
    if not record then return nil end
    local character = player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end

    -- Build parts table with mapped names
    local parts = {}
    for espName, partName in pairs(PART_MAP) do
        local part = record.bodyParts[partName]
        if part then
            parts[espName] = part
        end
    end
    -- Fallback: if we have a HumanoidRootPart, use it for root
    local root = record.bodyParts.HumanoidRootPart or character:FindFirstChild("HumanoidRootPart")

    return {
        Player = player,
        Character = character,
        Humanoid = humanoid,
        Root = root,
        Parts = parts,
        Health = humanoid.Health,
        MaxHealth = humanoid.MaxHealth,
    }
end

function ESP:UpdatePlayerData()
    local activePlayers = {}
    for player, record in pairs(self.Registry) do
        if isEnemy(player) then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    activePlayers[player] = true
                end
            end
        end
    end

    -- Remove players not active
    for player in pairs(Cache) do
        if not activePlayers[player] then
            self:Remove(player)
        end
    end

    -- Build data for active players
    for player in pairs(activePlayers) do
        if not Cache[player] then
            self:Create(player)
        end
        PlayersData[player] = self:buildPlayerData(player)
    end
end

function ESP:Render()
    for Player, Visuals in pairs(Cache) do
        local Data = PlayersData[Player]
        if Data and Data.Root then
            local drawColor = Settings.BoxColor
            local drawSkelColor = Settings.SkeletonColor
            local isPriority = RagebotFlags.PriorityPlayers[Player.Name]
            local isWhitelist = RagebotFlags.WhitelistedPlayers[Player.Name]
            if isPriority and Settings.PriorityColorEnabled then
                drawColor = Settings.PriorityColor
                drawSkelColor = Settings.PriorityColor
            elseif isWhitelist and Settings.WhitelistColorEnabled then
                drawColor = Settings.WhitelistColor
                drawSkelColor = Settings.WhitelistColor
            end

            local MinX, MinY = math_huge, math_huge
            local MaxX, MaxY = -math_huge, -math_huge
            local OnScreen = false
            -- Use the parts table
            for partName, part in pairs(Data.Parts) do
                local partSize = BodyPartSizes[partName]
                if part and partSize then
                    local Cframe = part.CFrame
                    local X, Y, Z = partSize.X * 0.5, partSize.Y * 0.5, partSize.Z * 0.5
                    local offsets = {
                        Vector3.new(-X, -Y, -Z), Vector3.new(X, -Y, -Z),
                        Vector3.new(-X, Y, -Z), Vector3.new(X, Y, -Z),
                        Vector3.new(-X, -Y, Z), Vector3.new(X, -Y, Z),
                        Vector3.new(-X, Y, Z), Vector3.new(X, Y, Z),
                    }
                    for i = 1, 8 do
                        local worldPos = Cframe:PointToWorldSpace(offsets[i])
                        local ScreenPos, Visible = Camera:WorldToViewportPoint(worldPos)
                        if Visible then
                            OnScreen = true
                            MinX = math_min(MinX, ScreenPos.X)
                            MinY = math_min(MinY, ScreenPos.Y)
                            MaxX = math_max(MaxX, ScreenPos.X)
                            MaxY = math_max(MaxY, ScreenPos.Y)
                        end
                    end
                end
            end

            local BoxX, BoxY, BoxW, BoxH
            if OnScreen then
                local Height = MaxY - MinY
                local DynamicPadding = math_clamp(Height * 0.05, 1, Settings.BoxPadding)
                local FormattedMinX = MinX - DynamicPadding
                local FormattedMinY = MinY - DynamicPadding
                local FormattedMaxX = MaxX + DynamicPadding
                local FormattedMaxY = MaxY + DynamicPadding
                BoxW = FormattedMaxX - FormattedMinX
                BoxH = FormattedMaxY - FormattedMinY
                BoxX = FormattedMinX
                BoxY = FormattedMinY
            end

            -- Draw box, name, health, skeleton (similar to before)
            if OnScreen and Settings.BoxESP then
                Visuals.Box.Position = Vector2.new(BoxX, BoxY)
                Visuals.Box.Size = Vector2.new(BoxW, BoxH)
                Visuals.Box.Color = drawColor
                Visuals.Box.Thickness = Settings.BoxThickness
                Visuals.Box.Visible = true
                if Settings.OutlineESP then
                    Visuals.OutlineBox.Position = Visuals.Box.Position
                    Visuals.OutlineBox.Size = Visuals.Box.Size
                    Visuals.OutlineBox.Color = Settings.OutlineColor
                    Visuals.OutlineBox.Thickness = Settings.OutlineThickness
                    Visuals.OutlineBox.Visible = true
                else
                    Visuals.OutlineBox.Visible = false
                end
            else
                Visuals.Box.Visible = false
                Visuals.OutlineBox.Visible = false
            end

            if OnScreen and Settings.NameESP then
                local textSize = Settings.NameSize or 13
                Visuals.NameText.Size = textSize
                Visuals.NameText.Position = Vector2.new(BoxX + BoxW / 2, BoxY - textSize - 2)
                Visuals.NameText.Text = Player.Name
                Visuals.NameText.Color = drawColor
                Visuals.NameText.Visible = true
            else
                Visuals.NameText.Visible = false
            end

            if OnScreen and Settings.HealthESP and Data.Health and Data.MaxHealth then
                local healthPercent = math_clamp(Data.Health / Data.MaxHealth, 0, 1)
                local barWidth = Settings.HealthBarWidth
                local barHeight = BoxH
                local gap = 4
                local barX = BoxX - barWidth - gap
                local barY = BoxY
                local fillHeight = barHeight * healthPercent
                Visuals.HealthBg.Position = Vector2.new(barX - 1, barY - 1)
                Visuals.HealthBg.Size = Vector2.new(barWidth + 2, barHeight + 2)
                Visuals.HealthBg.Visible = true
                Visuals.HealthBar.Position = Vector2.new(barX, barY + barHeight - fillHeight)
                Visuals.HealthBar.Size = Vector2.new(barWidth, fillHeight)
                Visuals.HealthBar.Visible = true
                Visuals.HealthText.Size = 12
                Visuals.HealthText.Position = Vector2.new(barX + barWidth/2, barY + barHeight + gap)
                Visuals.HealthText.Text = tostring(math_floor(Data.Health))
                Visuals.HealthText.Visible = true
            else
                Visuals.HealthBar.Visible = false
                Visuals.HealthBg.Visible = false
                Visuals.HealthText.Visible = false
            end

            if OnScreen and Settings.SkeletonESP then
                -- Simple skeleton using AttachmentJoints (requires joints to be present)
                for idx, joint in ipairs(AttachmentJoints) do
                    local partA = Data.Parts[joint[1]]
                    local partB = Data.Parts[joint[2]]
                    if partA and partB then
                        local posA = partA.Position
                        local posB = partB.Position
                        local screenA, visA = Camera:WorldToViewportPoint(posA)
                        local screenB, visB = Camera:WorldToViewportPoint(posB)
                        if visA and visB then
                            Visuals.Bones[idx].From = Vector2.new(screenA.X, screenA.Y)
                            Visuals.Bones[idx].To = Vector2.new(screenB.X, screenB.Y)
                            Visuals.Bones[idx].Color = drawSkelColor
                            Visuals.Bones[idx].Thickness = Settings.SkeletonThickness
                            Visuals.Bones[idx].Visible = true
                        else
                            Visuals.Bones[idx].Visible = false
                        end
                    else
                        Visuals.Bones[idx].Visible = false
                    end
                end
            else
                for i = 1, #Visuals.Bones do
                    Visuals.Bones[i].Visible = false
                end
            end
        else
            -- Hide all
            Visuals.Box.Visible = false
            Visuals.OutlineBox.Visible = false
            Visuals.HealthBar.Visible = false
            Visuals.HealthBg.Visible = false
            Visuals.HealthText.Visible = false
            Visuals.NameText.Visible = false
            for i = 1, #Visuals.Bones do
                Visuals.Bones[i].Visible = false
            end
        end
    end
end

return ESP
