local ESP = {}
ESP.__index = ESP

local surgecc = {}
do
    if not surgecc.fonts then surgecc.fonts = {} end
    if not surgecc.fonts.cache then surgecc.fonts.cache = {} end

    function surgecc.fonts.cache:register_font(Name, Weight, Style, Asset)
        if not isfolder("surge.cc") then makefolder("surge.cc") end
        if not isfile("surge.cc/" .. Asset.Id) then
            writefile("surge.cc/" .. Asset.Id, Asset.Font)
        end
        local data = {
            name = Name,
            faces = { { name = "Regular", weight = Weight, style = Style, assetId = getcustomasset("surge.cc/" .. Asset.Id) } }
        }
        writefile("surge.cc/" .. Name .. ".font", game:GetService("HttpService"):JSONEncode(data))
        return getcustomasset("surge.cc/" .. Name .. ".font")
    end

    surgecc.fonts.options = {
        ["Windows XP Tahoma"] = Font.new(surgecc.fonts.cache:register_font("Windows_XP_Tahoma", 400, "Regular", {
            Id = "WindowsXpTahoma.ttf",
            Font = "https://github.com/f1nobe7650/other/raw/main/uis/font.ttf"
        })),
        ["Minecraftia"] = Font.new(surgecc.fonts.cache:register_font("Minecraftia", 400, "Regular", {
            Id = "Minecraftia.ttf",
            Font = "https://github.com/fent4life/other/raw/refs/heads/main/fonts/Minecraftia.ttf"
        })),
        ["Proggy Tiny"] = Font.new(surgecc.fonts.cache:register_font("Proggy_Tiny", 400, "Regular", {
            Id = "ProggyTiny.ttf",
            Font = "https://github.com/fent4life/other/raw/refs/heads/main/fonts/ProggyTiny.ttf"
        })),
    }

    surgecc.fonts.offsets = {
        username = {
            ["Minecraftia"] = { size = 4, font = surgecc.fonts.options["Minecraftia"], position = -21 },
            ["Windows XP Tahoma"] = { size = 4, font = surgecc.fonts.options["Windows XP Tahoma"], position = -21 },
            ["Proggy Tiny"] = { size = 1.8, font = surgecc.fonts.options["Proggy Tiny"], position = -19 },
            ["System"] = { size = 4, font = Enum.Font.SourceSans, position = -19 },
            default = { size = 4, font = surgecc.fonts.options["Minecraftia"], position = -21 }
        },
        distance = {
            ["Minecraftia"] = { size = 4, font = surgecc.fonts.options["Minecraftia"], position = -1 },
            ["Windows XP Tahoma"] = { size = 4, font = surgecc.fonts.options["Windows XP Tahoma"], position = 0 },
            ["Proggy Tiny"] = { size = 1.8, font = surgecc.fonts.options["Proggy Tiny"], position = 1 },
            ["System"] = { size = 4, font = Enum.Font.SourceSans, position = 1 },
            default = { size = 4, font = surgecc.fonts.options["Minecraftia"], position = -1 }
        },
        weapon = {
            top = {
                ["Minecraftia"] = { size = 4, font = surgecc.fonts.options["Minecraftia"], position = 10 },
                ["Windows XP Tahoma"] = { size = 4, font = surgecc.fonts.options["Windows XP Tahoma"], position = 12 },
                ["Proggy Tiny"] = { size = 1.8, font = surgecc.fonts.options["Proggy Tiny"], position = 13 },
                ["System"] = { size = 4, font = Enum.Font.SourceSans, position = 13 },
                default = { size = 4, font = surgecc.fonts.options["Minecraftia"], position = 10 }
            },
            bottom = {
                ["Minecraftia"] = { size = 4, font = surgecc.fonts.options["Minecraftia"], position = -1 },
                ["Windows XP Tahoma"] = { size = 4, font = surgecc.fonts.options["Windows XP Tahoma"], position = 0 },
                ["Proggy Tiny"] = { size = 1.8, font = surgecc.fonts.options["Proggy Tiny"], position = 1 },
                ["System"] = { size = 4, font = Enum.Font.SourceSans, position = 1 },
                default = { size = 4, font = surgecc.fonts.options["Minecraftia"], position = -1 }
            }
        },
        health_text = {
            ["Minecraftia"] = {
                [100] = { offset_x = -31, offset_y = -9, size = 4 },
                [9]   = { offset_x = -24, offset_y = -9, size = 4 },
                default = { offset_x = -27, offset_y = -9, size = 4 },
                font = surgecc.fonts.options["Minecraftia"]
            },
            ["Windows XP Tahoma"] = {
                [100] = { offset_x = -28, offset_y = -8, size = 4 },
                [9]   = { offset_x = -23, offset_y = -8, size = 4 },
                default = { offset_x = -26, offset_y = -8, size = 4 },
                font = surgecc.fonts.options["Windows XP Tahoma"]
            },
            ["Proggy Tiny"] = {
                [100] = { offset_x = -29, offset_y = -7, size = 1.8 },
                [9]   = { offset_x = -23, offset_y = -7, size = 1.8 },
                default = { offset_x = -26, offset_y = -7, size = 1.8 },
                font = surgecc.fonts.options["Proggy Tiny"]
            },
            ["System"] = {
                [100] = { offset_x = -29, offset_y = -9, size = 4 },
                [9]   = { offset_x = -23, offset_y = -9, size = 4 },
                default = { offset_x = -25, offset_y = -9, size = 4 },
                font = Enum.Font.SourceSans
            }
        }
    }
