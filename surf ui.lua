-- ======================================
-- GGMenu UI Library v6.0 (Mobile + Config)
-- ======================================
local GGMenu = {}
GGMenu.__index = GGMenu

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Detectar dispositivo
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isTablet = isMobile and UserInputService.TouchEnabled

-- Configurações responsivas
GGMenu.Responsive = {
    IsMobile = isMobile,
    IsTablet = isTablet,
    Scale = isMobile and 0.85 or 1,
    FontSizeMultiplier = isMobile and 0.9 or 1,
    PaddingMultiplier = isMobile and 0.8 or 1
}

-- Configurações de tema (com suporte a tema claro/escuro)
GGMenu.Theme = {
    Accent = Color3.fromRGB(232, 84, 84),
    BgDark = Color3.fromRGB(12, 12, 15),
    BgCard = Color3.fromRGB(18, 18, 22),
    BgCardHover = Color3.fromRGB(25, 25, 30),
    TextPrimary = Color3.fromRGB(245, 245, 250),
    TextSecondary = Color3.fromRGB(160, 160, 175),
    Border = Color3.fromRGB(35, 35, 42),
    Success = Color3.fromRGB(72, 199, 142),
    Warning = Color3.fromRGB(241, 196, 15),
    Danger = Color3.fromRGB(231, 76, 60),
    
    -- Para tema claro (opcional)
    LightMode = false,
    Light = {
        Accent = Color3.fromRGB(220, 60, 60),
        BgDark = Color3.fromRGB(240, 240, 245),
        BgCard = Color3.fromRGB(250, 250, 255),
        BgCardHover = Color3.fromRGB(230, 230, 240),
        TextPrimary = Color3.fromRGB(30, 30, 40),
        TextSecondary = Color3.fromRGB(100, 100, 120),
        Border = Color3.fromRGB(200, 200, 210)
    }
}

-- Sistema de tema dinâmico
function GGMenu.SetTheme(lightMode)
    GGMenu.Theme.LightMode = lightMode
    if lightMode then
        GGMenu.CurrentTheme = GGMenu.Theme.Light
    else
        GGMenu.CurrentTheme = GGMenu.Theme
    end
end

-- Inicializar tema
GGMenu.CurrentTheme = GGMenu.Theme

-- Fonts responsivas
GGMenu.Fonts = {
    Title = Enum.Font.GothamBold,
    Header = Enum.Font.GothamSemibold,
    Body = isMobile and Enum.Font.GothamMedium or Enum.Font.Gotham,
    Code = Enum.Font.Code
}

-- Sistema de configurações
local SettingsSystem = {
    Configs = {},
    AutoSave = true,
    SaveMethod = nil -- "file", "datastore", "memory"
}

-- ======================================
-- UTILITÁRIOS
-- ======================================
local function Create(class, props, children)
    local obj = Instance.new(class)
    
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    
    if children then
        for _, child in ipairs(children) do
            child.Parent = obj
        end
    end
    
    return obj
end

local function Tween(obj, props, duration)
    duration = duration or (isMobile and 0.15 or 0.2)
    local ti = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
end

-- Tamanhos responsivos
local function ResponsiveSize(baseWidth, baseHeight)
    local scale = GGMenu.Responsive.Scale
    return UDim2.new(0, baseWidth * scale, 0, baseHeight * scale)
end

local function ResponsiveFontSize(baseSize)
    return baseSize * GGMenu.Responsive.FontSizeMultiplier
end

-- Detectar executor (cache)
local cachedExecutor = nil
local function GetExecutor()
    if cachedExecutor then return cachedExecutor end
    
    local exec = "Unknown"
    pcall(function()
        if identifyexecutor then exec = identifyexecutor()
        elseif getexecutorname then exec = getexecutorname()
        elseif _G.Executor then exec = tostring(_G.Executor)
        elseif ArceusX then exec = "Arceus X"
        elseif Hydrogen then exec = "Hydrogen"
        elseif Delta then exec = "Delta"
        elseif Codex then exec = "Codex"
        elseif VegaX then exec = "Vega X"
        elseif Xeno then exec = "Xeno"
        elseif Valex then exec = "Valex"
        elseif Nihon then exec = "Nihon"
        elseif Volcano then exec = "Volcano"
        elseif Bunni then exec = "Bunni"
        elseif Velocity then exec = "Velocity"
        elseif LX63 then exec = "LX63"
        elseif Visual then exec = "Visual"
        elseif isexecutorclosure then exec = "Executor"
        end
    end)
    
    cachedExecutor = exec
    return exec
