-- ======================================
-- GGMenu UI Library v6.3 (PC Only) - OTIMIZADA cu
-- ======================================
local GGMenu = {}
GGMenu.__index = GGMenu

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ======================================
-- SISTEMA DE CACHE E SINGLETON
-- ======================================
local cachedGuiParent = nil
local function GetGuiParent()
    if cachedGuiParent then return cachedGuiParent end
    
    -- Tentar CoreGui primeiro
    local success, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    
    if success and coreGui then
        cachedGuiParent = coreGui
        return coreGui
    end
    
    -- Fallback para PlayerGui
    local player = Players.LocalPlayer
    while not player do
        task.wait(0.1)
        player = Players.LocalPlayer
    end
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        playerGui = player:WaitForChild("PlayerGui")
    end
    
    cachedGuiParent = playerGui
    return playerGui
end

-- ======================================
-- SISTEMA DE TEMA DINÂMICO
-- ======================================
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
    Danger = Color3.fromRGB(231, 76, 60)
}

GGMenu.Fonts = {
    Title = Enum.Font.GothamBold,
    Header = Enum.Font.GothamSemibold,
    Body = Enum.Font.Gotham,
    Code = Enum.Font.Code
}

-- Registry para atualização dinâmica de tema
local ThemeRegistry = {
    Objects = {}, -- {obj, {prop = "themeKey", ...}}
}

-- Registra objeto para atualização de tema
local function RegisterForThemeUpdates(obj, propertyMap)
    table.insert(ThemeRegistry.Objects, {
        Object = obj,
        Properties = propertyMap
    })
    
    -- Aplicar tema inicial
    for prop, themeKey in pairs(propertyMap) do
        if GGMenu.Theme[themeKey] then
            obj[prop] = GGMenu.Theme[themeKey]
        end
    end
end

-- Atualiza tema em TODOS elementos registrados
function GGMenu.RefreshTheme()
    for _, entry in ipairs(ThemeRegistry.Objects) do
        if entry.Object and not entry.Object:IsDescendantOf(nil) then
            for prop, themeKey in pairs(entry.Properties) do
                if GGMenu.Theme[themeKey] and entry.Object[prop] then
                    entry.Object[prop] = GGMenu.Theme[themeKey]
                end
            end
        end
    end
end

-- ======================================
-- SISTEMA DE CONFIGURAÇÕES
-- ======================================
local SettingsSystem = {
    Configs = {},
    AutoSave = true
}

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

function GGMenu.SaveConfigs()
    if writefile and readfile then
        pcall(function()
            local json = game:GetService("HttpService"):JSONEncode(SettingsSystem.Configs)
            writefile("ggmenu_configs.json", json)
        end)
    elseif _G.GGMenu_Configs then
        _G.GGMenu_Configs = SettingsSystem.Configs
    end
end

function GGMenu.LoadConfigs()
    if readfile and isfile and isfile("ggmenu_configs.json") then
        pcall(function()
            local json = readfile("ggmenu_configs.json")
            local data = game:GetService("HttpService"):JSONDecode(json)
            SettingsSystem.Configs = data
        end)
    elseif _G.GGMenu_Configs then
        SettingsSystem.Configs = _G.GGMenu_Configs
    end
end

GGMenu.LoadConfigs()

-- ======================================
-- UTILITÁRIOS CENTRALIZADOS
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
    duration = duration or 0.2
    local ti = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
end

-- Detector de executor com cache
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

-- ======================================
-- SISTEMA DE INPUT CENTRALIZADO (MELHORIA 2)
-- ======================================
local InputManager = {
    Sliders = {}, -- {sliderObject, trackFrame}
    ActiveSlider = nil
}

-- Centraliza eventos de input para todos os sliders
UserInputService.InputChanged:Connect(function(input)
    if InputManager.ActiveSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local slider = InputManager.ActiveSlider
        local track = InputManager.Sliders[slider]
        
        if track then
            local x = input.Position.X - track.AbsolutePosition.X
            local percent = math.clamp(x / track.AbsoluteSize.X, 0, 1)
            local value = slider.Min + (slider.Max - slider.Min) * percent
            if not slider.IsFloat then value = math.floor(value) end
            slider:Set(value)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        InputManager.ActiveSlider = nil
    end
end)