end

local function create(class, prop)
    local instance = typeof(class) == "string" and Instance.new(class) or class
    for property, value in pairs(prop) do
        instance[property] = value
    end
    return instance
end

local function deepCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local DEFAULT_CONFIG = {
    esp = {
        enabled = true,
        font = "Windows XP Tahoma",
        box = {
            enabled = true,
            color = Color3.new(1,1,1),
            outline = Color3.fromRGB(),
            style = "Corners",
            gradient = {
                enabled = true,
                rotation = -20,
                animation = { enabled = true, speed = 30 },
                colors = { start = Color3.fromRGB(255,0,4), finish = Color3.fromRGB(247,134,255) }
            },
            box_fill = {
                enabled = true,
                transparency = 0.75,
                color = Color3.fromRGB(0,0,0),
                gradient = {
                    enabled = true,
                    rotation = -90,
                    animation = { enabled = true, speed = 60 },
                    colors = { start = Color3.fromRGB(206,53,226), finish = Color3.fromRGB(56,138,231) }
                }
            }
        },
        health_bar = {
            enabled = true,
            mode = "gradient",
            outline = Color3.fromRGB(),
            colors = { start = Color3.fromRGB(56,138,231), finish = Color3.fromRGB(207,41,207) }
        },
        health_text = {
            enabled = true,
            outline = Color3.fromRGB(),
            on_change = false
        },
        username = {
            enabled = true,
            case = "Default",
            style = "Display",
            color = Color3.new(1,1,1),
            outline = Color3.fromRGB()
        },
        distance = {
            enabled = true,
            case = "Default",
            color = Color3.new(1,1,1),
            outline = Color3.fromRGB()
        },
        weapon = {
            enabled = false,
            case = "Default",
            color = Color3.fromRGB(255,0,4),
            outline = Color3.fromRGB()
        },
        bouncing_text = {
            enabled = true,
            bouncing = true,
            speed = 5,
            colors = { start = Color3.fromRGB(0,123,255), finish = Color3.fromRGB(35,83,255) },
            outline = Color3.fromRGB(0,0,0),
            text = "ghettohaxx"
        },
        target = {
            enabled = true,
            color = Color3.new(1,1,1),
            isTarget = nil
        }
    }
}