end

-- Sistema de configurações
function GGMenu.CreateConfig(name, defaultConfig)
    local config = table.clone(defaultConfig or {})
    SettingsSystem.Configs[name] = config
    
    local configObj = {
        Name = name,
        Data = config,
        
        Get = function(self, key)
            return self.Data[key]
        end,
        
        Set = function(self, key, value)
            self.Data[key] = value
            if SettingsSystem.AutoSave then
                GGMenu.SaveConfigs()
            end
        end,
        
        Save = function(self)
            GGMenu.SaveConfigs()
        end,
        
        Reset = function(self)
            for k, v in pairs(defaultConfig) do
                self.Data[k] = v
            end
            self:Save()
        end
    }
    
    return configObj
end

-- Salvar configurações
function GGMenu.SaveConfigs()
    if SettingsSystem.SaveMethod == "file" and writefile and readfile then
        pcall(function()
            local json = game:GetService("HttpService"):JSONEncode(SettingsSystem.Configs)
            writefile("ggmenu_configs.json", json)
        end)
    elseif SettingsSystem.SaveMethod == "datastore" then
        -- Implementar datastore se necessário
    else
        -- Salvar em _G como fallback
        _G.GGMenu_Configs = SettingsSystem.Configs
    end
end

-- Carregar configurações
function GGMenu.LoadConfigs()
    if SettingsSystem.SaveMethod == "file" and readfile and isfile then
        pcall(function()
            local json = readfile("ggmenu_configs.json")
            local data = game:GetService("HttpService"):JSONDecode(json)
            SettingsSystem.Configs = data
        end)
    elseif _G.GGMenu_Configs then
        SettingsSystem.Configs = _G.GGMenu_Configs
    end
end

-- Configurar método de salvamento
function GGMenu.SetSaveMethod(method)
    SettingsSystem.SaveMethod = method
    if method == "file" then
        GGMenu.LoadConfigs()
    end
end