-- ======================================
-- COMPONENTES BASE COM THEME REGISTRY
-- ======================================
function GGMenu.CreateToggle(parent, text, defaultValue, configKey, configTable, callback)
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = 0
    })
    
    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 14,
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    RegisterForThemeUpdates(label, {TextColor3 = "TextPrimary"})
    
    local toggleFrame = Create("Frame", {
        Parent = container,
        Size = UDim2.new(0, 48, 0, 26),
        Position = UDim2.new(1, -48, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = defaultValue and GGMenu.Theme.Accent or GGMenu.Theme.BgCard,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    RegisterForThemeUpdates(toggleFrame, {
        BackgroundColor3 = defaultValue and "Accent" or "BgCard",
        UIStroke = "Border"
    })
    
    local toggleCircle = Create("Frame", {
        Parent = toggleFrame,
        Size = UDim2.new(0, 20, 0, 20),
        Position = defaultValue and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
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
        Frame = toggleFrame,
        Circle = toggleCircle,
        
        Set = function(self, value)
            self.Value = value
            local color = value and GGMenu.Theme.Accent or GGMenu.Theme.BgCard
            Tween(toggleFrame, {BackgroundColor3 = color})
            Tween(toggleCircle, {
                Position = value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            })
            
            if configKey and configTable then
                configTable:Set(configKey, value)
            end
            
            if callback then
                callback(value)
            end
        end,
        
        Toggle = function(self)
            self:Set(not self.Value)
        end,
        
        UpdateTheme = function(self)
            local color = self.Value and GGMenu.Theme.Accent or GGMenu.Theme.BgCard
            toggleFrame.BackgroundColor3 = color
        end
    }
    
    local button = Create("TextButton", {
        Parent = toggleFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 2
    })
    
    button.MouseButton1Click:Connect(function()
        toggle:Toggle()
    end)
    
    return toggle
end

function GGMenu.CreateSlider(parent, text, min, max, defaultValue, configKey, configTable)
    local isFloat = (defaultValue or min) % 1 ~= 0
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        LayoutOrder = 0
    })
    
    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, -60, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 14,
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    RegisterForThemeUpdates(label, {TextColor3 = "TextPrimary"})
    
    local valueLabel = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -60, 0, 0),
        BackgroundTransparency = 1,
        Text = isFloat and string.format("%.2f", defaultValue or min) or tostring(defaultValue or min),
        TextColor3 = GGMenu.Theme.TextSecondary,
        TextSize = 12,
        Font = GGMenu.Fonts.Code
    })
    
    RegisterForThemeUpdates(valueLabel, {TextColor3 = "TextSecondary"})
    
    local sliderTrack = Create("Frame", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -20),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 3)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    RegisterForThemeUpdates(sliderTrack, {
        BackgroundColor3 = "BgCard",
        UIStroke = "Border"
    })
    
    local sliderFill = Create("Frame", {
        Parent = sliderTrack,
        Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = GGMenu.Theme.Accent,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 3)})
    })
    
    RegisterForThemeUpdates(sliderFill, {BackgroundColor3 = "Accent"})
    
    local sliderButton = Create("Frame", {
        Parent = sliderTrack,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((defaultValue - min) / (max - min), -8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    RegisterForThemeUpdates(sliderButton, {UIStroke = "Border"})
    
    local slider = {
        Value = defaultValue or min,
        Min = min,
        Max = max,
        Container = container,
        IsFloat = isFloat,
        ConfigKey = configKey,
        ConfigTable = configTable,
        Track = sliderTrack,
        Fill = sliderFill,
        Button = sliderButton,
        ValueLabel = valueLabel,
        
        Set = function(self, value)
            value = math.clamp(value, min, max)
            self.Value = value
            local percent = (value - min) / (max - min)
            
            self.Fill.Size = UDim2.new(percent, 0, 1, 0)
            self.Button.Position = UDim2.new(percent, -8, 0.5, 0)
            self.ValueLabel.Text = self.IsFloat and string.format("%.2f", value) or tostring(math.floor(value))
            
            if configKey and configTable then
                configTable:Set(configKey, value)
            end
        end,
        
        UpdateTheme = function(self)
            self.Track.BackgroundColor3 = GGMenu.Theme.BgCard
            self.Fill.BackgroundColor3 = GGMenu.Theme.Accent
            self.ValueLabel.TextColor3 = GGMenu.Theme.TextSecondary
        end
    }
    
    -- Registrar slider no manager centralizado
    InputManager.Sliders[slider] = sliderTrack
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            InputManager.ActiveSlider = slider
            local x = input.Position.X - sliderTrack.AbsolutePosition.X
            local percent = math.clamp(x / sliderTrack.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * percent
            if not isFloat then value = math.floor(value) end
            slider:Set(value)
        end
    end)
    
    return slider
end

function GGMenu.CreateDropdown(parent, text, options, defaultValue, configKey, configTable)
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = 0
    })
    
    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0.5, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 14,
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    RegisterForThemeUpdates(label, {TextColor3 = "TextPrimary"})
    
    local dropdownButton = Create("TextButton", {
        Parent = container,
        Size = UDim2.new(0.5, 0, 0, 32),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        Text = defaultValue or options[1],
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 13,
        Font = GGMenu.Fonts.Body,
        AutoButtonColor = false
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    RegisterForThemeUpdates(dropdownButton, {
        BackgroundColor3 = "BgCard",
        TextColor3 = "TextPrimary",
        UIStroke = "Border"
    })
    
    dropdownButton.MouseEnter:Connect(function()
        Tween(dropdownButton, {BackgroundColor3 = GGMenu.Theme.BgCardHover})
    end)
    
    dropdownButton.MouseLeave:Connect(function()
        Tween(dropdownButton, {BackgroundColor3 = GGMenu.Theme.BgCard})
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
    
    -- SISTEMA DE CLIQUE FORA OTIMIZADO (MELHORIA 4)
    local clickConnection = nil
    
    local function toggleDropdown()
        if dropdownOpen then
            closeDropdown()
            if clickConnection then
                clickConnection:Disconnect()
                clickConnection = nil
            end
        else
            dropdownOpen = true
            dropdownFrame = Create("Frame", {
                Parent = container,
                Size = UDim2.new(0.5, 0, 0, math.min(#options * 32, 160)),
                Position = UDim2.new(0.5, 0, 0, 35),
                BackgroundColor3 = GGMenu.Theme.BgDark,
                BorderSizePixel = 0,
                ZIndex = 100
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
            })
            
            RegisterForThemeUpdates(dropdownFrame, {
                BackgroundColor3 = "BgDark",
                UIStroke = "Border"
            })
            
            for i, option in ipairs(options) do
                local optionBtn = Create("TextButton", {
                    Parent = dropdownFrame,
                    Size = UDim2.new(1, 0, 0, 32),
                    Position = UDim2.new(0, 0, 0, (i-1)*32),
                    BackgroundColor3 = GGMenu.Theme.BgDark,
                    Text = option,
                    TextColor3 = GGMenu.Theme.TextPrimary,
                    TextSize = 13,
                    Font = GGMenu.Fonts.Body,
                    AutoButtonColor = false,
                    ZIndex = 101
                })
                
                RegisterForThemeUpdates(optionBtn, {
                    BackgroundColor3 = "BgDark",
                    TextColor3 = "TextPrimary"
                })
                
                optionBtn.MouseEnter:Connect(function()
                    Tween(optionBtn, {BackgroundColor3 = GGMenu.Theme.BgCard})
                end)
                
                optionBtn.MouseLeave:Connect(function()
                    Tween(optionBtn, {BackgroundColor3 = GGMenu.Theme.BgDark})
                end)
                
                optionBtn.MouseButton1Click:Connect(function()
                    dropdownButton.Text = option
                    closeDropdown()
                    
                    if configKey and configTable then
                        configTable:Set(configKey, option)
                    end
                    
                    if clickConnection then
                        clickConnection:Disconnect()
                        clickConnection = nil
                    end
                end)
            end
            
            -- Evento de clique fora (apenas quando dropdown está aberto)
            clickConnection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownFrame then
                    local mousePos = UserInputService:GetMouseLocation()
                    local framePos = dropdownFrame.AbsolutePosition
                    local frameSize = dropdownFrame.AbsoluteSize
                    
                    if not (mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
                           mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y) then
                        closeDropdown()
                        clickConnection:Disconnect()
                        clickConnection = nil
                    end
                end
            end)
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(toggleDropdown)
    
    local dropdown = {
        Container = container,
        GetValue = function() return dropdownButton.Text end,
        SetValue = function(value) 
            dropdownButton.Text = value
            if configKey and configTable then
                configTable:Set(configKey, value)
            end
        end,
        UpdateTheme = function(self)
            dropdownButton.BackgroundColor3 = GGMenu.Theme.BgCard
            dropdownButton.TextColor3 = GGMenu.Theme.TextPrimary
        end
    }
    
    return dropdown
end

-- ======================================
-- FPS BAR OTIMIZADA (MELHORIA 3)
-- ======================================
function GGMenu.CreateFPSBar()
    local screenGui = Create("ScreenGui", {
        Parent = GetGuiParent(),
        Name = "GGMenu_FPSBar",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000
    })
    
    local bar = Create("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 450, 0, 32),
        Position = UDim2.new(0, 10, 1, -42),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {Color = GGMenu.Theme.Accent, Thickness = 1.2})
    })
    
    RegisterForThemeUpdates(bar, {
        BackgroundColor3 = "BgCard",
        UIStroke = "Accent"
    })
    
    local textLabel = Create("TextLabel", {
        Parent = bar,
        Size = UDim2.new(1, -15, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "GGMenu | Loading...",
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 13,
        Font = GGMenu.Fonts.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextStrokeTransparency = 0.7
    })
    
    RegisterForThemeUpdates(textLabel, {TextColor3 = "TextPrimary"})
    
    local statusDot = Create("Frame", {
        Parent = bar,
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(1, -15, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = GGMenu.Theme.Success,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    -- Sistema de arrastar
    local dragging = false
    local dragStart, startPos
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = bar.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            bar.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Sistema de FPS e Ping otimizado
    local last = tick()
    local fps = 60
    local fpsSamples = {}
    local executor = GetExecutor()
    
    RunService.RenderStepped:Connect(function()
        local now = tick()
        local currentFPS = math.floor(1 / math.max(now - last, 0.0001))
        last = now
        
        -- Média móvel para FPS estável
        table.insert(fpsSamples, currentFPS)
        if #fpsSamples > 30 then table.remove(fpsSamples, 1) end
        
        local total = 0
        for _, v in ipairs(fpsSamples) do total = total + v end
        fps = math.floor(total / #fpsSamples)
        
        -- Atualizar cor do status
        if fps >= 50 then
            statusDot.BackgroundColor3 = GGMenu.Theme.Success
        elseif fps >= 30 then
            statusDot.BackgroundColor3 = GGMenu.Theme.Warning
        else
            statusDot.BackgroundColor3 = GGMenu.Theme.Danger
        end
        
        -- Sistema de ping com fallback (MELHORIA 3)
        local ping = 0
        pcall(function()
            -- Método 1: Stats do Roblox
            if Stats.Network and Stats.Network.ServerStatsItem then
                local pingItem = Stats.Network.ServerStatsItem["Data Ping"]
                if pingItem then
                    ping = math.floor(pingItem:GetValue())
                end
            end
            
            -- Método 2: NetworkClient (fallback)
            if ping == 0 and game:GetService("NetworkClient") then
                ping = math.floor(game:GetService("NetworkClient"):GetServerResponseTime() * 1000)
            end
            
            -- Método 3: Player method (último recurso)
            if ping == 0 and Players.LocalPlayer:GetNetworkPing then
                ping = math.floor(Players.LocalPlayer:GetNetworkPing() * 1000)
            end
        end)
        
        local timeStr = os.date("%H:%M:%S")
        textLabel.Text = string.format(
            "GGMenu | %s | %d FPS | %d ms | %s | %s",
            Players.LocalPlayer.Name, fps, ping, timeStr, executor
        )
    end)
    
    return {
        Gui = screenGui,
        Bar = bar,
        TextLabel = textLabel,
        StatusDot = statusDot,
        
        SetVisible = function(self, visible) 
            screenGui.Enabled = visible 
        end,
        
        Destroy = function(self) 
            screenGui:Destroy() 
        end,
        
        UpdateTheme = function(self)
            bar.BackgroundColor3 = GGMenu.Theme.BgCard
            bar.UIStroke.Color = GGMenu.Theme.Accent
            textLabel.TextColor3 = GGMenu.Theme.TextPrimary
        end
    }
end

-- ======================================
-- JANELA COM TABS E THEME SUPPORT
-- ======================================
function GGMenu.CreateWindow(title)
    local screenGui = Create("ScreenGui", {
        Parent = GetGuiParent(),
        Name = "GGMenu_Window",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 2000
    })
    
    local mainFrame = Create("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 500, 0, 550),
        Position = UDim2.new(0.5, -250, 0.5, -275),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BorderSizePixel = 0,
        Visible = false
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Create("UIStroke", {Color = GGMenu.Theme.Accent, Thickness = 2})
    })
    
    RegisterForThemeUpdates(mainFrame, {
        BackgroundColor3 = "BgCard",
        UIStroke = "Accent"
    })
    
    -- Header
    local header = Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = GGMenu.Theme.BgDark,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 12, 0, 0)})
    })
    
    RegisterForThemeUpdates(header, {BackgroundColor3 = "BgDark"})
    
    local titleLabel = Create("TextLabel", {
        Parent = header,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 20,
        Font = GGMenu.Fonts.Title,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    RegisterForThemeUpdates(titleLabel, {TextColor3 = "TextPrimary"})
    
    -- Botão de fechar
    local closeButton = Create("TextButton", {
        Parent = header,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -40, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        Text = "×",
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    RegisterForThemeUpdates(closeButton, {
        BackgroundColor3 = "BgCard",
        TextColor3 = "TextPrimary",
        UIStroke = "Border"
    })
    
    -- Hover effects
    closeButton.MouseEnter:Connect(function()
        Tween(closeButton, {
            BackgroundColor3 = GGMenu.Theme.Danger,
            TextColor3 = Color3.new(1, 1, 1)
        })
    end)
    
    closeButton.MouseLeave:Connect(function()
        Tween(closeButton, {
            BackgroundColor3 = GGMenu.Theme.BgCard,
            TextColor3 = GGMenu.Theme.TextPrimary
        })
    end)
    
    -- Sistema de drag
    local dragging = false
    local dragStart, startPos
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Área de tabs
    local tabsContainer = Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 60),
        BackgroundTransparency = 1
    })
    
    local tabsList = Create("ScrollingFrame", {
        Parent = tabsContainer,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    })
    
    -- Área de conteúdo
    local contentArea = Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, -30, 1, -110),
        Position = UDim2.new(0, 15, 0, 105),
        BackgroundTransparency = 1
    })
    
    -- Variáveis da janela
    local tabs = {}
    local currentTab = nil
    
    -- Interface da janela
    local window = {
        Gui = screenGui,
        Frame = mainFrame,
        Tabs = tabs,
        Visible = false,
        
        AddTab = function(self, tabName)
            local tabId = #tabs + 1
            
            -- Criar botão da tab
            local tabButton = Create("TextButton", {
                Parent = tabsList,
                Size = UDim2.new(0, 80, 1, 0),
                Position = UDim2.new(0, ((tabId-1) * 85), 0, 0),
                BackgroundColor3 = GGMenu.Theme.BgCard,
                Text = tabName,
                TextColor3 = GGMenu.Theme.TextSecondary,
                TextSize = 13,
                Font = GGMenu.Fonts.Body,
                AutoButtonColor = false
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
            })
            
            RegisterForThemeUpdates(tabButton, {
                BackgroundColor3 = "BgCard",
                TextColor3 = "TextSecondary",
                UIStroke = "Border"
            })
            
            -- Atualizar tamanho do canvas
            tabsList.CanvasSize = UDim2.new(0, tabId * 85, 0, 0)
            
            -- Criar conteúdo da tab
            local tabContent = Create("ScrollingFrame", {
                Parent = contentArea,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = GGMenu.Theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                BorderSizePixel = 0,
                Visible = false
            })
            
            RegisterForThemeUpdates(tabContent, {ScrollBarImageColor3 = "Accent"})
            
            local componentsContainer = Create("Frame", {
                Parent = tabContent,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1
            })
            
            local listLayout = Create("UIListLayout", {
                Parent = componentsContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })
            
            listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                tabContent.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
            end)
            
            -- Função para mostrar/ocultar tab
            local function showTab()
                for _, tabData in pairs(tabs) do
                    tabData.Content.Visible = false
                    Tween(tabData.Button, {
                        BackgroundColor3 = GGMenu.Theme.BgCard,
                        TextColor3 = GGMenu.Theme.TextSecondary
                    })
                end
                
                tabContent.Visible = true
                Tween(tabButton, {
                    BackgroundColor3 = GGMenu.Theme.Accent,
                    TextColor3 = Color3.new(1, 1, 1)
                })
                
                currentTab = tabId
            end
            
            -- Eventos do botão
            tabButton.MouseButton1Click:Connect(showTab)
            
            tabButton.MouseEnter:Connect(function()
                if currentTab ~= tabId then
                    Tween(tabButton, {BackgroundColor3 = GGMenu.Theme.BgCardHover})
                end
            end)
            
            tabButton.MouseLeave:Connect(function()
                if currentTab ~= tabId then
                    Tween(tabButton, {BackgroundColor3 = GGMenu.Theme.BgCard})
                end
            end)
            
            -- Armazenar tab
            local tabData = {
                Name = tabName,
                Button = tabButton,
                Content = tabContent,
                Container = componentsContainer,
                Show = showTab,
                UpdateTheme = function(self)
                    self.Button.BackgroundColor3 = currentTab == tabId and GGMenu.Theme.Accent or GGMenu.Theme.BgCard
                    self.Button.TextColor3 = currentTab == tabId and Color3.new(1,1,1) or GGMenu.Theme.TextSecondary
                    self.Content.ScrollBarImageColor3 = GGMenu.Theme.Accent
                end
            }
            
            tabs[tabId] = tabData
            self.Tabs[tabName] = tabData
            
            -- Se for a primeira tab, mostrar
            if tabId == 1 then
                showTab()
            end
            
            -- Interface da tab
            local tabInterface = {}
            
            function tabInterface:AddSection(title)
                local section = Create("Frame", {
                    Parent = componentsContainer,
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1,
                    LayoutOrder = 0
                })
                
                local sectionLabel = Create("TextLabel", {
                    Parent = section,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = title:upper(),
                    TextColor3 = GGMenu.Theme.Accent,
                    TextSize = 14,
                    Font = GGMenu.Fonts.Header,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                RegisterForThemeUpdates(sectionLabel, {TextColor3 = "Accent"})
                
                local sectionInterface = {}
                
                function sectionInterface:AddToggle(text, default, configKey, configTable, callback)
                    return GGMenu.CreateToggle(componentsContainer, text, default, configKey, configTable, callback)
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
                        Size = UDim2.new(1, 0, 0, 25),
                        LayoutOrder = 0,
                        BackgroundTransparency = 1,
                        Text = text,
                        TextColor3 = GGMenu.Theme.TextSecondary,
                        TextSize = 13,
                        Font = GGMenu.Fonts.Body,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    RegisterForThemeUpdates(label, {TextColor3 = "TextSecondary"})
                    return label
                end
                
                function sectionInterface:AddSpacer(height)
                    local spacer = Create("Frame", {
                        Parent = componentsContainer,
                        Size = UDim2.new(1, 0, 0, height or 20),
                        LayoutOrder = 0,
                        BackgroundTransparency = 1
                    })
                    return spacer
                end
                
                function sectionInterface:AddButton(text, callback)
                    local button = Create("TextButton", {
                        Parent = componentsContainer,
                        Size = UDim2.new(1, 0, 0, 40),
                        LayoutOrder = 0,
                        BackgroundColor3 = GGMenu.Theme.Accent,
                        Text = text,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextSize = 14,
                        Font = GGMenu.Fonts.Body,
                        AutoButtonColor = false
                    }, {
                        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                        Create("UIStroke", {Color = GGMenu.Theme.Accent, Thickness = 1})
                    })
                    
                    RegisterForThemeUpdates(button, {
                        BackgroundColor3 = "Accent",
                        UIStroke = "Accent"
                    })
                    
                    button.MouseEnter:Connect(function()
                        Tween(button, {BackgroundColor3 = GGMenu.Theme.BgCardHover})
                    end)
                    
                    button.MouseLeave:Connect(function()
                        Tween(button, {BackgroundColor3 = GGMenu.Theme.Accent})
                    end)
                    
                    button.MouseButton1Click:Connect(function()
                        if callback then callback() end
                    end)
                    
                    return button
                end
                
                return sectionInterface
            end
            
            return tabInterface
        end,
        
        SetVisible = function(self, visible)
            mainFrame.Visible = visible
            self.Visible = visible
        end,
        
        Toggle = function(self)
            self.Visible = not self.Visible
            mainFrame.Visible = self.Visible
            return self.Visible
        end,
        
        UpdateTheme = function(self)
            mainFrame.BackgroundColor3 = GGMenu.Theme.BgCard
            mainFrame.UIStroke.Color = GGMenu.Theme.Accent
            header.BackgroundColor3 = GGMenu.Theme.BgDark
            titleLabel.TextColor3 = GGMenu.Theme.TextPrimary
            closeButton.BackgroundColor3 = GGMenu.Theme.BgCard
            closeButton.TextColor3 = GGMenu.Theme.TextPrimary
            
            for _, tabData in pairs(tabs) do
                if tabData.UpdateTheme then
                    tabData:UpdateTheme()
                end
            end
        end
    }
    
    -- Fechar janela com botão X
    closeButton.MouseButton1Click:Connect(function()
        window:SetVisible(false)
    end)
    
    return window
end

-- ======================================
-- SISTEMA DE NOTIFICAÇÕES OTIMIZADO
-- ======================================
local NotifySingleton = nil

function GGMenu.Notify(title, text, duration)
    duration = duration or 3
    
    if not NotifySingleton then
        NotifySingleton = Create("ScreenGui", {
            Parent = GetGuiParent(),
            Name = "GGMenu_NotifyContainer",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 3000
        })
    end
    
    local frame = Create("Frame", {
        Parent = NotifySingleton,
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, -310, 1, -90),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {Color = GGMenu.Theme.Accent, Thickness = 1})
    })
    
    RegisterForThemeUpdates(frame, {
        BackgroundColor3 = "BgCard",
        UIStroke = "Accent"
    })
    
    local titleLabel = Create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = GGMenu.Theme.Accent,
        TextSize = 16,
        Font = GGMenu.Fonts.Header,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    RegisterForThemeUpdates(titleLabel, {TextColor3 = "Accent"})
    
    local textLabel = Create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 13,
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true
    })
    
    RegisterForThemeUpdates(textLabel, {TextColor3 = "TextPrimary"})
    
    -- Animação de entrada
    frame.Position = UDim2.new(1, 400, 1, -90)
    Tween(frame, {Position = UDim2.new(1, -310, 1, -90)})
    
    -- Auto-destruir
    task.delay(duration, function()
        Tween(frame, {
            Position = UDim2.new(1, 400, 1, -90)
        }, 0.3)
        
        task.wait(0.3)
        frame:Destroy()
    end)