function ESP.new(model, options)
    local self = setmetatable({}, ESP)
    self.model = model
    self.config = deepCopy(DEFAULT_CONFIG)
    if options and options.esp then
        for k, v in pairs(options.esp) do
            if type(v) == "table" and self.config.esp[k] and type(self.config.esp[k]) == "table" then
                for k2, v2 in pairs(v) do
                    self.config.esp[k][k2] = v2
                end
            else
                self.config.esp[k] = v
            end
        end
    end

    self.cache = self:_buildUI()
    self.connection = nil
    self:_startUpdater()
    return self
end

function ESP:_buildUI()
    local screenGui = create("ScreenGui", {
        Parent = cloneref(gethui()),
        DisplayOrder = -1,
        IgnoreGuiInset = true,
    })

    local holder = create("Frame", {
        Parent = screenGui,
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
    })

    local box_fill = create("Frame", {
        Parent = holder,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Visible = false,
    })

    local fill_gradient = create("UIGradient", { Parent = holder, Enabled = false })
    local outline = create("UIStroke", {
        Enabled = false,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Thickness = 3,
        Parent = holder,
    })
    local inline = create("UIStroke", {
        Enabled = false,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Thickness = 1,
        Parent = box_fill,
    })
    local inline_gradient = create("UIGradient", { Parent = inline, Enabled = false })

    local healthbar = create("Frame", {
        BorderSizePixel = 0,
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        Parent = box_fill,
    })
    local healthbar_outline = create("UIStroke", {
        Transparency = 0,
        Color = Color3.fromRGB(0,0,0),
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Thickness = 1,
        Parent = healthbar,
    })
    local healthbar_inline = create("Frame", {
        BorderSizePixel = 0,
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Parent = healthbar,
    })
    local healthbar_gradient = create("UIGradient", {
        Parent = healthbar_inline,
        Enabled = false,
        Rotation = 90,
    })

    local username = create("TextLabel", {
        BackgroundTransparency = 1,
        TextStrokeTransparency = 0,
        Font = Enum.Font.Arimo,
    })
    local username_outline = create("UIStroke", {
        Enabled = true,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Thickness = 1,
        Parent = username,
    })

    local distance = create("TextLabel", {
        BackgroundTransparency = 1,
        TextStrokeTransparency = 0,
        Font = Enum.Font.Arimo,
    })
    local distance_outline = create("UIStroke", {
        Enabled = true,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Thickness = 1,
        Parent = distance,
    })

    local weapon = create("TextLabel", {
        BackgroundTransparency = 1,
        TextStrokeTransparency = 0,
        Font = Enum.Font.Arimo,
    })
    local weapon_outline = create("UIStroke", {
        Enabled = true,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Thickness = 1,
        Parent = weapon,
    })

    local healthtext = create("TextLabel", {
        BackgroundTransparency = 1,
        TextStrokeTransparency = 0,
        Font = Enum.Font.Arimo,
    })
    local healthtext_outline = create("UIStroke", {
        Enabled = true,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Thickness = 1,
        Parent = healthtext,
    })

    local bouncing = create("TextLabel", {
        BackgroundTransparency = 1,
        TextStrokeTransparency = 0,
        Font = Enum.Font.Arimo,
    })
    local bouncing_outline = create("UIStroke", {
        Enabled = true,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Thickness = 1,
        Parent = bouncing,
    })

    -- Corner frames
    local top_left = create("Frame", { Parent = holder, BorderColor3 = Color3.fromRGB(0,0,0), ZIndex = 50, Size = UDim2.new(0,1,0.3,0), BackgroundColor3 = Color3.fromRGB(255,255,255), Position = UDim2.new(0,-2,0,-1) })
    local top_corner1 = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(0,1), Position = UDim2.new(0,-2,0,0), ZIndex = 500, BorderSizePixel = 0, Size = UDim2.new(0,1,0,2), BackgroundColor3 = Color3.fromRGB(255,255,255) })
    local top_corner2 = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(0,1), Position = UDim2.new(1,1,0,0), ZIndex = 500, BorderSizePixel = 0, Size = UDim2.new(0,1,0,2), BackgroundColor3 = Color3.fromRGB(255,255,255) })
    local top_right = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,2,0,-1), BorderColor3 = Color3.fromRGB(0,0,0), ZIndex = 50, Size = UDim2.new(0,1,0.3,0), BackgroundColor3 = Color3.fromRGB(255,255,255) })
    local bottom_left = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(0,1), Position = UDim2.new(0,-2,1,2), BorderColor3 = Color3.fromRGB(0,0,0), ZIndex = 50, Size = UDim2.new(0.4,0,0,1), BackgroundColor3 = Color3.fromRGB(255,255,255) })
    local bottom_corner1 = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(0,1), Position = UDim2.new(0,-2,1,1), ZIndex = 500, BorderSizePixel = 0, Size = UDim2.new(0,1,0,1), BackgroundColor3 = Color3.fromRGB(255,255,255) })
    local bottom_corner2 = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(0,1), Position = UDim2.new(1,1,1,1), ZIndex = 500, BorderSizePixel = 0, Size = UDim2.new(0,1,0,1), BackgroundColor3 = Color3.fromRGB(255,255,255) })
    local bottom_right = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(1,1), Position = UDim2.new(1,2,1,2), BorderColor3 = Color3.fromRGB(0,0,0), ZIndex = 50, Size = UDim2.new(0.4,0,0,1), BackgroundColor3 = Color3.fromRGB(255,255,255) })
    local bottom_left2 = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(0,1), Position = UDim2.new(0,-2,1,0), BorderColor3 = Color3.fromRGB(0,0,0), ZIndex = 50, Size = UDim2.new(0,1,0.3,0), BackgroundColor3 = Color3.fromRGB(255,255,255) })
    local bottom_right2 = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(1,1), Position = UDim2.new(1,2,1,0), BorderColor3 = Color3.fromRGB(0,0,0), ZIndex = 50, Size = UDim2.new(0,1,0.3,0), BackgroundColor3 = Color3.fromRGB(255,255,255) })
    local top_left2 = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(0,1), BorderColor3 = Color3.fromRGB(0,0,0), ZIndex = 50, Size = UDim2.new(0.4,0,0,1), BackgroundColor3 = Color3.fromRGB(255,255,255), Position = UDim2.new(0,-2,0,-1) })
    local top_right2 = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(1,1), Position = UDim2.new(1,2,0,-1), BorderColor3 = Color3.fromRGB(0,0,0), ZIndex = 50, Size = UDim2.new(0.4,0,0,1), BackgroundColor3 = Color3.fromRGB(255,255,255) })

    local elements = {
        holder = holder,
        box_fill = box_fill,
        inline = inline,
        outline = outline,
        inline_gradient = inline_gradient,
        fill_gradient = fill_gradient,
        healthbar = healthbar,
        healthbar_outline = healthbar_outline,
        healthbar_inline = healthbar_inline,
        healthbar_gradient = healthbar_gradient,
        username = username,
        username_outline = username_outline,
        distance = distance,
        distance_outline = distance_outline,
        weapon = weapon,
        weapon_outline = weapon_outline,
        healthtext = healthtext,
        healthtext_outline = healthtext_outline,
        bouncing = bouncing,
        bouncing_outline = bouncing_outline,
        top_left = top_left,
        top_right = top_right,
        bottom_left = bottom_left,
        bottom_right = bottom_right,
        bottom_left2 = bottom_left2,
        bottom_right2 = bottom_right2,
        top_left2 = top_left2,
        top_right2 = top_right2,
        top_corner1 = top_corner1,
        top_corner2 = top_corner2,
        bottom_corner1 = bottom_corner1,
        bottom_corner2 = bottom_corner2,
        screenGui = screenGui,
    }

    setmetatable(elements, { __gc = function() screenGui:Destroy() end })
    return elements