-- ======================================
-- COMPONENTES BASE (RESPONSIVOS)
-- ======================================
function GGMenu.CreateToggle(parent, text, defaultValue, configKey, configTable)
    local container = Create("Frame", {
        Parent = parent,
        Size = ResponsiveSize(1, 40),
        BackgroundTransparency = 1,
        LayoutOrder = 0
    })
    
    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.CurrentTheme.TextPrimary,
        TextSize = ResponsiveFontSize(14),
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleSize = isMobile and 40 or 48
    local circleSize = isMobile and 16 or 20
    
    local toggleFrame = Create("Frame", {
        Parent = container,
        Size = ResponsiveSize(toggleSize, 26),
        Position = UDim2.new(1, -toggleSize, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = defaultValue and GGMenu.CurrentTheme.Accent or GGMenu.CurrentTheme.BgCard,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Create("UIStroke", {Color = GGMenu.CurrentTheme.Border, Thickness = 1})
    })
    
    local toggleCircle = Create("Frame", {
        Parent = toggleFrame,
        Size = ResponsiveSize(circleSize, circleSize),
        Position = defaultValue and UDim2.new(1, -(circleSize+1), 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(defaultValue and 1 or 0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    local toggle = {
        Value = defaultValue or false,
        Container = container,
        ConfigKey = configKey,
        ConfigTable = configTable,
        
        Set = function(self, value)
            self.Value = value
            Tween(toggleFrame, {BackgroundColor3 = value and GGMenu.CurrentTheme.Accent or GGMenu.CurrentTheme.BgCard})
            Tween(toggleCircle, {
                Position = value and UDim2.new(1, -(circleSize+1), 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            })
            
            -- Salvar em configuração se fornecido
            if configKey and configTable then
                configTable:Set(configKey, value)
            end
        end,
        
        Toggle = function(self)
            self:Set(not self.Value)
        end,
        
        Destroy = function(self)
            container:Destroy()
        end
    }
    
    -- Suporte a touch para mobile
    local button = Create("TextButton", {
        Parent = toggleFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 2
    })
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            toggle:Toggle()
        end
    end)
    
    return toggle
end

function GGMenu.CreateSlider(parent, text, min, max, defaultValue, configKey, configTable)
    local isFloat = (defaultValue or min) % 1 ~= 0
    local container = Create("Frame", {
        Parent = parent,
        Size = ResponsiveSize(1, 50),
        BackgroundTransparency = 1,
        LayoutOrder = 0
    })
    
    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, -60, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.CurrentTheme.TextPrimary,
        TextSize = ResponsiveFontSize(14),
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local valueLabel = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -60, 0, 0),
        BackgroundTransparency = 1,
        Text = isFloat and string.format("%.2f", defaultValue or min) or tostring(defaultValue or min),
        TextColor3 = GGMenu.CurrentTheme.TextSecondary,
        TextSize = ResponsiveFontSize(12),
        Font = GGMenu.Fonts.Code
    })
    
    local sliderTrack = Create("Frame", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, isMobile and 8 or 6),
        Position = UDim2.new(0, 0, 1, -20),
        BackgroundColor3 = GGMenu.CurrentTheme.BgCard,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, isMobile and 4 : 3)}),
        Create("UIStroke", {Color = GGMenu.CurrentTheme.Border, Thickness = 1})
    })
    
    local sliderFill = Create("Frame", {
        Parent = sliderTrack,
        Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = GGMenu.CurrentTheme.Accent,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, isMobile and 4 : 3)})
    })
    
    local buttonSize = isMobile and 20 or 16
    local sliderButton = Create("Frame", {
        Parent = sliderTrack,
        Size = ResponsiveSize(buttonSize, buttonSize),
        Position = UDim2.new((defaultValue - min) / (max - min), -(buttonSize/2), 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Create("UIStroke", {Color = GGMenu.CurrentTheme.Border, Thickness = 1})
    })
    
    local slider = {
        Value = defaultValue or min,
        Min = min,
        Max = max,
        Container = container,
        IsFloat = isFloat,
        ConfigKey = configKey,
        ConfigTable = configTable,
        
        Set = function(self, value)
            value = math.clamp(value, min, max)
            self.Value = value
            local percent = (value - min) / (max - min)
            
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderButton.Position = UDim2.new(percent, -(buttonSize/2), 0.5, 0)
            valueLabel.Text = self.IsFloat and string.format("%.2f", value) or tostring(math.floor(value))
            
            -- Salvar em configuração se fornecido
            if configKey and configTable then
                configTable:Set(configKey, value)
            end
        end,
        
        Destroy = function(self)
            container:Destroy()
        end
    }
    
    local dragging = false
    
    local function updateSlider(input)
        local x = input.Position.X - sliderTrack.AbsolutePosition.X
        local percent = math.clamp(x / sliderTrack.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * percent
        if not isFloat then value = math.floor(value) end
        slider:Set(value)
    end
    
    -- Suporte a touch e mouse
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return slider
end

function GGMenu.CreateDropdown(parent, text, options, defaultValue, configKey, configTable)
    local container = Create("Frame", {
        Parent = parent,
        Size = ResponsiveSize(1, 40),
        BackgroundTransparency = 1,
        LayoutOrder = 0
    })
    
    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0.5, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.CurrentTheme.TextPrimary,
        TextSize = ResponsiveFontSize(14),
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local dropdownButton = Create("TextButton", {
        Parent = container,
        Size = UDim2.new(0.5, 0, 0, isMobile and 36 : 32),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundColor3 = GGMenu.CurrentTheme.BgCard,
        Text = defaultValue or options[1],
        TextColor3 = GGMenu.CurrentTheme.TextPrimary,
        TextSize = ResponsiveFontSize(13),
        Font = GGMenu.Fonts.Body,
        AutoButtonColor = false
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIStroke", {Color = GGMenu.CurrentTheme.Border, Thickness = 1})
    })
    
    dropdownButton.MouseEnter:Connect(function()
        Tween(dropdownButton, {BackgroundColor3 = GGMenu.CurrentTheme.BgCardHover})
    end)
    
    dropdownButton.MouseLeave:Connect(function()
        Tween(dropdownButton, {BackgroundColor3 = GGMenu.CurrentTheme.BgCard})
    end)
    
    local dropdownOpen = false
    local dropdownFrame = nil
    
    local function closeDropdown()
        if dropdownFrame then
            dropdownFrame:Destroy()
            dropdownFrame = nil
        end
        dropdownOpen = false
    end
    
    local function toggleDropdown()
        if dropdownOpen then
            closeDropdown()
        else
            dropdownOpen = true
            dropdownFrame = Create("Frame", {
                Parent = container,
                Size = UDim2.new(0.5, 0, 0, math.min(#options * 32, 160)),
                Position = UDim2.new(0.5, 0, 0, 35),
                BackgroundColor3 = GGMenu.CurrentTheme.BgDark,
                BorderSizePixel = 0,
                ZIndex = 100
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {Color = GGMenu.CurrentTheme.Border, Thickness = 1})
            })
            
            for i, option in ipairs(options) do
                local optionBtn = Create("TextButton", {
                    Parent = dropdownFrame,
                    Size = UDim2.new(1, 0, 0, isMobile and 36 : 32),
                    Position = UDim2.new(0, 0, 0, (i-1)*(isMobile and 36 : 32)),
                    BackgroundColor3 = GGMenu.CurrentTheme.BgDark,
                    Text = option,
                    TextColor3 = GGMenu.CurrentTheme.TextPrimary,
                    TextSize = ResponsiveFontSize(13),
                    Font = GGMenu.Fonts.Body,
                    AutoButtonColor = false,
                    ZIndex = 101
                })
                
                optionBtn.MouseEnter:Connect(function()
                    Tween(optionBtn, {BackgroundColor3 = GGMenu.CurrentTheme.BgCard})
                end)
                
                optionBtn.MouseLeave:Connect(function()
                    Tween(optionBtn, {BackgroundColor3 = GGMenu.CurrentTheme.BgDark})
                end)
                
                optionBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                       input.UserInputType == Enum.UserInputType.Touch then
                        dropdownButton.Text = option
                        closeDropdown()
                        
                        -- Salvar em configuração se fornecido
                        if configKey and configTable then
                            configTable:Set(configKey, option)
                        end
                    end
                end)
            end
        end
    end
    
    dropdownButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            toggleDropdown()
        end
    end)
    
    -- Fechar ao clicar fora
    local clickConnection = UserInputService.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch) and dropdownFrame then
            local mousePos = input.Position
            local framePos = dropdownFrame.AbsolutePosition
            local frameSize = dropdownFrame.AbsoluteSize
            
            if not (mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
                   mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y) then
                closeDropdown()
            end
        end
    end)
    
    local dropdown = {
        Container = container,
        GetValue = function() return dropdownButton.Text end,
        SetValue = function(value) 
            dropdownButton.Text = value
            
            -- Salvar em configuração se fornecido
            if configKey and configTable then
                configTable:Set(configKey, value)
            end
        end,
        Destroy = function(self)
            clickConnection:Disconnect()
            container:Destroy()
        end
    }
    
    return dropdown
