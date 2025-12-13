-- ======================================
-- GGMenu UI Library v6.0 (Otimizada e Minimalista)
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
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Configurações
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

-- Cache de instâncias
local Instances = {}
local ActiveBinds = {}
local ExecutorCache = nil

-- ======================================
-- UTILITÁRIOS OTIMIZADOS
-- ======================================
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    return obj
end

local function Tween(obj, props, duration)
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quint), props)
    tween:Play()
    return tween
end

local function GetExecutor()
    if ExecutorCache then return ExecutorCache end
    
    local executors = {
        {"identifyexecutor", "Executor"},
        {"getexecutorname", "Executor"},
        {_G.Executor, "Global"},
        {ArceusX, "Arceus X"},
        {Hydrogen, "Hydrogen"},
        {Delta, "Delta"},
        {Codex, "Codex"},
        {VegaX, "Vega X"},
        {Xeno, "Xeno"},
        {Valex, "Valex"}
    }
    
    for _, executor in pairs(executors) do
        if executor[1] then
            ExecutorCache = executor[2]
            return executor[2]
        end
    end
    
    ExecutorCache = "Unknown"
    return "Unknown"
end

local function DeepCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = type(v) == "table" and DeepCopy(v) or v
    end
    return copy
end

-- ======================================
-- TELA DE CARREGAMENTO
-- ======================================
function GGMenu.CreateLoadingScreen(title)
    local loadingGui = Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_Loading",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local container = Create("Frame", {
        Parent = loadingGui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = GGMenu.Theme.BgDark,
        BackgroundTransparency = 0.1
    })
    
    local centerFrame = Create("Frame", {
        Parent = container,
        Size = UDim2.new(0, 400, 0, 200),
        Position = UDim2.new(0.5, -200, 0.5, -100),
        BackgroundColor3 = GGMenu.Theme.BgCard
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Create("UIStroke", {Color = GGMenu.Theme.Accent, Thickness = 2})
    })
    
    local titleLabel = Create("TextLabel", {
        Parent = centerFrame,
        Size = UDim2.new(1, -40, 0, 50),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Text = "GGMenu " .. (title or "v6.0"),
        TextColor3 = GGMenu.Theme.Accent,
        TextSize = 28,
        Font = GGMenu.Fonts.Title
    })
    
    local statusLabel = Create("TextLabel", {
        Parent = centerFrame,
        Size = UDim2.new(1, -40, 0, 30),
        Position = UDim2.new(0, 20, 0, 90),
        BackgroundTransparency = 1,
        Text = "Loading...",
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 18,
        Font = GGMenu.Fonts.Body
    })
    
    local progressBar = Create("Frame", {
        Parent = centerFrame,
        Size = UDim2.new(1, -40, 0, 6),
        Position = UDim2.new(0, 20, 1, -40),
        BackgroundColor3 = GGMenu.Theme.BgCardHover
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    local progressFill = Create("Frame", {
        Parent = progressBar,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = GGMenu.Theme.Accent
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    local loading = {
        Gui = loadingGui,
        SetStatus = function(text)
            statusLabel.Text = text
        end,
        SetProgress = function(percent)
            Tween(progressFill, {Size = UDim2.new(percent, 0, 1, 0)})
        end,
        Destroy = function()
            Tween(container, {BackgroundTransparency = 1}, 0.3).Completed:Connect(function()
                loadingGui:Destroy()
            end)
        end
    }
    
    return loading
end

-- ======================================
-- COMPONENTES PRINCIPAIS
-- ======================================
function GGMenu.CreateToggle(parent, text, default, callback)
    local toggle = {
        Value = default or false,
        Callback = callback
    }
    
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = #parent:GetChildren()
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
    
    local toggleButton = Create("TextButton", {
        Parent = container,
        Size = UDim2.new(0, 48, 0, 24),
        Position = UDim2.new(1, -48, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = default and GGMenu.Theme.Accent or GGMenu.Theme.BgCard,
        AutoButtonColor = false,
        Text = ""
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    local toggleDot = Create("Frame", {
        Parent = toggleButton,
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1)
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    function toggle:Set(value)
        self.Value = value
        Tween(toggleButton, {BackgroundColor3 = value and GGMenu.Theme.Accent or GGMenu.Theme.BgCard})
        Tween(toggleDot, {Position = value and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)})
        if self.Callback then self.Callback(value) end
    end
    
    function toggle:Toggle()
        self:Set(not self.Value)
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        toggle:Toggle()
    end)
    
    return toggle
end

function GGMenu.CreateSlider(parent, text, min, max, default, callback)
    local slider = {
        Value = default or min,
        Min = min,
        Max = max
    }
    
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1
    })
    
    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0.7, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 14,
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local valueLabel = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0.3, 0, 0, 20),
        Position = UDim2.new(0.7, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(default or min),
        TextColor3 = GGMenu.Theme.TextSecondary,
        TextSize = 13,
        Font = GGMenu.Fonts.Code
    })
    
    local track = Create("Frame", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -18),
        BackgroundColor3 = GGMenu.Theme.BgCard
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    local fill = Create("Frame", {
        Parent = track,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = GGMenu.Theme.Accent
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    local knob = Create("Frame", {
        Parent = track,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((default - min) / (max - min), -8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1)
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    function slider:Set(value)
        value = math.clamp(value, self.Min, self.Max)
        self.Value = value
        local percent = (value - self.Min) / (self.Max - self.Min)
        
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -8, 0.5, 0)
        valueLabel.Text = string.format("%.2f", value)
        
        if callback then callback(value) end
    end
    
    local dragging = false
    
    local function update(input)
        local x = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        local percent = math.clamp(x, 0, 1)
        local value = min + (max - min) * percent
        slider:Set(value)
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return slider
end

function GGMenu.CreateButton(parent, text, callback)
    local button = Create("TextButton", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        Text = text,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 14,
        Font = GGMenu.Fonts.Body,
        AutoButtonColor = false
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    button.MouseEnter:Connect(function()
        Tween(button, {BackgroundColor3 = GGMenu.Theme.BgCardHover})
    end)
    
    button.MouseLeave:Connect(function()
        Tween(button, {BackgroundColor3 = GGMenu.Theme.BgCard})
    end)
    
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return button
end

-- ======================================
-- SISTEMA DE BIND
-- ======================================
function GGMenu.BindKey(keyCode, callback)
    local bind = {
        Key = keyCode,
        Callback = callback,
        Active = true
    }
    
    table.insert(ActiveBinds, bind)
    
    return {
        Unbind = function()
            bind.Active = false
            for i, b in ipairs(ActiveBinds) do
                if b == bind then
                    table.remove(ActiveBinds, i)
                    break
                end
            end
        end
    }
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode then
        for _, bind in ipairs(ActiveBinds) do
            if bind.Active and input.KeyCode == bind.Key then
                pcall(bind.Callback)
                break
            end
        end
    end
end)

-- ======================================
-- JANELA PRINCIPAL
-- ======================================
function GGMenu.CreateWindow(title)
    local screenGui = Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_Window",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local mainFrame = Create("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 600, 0, 650), -- Mais esticada
        Position = UDim2.new(0.5, -300, 0.5, -325),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        Visible = false
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Create("UIStroke", {Color = GGMenu.Theme.Accent, Thickness = 2})
    })
    
    -- Header com drag
    local header = Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = GGMenu.Theme.BgDark
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 12, 0, 0)})
    })
    
    local titleLabel = Create("TextLabel", {
        Parent = header,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "GGMenu v6.0",
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 20,
        Font = GGMenu.Fonts.Title,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local closeButton = Create("TextButton", {
        Parent = header,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = GGMenu.Theme.Danger,
        Text = "×",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    -- Sistema de drag
    local dragging, dragStart, startPos = false
    
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
    local tabContainer = Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1
    })
    
    local contentContainer = Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, -20, 1, -100),
        Position = UDim2.new(0, 10, 0, 95),
        BackgroundTransparency = 1
    })
    
    local tabs = {}
    local currentTab = nil
    
    local window = {
        Gui = screenGui,
        Frame = mainFrame,
        Tabs = {}
    }
    
    function window:AddTab(name)
        local tabId = #tabs + 1
        local tabButton = Create("TextButton", {
            Parent = tabContainer,
            Size = UDim2.new(0, 90, 1, 0),
            Position = UDim2.new(0, (tabId-1)*95, 0, 0),
            BackgroundColor3 = tabId == 1 and GGMenu.Theme.Accent or GGMenu.Theme.BgCard,
            Text = name,
            TextColor3 = tabId == 1 and Color3.new(1,1,1) or GGMenu.Theme.TextSecondary,
            TextSize = 13,
            Font = GGMenu.Fonts.Body,
            AutoButtonColor = false
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 6)})
        })
        
        local tabContent = Create("ScrollingFrame", {
            Parent = contentContainer,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = GGMenu.Theme.Accent,
            Visible = tabId == 1,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        
        local content = Create("Frame", {
            Parent = tabContent,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        })
        
        local layout = Create("UIListLayout", {
            Parent = content,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
        end)
        
        local tab = {
            Name = name,
            Button = tabButton,
            Content = content,
            Container = tabContent
        }
        
        tabs[tabId] = tab
        window.Tabs[name] = tab
        
        tabButton.MouseButton1Click:Connect(function()
            for i, t in ipairs(tabs) do
                t.Container.Visible = false
                t.Button.BackgroundColor3 = GGMenu.Theme.BgCard
                t.Button.TextColor3 = GGMenu.Theme.TextSecondary
            end
            
            tab.Container.Visible = true
            tab.Button.BackgroundColor3 = GGMenu.Theme.Accent
            tab.Button.TextColor3 = Color3.new(1,1,1)
            currentTab = tabId
        end)
        
        local interface = {}
        
        function interface:AddToggle(text, default, callback)
            local toggle = GGMenu.CreateToggle(content, text, default, callback)
            toggle.Container.LayoutOrder = #content:GetChildren()
            return toggle
        end
        
        function interface:AddSlider(text, min, max, default, callback)
            local slider = GGMenu.CreateSlider(content, text, min, max, default, callback)
            slider.Container.LayoutOrder = #content:GetChildren()
            return slider
        end
        
        function interface:AddButton(text, callback)
            local button = GGMenu.CreateButton(content, text, callback)
            button.LayoutOrder = #content:GetChildren()
            return button
        end
        
        function interface:AddLabel(text)
            local label = Create("TextLabel", {
                Parent = content,
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = GGMenu.Theme.TextSecondary,
                TextSize = 13,
                Font = GGMenu.Fonts.Body,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = #content:GetChildren()
            })
            return label
        end
        
        function interface:AddDivider()
            local divider = Create("Frame", {
                Parent = content,
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = GGMenu.Theme.Border,
                LayoutOrder = #content:GetChildren()
            })
            return divider
        end
        
        return interface
    end
    
    function window:SetVisible(visible)
        if visible then
            mainFrame.Visible = true
            Tween(mainFrame, {Size = UDim2.new(0, 600, 0, 650)}, 0.3)
        else
            Tween(mainFrame, {Size = UDim2.new(0, 600, 0, 0)}, 0.2).Completed:Connect(function()
                mainFrame.Visible = false
            end)
        end
    end
    
    function window:Toggle()
        self:SetVisible(not mainFrame.Visible)
    end
    
    closeButton.MouseButton1Click:Connect(function()
        window:SetVisible(false)
    end)
    
    -- Bind padrão: INSERT
    GGMenu.BindKey(Enum.KeyCode.Insert, function()
        window:Toggle()
    end)
    
    return window
end

-- ======================================
-- FPS BAR SIMPLIFICADA
-- ======================================
function GGMenu.CreateFPSBar()
    local screenGui = Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_FPS",
        ResetOnSpawn = false
    })
    
    local bar = Create("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 300, 0, 28),
        Position = UDim2.new(0, 10, 1, -38),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BackgroundTransparency = 0.1
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {Color = GGMenu.Theme.Accent, Thickness = 1})
    })
    
    local label = Create("TextLabel", {
        Parent = bar,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = "FPS: 60 | PING: 0",
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 12,
        Font = GGMenu.Fonts.Code,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Atualização FPS
    local lastUpdate = tick()
    local fps = 60
    local samples = {}
    
    RunService.RenderStepped:Connect(function()
        local now = tick()
        local delta = now - lastUpdate
        lastUpdate = now
        
        local currentFPS = math.floor(1 / math.max(delta, 0.0001))
        table.insert(samples, currentFPS)
        if #samples > 30 then table.remove(samples, 1) end
        
        local total = 0
        for _, v in ipairs(samples) do total = total + v end
        fps = math.floor(total / #samples)
        
        -- Ping
        local ping = 0
        pcall(function()
            local stats = Stats.Network:FindFirstChild("ServerStatsItem")
            if stats then
                local pingItem = stats:FindFirstChild("Data Ping")
                if pingItem then
                    ping = math.floor(pingItem:GetValue())
                end
            end
        end)
        
        label.Text = string.format("GGMenu | %d FPS | %d ms | %s", fps, ping, GetExecutor())
    end)
    
    return {
        Gui = screenGui,
        SetVisible = function(visible) screenGui.Enabled = visible end,
        Destroy = function() screenGui:Destroy() end
    }
end

-- ======================================
-- INICIALIZAÇÃO PRINCIPAL
-- ======================================
function GGMenu:Init(options)
    options = options or {}
    
    -- Mostrar loading
    local loading = self.CreateLoadingScreen("v6.0")
    loading.SetStatus("Initializing...")
    loading.SetProgress(0.3)
    
    -- Criar FPS Bar se solicitado
    local fpsBar
    if options.ShowFPS ~= false then
        loading.SetStatus("Creating FPS Bar...")
        fpsBar = self.CreateFPSBar()
        loading.SetProgress(0.6)
    end
    
    -- Criar janela principal
    loading.SetStatus("Creating Main Window...")
    local window = self.CreateWindow(options.Title or "GGMenu v6.0")
    loading.SetProgress(0.9)
    
    -- Remover loading
    task.wait(0.5)
    loading.SetStatus("Ready!")
    loading.SetProgress(1)
    task.wait(0.3)
    loading.Destroy()
    
    -- Bind de teclas customizadas
    if options.Binds then
        for key, func in pairs(options.Binds) do
            self.BindKey(key, func)
        end
    end
    
    print("GGMenu v6.0 Initialized!")
    print("Executor:", GetExecutor())
    print("Press INSERT to toggle menu")
    
    return {
        Window = window,
        FPSBar = fpsBar,
        BindKey = GGMenu.BindKey,
        CreateToggle = GGMenu.CreateToggle,
        CreateSlider = GGMenu.CreateSlider,
        CreateButton = GGMenu.CreateButton
    }
end

return GGMenu