end

-- ======================================
-- INICIALIZAÇÃO PRINCIPAL
-- ======================================
local CurrentUI = nil
local UIKey = Enum.KeyCode.Insert

function GGMenu:Init()
    if CurrentUI then
        return CurrentUI
    end
    
    local components = {}
    
    -- FPS Bar
    components.FPSBar = self.CreateFPSBar()
    
    -- Janela principal
    components.MainWindow = self.CreateWindow("GGMenu v6.3")
    
    -- Sistema de tecla Insert
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == UIKey then
            components.MainWindow:Toggle()
        end
    end)
    
    -- Tab de configurações
    local configTab = components.MainWindow:AddTab("Configurações")
    
    -- Seção Interface
    local interfaceSection = configTab:AddSection("Interface")
    
    local uiConfig = self.CreateConfig("UI_Settings", {
        FPSBarVisible = true,
        UIEnabled = true
    })
    
    interfaceSection:AddToggle("Mostrar FPS Bar", uiConfig:Get("FPSBarVisible"), "FPSBarVisible", uiConfig,
        function(value)
            components.FPSBar:SetVisible(value)
        end
    )
    
    interfaceSection:AddToggle("Tecla Insert Ativa", uiConfig:Get("UIEnabled"), "UIEnabled", uiConfig,
        function(value)
            -- Ativa/desativa o listener da tecla
        end
    )
    
    -- Seção Tema (COM ATUALIZAÇÃO DINÂMICA)
    local themeSection = configTab:AddSection("Tema")
    
    local themeConfig = self.CreateConfig("UI_Theme", {
        Accent = self.Theme.Accent,
        Background = self.Theme.BgCard
    })
    
    themeSection:AddLabel("⚠️ Atualização dinâmica ativa!")
    
    local themes = {
        {name = "Vermelho", accent = Color3.fromRGB(232, 84, 84), bg = Color3.fromRGB(18, 18, 22)},
        {name = "Azul", accent = Color3.fromRGB(0, 170, 255), bg = Color3.fromRGB(10, 15, 30)},
        {name = "Verde", accent = Color3.fromRGB(72, 199, 142), bg = Color3.fromRGB(15, 25, 20)},
        {name = "Roxo", accent = Color3.fromRGB(155, 89, 182), bg = Color3.fromRGB(25, 20, 35)}
    }
    
    for _, theme in ipairs(themes) do
        themeSection:AddButton("Tema " .. theme.name, function()
            self.Theme.Accent = theme.accent
            self.Theme.BgCard = theme.bg
            themeConfig:Set("Accent", theme.accent)
            themeConfig:Set("Background", theme.bg)
            
            -- ATUALIZA TODOS ELEMENTOS EXISTENTES
            self.RefreshTheme()
            self.Notify("Tema " .. theme.name, "Atualizado em todos elementos!", 3)
        end)
    end
    
    -- Tab informações
    local infoTab = components.MainWindow:AddTab("Informações")
    local systemSection = infoTab:AddSection("Sistema")
    
    systemSection:AddLabel("Executor: " .. GetExecutor())
    systemSection:AddLabel("Versão: 6.3 (PC Only)")
    systemSection:AddLabel("Data: " .. os.date("%d/%m/%Y"))
    systemSection:AddLabel("")
    systemSection:AddLabel("✨ NOVIDADES v6.3:")
    systemSection:AddLabel("- Temas dinâmicos")
    systemSection:AddLabel("- Input centralizado")
    systemSection:AddLabel("- Ping com fallback")
    systemSection:AddLabel("- Dropdown otimizado")
    
    -- Tab utilitários
    local utilsTab = components.MainWindow:AddTab("Utilitários")
    local gameSection = utilsTab:AddSection("Jogo")
    
    gameSection:AddButton("Reiniciar Personagem", function()
        local char = Players.LocalPlayer.Character
        if char then
            char:BreakJoints()
            self.Notify("Personagem", "Reiniciado com sucesso!", 2)
        end
    end)
    
    gameSection:AddButton("Copiar Localização", function()
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            if setclipboard then
                setclipboard(string.format("Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z))
                self.Notify("Copiado", "Localização copiada!", 2)
            end
        end
    end)
    
    -- Instância UI
    local uiInstance = {
        FPSBar = components.FPSBar,
        Window = components.MainWindow,
        
        SetKey = function(keyCode)
            UIKey = keyCode
            return uiInstance
        end,
        
        Toggle = function()
            return components.MainWindow:Toggle()
        end,
        
        Show = function()
            components.MainWindow:SetVisible(true)
        end,
        
        Hide = function()
            components.MainWindow:SetVisible(false)
        end,
        
        Destroy = function()
            components.FPSBar:Destroy()
            components.MainWindow.Gui:Destroy()
            if NotifySingleton then
                NotifySingleton:Destroy()
                NotifySingleton = nil
            end
            CurrentUI = nil
        end
    }
    
    CurrentUI = uiInstance
    return uiInstance
end

-- ======================================
-- API PÚBLICA
-- ======================================
function GGMenu.new(title)
    title = title or "GGMenu v6.3"
    
    local self = setmetatable({}, GGMenu)
    local ui = GGMenu:Init()
    
    self.Show = ui.Show
    self.Hide = ui.Hide
    self.Toggle = ui.Toggle
    self.Destroy = ui.Destroy
    self.SetKey = ui.SetKey
    self.GetWindow = function() return ui.Window end
    self.GetFPSBar = function() return ui.FPSBar end
    
    return self
end

-- ======================================
-- EXEMPLO COMPLETO
-- ======================================
function GGMenu.CreateExample()
    local ui = GGMenu:Init()
    local exampleTab = ui.Window:AddTab("Exemplo")
    local controls = exampleTab:AddSection("Controles")
    
    local config = GGMenu.CreateConfig("Example_Config", {
        toggle1 = true,
        sliderValue = 50,
        dropdownOption = "Opção 1"
    })
    
    controls:AddToggle("Toggle com Callback", config:Get("toggle1"), "toggle1", config,
        function(value)
            GGMenu.Notify("Toggle", "Estado: " .. (value and "ON" or "OFF"), 2)
        end
    )
    
    controls:AddSlider("Slider", 0, 100, config:Get("sliderValue"), "sliderValue", config)
    
    local options = {"Opção 1", "Opção 2", "Opção 3"}
    controls:AddDropdown("Dropdown", options, config:Get("dropdownOption"), "dropdownOption", config)
    
    controls:AddSpacer(10)
    
    controls:AddButton("Testar Tema", function()
        GGMenu.Theme.Accent = Color3.fromRGB(math.random(50, 255), math.random(50, 255), math.random(50, 255))
        GGMenu.RefreshTheme()
        GGMenu.Notify("Tema Aleatório", "Aplicado!", 2)
    end)
    
    controls:AddButton("Fechar UI", ui.Hide)
    controls:AddButton("Abrir UI", ui.Show)
    
    return ui
end

-- ======================================
-- EXPORTAÇÃO
-- ======================================
return setmetatable(GGMenu, {
    __call = function(self, ...)
        return GGMenu:Init(...)
    end
})
