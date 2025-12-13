-- ======================================
-- GGMenu UI Library v4.1 (Corrigido) --xvideo
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

-- Cache do executor (executa uma vez)
local CachedExecutor = nil
local function GetExecutor()
    if CachedExecutor then return CachedExecutor end
    
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
    
    CachedExecutor = exec
    return exec
end

GGMenu.GetExecutor = GetExecutor

-- Configuração do Tema
GGMenu.Theme = {
    Accent = Color3.fromRGB(232, 84, 84),
    AccentLight = Color3.fromRGB(255, 120, 120),
    AccentDark = Color3.fromRGB(185, 60, 60),
    BgDark = Color3.fromRGB(12, 12, 15),
    BgCard = Color3.fromRGB(18, 18, 22),
    BgCardHover = Color3.fromRGB(25, 25, 30),
    TextPrimary = Color3.fromRGB(245, 245, 250),
    TextSecondary = Color3.fromRGB(160, 160, 175),
    TextDim = Color3.fromRGB(90, 90, 105),
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
-- FUNÇÕES UTILITÁRIAS (CORRIGIDA)
-- ======================================
local function Create(class, props, children)
    local obj = Instance.new(class)
    
    -- Aplica propriedades
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    
    -- Aplica parent
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    
    -- Adiciona filhos
    if children then
        for _, child in ipairs(children) do
            child.Parent = obj
        end
    end
    
    return obj
end

local function Tween(obj, duration, props, style, direction)
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    local ti = TweenInfo.new(duration, style, direction)
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
end

-- ======================================
-- COMPONENTES DA UI (CORRIGIDOS)
-- ======================================

-- Toggle Switch
function GGMenu.CreateToggle(parent, text, defaultValue, callback)
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1
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
    
    local toggleFrame = Create("Frame", {
        Parent = container,
        Size = UDim2.new(0, 48, 0, 26),
        Position = UDim2.new(1, -48, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = defaultValue and GGMenu.Theme.Accent or GGMenu.Theme.BgCard,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggleFrame
    })
    
    Create("UIStroke", {
        Color = GGMenu.Theme.Border,
        Thickness = 1,
        Parent = toggleFrame
    })
    
    local toggleCircle = Create("Frame", {
        Parent = toggleFrame,
        Size = UDim2.new(0, 20, 0, 20),
        Position = defaultValue and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(defaultValue and 1 or 0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggleCircle
    })
    
    local toggle = {
        Value = defaultValue or false,
        Container = container,  -- 🔴 ADICIONADO
        Set = function(self, value)
            self.Value = value
            Tween(toggleFrame, 0.25, {
                BackgroundColor3 = value and GGMenu.Theme.Accent or GGMenu.Theme.BgCard
            })
            Tween(toggleCircle, 0.25, {
                Position = value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            })
            if callback then callback(value) end
        end,
        Toggle = function(self)
            self:Set(not self.Value)
        end
    }
    
    local btn = Create("TextButton", {
        Parent = toggleFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 10
    })
    
    btn.MouseButton1Click:Connect(function()
        toggle:Toggle()
    end)
    
    return toggle
end

-- Slider
function GGMenu.CreateSlider(parent, text, min, max, defaultValue, callback)
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1
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
    
    local valueLabel = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -60, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(defaultValue or min),
        TextColor3 = GGMenu.Theme.TextSecondary,
        TextSize = 12,
        Font = GGMenu.Fonts.Code
    })
    
    local sliderTrack = Create("Frame", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -20),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 3),
        Parent = sliderTrack
    })
    
    Create("UIStroke", {
        Color = GGMenu.Theme.Border,
        Thickness = 1,
        Parent = sliderTrack
    })
    
    local sliderFill = Create("Frame", {
        Parent = sliderTrack,
        Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = GGMenu.Theme.Accent,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 3),
        Parent = sliderFill
    })
    
    local sliderButton = Create("Frame", {
        Parent = sliderTrack,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((defaultValue - min) / (max - min), -8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = sliderButton
    })
    
    Create("UIStroke", {
        Color = GGMenu.Theme.Border,
        Thickness = 1,
        Parent = sliderButton
    })
    
    local slider = {
        Value = defaultValue or min,
        Min = min,
        Max = max,
        Container = container,  -- 🔴 ADICIONADO
        Set = function(self, value)
            value = math.clamp(value, min, max)
            self.Value = value
            local percent = (value - min) / (max - min)
            
            Tween(sliderFill, 0.2, {Size = UDim2.new(percent, 0, 1, 0)})
            Tween(sliderButton, 0.2, {Position = UDim2.new(percent, -8, 0.5, 0)})
            valueLabel.Text = tostring(math.floor(value))
            
            if callback then callback(value) end
        end
    }
    
    local dragging = false
    
    local function updateSlider(input)
        local x = input.Position.X - sliderTrack.AbsolutePosition.X
        local percent = math.clamp(x / sliderTrack.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * percent
        slider:Set(value)
    end
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return slider
end

-- Dropdown (com fechamento automático)
function GGMenu.CreateDropdown(parent, text, options, defaultValue, callback)
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1
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
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = dropdownButton
    })
    
    Create("UIStroke", {
        Color = GGMenu.Theme.Border,
        Thickness = 1,
        Parent = dropdownButton
    })
    
    dropdownButton.MouseEnter:Connect(function()
        Tween(dropdownButton, 0.2, {BackgroundColor3 = GGMenu.Theme.BgCardHover})
    end)
    
    dropdownButton.MouseLeave:Connect(function()
        Tween(dropdownButton, 0.2, {BackgroundColor3 = GGMenu.Theme.BgCard})
    end)
    
    local dropdownOpen = false
    local dropdownFrame = nil
    
    -- Fechar dropdown ao clicar fora
    local function closeAllDropdowns()
        if dropdownFrame then
            dropdownFrame:Destroy()
            dropdownFrame = nil
            dropdownOpen = false
        end
    end
    
    -- Conectar evento global para fechar dropdowns
    local closeConnection
    local function setupCloseListener()
        if closeConnection then closeConnection:Disconnect() end
        
        closeConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if dropdownFrame and not dropdownFrame:IsDescendantOf(container) then
                    closeAllDropdowns()
                end
            end
        end)
    end
    
    local function toggleDropdown()
        closeAllDropdowns() -- Fecha outros dropdowns abertos
        
        if not dropdownOpen then
            dropdownOpen = true
            
            dropdownFrame = Create("Frame", {
                Parent = container,
                Size = UDim2.new(0.5, 0, 0, #options * 32),
                Position = UDim2.new(0.5, 0, 0, 35),
                BackgroundColor3 = GGMenu.Theme.BgDark,
                ClipsDescendants = true,
                BorderSizePixel = 0,
                ZIndex = 100
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = dropdownFrame
            })
            
            Create("UIStroke", {
                Color = GGMenu.Theme.Border,
                Thickness = 1,
                Parent = dropdownFrame
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
                
                optionBtn.MouseEnter:Connect(function()
                    Tween(optionBtn, 0.2, {BackgroundColor3 = GGMenu.Theme.BgCard})
                end)
                
                optionBtn.MouseLeave:Connect(function()
                    Tween(optionBtn, 0.2, {BackgroundColor3 = GGMenu.Theme.BgDark})
                end)
                
                optionBtn.MouseButton1Click:Connect(function()
                    dropdownButton.Text = option
                    closeAllDropdowns()
                    if callback then callback(option) end
                end)
            end
            
            setupCloseListener()
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(toggleDropdown)
    
    -- 🔴 RETORNO CORRIGIDO
    return {
        Container = container,
        GetValue = function() return dropdownButton.Text end,
        SetValue = function(value) 
            dropdownButton.Text = value
            if callback then callback(value) end
        end
    }
end

-- ======================================
-- FPS BAR (OTIMIZADA)
-- ======================================
function GGMenu.CreateFPSBar(config)
    config = config or {}
    
    local screenGui = Create("ScreenGui", {
        Parent = CoreGui,
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
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = bar
    })
    
    Create("UIStroke", {
        Color = GGMenu.Theme.Accent,
        Thickness = 1.2,
        Parent = bar
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
    
    local statusDot = Create("Frame", {
        Parent = bar,
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(1, -15, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = GGMenu.Theme.Success,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = statusDot
    })
    
    -- Sistema de arrastar (sem Draggable = true)
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
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Atualização FPS (com cache do executor)
    local last = tick()
    local fps = 60
    local fpsSamples = {}
    local executor = CachedExecutor or GetExecutor()  -- 🔴 CACHE
    
    RunService.RenderStepped:Connect(function()
        local now = tick()
        local currentFPS = math.floor(1 / math.max(now - last, 0.0001))
        last = now
        
        table.insert(fpsSamples, currentFPS)
        if #fpsSamples > 30 then table.remove(fpsSamples, 1) end
        
        local total = 0
        for _, v in ipairs(fpsSamples) do total = total + v end
        fps = math.floor(total / #fpsSamples)
        
        -- Atualizar cor do indicador
        if fps >= 50 then
            statusDot.BackgroundColor3 = GGMenu.Theme.Success
        elseif fps >= 30 then
            statusDot.BackgroundColor3 = GGMenu.Theme.Warning
        else
            statusDot.BackgroundColor3 = GGMenu.Theme.Danger
        end
        
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        
        local timeStr = os.date("%H:%M:%S")
        
        textLabel.Text = string.format(
            "GGMenu | %s | %d FPS | %d ms | %s | %s",
            Players.LocalPlayer.Name,
            fps,
            ping,
            timeStr,
            executor  -- 🔴 USA CACHE
        )
    end)
    
    local fpsBar = {
        Gui = screenGui,
        Bar = bar,
        SetVisible = function(self, visible)
            screenGui.Enabled = visible
        end,
        Destroy = function(self)
            screenGui:Destroy()
        end
    }
    
    return fpsBar
end

-- ======================================
-- MAIN WINDOW (OTIMIZADA)
-- ======================================
function GGMenu.CreateWindow(title)
    local window = {}
    
    local screenGui = Create("ScreenGui", {
        Parent = CoreGui,
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
        Active = true,
        Draggable = true  -- 🔴 Usando Draggable nativo
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = mainFrame
    })
    
    Create("UIStroke", {
        Color = GGMenu.Theme.Accent,
        Thickness = 2,
        Parent = mainFrame
    })
    
    -- Header
    local header = Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = GGMenu.Theme.BgDark,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 12, 0, 0),
        Parent = header
    })
    
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
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = closeButton
    })
    
    Create("UIStroke", {
        Color = GGMenu.Theme.Border,
        Thickness = 1,
        Parent = closeButton
    })
    
    closeButton.MouseEnter:Connect(function()
        Tween(closeButton, 0.2, {
            BackgroundColor3 = GGMenu.Theme.Danger,
            TextColor3 = Color3.new(1, 1, 1)
        })
    end)
    
    closeButton.MouseLeave:Connect(function()
        Tween(closeButton, 0.2, {
            BackgroundColor3 = GGMenu.Theme.BgCard,
            TextColor3 = GGMenu.Theme.TextPrimary
        })
    end)
    
    -- Content Area com scroll automático
    local content = Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, -30, 1, -90),
        Position = UDim2.new(0, 15, 0, 75),
        BackgroundTransparency = 1
    })
    
    local scroll = Create("ScrollingFrame", {
        Parent = content,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = GGMenu.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    })
    
    -- Container com UIListLayout para auto-size
    local componentsContainer = Create("Frame", {
        Parent = scroll,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1
    })
    
    local listLayout = Create("UIListLayout", {
        Parent = componentsContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    -- Atualizar canvas size automaticamente
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)
    
    local contentHeight = 0
    local windowVisible = true
    
    -- Função para adicionar seções
    function window:AddSection(title)
        if title == "" then
            return window:AddSpacer(20) -- 🟠 Trata seção vazia como espaçador
        end
        
        local section = Create("Frame", {
            Parent = componentsContainer,
            Size = UDim2.new(1, 0, 0, 35),
            LayoutOrder = contentHeight,
            BackgroundTransparency = 1
        })
        
        contentHeight = contentHeight + 1
        
        Create("TextLabel", {
            Parent = section,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = title:upper(),
            TextColor3 = GGMenu.Theme.Accent,
            TextSize = 14,
            Font = GGMenu.Fonts.Header,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local sectionComponents = {}
        
        function sectionComponents:AddToggle(text, default, callback)
            local toggle = GGMenu.CreateToggle(componentsContainer, text, default, callback)
            toggle.Container.LayoutOrder = contentHeight  -- 🔴 Container corrigido
            contentHeight = contentHeight + 1
            return toggle
        end
        
        function sectionComponents:AddSlider(text, min, max, default, callback)
            local slider = GGMenu.CreateSlider(componentsContainer, text, min, max, default, callback)
            slider.Container.LayoutOrder = contentHeight  -- 🔴 Container corrigido
            contentHeight = contentHeight + 1
            return slider
        end
        
        function sectionComponents:AddDropdown(text, options, default, callback)
            local dropdown = GGMenu.CreateDropdown(componentsContainer, text, options, default, callback)
            dropdown.Container.LayoutOrder = contentHeight  -- 🔴 Container corrigido
            contentHeight = contentHeight + 1
            return dropdown
        end
        
        function sectionComponents:AddLabel(text)
            local label = Create("TextLabel", {
                Parent = componentsContainer,
                Size = UDim2.new(1, 0, 0, 25),
                LayoutOrder = contentHeight,
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = GGMenu.Theme.TextSecondary,
                TextSize = 13,
                Font = GGMenu.Fonts.Body,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            contentHeight = contentHeight + 1
            return label
        end
        
        return sectionComponents
    end
    
    -- Função para adicionar espaçador (novo)
    function window:AddSpacer(height)
        local spacer = Create("Frame", {
            Parent = componentsContainer,
            Size = UDim2.new(1, 0, 0, height or 20),
            LayoutOrder = contentHeight,
            BackgroundTransparency = 1
        })
        
        contentHeight = contentHeight + 1
        return spacer
    end
    
    -- Fechar janela
    closeButton.MouseButton1Click:Connect(function()
        windowVisible = not windowVisible
        mainFrame.Visible = windowVisible
    end)
    
    -- Hotkey (INSERT)
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            windowVisible = not windowVisible
            mainFrame.Visible = windowVisible
        end
    end)
    
    window.Gui = screenGui
    window.Frame = mainFrame
    
    window.SetVisible = function(self, visible)
        mainFrame.Visible = visible
        windowVisible = visible
    end
    
    window.Destroy = function(self)
        screenGui:Destroy()
    end
    
    return window
end

-- ======================================
-- SISTEMA DE INICIALIZAÇÃO (CORRIGIDO)
-- ======================================
function GGMenu:Init(showFPSBar)
    showFPSBar = showFPSBar ~= false
    
    local components = {}
    
    -- Criar FPS Bar
    if showFPSBar then
        components.FPSBar = self.CreateFPSBar()
    end
    
    -- Criar Janela Principal
    components.Window = self.CreateWindow("GGMenu v4.1")
    
    -- Configurações salvas (namespace único)
    local settingsKey = "__GGMenu_Settings_" .. tostring(math.random(1000, 9999))
    if not _G[settingsKey] then
        _G[settingsKey] = {
            TeamCheck = true,
            ESP = true,
            ShowDistance = true,
            ShowNames = true,
            Aimbot = false,
            FOVSize = 180,
            Smoothing = 0.15,
            Acceleration = 0.20,
            TargetPart = "Head"
        }
    end
    
    local settings = _G[settingsKey]
    
    -- Adicionar seções
    local visualSection = components.Window:AddSection("VISUAL")
    
    components.Toggles = {}
    components.Toggles.TeamCheck = visualSection:AddToggle("Team Check", settings.TeamCheck, function(value)
        settings.TeamCheck = value
        print("Team Check:", value and "ON" or "OFF")
    end)
    
    components.Toggles.ESP = visualSection:AddToggle("Enable ESP", settings.ESP, function(value)
        settings.ESP = value
        print("ESP:", value and "ON" or "OFF")
    end)
    
    components.Toggles.ShowDistance = visualSection:AddToggle("Show Distance", settings.ShowDistance, function(value)
        settings.ShowDistance = value
        print("Show Distance:", value and "ON" or "OFF")
    end)
    
    components.Toggles.ShowNames = visualSection:AddToggle("Show Names", settings.ShowNames, function(value)
        settings.ShowNames = value
        print("Show Names:", value and "ON" or "OFF")
    end)
    
    components.Window:AddSpacer(20)  -- 🟠 Substitui AddSection("")
    
    local aimbotSection = components.Window:AddSection("AIMBOT")
    
    aimbotSection:AddLabel("Enable Aimbot")
    components.Toggles.Aimbot = aimbotSection:AddToggle("", settings.Aimbot, function(value)  -- 🔴 CORRIGIDO: aimbotSection
        settings.Aimbot = value
        print("Aimbot:", value and "ON" or "OFF")
    end)
    
    components.Dropdowns = {}
    components.Dropdowns.TargetPart = aimbotSection:AddDropdown("Target Part", {"Head", "Torso", "Random"}, settings.TargetPart, function(value)
        settings.TargetPart = value
        print("Target Part:", value)
    end)
    
    components.Sliders = {}
    components.Sliders.FOVSize = aimbotSection:AddSlider("FOV Size", 10, 360, settings.FOVSize, function(value)
        settings.FOVSize = value
        print("FOV Size:", value)
    end)
    
    components.Sliders.Smoothing = aimbotSection:AddSlider("Smoothing Curve", 0, 1, settings.Smoothing, function(value)
        settings.Smoothing = value
        print("Smoothing:", value)
    end)
    
    components.Sliders.Acceleration = aimbotSection:AddSlider("Acceleration Curve", 0, 1, settings.Acceleration, function(value)
        settings.Acceleration = value
        print("Acceleration:", value)
    end)
    
    -- Informações do sistema
    print("GGMenu v4.1 loaded!")
    print("Executor:", GetExecutor())
    print("Settings key:", settingsKey)
    print("Press INSERT to toggle menu")
    
    -- Retornar também a chave de configurações
    components.SettingsKey = settingsKey
    
    return components
end

return GGMenu