end

-- ======================================
-- FPS BAR RESPONSIVA
-- ======================================
function GGMenu.CreateFPSBar()
    local screenGui = Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_FPSBar",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000
    })
    
    local barWidth = isMobile and 350 or 450
    local barHeight = isMobile and 28 or 32
    
    local bar = Create("Frame", {
        Parent = screenGui,
        Size = ResponsiveSize(barWidth, barHeight),
        Position = UDim2.new(0, 10, 1, -(barHeight + 10)),
        BackgroundColor3 = GGMenu.CurrentTheme.BgCard,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, isMobile and 6 : 8)}),
        Create("UIStroke", {Color = GGMenu.CurrentTheme.Accent, Thickness = isMobile and 1 : 1.2})
    })
    
    local textLabel = Create("TextLabel", {
        Parent = bar,
        Size = UDim2.new(1, -15, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = "GGMenu | Loading...",
        TextColor3 = GGMenu.CurrentTheme.TextPrimary,
        TextSize = ResponsiveFontSize(isMobile and 11 : 13),
        Font = GGMenu.Fonts.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextStrokeTransparency = 0.7
    })
    
    local statusDot = Create("Frame", {
        Parent = bar,
        Size = ResponsiveSize(6, 6),
        Position = UDim2.new(1, -12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = GGMenu.CurrentTheme.Success,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    -- Sistema de arrastar manual com suporte a touch
    local dragging = false
    local dragStart, startPos
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = bar.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            bar.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Atualização FPS
    local last = tick()
    local fps = 60
    local fpsSamples = {}
    local executor = GetExecutor()
    
    RunService.RenderStepped:Connect(function()
        local now = tick()
        local currentFPS = math.floor(1 / math.max(now - last, 0.0001))
        last = now
        
        table.insert(fpsSamples, currentFPS)
        if #fpsSamples > 30 then table.remove(fpsSamples, 1) end
        
        local total = 0
        for _, v in ipairs(fpsSamples) do total = total + v end
        fps = math.floor(total / #fpsSamples)
        
        -- Atualizar cor
        if fps >= 50 then
            statusDot.BackgroundColor3 = GGMenu.CurrentTheme.Success
        elseif fps >= 30 then
            statusDot.BackgroundColor3 = GGMenu.CurrentTheme.Warning
        else
            statusDot.BackgroundColor3 = GGMenu.CurrentTheme.Danger
        end
        
        -- Pegar ping
        local ping = 0
        pcall(function()
            if Stats.Network and Stats.Network.ServerStatsItem then
                local pingItem = Stats.Network.ServerStatsItem["Data Ping"]
                if pingItem then
                    ping = math.floor(pingItem:GetValue())
                end
            end
        end)
        
        local timeStr = os.date("%H:%M:%S")
        textLabel.Text = string.format(
            "GGMenu | %s | %d FPS | %d ms | %s",
            Players.LocalPlayer.Name, fps, ping, timeStr
        )
    end)
    
    local fpsBar = {
        Gui = screenGui,
        Bar = bar,
        SetVisible = function(self, visible) screenGui.Enabled = visible end,
        Destroy = function(self) screenGui:Destroy() end
    }
    
    return fpsBar
end

-- ======================================
-- JANELA COM TABS RESPONSIVA
-- ======================================
function GGMenu.CreateWindow(title)
    local screenGui = Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_Window",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 2000
    })
    
    local windowWidth = isMobile and 380 or 500
    local windowHeight = isMobile and 500 : 550
    
    local mainFrame = Create("Frame", {
        Parent = screenGui,
        Size = ResponsiveSize(windowWidth, windowHeight),
        Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2),
        BackgroundColor3 = GGMenu.CurrentTheme.BgCard,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, isMobile and 10 : 12)}),
        Create("UIStroke", {Color = GGMenu.CurrentTheme.Accent, Thickness = isMobile and 1.5 : 2})
    })
    
    -- Header (área de drag)
    local header = Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, isMobile and 50 : 60),
        BackgroundColor3 = GGMenu.CurrentTheme.BgDark,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, isMobile and 10 : 12, 0, 0)})
    })
    
    local titleLabel = Create("TextLabel", {
        Parent = header,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = GGMenu.CurrentTheme.TextPrimary,
        TextSize = ResponsiveFontSize(isMobile and 18 : 20),
        Font = GGMenu.Fonts.Title,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local closeButton = Create("TextButton", {
        Parent = header,
        Size = ResponsiveSize(32, 32),
        Position = UDim2.new(1, -35, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = GGMenu.CurrentTheme.BgCard,
        Text = "×",
        TextColor3 = GGMenu.CurrentTheme.TextPrimary,
        TextSize = ResponsiveFontSize(isMobile and 20 : 24),
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, isMobile and 4 : 6)}),
        Create("UIStroke", {Color = GGMenu.CurrentTheme.Border, Thickness = 1})
    })
    
    closeButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            Tween(closeButton, {BackgroundColor3 = GGMenu.CurrentTheme.Danger, TextColor3 = Color3.new(1, 1, 1)})
        end
    end)
    
    closeButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            Tween(closeButton, {BackgroundColor3 = GGMenu.CurrentTheme.BgCard, TextColor3 = GGMenu.CurrentTheme.TextPrimary})
        end
    end)
    
    -- Sistema de drag manual com suporte a touch
    local dragging = false
    local dragStart, startPos
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Área de tabs
    local tabsContainer = Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, isMobile and 36 : 40),
        Position = UDim2.new(0, 0, 0, isMobile and 50 : 60),
        BackgroundTransparency = 1
    })
    
    local tabsList = Create("ScrollingFrame", {
        Parent = tabsContainer,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    })
    
    -- Área de conteúdo
    local contentArea = Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, -20, 1, -(isMobile and 96 : 110)),
        Position = UDim2.new(0, 10, 0, isMobile and 91 : 105),
        BackgroundTransparency = 1
    })
    
    -- Variáveis da janela
    local tabs = {}
    local currentTab = nil
    local windowVisible = false
    
    -- Funções da janela
    local window = {
        Gui = screenGui,
        Frame = mainFrame,
        Tabs = {},
        
        AddTab = function(self, tabName)
            local tabId = #tabs + 1
            local tabWidth = isMobile and 70 : 80
            
            -- Criar botão da tab
            local tabButton = Create("TextButton", {
                Parent = tabsList,
                Size = ResponsiveSize(tabWidth, isMobile and 30 : 32),
                Position = UDim2.new(0, ((tabId-1) * (tabWidth + 5)), 0, 0),
                BackgroundColor3 = GGMenu.CurrentTheme.BgCard,
                Text = tabName,
                TextColor3 = GGMenu.CurrentTheme.TextSecondary,
                TextSize = ResponsiveFontSize(isMobile and 11 : 13),
                Font = GGMenu.Fonts.Body,
                AutoButtonColor = false
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, isMobile and 4 : 6)}),
                Create("UIStroke", {Color = GGMenu.CurrentTheme.Border, Thickness = 1})
            })
            
            -- Atualizar tamanho do canvas
            tabsList.CanvasSize = UDim2.new(0, tabId * (tabWidth + 5), 0, 0)
            
            -- Criar conteúdo da tab
            local tabContent = Create("ScrollingFrame", {
                Parent = contentArea,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ScrollBarThickness = isMobile and 6 : 4,
                ScrollBarImageColor3 = GGMenu.CurrentTheme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                BorderSizePixel = 0,
                Visible = false
            })
            
            local componentsContainer = Create("Frame", {
                Parent = tabContent,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1
            })
            
            local listLayout = Create("UIListLayout", {
                Parent = componentsContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, isMobile and 3 : 5)
            })
            
            listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                tabContent.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
            end)
            
            -- Função para mostrar/ocultar tab
            local function showTab()
                -- Esconder todas as tabs
                for _, tabData in pairs(tabs) do
                    tabData.Content.Visible = false
                    Tween(tabData.Button, {
                        BackgroundColor3 = GGMenu.CurrentTheme.BgCard,
                        TextColor3 = GGMenu.CurrentTheme.TextSecondary
                    })
                end
                
                -- Mostrar esta tab
                tabContent.Visible = true
                Tween(tabButton, {
                    BackgroundColor3 = GGMenu.CurrentTheme.Accent,
                    TextColor3 = Color3.new(1, 1, 1)
                })
                
                currentTab = tabId
            end
            
            -- Evento do botão
            tabButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.Touch then
                    showTab()
                end
            end)
            
            tabButton.MouseEnter:Connect(function()
                if currentTab ~= tabId then
                    Tween(tabButton, {BackgroundColor3 = GGMenu.CurrentTheme.BgCardHover})
                end
            end)
            
            tabButton.MouseLeave:Connect(function()
                if currentTab ~= tabId then
                    Tween(tabButton, {BackgroundColor3 = GGMenu.CurrentTheme.BgCard})
                end
            end)
            
            -- Armazenar tab
            local tabData = {
                Name = tabName,
                Button = tabButton,
                Content = tabContent,
                Container = componentsContainer,
                Show = showTab
            }
            
            tabs[tabId] = tabData
            self.Tabs[tabName] = tabData
            
            -- Se for a primeira tab, mostrar
            if tabId == 1 then
                showTab()
            end
            
            -- Retornar interface para adicionar componentes
            local tabInterface = {}
            
            function tabInterface:AddSection(title)
                local section = Create("Frame", {
                    Parent = componentsContainer,
                    Size = UDim2.new(1, 0, 0, isMobile and 30 : 35),
                    BackgroundTransparency = 1,
                    LayoutOrder = 0
                })
                
                Create("TextLabel", {
                    Parent = section,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = title:upper(),
                    TextColor3 = GGMenu.CurrentTheme.Accent,
                    TextSize = ResponsiveFontSize(isMobile and 12 : 14),
                    Font = GGMenu.Fonts.Header,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local sectionInterface = {}
                
                function sectionInterface:AddToggle(text, default, configKey, configTable)
                    return GGMenu.CreateToggle(componentsContainer, text, default, configKey, configTable)
                end
                
                function sectionInterface:AddSlider(text, min, max, default, configKey, configTable)
                    return GGMenu.CreateSlider(componentsContainer, text, min, max, default, configKey, configTable)
                end
                
                function sectionInterface:AddDropdown(text, options, default, configKey, configTable)
                    return GGMenu.CreateDropdown(componentsContainer, text, options, default, configKey, configTable)
                end
                
                function sectionInterface:AddLabel(text)
                    local label = Create("TextLabel", {
                        Parent = componentsContainer,
                        Size = UDim2.new(1, 0, 0, isMobile and 22 : 25),
                        LayoutOrder = 0,
                        BackgroundTransparency = 1,
                        Text = text,
                        TextColor3 = GGMenu.CurrentTheme.TextSecondary,
                        TextSize = ResponsiveFontSize(isMobile and 11 : 13),
                        Font = GGMenu.Fonts.Body,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    return label
                end
                
                function sectionInterface:AddSpacer(height)
                    local spacer = Create("Frame", {
                        Parent = componentsContainer,
                        Size = UDim2.new(1, 0, 0, height or (isMobile and 15 : 20)),
                        LayoutOrder = 0,
                        BackgroundTransparency = 1
                    })
                    return spacer
                end
                
                function sectionInterface:AddButton(text, callback)
                    local button = Create("TextButton", {
                        Parent = componentsContainer,
                        Size = UDim2.new(1, 0, 0, isMobile and 36 : 40),
                        LayoutOrder = 0,
                        BackgroundColor3 = GGMenu.CurrentTheme.Accent,
                        Text = text,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextSize = ResponsiveFontSize(isMobile and 12 : 14),
                        Font = GGMenu.Fonts.Body,
                        AutoButtonColor = false
                    }, {
                        Create("UICorner", {CornerRadius = UDim.new(0, isMobile and 6 : 8)}),
                        Create("UIStroke", {Color = GGMenu.CurrentTheme.Accent, Thickness = 1})
                    })
                    
                    button.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                           input.UserInputType == Enum.UserInputType.Touch then
                            Tween(button, {BackgroundColor3 = GGMenu.CurrentTheme.BgCardHover})
                        end
                    end)
                    
                    button.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                           input.UserInputType == Enum.UserInputType.Touch then
                            Tween(button, {BackgroundColor3 = GGMenu.CurrentTheme.Accent})
                            if callback then callback() end
                        end
                    end)
                    
                    return button
                end
                
                return sectionInterface
            end
            
            return tabInterface
        end,
        
        SetVisible = function(self, visible)
            mainFrame.Visible = visible
            windowVisible = visible
        end,
        
        Destroy = function(self)
            screenGui:Destroy()
        end
    }
    
    -- Fechar janela
    closeButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            window:SetVisible(false)
        end
    end)
    
    -- Começar invisível
    window:SetVisible(false)
    
    return window
