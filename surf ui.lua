-- ======================================
-- GGMenu UI Library v6.0 (CORRIGIDA) anal
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
local ContentProvider = game:GetService("ContentProvider")

-- Configurações padrão
GGMenu.Config = {
    ToggleKey = Enum.KeyCode.Insert,
    DefaultWindowSize = UDim2.new(0, 500, 0, 550),
    FPSBarSize = UDim2.new(0, 450, 0, 32),
    SliderDragPrecision = 0.01,
    Title = "GGMenu v6.0",
    ResponsiveScale = 0.8,
    MaxWindowWidth = 600,
    MinWindowWidth = 400
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
    Danger = Color3.fromRGB(231, 76, 60),
    SearchHighlight = Color3.fromRGB(84, 232, 180)
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
    
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then
                obj[k] = v
            end
        end
        
        if props.Parent then
            obj.Parent = props.Parent
        end
    end
    
    if children then
        for _, child in ipairs(children) do
            child.Parent = obj
        end
    end
    
    return obj
end

function Utils.Tween(obj, props, duration, easingStyle, easingDirection)
    duration = duration or 0.2
    easingStyle = easingStyle or Enum.EasingStyle.Quint
    easingDirection = easingDirection or Enum.EasingDirection.Out
    local ti = TweenInfo.new(duration, easingStyle, easingDirection)
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
end

-- Cache de executor (SEM chamadas de nil)
function Utils.GetExecutor()
    -- Retorna string simples sem chamar funções que podem ser nil
    return "Executor Detected"
end

-- Sistema de conexões seguro
local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager

function ConnectionManager.new()
    return setmetatable({connections = {}}, ConnectionManager)
end

function ConnectionManager:Add(conn)
    if conn and (type(conn) == "userdata" or type(conn) == "table") then
        table.insert(self.connections, conn)
    end
    return conn
end

function ConnectionManager:Connect(signal, callback)
    if signal and callback and type(callback) == "function" then
        local conn = signal:Connect(callback)
        return self:Add(conn)
    end
    return nil
end

function ConnectionManager:DisconnectAll()
    for _, conn in ipairs(self.connections) do
        if conn and typeof(conn) == "RBXScriptConnection" and conn.Connected then
            conn:Disconnect()
        end
    end
    self.connections = {}
end

-- ======================================
-- COMPONENTE TOGGLE SIMPLES E SEGURO
-- ======================================
function GGMenu.CreateToggle(parent, text, defaultValue, callback)
    local connectionManager = ConnectionManager.new()
    
    local container = Utils.Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = 0
    })
    
    local label = Utils.Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text or "Toggle",
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
        BackgroundColor3 = defaultValue and GGMenu.Theme.Accent or GGMenu.Theme.BgCard
    })
    
    Utils.Create("UICorner", {Parent = toggleFrame, CornerRadius = UDim.new(1, 0)})
    Utils.Create("UIStroke", {Parent = toggleFrame, Color = GGMenu.Theme.Border, Thickness = 1})
    
    local toggleCircle = Utils.Create("Frame", {
        Parent = toggleFrame,
        Size = UDim2.new(0, 20, 0, 20),
        Position = defaultValue and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(defaultValue and 1 or 0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1)
    })
    
    Utils.Create("UICorner", {Parent = toggleCircle, CornerRadius = UDim.new(1, 0)})
    
    local toggle = {
        Value = defaultValue or false,
        Container = container,
        _connections = connectionManager,
        
        Set = function(self, value)
            self.Value = value
            Utils.Tween(toggleFrame, {BackgroundColor3 = value and GGMenu.Theme.Accent or GGMenu.Theme.BgCard})
            Utils.Tween(toggleCircle, {Position = value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)})
            
            if callback and type(callback) == "function" then
                pcall(callback, value)
            end
        end,
        
        Toggle = function(self)
            self:Set(not self.Value)
        end,
        
        Destroy = function(self)
            if self._connections then
                self._connections:DisconnectAll()
            end
            if container and container.Parent then
                container:Destroy()
            end
        end
    }
    
    connectionManager:Connect(toggleFrame.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle:Toggle()
        end
    end)
    
    return toggle
end

