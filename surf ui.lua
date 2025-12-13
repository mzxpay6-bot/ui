-- ======================================
-- GGMenu UI Library v5.3 (Otimizada e Modular) pelegpo
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

-- Configurações padrão
GGMenu.Config = {
    ToggleKey = Enum.KeyCode.Insert,
    DefaultWindowSize = UDim2.new(0, 500, 0, 550),
    FPSBarSize = UDim2.new(0, 450, 0, 32),
    SliderDragPrecision = 0.01,
    Title = "GGMenu v5.3"
}

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

-- ======================================
-- UTILITÁRIOS OTIMIZADOS
-- ======================================
local Utils = {}

function Utils.Create(class, props, children)
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

function Utils.Tween(obj, props, duration)
    duration = duration or 0.2
    local ti = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
end

-- Cache de executor
local cachedExecutor = nil
function Utils.GetExecutor()
    if cachedExecutor then return cachedExecutor end
    
    local exec = "Unknown"
    pcall(function()
        local executorFuncs = {
            identifyexecutor, getexecutorname, isexecutorclosure,
            function() return _G.Executor end
        }
        
        for _, func in pairs(executorFuncs) do
            if type(func) == "function" then
                local result = func()
                if result and type(result) == "string" then
                    exec = result
                    break
                end
            end
        end
        
        -- Detecções específicas
        if ArceusX then exec = "Arceus X"
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
        end
    end)
    
    cachedExecutor = exec
    return exec
end

-- Sistema de fila circular para FPS
local CircularBuffer = {}
CircularBuffer.__index = CircularBuffer

function CircularBuffer.new(size)
    local self = setmetatable({}, CircularBuffer)
    self.size = size
    self.buffer = {}
    self.index = 1
    self.count = 0
    self.sum = 0
    return self
end

function CircularBuffer:Add(value)
    if self.count < self.size then
        table.insert(self.buffer, value)
        self.sum = self.sum + value
        self.count = self.count + 1
    else
        local old = self.buffer[self.index]
        self.sum = self.sum - old + value
        self.buffer[self.index] = value
        self.index = (self.index % self.size) + 1
    end
end

function CircularBuffer:Average()
    return self.count > 0 and (self.sum / self.count) or 0
end

-- Gerenciador de conexões
local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager

function ConnectionManager.new()
    local self = setmetatable({}, ConnectionManager)
    self.connections = {}
    return self
end

function ConnectionManager:Add(connection)
    table.insert(self.connections, connection)
    return connection
end

function ConnectionManager:Connect(signal, callback)
    local connection = signal:Connect(callback)
    self:Add(connection)
    return connection
end