end

-- ======================================
-- INICIALIZAÇÃO COMPLETA
-- ======================================
function GGMenu:Init(options)
    options = options or {}
    local showFPSBar = options.FPSBar ~= false
    local configName = options.ConfigName or "Default"
    local saveMethod = options.SaveMethod or "memory"
    
    -- Configurar método de salvamento
    GGMenu.SetSaveMethod(saveMethod)
    
    local components = {}
    
    -- FPS Bar (opcional)
    if showFPSBar then
        components.FPSBar = self.CreateFPSBar()
    end
    
    -- Janela (começa invisível)
    components.Window = self.CreateWindow("GGMenu v6.0")
    
    -- Hotkey para mostrar/ocultar (INSERT para PC, toque duplo para mobile)
    if not isMobile then
        local toggleConnection = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Insert then
                components.Window:SetVisible(not components.Window.Frame.Visible)
            end
        end)
        
        components._toggleConnection = toggleConnection
    else
        -- Para mobile: botão flutuante
        local floatingButton = Create("ImageButton", {
            Parent = CoreGui,
            Size = ResponsiveSize(50, 50),
            Position = UDim2.new(1, -60, 1, -60),
            BackgroundColor3 = GGMenu.CurrentTheme.Accent,
            Image = "rbxassetid://10734949127", -- Ícone de menu
            ScaleType = Enum.ScaleType.Fit,
            BackgroundTransparency = 0.3
        }, {
            Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
            Create("UIStroke", {Color = GGMenu.CurrentTheme.Accent, Thickness = 2})
        })
        
        floatingButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                components.Window:SetVisible(not components.Window.Frame.Visible)
            end
        end)
        
        components._floatingButton = floatingButton
    end
    
    -- Configuração padrão
    components.Config = GGMenu.CreateConfig(configName, {})
    
    -- Conectar para limpeza
    components.DestroyAll = function()
        if components._toggleConnection then
            components._toggleConnection:Disconnect()
        end
        if components._floatingButton then
            components._floatingButton:Destroy()
        end
        if components.FPSBar then
            components.FPSBar:Destroy()
        end
        if components.Window then
            components.Window:Destroy()
        end
        GGMenu.SaveConfigs()
    end
    
    print("GGMenu v6.0 loaded!")
    print("Device:", isMobile and "Mobile" .. (isTablet and " (Tablet)" or "") or "Desktop")
    print("Executor:", GetExecutor())
    print("Config:", configName)
    if not isMobile then
        print("Press INSERT to show/hide menu")
    else
        print("Tap the floating button to show/hide menu")
    end
    
    return components
end

-- Versão minimalista
function GGMenu:CreateLibrary()
    return {
        CreateWindow = GGMenu.CreateWindow,
        CreateFPSBar = GGMenu.CreateFPSBar,
        CreateToggle = GGMenu.CreateToggle,
        CreateSlider = GGMenu.CreateSlider,
        CreateDropdown = GGMenu.CreateDropdown,
        CreateConfig = GGMenu.CreateConfig,
        SetTheme = GGMenu.SetTheme,
        SetSaveMethod = GGMenu.SetSaveMethod,
        SaveConfigs = GGMenu.SaveConfigs,
        Theme = GGMenu.Theme,
        Fonts = GGMenu.Fonts,
        Responsive = GGMenu.Responsive
    }
end

return GGMenu