end

function ESP:_startUpdater()
    local selfRef = self   -- capture self for the closure
    self.connection = game:GetService("RunService").RenderStepped:Connect(function()
        selfRef:_update()
    end)
end

function ESP:_update()
    local model = self.model
    if not model or not model.Parent then
        self.cache.holder.Visible = false
        return
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local rootPart = model:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart or humanoid.Health <= 0 then
        self.cache.holder.Visible = false
        return
    end

    local camera = workspace.CurrentCamera
    if not camera then return end

    local position, onScreen = camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        self.cache.holder.Visible = false
        return
    end

    local theta = math.rad(camera.FieldOfView)
    local d = 2 * position.Z * math.tan(theta / 2)
    local scale = (rootPart.Size.Y * camera.ViewportSize.Y) / (d * 1.5)
    local height = 4.5 * scale
    local width = 3 * scale

    local health = humanoid.Health
    local maxHealth = humanoid.MaxHealth
    local healthPercent = math.clamp(health / maxHealth, 0, 1)

    local selected_font = self.config.esp.font or "Minecraftia"
    local distanceVal = 0
    if camera then
        distanceVal = math.floor((camera.CFrame.Position - rootPart.Position).Magnitude / 3.571)
    end

    local cfg = self.config.esp
    local elements = self.cache

    if cfg.enabled then
        elements.holder.Visible = true
        elements.holder.Position = UDim2.new(0, position.X - width/2, 0, position.Y - height/2.3)
        elements.holder.Size = UDim2.new(0, width, 0, height)

        elements.box_fill.Visible = true
        elements.box_fill.Position = UDim2.new(0, -1, 0, -1)
        elements.box_fill.Size = UDim2.new(1, 2, 1, 2)

        if cfg.box.enabled then
            if cfg.box.style == "Corners" then
                local c = cfg.box.color
                for _, name in ipairs({"top_left","top_left2","top_corner1","top_right","top_right2","top_corner2",
                                        "bottom_left","bottom_left2","bottom_corner1","bottom_right","bottom_right2","bottom_corner2"}) do
                    local frame = elements[name]
                    if frame then
                        frame.Visible = true
                        frame.BackgroundColor3 = c
                    end
                end
                elements.inline.Enabled = false
                elements.outline.Enabled = false
            else
                for _, name in ipairs({"top_left","top_right","bottom_left","bottom_right","bottom_left2","bottom_right2",
                                        "top_left2","top_right2","bottom_corner1","bottom_corner2","top_corner1","top_corner2"}) do
                    local frame = elements[name]
                    if frame then frame.Visible = false end
                end
                elements.inline.Enabled = true
                elements.inline.Transparency = 0
                elements.inline.Color = cfg.box.color

                elements.outline.Enabled = true
                elements.outline.Transparency = 0
                elements.outline.Color = cfg.box.outline or Color3.fromRGB()

                if cfg.box.gradient.enabled then
                    elements.inline_gradient.Enabled = true
                    elements.inline_gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, cfg.box.gradient.colors.start),
                        ColorSequenceKeypoint.new(1, cfg.box.gradient.colors.finish)
                    })
                    elements.inline.Color = Color3.new(1,1,1)
                    if cfg.box.gradient.animation.enabled then
                        elements.inline_gradient.Rotation = math.sin(tick() * cfg.box.gradient.animation.speed / 45) * 180
                    else
                        elements.inline_gradient.Rotation = cfg.box.gradient.rotation
                    end
                else
                    elements.inline_gradient.Enabled = false
                    elements.inline.Color = cfg.box.color
                end
            end

            -- Box fill
            if cfg.box.box_fill.enabled then
                local fill = cfg.box.box_fill
                if fill.gradient.enabled then
                    elements.fill_gradient.Enabled = true
                    elements.fill_gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, fill.gradient.colors.start),
                        ColorSequenceKeypoint.new(1, fill.gradient.colors.finish)
                    })
                    elements.holder.BackgroundColor3 = Color3.new(1,1,1)
                    elements.holder.BackgroundTransparency = fill.transparency
                    if fill.gradient.animation.enabled then
                        elements.fill_gradient.Rotation = math.sin(tick() * fill.gradient.animation.speed / 45) * 180
                    else
                        elements.fill_gradient.Rotation = fill.gradient.rotation
                    end
                else
                    elements.fill_gradient.Enabled = false
                    elements.holder.BackgroundColor3 = fill.color
                    elements.holder.BackgroundTransparency = fill.transparency
                end
            else
                elements.holder.BackgroundColor3 = Color3.new()
                elements.holder.BackgroundTransparency = 1
            end
        else
            elements.outline.Enabled = false
            elements.inline.Enabled = false
        end

        -- Health bar
        if cfg.health_bar.enabled then
            elements.healthbar.Visible = true
            elements.healthbar.Size = UDim2.new(0, 2, 0, height + 4)
            elements.healthbar.Position = UDim2.new(0, -8, 0, -2)
            elements.healthbar.Transparency = 0

            elements.healthbar_inline.Visible = true
            elements.healthbar_inline.Size = UDim2.new(1, 0, healthPercent, 0)
            elements.healthbar_inline.Position = UDim2.new(0, 0, 1 - healthPercent, 0)
            elements.healthbar_inline.Transparency = 0

            elements.healthbar_outline.Transparency = 0
            elements.healthbar_outline.Enabled = true

            if string.lower(cfg.health_bar.mode) == "gradient" then
                elements.healthbar_gradient.Enabled = true
                elements.healthbar_gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, cfg.health_bar.colors.start),
                    ColorSequenceKeypoint.new(1, cfg.health_bar.colors.finish)
                })
                elements.healthbar_inline.BackgroundColor3 = Color3.new(1,1,1)
            else
                elements.healthbar_gradient.Enabled = false
                elements.healthbar_inline.BackgroundColor3 = cfg.health_bar.colors.finish:lerp(cfg.health_bar.colors.start, healthPercent)
            end
        else
            elements.healthbar.Visible = false
            elements.healthbar_inline.Visible = false
            elements.healthbar_outline.Enabled = false
        end

        -- Health text
        if cfg.health_bar.enabled and cfg.health_text.enabled then
            elements.healthtext.Parent = elements.holder
            elements.healthtext.Visible = true
            elements.healthtext.Text = math.floor(health)
            elements.healthtext.TextStrokeColor3 = cfg.health_text.outline
            elements.healthtext_outline.Color = cfg.health_text.outline
            elements.healthtext.TextColor3 = cfg.health_bar.colors.finish:lerp(cfg.health_bar.colors.start, healthPercent)
            elements.healthtext.TextTransparency = 0
            elements.healthtext.TextStrokeTransparency = 0

            if cfg.health_text.on_change and health == 100 then
                elements.healthtext.Visible = false
            else
                elements.healthtext.Visible = true
            end

            local off, size
            local h = math.floor(health)
            local offsets = surgecc.fonts.offsets.health_text[selected_font]
            if offsets[h] then
                off = offsets[h]
            else
                off = offsets.default
            end
            elements.healthtext.Size = UDim2.new(0, 18, 0, 18)
            elements.healthtext.FontSize = off.size
            elements.healthtext.FontFace = offsets.font
            elements.healthtext.Position = UDim2.new(0, off.offset_x, elements.healthbar_inline.Position.Y.Scale, elements.healthbar_inline.Position.Y.Offset + off.offset_y)
        else
            elements.healthtext.Visible = false
        end

        -- Username
        if cfg.username.enabled then
            elements.username.Parent = elements.holder
            elements.username.Visible = true
            elements.username.TextStrokeColor3 = cfg.username.outline
            elements.username_outline.Color = cfg.username.outline
            elements.username.TextTransparency = 0
            elements.username.TextStrokeTransparency = 0

            local isTarget = false
            if cfg.target.enabled and cfg.target.isTarget then
                isTarget = cfg.target.isTarget(model)
            end
            elements.username.TextColor3 = isTarget and cfg.target.color or cfg.username.color

            elements.username.Text = model.Name or "Unknown"
            local off = surgecc.fonts.offsets.username[selected_font] or surgecc.fonts.offsets.username.default
            elements.username.Size = UDim2.new(0, 100, 0, 18)
            elements.username.FontSize = off.size
            elements.username.FontFace = off.font
            elements.username.Position = UDim2.new(0.5, -elements.username.Size.X.Offset/2, 0, off.position)
        else
            elements.username.Visible = false
        end

        -- Distance
        if cfg.distance.enabled then
            elements.distance.Parent = elements.holder
            elements.distance.Visible = true
            elements.distance.Text = tostring(distanceVal) .. " m"
            local isTarget = false
            if cfg.target.enabled and cfg.target.isTarget then
                isTarget = cfg.target.isTarget(model)
            end
            elements.distance.TextColor3 = isTarget and cfg.target.color or cfg.distance.color
            elements.distance.TextTransparency = 0
            elements.distance.TextStrokeTransparency = 0

            local off = surgecc.fonts.offsets.distance[selected_font] or surgecc.fonts.offsets.distance.default
            elements.distance.Size = UDim2.new(0, 100, 0, 18)
            elements.distance.FontSize = off.size
            elements.distance.FontFace = off.font
            elements.distance.Position = UDim2.new(0.5, -elements.distance.Size.X.Offset/2, 1, off.position)
        else
            elements.distance.Visible = false
        end

        if cfg.weapon.enabled then
            elements.weapon.Parent = elements.holder
            elements.weapon.Visible = true
            elements.weapon.TextTransparency = 0
            elements.weapon.TextStrokeTransparency = 0
            elements.weapon.TextColor3 = cfg.weapon.color
            elements.weapon.Text = self:getWeaponName() or "nothing"

            local pos = cfg.distance.enabled and "top" or "bottom"
            local off = surgecc.fonts.offsets.weapon[pos][selected_font] or surgecc.fonts.offsets.weapon[pos].default
            elements.weapon.FontFace = off.font
            elements.weapon.Position = UDim2.new(0.5, -elements.distance.Size.X.Offset/2, 1, off.position)
            elements.weapon.Size = UDim2.new(0, 100, 0, 18)
            elements.weapon.FontSize = off.size
        else
            elements.weapon.Visible = false
        end

        -- Bouncing text
        if cfg.bouncing_text.enabled then
            elements.bouncing.Parent = elements.holder
            elements.bouncing.Visible = true
            elements.bouncing.Text = cfg.bouncing_text.text or ""
            elements.bouncing.TextColor3 = cfg.bouncing_text.colors.start
            elements.bouncing.TextStrokeColor3 = cfg.bouncing_text.outline
            elements.bouncing_outline.Color = cfg.bouncing_text.outline
            elements.bouncing.TextTransparency = 0
            elements.bouncing.TextStrokeTransparency = 0

            local bounce = cfg.bouncing_text.bouncing and math.sin(tick() * cfg.bouncing_text.speed) * 10 or 0
            elements.bouncing.Size = UDim2.new(0, 200, 0, 18)
            elements.bouncing.FontSize = 4
            elements.bouncing.FontFace = surgecc.fonts.options[selected_font] or Enum.Font.SourceSans
            elements.bouncing.Position = UDim2.new(0.5, -100, 0.5, -9 + bounce)
            elements.bouncing.BackgroundTransparency = 1
        else
            elements.bouncing.Visible = false
        end

    else
        elements.holder.Visible = false
    end
end

function ESP:getWeaponName()
    return "nothing"
end

function ESP:SetOptions(newOptions)
    if newOptions and newOptions.esp then
        for k, v in pairs(newOptions.esp) do
            if type(v) == "table" and self.config.esp[k] and type(self.config.esp[k]) == "table" then
                for k2, v2 in pairs(v) do
                    self.config.esp[k][k2] = v2
                end
            else
                self.config.esp[k] = v
            end
        end
    end
end

function ESP:Destroy()
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
    if self.cache and self.cache.screenGui then
        self.cache.screenGui:Destroy()
    end
    self.cache = nil
    self.model = nil
end

return ESP