function ConnectionManager:DisconnectAll()
    for _, connection in ipairs(self.connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    self.connections = {}
end

-- ======================================
-- COMPONENTES BASE OTIMIZADOS
-- ======================================
function GGMenu.CreateToggle(parent, text, defaultValue, callback)
    local connectionManager = ConnectionManager.new()
    
    local container = Utils.Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = parent:GetChildren() and #parent:GetChildren() + 1 or 1
    })
    
    local label = Utils.Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 14,
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleFrame = Utils.Create("Frame", {
        Parent = container,
        Size = UDim2.new(0, 48, 0, 26),
        Position = UDim2.new(1, -48, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = defaultValue and GGMenu.Theme.Accent or GGMenu.Theme.BgCard,
        BorderSizePixel = 0
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Utils.Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    local toggleCircle = Utils.Create("Frame", {
        Parent = toggleFrame,
        Size = UDim2.new(0, 20, 0, 20),
        Position = defaultValue and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(defaultValue and 1 or 0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    local toggle = {
        Value = defaultValue or false,
        Container = container,
        _connections = connectionManager,
        
        Set = function(self, value)
            self.Value = value
            Utils.Tween(toggleFrame, {BackgroundColor3 = value and GGMenu.Theme.Accent or GGMenu.Theme.BgCard})
            Utils.Tween(toggleCircle, {Position = value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)})
            if callback then callback(value) end
        end,
        
        Toggle = function(self)
            self:Set(not self.Value)
        end,
        
        Destroy = function(self)
            self._connections:DisconnectAll()
            container:Destroy()
        end
    }
    
    connectionManager:Connect(toggleFrame.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle:Toggle()
        end
    end)
    
    return toggle
end

function GGMenu.CreateSlider(parent, text, min, max, defaultValue, callback)
    local connectionManager = ConnectionManager.new()
    local isFloat = math.abs((defaultValue or min) - math.floor(defaultValue or min)) > 0.001
    
    local container = Utils.Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        LayoutOrder = parent:GetChildren() and #parent:GetChildren() + 1 or 1
    })
    
    local label = Utils.Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, -60, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 14,
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local valueLabel = Utils.Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -60, 0, 0),
        BackgroundTransparency = 1,
        Text = isFloat and string.format("%.2f", defaultValue or min) or tostring(math.floor(defaultValue or min)),
        TextColor3 = GGMenu.Theme.TextSecondary,
        TextSize = 12,
        Font = GGMenu.Fonts.Code
    })
    
    local sliderTrack = Utils.Create("Frame", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -20),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BorderSizePixel = 0
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 3)}),
        Utils.Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    local sliderFill = Utils.Create("Frame", {
        Parent = sliderTrack,
        Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = GGMenu.Theme.Accent,
        BorderSizePixel = 0
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 3)})
    })
    
    local sliderButton = Utils.Create("Frame", {
        Parent = sliderTrack,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((defaultValue - min) / (max - min), -8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Utils.Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    local slider = {
        Value = defaultValue or min,
        Min = min,
        Max = max,
        Container = container,
        IsFloat = isFloat,
        _connections = connectionManager,
        
        Set = function(self, value)
            value = math.clamp(value, min, max)
            self.Value = value
            local percent = (value - min) / (max - min)
            
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderButton.Position = UDim2.new(percent, -8, 0.5, 0)
            valueLabel.Text = self.IsFloat and string.format("%.2f", value) or tostring(math.floor(value))
            
            if callback then callback(value) end
        end,
        
        Destroy = function(self)
            self._connections:DisconnectAll()
            container:Destroy()
        end
    }
    
    local dragging = false
    
    local function updateSlider(input)
        local x = input.Position.X - sliderTrack.AbsolutePosition.X
        local percent = math.clamp(x / sliderTrack.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * percent
        if not isFloat then value = math.floor(value + 0.5) end
        slider:Set(value)
    end
    
    connectionManager:Connect(sliderTrack.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    connectionManager:Connect(UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    connectionManager:Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return slider
end

function GGMenu.CreateDropdown(parent, text, options, defaultValue, callback)
    local connectionManager = ConnectionManager.new()
    
    local container = Utils.Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = parent:GetChildren() and #parent:GetChildren() + 1 or 1
    })
    
    local label = Utils.Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0.5, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 14,
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local dropdownButton = Utils.Create("TextButton", {
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
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Utils.Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    connectionManager:Connect(dropdownButton.MouseEnter, function()
        Utils.Tween(dropdownButton, {BackgroundColor3 = GGMenu.Theme.BgCardHover})
    end)
    
    connectionManager:Connect(dropdownButton.MouseLeave, function()
        Utils.Tween(dropdownButton, {BackgroundColor3 = GGMenu.Theme.BgCard})
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
            dropdownFrame = Utils.Create("Frame", {
                Parent = container,
                Size = UDim2.new(0.5, 0, 0, math.min(#options * 32, 160)),
                Position = UDim2.new(0.5, 0, 0, 35),
                BackgroundColor3 = GGMenu.Theme.BgDark,
                BorderSizePixel = 0,
                ZIndex = 100
            }, {
                Utils.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Utils.Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
            })
            
            for i, option in ipairs(options) do
                local optionBtn = Utils.Create("TextButton", {
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
                
                connectionManager:Connect(optionBtn.MouseEnter, function()
                    Utils.Tween(optionBtn, {BackgroundColor3 = GGMenu.Theme.BgCard})
                end)
                
                connectionManager:Connect(optionBtn.MouseLeave, function()
                    Utils.Tween(optionBtn, {BackgroundColor3 = GGMenu.Theme.BgDark})
                end)
                
                connectionManager:Connect(optionBtn.MouseButton1Click, function()
                    dropdownButton.Text = option
                    closeDropdown()
                    if callback then callback(option) end
                end)
            end
        end
    end
    
    connectionManager:Connect(dropdownButton.MouseButton1Click, toggleDropdown)
    
    -- Fechar ao clicar fora
    connectionManager:Connect(UserInputService.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownFrame then
            local mousePos = UserInputService:GetMouseLocation()
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
        _connections = connectionManager,
        
        GetValue = function() return dropdownButton.Text end,
        
        SetValue = function(value) 
            dropdownButton.Text = value
            if callback then callback(value) end
        end,
        
        Destroy = function(self)
            self._connections:DisconnectAll()
            container:Destroy()
        end
    }
    
    return dropdown
end

-- ======================================
-- FPS BAR OTIMIZADA
-- ======================================
function GGMenu.CreateFPSBar(position)
    local connectionManager = ConnectionManager.new()
    
    local screenGui = Utils.Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_FPSBar",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000
    })
    
    local bar = Utils.Create("Frame", {
        Parent = screenGui,
        Size = GGMenu.Config.FPSBarSize,
        Position = position or UDim2.new(0, 10, 1, -42),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Utils.Create("UIStroke", {Color = GGMenu.Theme.Accent, Thickness = 1.2})
    })
    
    local textLabel = Utils.Create("TextLabel", {
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
    
    local statusDot = Utils.Create("Frame", {
        Parent = bar,
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(1, -15, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = GGMenu.Theme.Success,
        BorderSizePixel = 0
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    -- Sistema de arrastar
    local dragging = false
    local dragStart, startPos
    
    connectionManager:Connect(bar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = bar.Position
        end
    end)
    
    connectionManager:Connect(UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            bar.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    connectionManager:Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Sistema de FPS otimizado
    local last = tick()
    local fpsBuffer = CircularBuffer.new(30)
    local executor = Utils.GetExecutor()
    
    local renderConnection = RunService.RenderStepped:Connect(function()
        local now = tick()
        local currentFPS = math.floor(1 / math.max(now - last, 0.0001))
        last = now
        
        fpsBuffer:Add(currentFPS)
        local fps = math.floor(fpsBuffer:Average())
        
        -- Atualizar cor
        if fps >= 50 then
            statusDot.BackgroundColor3 = GGMenu.Theme.Success
        elseif fps >= 30 then
            statusDot.BackgroundColor3 = GGMenu.Theme.Warning
        else
            statusDot.BackgroundColor3 = GGMenu.Theme.Danger
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
            "GGMenu | %s | %d FPS | %d ms | %s | %s",
            Players.LocalPlayer.Name, fps, ping, timeStr, executor
        )
    end)
    
    connectionManager:Add(renderConnection)
    
    local fpsBar = {
        Gui = screenGui,
        Bar = bar,
        _connections = connectionManager,
        
        SetVisible = function(self, visible) 
            screenGui.Enabled = visible 
        end,
        
        SetPosition = function(self, position)
            bar.Position = position
        end,
        
        Destroy = function(self)
            self._connections:DisconnectAll()
            screenGui:Destroy()
        end
    }
    
    return fpsBar
end

-- ======================================
-- JANELA COM TABS OTIMIZADA
-- ======================================
function GGMenu.CreateWindow(title)
    local connectionManager = ConnectionManager.new()
    
    local screenGui = Utils.Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_Window",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 2000
    })
    
    local mainFrame = Utils.Create("Frame", {
        Parent = screenGui,
        Size = GGMenu.Config.DefaultWindowSize,
        Position = UDim2.new(0.5, -250, 0.5, -275),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BorderSizePixel = 0
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Utils.Create("UIStroke", {Color = GGMenu.Theme.Accent, Thickness = 2})
    })
    
    -- Header (área de drag)
    local header = Utils.Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = GGMenu.Theme.BgDark,
        BorderSizePixel = 0
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 12, 0, 0)})
    })
    
    local titleLabel = Utils.Create("TextLabel", {
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
    
    local closeButton = Utils.Create("TextButton", {
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
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Utils.Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    connectionManager:Connect(closeButton.MouseEnter, function()
        Utils.Tween(closeButton, {BackgroundColor3 = GGMenu.Theme.Danger, TextColor3 = Color3.new(1, 1, 1)})
    end)
    
    connectionManager:Connect(closeButton.MouseLeave, function()
        Utils.Tween(closeButton, {BackgroundColor3 = GGMenu.Theme.BgCard, TextColor3 = GGMenu.Theme.TextPrimary})
    end)
    
    -- Sistema de drag
    local dragging = false
    local dragStart, startPos
    
    connectionManager:Connect(header.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    connectionManager:Connect(UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    connectionManager:Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Área de tabs
    local tabsContainer = Utils.Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 60),
        BackgroundTransparency = 1
    })
    
    local tabsList = Utils.Create("Frame", {
        Parent = tabsContainer,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1
    })
    
    -- Área de conteúdo
    local contentArea = Utils.Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, -30, 1, -110),
        Position = UDim2.new(0, 15, 0, 105),
        BackgroundTransparency = 1
    })
    
    -- Variáveis da janela
    local tabs = {}
    local currentTab = nil
    local windowVisible = false
    
    -- Helper para adicionar componentes
    local function AddComponentToContainer(container, componentType, ...)
        local component
        
        if componentType == "Toggle" then
            local text, default, callback = ...
            component = GGMenu.CreateToggle(container, text, default, callback)
        elseif componentType == "Slider" then
            local text, min, max, default, callback = ...
            component = GGMenu.CreateSlider(container, text, min, max, default, callback)
        elseif componentType == "Dropdown" then
            local text, options, default, callback = ...
            component = GGMenu.CreateDropdown(container, text, options, default, callback)
        elseif componentType == "Label" then
            local text = ...
            component = Utils.Create("TextLabel", {
                Parent = container,
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = GGMenu.Theme.TextSecondary,
                TextSize = 13,
                Font = GGMenu.Fonts.Body,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        elseif componentType == "Spacer" then
            local height = ... or 20
            component = Utils.Create("Frame", {
                Parent = container,
                Size = UDim2.new(1, 0, 0, height),
                BackgroundTransparency = 1
            })
        end
        
        if component then
            component.LayoutOrder = container:GetChildren() and #container:GetChildren() or 1
        end
        
        return component
    end
    
    -- Funções da janela
    local window = {
        Gui = screenGui,
        Frame = mainFrame,
        Tabs = {},
        _connections = connectionManager,
        
        AddTab = function(self, tabName)
            local tabId = #tabs + 1
            
            -- Criar botão da tab
            local tabButton = Utils.Create("TextButton", {
                Parent = tabsList,
                Size = UDim2.new(0, 80, 1, 0),
                Position = UDim2.new(0, (#tabs * 85), 0, 0),
                BackgroundColor3 = GGMenu.Theme.BgCard,
                Text = tabName,
                TextColor3 = GGMenu.Theme.TextSecondary,
                TextSize = 13,
                Font = GGMenu.Fonts.Body,
                AutoButtonColor = false
            }, {
                Utils.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Utils.Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
            })
            
            -- Criar conteúdo da tab
            local tabContent = Utils.Create("ScrollingFrame", {
                Parent = contentArea,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = GGMenu.Theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                BorderSizePixel = 0,
                Visible = false
            })
            
            local componentsContainer = Utils.Create("Frame", {
                Parent = tabContent,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1
            })
            
            local listLayout = Utils.Create("UIListLayout", {
                Parent = componentsContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })
            
            connectionManager:Connect(listLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                tabContent.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
            end)
            
            -- Função para mostrar/ocultar tab
            local function showTab()
                for _, tabData in pairs(tabs) do
                    tabData.Content.Visible = false
                    Utils.Tween(tabData.Button, {
                        BackgroundColor3 = GGMenu.Theme.BgCard,
                        TextColor3 = GGMenu.Theme.TextSecondary
                    })
                end
                
                tabContent.Visible = true
                Utils.Tween(tabButton, {
                    BackgroundColor3 = GGMenu.Theme.Accent,
                    TextColor3 = Color3.new(1, 1, 1)
                })
                
                currentTab = tabId
            end
            
            -- Eventos do botão
            connectionManager:Connect(tabButton.MouseButton1Click, showTab)
            
            connectionManager:Connect(tabButton.MouseEnter, function()
                if currentTab ~= tabId then
                    Utils.Tween(tabButton, {BackgroundColor3 = GGMenu.Theme.BgCardHover})
                end
            end)
            
            connectionManager:Connect(tabButton.MouseLeave, function()
                if currentTab ~= tabId then
                    Utils.Tween(tabButton, {BackgroundColor3 = GGMenu.Theme.BgCard})
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
                local section = Utils.Create("Frame", {
                    Parent = componentsContainer,
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1
                })
                
                Utils.Create("TextLabel", {
                    Parent = section,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = title:upper(),
                    TextColor3 = GGMenu.Theme.Accent,
                    TextSize = 14,
                    Font = GGMenu.Fonts.Header,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local sectionInterface = {}
                
                function sectionInterface:AddToggle(text, default, callback)
                    return AddComponentToContainer(componentsContainer, "Toggle", text, default, callback)
                end
                
                function sectionInterface:AddSlider(text, min, max, default, callback)
                    return AddComponentToContainer(componentsContainer, "Slider", text, min, max, default, callback)
                end
                
                function sectionInterface:AddDropdown(text, options, default, callback)
                    return AddComponentToContainer(componentsContainer, "Dropdown", text, options, default, callback)
                end
                
                function sectionInterface:AddLabel(text)
                    return AddComponentToContainer(componentsContainer, "Label", text)
                end
                
                function sectionInterface:AddSpacer(height)
                    return AddComponentToContainer(componentsContainer, "Spacer", height)
                end
                
                return sectionInterface
            end
            
            function tabInterface:AddToggle(text, default, callback)
                return AddComponentToContainer(componentsContainer, "Toggle", text, default, callback)
            end
            
            function tabInterface:AddSlider(text, min, max, default, callback)
                return AddComponentToContainer(componentsContainer, "Slider", text, min, max, default, callback)
            end
            
            function tabInterface:AddDropdown(text, options, default, callback)
                return AddComponentToContainer(componentsContainer, "Dropdown", text, options, default, callback)
            end
            
            function tabInterface:AddLabel(text)
                return AddComponentToContainer(componentsContainer, "Label", text)
            end
            
            function tabInterface:AddSpacer(height)
                return AddComponentToContainer(componentsContainer, "Spacer", height)
            end
            
            return tabInterface
        end,
        
        SetVisible = function(self, visible)
            mainFrame.Visible = visible
            windowVisible = visible
        end,
        
        ToggleVisible = function(self)
            self:SetVisible(not windowVisible)
        end,
        
        Destroy = function(self)
            self._connections:DisconnectAll()
            screenGui:Destroy()
        end
    }
    
    -- Fechar janela
    connectionManager:Connect(closeButton.MouseButton1Click, function()
        window:SetVisible(false)
    end)
    
    -- Começar invisível
    window:SetVisible(false)
    
    return window
end

-- ======================================
-- PAINEL DE STATUS DRAGGABLE
-- ======================================
function GGMenu.CreateStatusPanel(position)
    local connectionManager = ConnectionManager.new()
    
    local screenGui = Utils.Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_StatusPanel",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1500
    })
    
    local panel = Utils.Create("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 200, 0, 150),
        Position = position or UDim2.new(1, -210, 0, 50),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 1
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Utils.Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    -- Sistema de arrastar
    local dragging = false
    local dragStart, startPos
    
    connectionManager:Connect(panel.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
        end
    end)
    
    connectionManager:Connect(UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    connectionManager:Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    local uiList = Utils.Create("UIListLayout", {
        Parent = panel,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    local uiPadding = Utils.Create("UIPadding", {
        Parent = panel,
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })
    
    local statusLabels = {}
    
    local function AddStatus(text, initialValue)
        local lbl = Utils.Create("TextLabel", {
            Parent = panel,
            Size = UDim2.new(1, -10, 0, 20),
            BackgroundTransparency = 1,
            TextSize = 14,
            Font = GGMenu.Fonts.Header,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = initialValue and GGMenu.Theme.Accent or GGMenu.Theme.TextSecondary,
            Text = text .. ": " .. (initialValue and "ON" or "OFF"),
            LayoutOrder = #statusLabels + 1
        })
        
        statusLabels[text] = lbl
        return lbl
    end
    
    local function UpdateStatus(text, value)
        if statusLabels[text] then
            statusLabels[text].Text = text .. ": " .. (value and "ON" or "OFF")
            statusLabels[text].TextColor3 = value and GGMenu.Theme.Accent or GGMenu.Theme.TextSecondary
        end
    end
    
    return {
        Panel = panel,
        _connections = connectionManager,
        
        Add = AddStatus,
        Update = UpdateStatus,
        
        SetVisible = function(self, visible)
            screenGui.Enabled = visible
        end,
        
        SetPosition = function(self, position)
            panel.Position = position
        end,
        
        Destroy = function(self)
            self._connections:DisconnectAll()
            screenGui:Destroy()
        end
    }
end

-- ======================================
-- SISTEMA DE BINDS DE TECLAS
-- ======================================
local KeybindManager = {}
KeybindManager.__index = KeybindManager

function KeybindManager.new()
    local self = setmetatable({}, KeybindManager)
    self.binds = {}
    self.connection = nil
    return self
end

function KeybindManager:Add(keyCode, callback, description)
    local bind = {
        Key = keyCode,
        Callback = callback,
        Description = description
    }
    
    table.insert(self.binds, bind)
    return bind
end

function KeybindManager:Remove(keyCode)
    for i, bind in ipairs(self.binds) do
        if bind.Key == keyCode then
            table.remove(self.binds, i)
            return true
        end
    end
    return false
end

function KeybindManager:Start()
    if self.connection then return end
    
    self.connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        for _, bind in ipairs(self.binds) do
            if input.KeyCode == bind.Key then
                pcall(bind.Callback)
            end
        end
    end)
end

function KeybindManager:Stop()
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
end

-- ======================================
-- INICIALIZAÇÃO MODULAR OTIMIZADA
-- ======================================
function GGMenu:Init(options)
    -- Verificação segura para options
    local config = {}
    
    if type(options) == "table" then
        config = options
    elseif options == nil then
        config = {}
    else
        -- Se for booleano ou outro tipo, trata como showFPSBar
        config.ShowFPSBar = options == true
        warn("GGMenu: Deprecated usage - Use table for options instead of boolean")
    end
    
    -- Configurações com valores padrão
    local showFPSBar = config.ShowFPSBar ~= false
    local toggleKey = config.ToggleKey or GGMenu.Config.ToggleKey
    local fpsBarPosition = config.FPSBarPosition
    local statusPanelPosition = config.StatusPanelPosition
    local title = config.Title or GGMenu.Config.Title
    
    local components = {}
    local mainConnectionManager = ConnectionManager.new()
    
    -- FPS Bar (opcional)
    if showFPSBar then
        components.FPSBar = self.CreateFPSBar(fpsBarPosition)
    end
    
    -- Janela
    components.Window = self.CreateWindow(title)
    
    -- Status Panel (opcional)
    if config.ShowStatusPanel then
        components.StatusPanel = self.CreateStatusPanel(statusPanelPosition)
    end
    
    -- Keybind Manager
    local keybindManager = KeybindManager.new()
    
    -- Hotkey para mostrar/ocultar
    keybindManager:Add(toggleKey, function()
        components.Window:ToggleVisible()
    end, "Toggle UI Window")
    
    keybindManager:Start()
    
    -- Conectar para limpeza
    components.DestroyAll = function()
        keybindManager:Stop()
        mainConnectionManager:DisconnectAll()
        
        if components.FPSBar then
            components.FPSBar:Destroy()
        end
        
        if components.Window then
            components.Window:Destroy()
        end
        
        if components.StatusPanel then
            components.StatusPanel:Destroy()
        end
        
        print("GGMenu cleaned up!")
    end
    
    -- Gerenciador de binds público
    components.BindKey = function(keyCode, callback, description)
        return keybindManager:Add(keyCode, callback, description)
    end
    
    components.UnbindKey = function(keyCode)
        return keybindManager:Remove(keyCode)
    end
    
    components.SetTheme = function(newTheme)
        for key, value in pairs(newTheme) do
            if GGMenu.Theme[key] ~= nil then
                GGMenu.Theme[key] = value
            end
        end
    end
    
    print("GGMenu v5.3 loaded!")
    print("Executor:", Utils.GetExecutor())
    print(string.format("Press %s to show/hide menu", toggleKey.Name))
    
    return components
end

-- Compatibilidade com versão antiga
function GGMenu:InitLegacy(showFPSBar)
    return self:Init({ShowFPSBar = showFPSBar})
end

-- Versão minimalista para usar apenas componentes
function GGMenu:CreateLibrary()
    return {
        CreateWindow = GGMenu.CreateWindow,
        CreateFPSBar = GGMenu.CreateFPSBar,
        CreateStatusPanel = GGMenu.CreateStatusPanel,
        CreateToggle = GGMenu.CreateToggle,
        CreateSlider = GGMenu.CreateSlider,
        CreateDropdown = GGMenu.CreateDropdown,
        Theme = GGMenu.Theme,
        Fonts = GGMenu.Fonts,
        Config = GGMenu.Config,
        Utils = Utils
    }
end

return GGMenu