-- ======================================
-- JANELA SIMPLIFICADA
-- ======================================
function GGMenu.CreateWindow(title)
    local connectionManager = ConnectionManager.new()
    
    local screenGui = Utils.Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_Window",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local mainFrame = Utils.Create("Frame", {
        Parent = screenGui,
        Size = GGMenu.Config.DefaultWindowSize,
        Position = UDim2.new(0.5, -250, 0.5, -275),
        BackgroundColor3 = GGMenu.Theme.BgCard
    })
    
    Utils.Create("UICorner", {Parent = mainFrame, CornerRadius = UDim.new(0, 12)})
    Utils.Create("UIStroke", {Parent = mainFrame, Color = GGMenu.Theme.Accent, Thickness = 2})
    
    -- Header
    local header = Utils.Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = GGMenu.Theme.BgDark
    })
    
    Utils.Create("UICorner", {Parent = header, CornerRadius = UDim.new(0, 12, 0, 0)})
    
    local titleLabel = Utils.Create("TextLabel", {
        Parent = header,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = title or GGMenu.Config.Title,
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
    })
    
    Utils.Create("UICorner", {Parent = closeButton, CornerRadius = UDim.new(0, 6)})
    Utils.Create("UIStroke", {Parent = closeButton, Color = GGMenu.Theme.Border, Thickness = 1})
    
    -- Área de conteúdo
    local contentArea = Utils.Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, -30, 1, -110),
        Position = UDim2.new(0, 15, 0, 105),
        BackgroundTransparency = 1
    })
    
    local contentScrolling = Utils.Create("ScrollingFrame", {
        Parent = contentArea,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = GGMenu.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    
    local contentContainer = Utils.Create("Frame", {
        Parent = contentScrolling,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1
    })
    
    local listLayout = Utils.Create("UIListLayout", {
        Parent = contentContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    -- Update canvas size
    connectionManager:Connect(listLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        contentScrolling.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)
    
    -- Eventos
    connectionManager:Connect(closeButton.MouseButton1Click, function()
        screenGui.Enabled = false
    end)
    
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
    
    local window = {
        Gui = screenGui,
        Frame = mainFrame,
        Content = contentContainer,
        _connections = connectionManager,
        
        AddToggle = function(self, text, defaultValue, callback)
            return GGMenu.CreateToggle(self.Content, text, defaultValue, callback)
        end,
        
        AddLabel = function(self, text)
            local label = Utils.Create("TextLabel", {
                Parent = self.Content,
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = GGMenu.Theme.TextSecondary,
                TextSize = 13,
                Font = GGMenu.Fonts.Body,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = self.Content:GetChildren() and #self.Content:GetChildren() or 1
            })
            return label
        end,
        
        AddSpacer = function(self, height)
            local spacer = Utils.Create("Frame", {
                Parent = self.Content,
                Size = UDim2.new(1, 0, 0, height or 20),
                BackgroundTransparency = 1,
                LayoutOrder = self.Content:GetChildren() and #self.Content:GetChildren() or 1
            })
            return spacer
        end,
        
        Show = function(self)
            screenGui.Enabled = true
        end,
        
        Hide = function(self)
            screenGui.Enabled = false
        end,
        
        Toggle = function(self)
            screenGui.Enabled = not screenGui.Enabled
        end,
        
        Destroy = function(self)
            if self._connections then
                self._connections:DisconnectAll()
            end
            if screenGui then
                screenGui:Destroy()
            end
        end
    }
    
    -- Iniciar oculta
    screenGui.Enabled = false
    
    return window
end

-- ======================================
-- FPS BAR SIMPLIFICADA
-- ======================================
function GGMenu.CreateFPSBar()
    local screenGui = Utils.Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_FPSBar",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local bar = Utils.Create("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 450, 0, 32),
        Position = UDim2.new(0, 10, 1, -42),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BackgroundTransparency = 0.1
    })
    
    Utils.Create("UICorner", {Parent = bar, CornerRadius = UDim.new(0, 8)})
    Utils.Create("UIStroke", {Parent = bar, Color = GGMenu.Theme.Accent, Thickness = 1.2})
    
    local textLabel = Utils.Create("TextLabel", {
        Parent = bar,
        Size = UDim2.new(1, -15, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "GGMenu | Loading...",
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 13,
        Font = GGMenu.Fonts.Code,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local fpsBuffer = {}
    local bufferSize = 30
    local bufferIndex = 1
    
    RunService.RenderStepped:Connect(function()
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        
        -- Buffer circular simples
        fpsBuffer[bufferIndex] = fps
        bufferIndex = (bufferIndex % bufferSize) + 1
        
        local total = 0
        local count = 0
        for _, v in pairs(fpsBuffer) do
            if v then
                total = total + v
                count = count + 1
            end
        end
        
        local avgFPS = count > 0 and math.floor(total / count) or fps
        
        textLabel.Text = string.format(
            "GGMenu | %s | %d FPS",
            Players.LocalPlayer.Name,
            avgFPS
        )
    end)
    
    return {
        Gui = screenGui,
        Bar = bar,
        SetVisible = function(self, visible)
            screenGui.Enabled = visible
        end,
        Destroy = function(self)
            screenGui:Destroy()
        end
    }
end

-- ======================================
-- INICIALIZAÇÃO PRINCIPAL (SEM ERROS)
-- ======================================
function GGMenu:Init(options)
    options = options or {}
    
    local components = {}
    
    -- Criar FPS Bar (opcional)
    if options.ShowFPSBar ~= false then
        components.FPSBar = self.CreateFPSBar()
    end
    
    -- Criar janela
    components.Window = self.CreateWindow(options.Title or GGMenu.Config.Title)
    
    -- Adicionar bind key para mostrar/ocultar
    local toggleKey = options.ToggleKey or GGMenu.Config.ToggleKey
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            components.Window:Toggle()
        end
    end)
    
    print("GGMenu v6.0 inicializado com sucesso!")
    print("Pressione", toggleKey.Name, "para mostrar/ocultar o menu")
    
    return components
end

return GGMenu
