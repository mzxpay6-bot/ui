-- ======================================
-- GGMenu UI Library v3.0 (CS Style)
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
local HttpService = game:GetService("HttpService")

-- Configuração padrão
GGMenu.Theme = {
    Primary = Color3.fromRGB(0, 170, 255),     -- Azul CS
    Secondary = Color3.fromRGB(30, 30, 35),    -- Fundo escuro
    Dark = Color3.fromRGB(20, 20, 25),         -- Fundo mais escuro
    Light = Color3.fromRGB(40, 40, 45),        -- Fundo claro
    Text = Color3.fromRGB(240, 240, 240),      -- Texto branco
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Success = Color3.fromRGB(0, 200, 0),       -- Verde
    Warning = Color3.fromRGB(255, 165, 0),     -- Laranja
    Danger = Color3.fromRGB(220, 60, 60),      -- Vermelho
    Border = Color3.fromRGB(60, 60, 70)        -- Bordas
}

GGMenu.Fonts = {
    Title = Enum.Font.GothamBold,
    Header = Enum.Font.GothamSemibold,
    Body = Enum.Font.Gotham,
    Code = Enum.Font.Code
}

-- ======================================
-- DETECTOR DE EXECUTOR
-- ======================================
function GGMenu.DetectExecutor()
    local exec = "Unknown"
    
    pcall(function()
        if identifyexecutor then
            exec = identifyexecutor()
        elseif getexecutorname then
            exec = getexecutorname()
        elseif _G.Executor then
            exec = tostring(_G.Executor)
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
        elseif Wave then exec = "Wave"
        elseif Swift then exec = "Swift"
        elseif Fluxus then exec = "Fluxus"
        elseif isexecutorclosure then
            exec = "Executor"
        end
    end)
    
    return exec
end

-- ======================================
-- COMPONENTES DA UI
-- ======================================
local function Create(cls, props)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do
        if k == "Parent" then
            obj.Parent = v
        else
            obj[k] = v
        end
    end
    return obj
end

-- Toggle Switch (ON/OFF)
function GGMenu.CreateToggle(parent, text, defaultValue, callback)
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1
    })
    
    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.Theme.Text,
        TextSize = 14,
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleFrame = Create("Frame", {
        Parent = container,
        Size = UDim2.new(0, 50, 0, 24),
        Position = UDim2.new(1, -50, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = GGMenu.Theme.Dark,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = toggleFrame,
        CornerRadius = UDim.new(0, 12)
    })
    
    Create("UIStroke", {
        Parent = toggleFrame,
        Color = GGMenu.Theme.Border,
        Thickness = 1
    })
    
    local toggleCircle = Create("Frame", {
        Parent = toggleFrame,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = defaultValue and GGMenu.Theme.Success or Color3.fromRGB(100, 100, 100),
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = toggleCircle,
        CornerRadius = UDim.new(1, 0)
    })
    
    if defaultValue then
        toggleCircle.Position = UDim2.new(1, -22, 0.5, 0)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    end
    
    local toggle = {
        Value = defaultValue or false,
        Set = function(self, value)
            self.Value = value
            TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
                Position = value and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                BackgroundColor3 = value and GGMenu.Theme.Success or Color3.fromRGB(100, 100, 100)
            }):Play()
            
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), {
                BackgroundColor3 = value and Color3.fromRGB(0, 100, 0) or GGMenu.Theme.Dark
            }):Play()
            
            if callback then
                callback(value)
            end
        end,
        Toggle = function(self)
            self:Set(not self.Value)
        end
    }
    
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle:Toggle()
        end
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
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.Theme.Text,
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
        BackgroundColor3 = GGMenu.Theme.Dark,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = sliderTrack,
        CornerRadius = UDim.new(0, 3)
    })
    
    Create("UIStroke", {
        Parent = sliderTrack,
        Color = GGMenu.Theme.Border,
        Thickness = 1
    })
    
    local sliderFill = Create("Frame", {
        Parent = sliderTrack,
        Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = GGMenu.Theme.Primary,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = sliderFill,
        CornerRadius = UDim.new(0, 3)
    })
    
    local sliderButton = Create("Frame", {
        Parent = sliderTrack,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((defaultValue - min) / (max - min), -8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = GGMenu.Theme.Text,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = sliderButton,
        CornerRadius = UDim.new(1, 0)
    })
    
    Create("UIStroke", {
        Parent = sliderButton,
        Color = GGMenu.Theme.Border,
        Thickness = 1
    })
    
    local slider = {
        Value = defaultValue or min,
        Min = min,
        Max = max,
        Set = function(self, value)
            value = math.clamp(value, min, max)
            self.Value = value
            
            local percent = (value - min) / (max - min)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderButton.Position = UDim2.new(percent, -8, 0.5, 0)
            valueLabel.Text = tostring(math.floor(value))
            
            if callback then
                callback(value)
            end
        end
    }
    
    local dragging = false
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            
            local x = input.Position.X - sliderTrack.AbsolutePosition.X
            local percent = math.clamp(x / sliderTrack.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * percent
            
            slider:Set(value)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local x = input.Position.X - sliderTrack.AbsolutePosition.X
            local percent = math.clamp(x / sliderTrack.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * percent
            
            slider:Set(value)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return slider
end

-- Dropdown
function GGMenu.CreateDropdown(parent, text, options, defaultValue, callback)
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1
    })
    
    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0.5, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.Theme.Text,
        TextSize = 14,
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local dropdownButton = Create("TextButton", {
        Parent = container,
        Size = UDim2.new(0.5, 0, 0, 30),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundColor3 = GGMenu.Theme.Dark,
        Text = defaultValue or options[1],
        TextColor3 = GGMenu.Theme.Text,
        TextSize = 13,
        Font = GGMenu.Fonts.Body,
        AutoButtonColor = false,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = dropdownButton,
        CornerRadius = UDim.new(0, 4)
    })
    
    Create("UIStroke", {
        Parent = dropdownButton,
        Color = GGMenu.Theme.Border,
        Thickness = 1
    })
    
    local dropdownOpen = false
    local dropdownFrame
    
    local function toggleDropdown()
        dropdownOpen = not dropdownOpen
        
        if dropdownOpen then
            dropdownFrame = Create("Frame", {
                Parent = container,
                Size = UDim2.new(0.5, 0, 0, #options * 30),
                Position = UDim2.new(0.5, 0, 0, 35),
                BackgroundColor3 = GGMenu.Theme.Dark,
                ClipsDescendants = true,
                BorderSizePixel = 0,
                ZIndex = 100
            })
            
            Create("UICorner", {
                Parent = dropdownFrame,
                CornerRadius = UDim.new(0, 4)
            })
            
            Create("UIStroke", {
                Parent = dropdownFrame,
                Color = GGMenu.Theme.Border,
                Thickness = 1
            })
            
            for i, option in ipairs(options) do
                local optionButton = Create("TextButton", {
                    Parent = dropdownFrame,
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, (i-1)*30),
                    BackgroundColor3 = GGMenu.Theme.Dark,
                    Text = option,
                    TextColor3 = GGMenu.Theme.Text,
                    TextSize = 13,
                    Font = GGMenu.Fonts.Body,
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    ZIndex = 101
                })
                
                optionButton.MouseEnter:Connect(function()
                    optionButton.BackgroundColor3 = GGMenu.Theme.Light
                end)
                
                optionButton.MouseLeave:Connect(function()
                    optionButton.BackgroundColor3 = GGMenu.Theme.Dark
                end)
                
                optionButton.MouseButton1Click:Connect(function()
                    dropdownButton.Text = option
                    dropdownOpen = false
                    dropdownFrame:Destroy()
                    
                    if callback then
                        callback(option)
                    end
                end)
            end
        else
            if dropdownFrame then
                dropdownFrame:Destroy()
            end
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(toggleDropdown)
    
    return {
        GetValue = function()
            return dropdownButton.Text
        end,
        SetValue = function(value)
            dropdownButton.Text = value
            if callback then
                callback(value)
            end
        end
    }
end

-- ======================================
-- FPS BAR
-- ======================================
function GGMenu.CreateFPSBar()
    local fpsBar = {}
    
    local screenGui = Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_FPSBar",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local bar = Create("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 450, 0, 28),
        Position = UDim2.new(0, 10, 1, -38),
        BackgroundColor3 = GGMenu.Theme.Secondary,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = bar,
        CornerRadius = UDim.new(0, 4)
    })
    
    Create("UIStroke", {
        Parent = bar,
        Color = GGMenu.Theme.Primary,
        Thickness = 1.2
    })
    
    local textLabel = Create("TextLabel", {
        Parent = bar,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = "GGMenu | Loading...",
        TextColor3 = GGMenu.Theme.Text,
        TextSize = 13,
        Font = GGMenu.Fonts.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextStrokeTransparency = 0.7,
        TextStrokeColor3 = Color3.new(0, 0, 0)
    })
    
    local statusDot = Create("Frame", {
        Parent = bar,
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(1, -12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = GGMenu.Theme.Success,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = statusDot,
        CornerRadius = UDim.new(1, 0)
    })
    
    local last = tick()
    local fps = 60
    local fpsSamples = {}
    
    RunService.RenderStepped:Connect(function()
        local now = tick()
        local currentFPS = math.floor(1 / math.max(now - last, 0.0001))
        last = now
        
        table.insert(fpsSamples, currentFPS)
        if #fpsSamples > 30 then table.remove(fpsSamples, 1) end
        
        local total = 0
        for _, v in ipairs(fpsSamples) do total = total + v end
        fps = math.floor(total / #fpsSamples)
        
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
        
        local executor = GGMenu.DetectExecutor()
        local timeStr = os.date("%H:%M:%S")
        
        textLabel.Text = string.format(
            "GGMenu | %s | %d FPS | %d ms | %s | %s",
            Players.LocalPlayer.Name,
            fps,
            ping,
            timeStr,
            executor
        )
    end)
    
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
    
    fpsBar.Gui = screenGui
    fpsBar.Bar = bar
    
    fpsBar.SetVisible = function(self, visible)
        screenGui.Enabled = visible
    end
    
    fpsBar.Destroy = function(self)
        screenGui:Destroy()
    end
    
    return fpsBar
end

-- ======================================
-- MAIN WINDOW (CS Style)
-- ======================================
function GGMenu.CreateWindow(title)
    local window = {}
    
    local screenGui = Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_Window",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local mainFrame = Create("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 450, 0, 500),
        Position = UDim2.new(0.5, -225, 0.5, -250),
        BackgroundColor3 = GGMenu.Theme.Secondary,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true
    })
    
    Create("UICorner", {
        Parent = mainFrame,
        CornerRadius = UDim.new(0, 8)
    })
    
    Create("UIStroke", {
        Parent = mainFrame,
        Color = GGMenu.Theme.Primary,
        Thickness = 2
    })
    
    -- Header
    local header = Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = GGMenu.Theme.Dark,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = header,
        CornerRadius = UDim.new(0, 8, 0, 0)
    })
    
    local titleLabel = Create("TextLabel", {
        Parent = header,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = "  " .. title,
        TextColor3 = GGMenu.Theme.Text,
        TextSize = 18,
        Font = GGMenu.Fonts.Header,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local closeButton = Create("TextButton", {
        Parent = header,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, -15),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = GGMenu.Theme.Danger,
        Text = "×",
        TextColor3 = GGMenu.Theme.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = closeButton,
        CornerRadius = UDim.new(0, 4)
    })
    
    -- Content Area
    local content = Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, -20, 1, -70),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundTransparency = 1
    })
    
    local scroll = Create("ScrollingFrame", {
        Parent = content,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = GGMenu.Theme.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    })
    
    -- User Info Section (como na imagem)
    local userSection = Create("Frame", {
        Parent = scroll,
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundTransparency = 1
    })
    
    Create("TextLabel", {
        Parent = userSection,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        Text = "Welcome back",
        TextColor3 = GGMenu.Theme.TextSecondary,
        TextSize = 12,
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Create("TextLabel", {
        Parent = userSection,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "User",
        TextColor3 = GGMenu.Theme.Text,
        TextSize = 20,
        Font = GGMenu.Fonts.Title,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local activeBadge = Create("Frame", {
        Parent = userSection,
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(0, 0, 0, 60),
        BackgroundColor3 = Color3.fromRGB(0, 100, 0),
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = activeBadge,
        CornerRadius = UDim.new(0, 4)
    })
    
    Create("TextLabel", {
        Parent = activeBadge,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "ACTIVE",
        TextColor3 = Color3.fromRGB(200, 255, 200),
        TextSize = 11,
        Font = GGMenu.Fonts.Header,
        TextXAlignment = Enum.TextXAlignment.Center
    })
    
    -- Separator
    local separator = Create("Frame", {
        Parent = scroll,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 90),
        BackgroundColor3 = GGMenu.Theme.Border
    })
    
    -- Content container para componentes
    local componentsContainer = Create("Frame", {
        Parent = scroll,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 100),
        BackgroundTransparency = 1
    })
    
    local components = {}
    local contentHeight = 100
    
    function window:AddSection(title)
        local section = Create("Frame", {
            Parent = componentsContainer,
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, contentHeight),
            BackgroundTransparency = 1
        })
        
        Create("TextLabel", {
            Parent = section,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = title:upper(),
            TextColor3 = GGMenu.Theme.Primary,
            TextSize = 14,
            Font = GGMenu.Fonts.Header,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        contentHeight = contentHeight + 35
        
        local sectionComponents = {}
        
        function sectionComponents:AddToggle(text, default, callback)
            local toggle = GGMenu.CreateToggle(componentsContainer, text, default, callback)
            toggle.container.Position = UDim2.new(0, 0, 0, contentHeight)
            contentHeight = contentHeight + 35
            return toggle
        end
        
        function sectionComponents:AddSlider(text, min, max, default, callback)
            local slider = GGMenu.CreateSlider(componentsContainer, text, min, max, default, callback)
            slider.container.Position = UDim2.new(0, 0, 0, contentHeight)
            contentHeight = contentHeight + 55
            return slider
        end
        
        function sectionComponents:AddDropdown(text, options, default, callback)
            local dropdown = GGMenu.CreateDropdown(componentsContainer, text, options, default, callback)
            dropdown.container.Position = UDim2.new(0, 0, 0, contentHeight)
            contentHeight = contentHeight + 45
            return dropdown
        end
        
        function sectionComponents:AddLabel(text)
            local label = Create("TextLabel", {
                Parent = componentsContainer,
                Size = UDim2.new(1, 0, 0, 25),
                Position = UDim2.new(0, 0, 0, contentHeight),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = GGMenu.Theme.TextSecondary,
                TextSize = 13,
                Font = GGMenu.Fonts.Body,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            contentHeight = contentHeight + 30
            return label
        end
        
        return sectionComponents
    end
    
    -- Update canvas size
    scroll.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
    componentsContainer.Size = UDim2.new(1, 0, 0, contentHeight)
    
    -- Close button functionality
    local windowVisible = true
    
    closeButton.MouseButton1Click:Connect(function()
        windowVisible = not windowVisible
        mainFrame.Visible = windowVisible
    end)
    
    -- Toggle visibility with key (Insert)
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            windowVisible = not windowVisible
            mainFrame.Visible = windowVisible
        end
    end)
    
    window.Gui = screenGui
    window.Frame = mainFrame
    window.Scroll = scroll
    
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
-- INICIALIZAÇÃO RÁPIDA
-- ======================================
function GGMenu:Init()
    -- Criar FPS Bar
    local fpsBar = self.CreateFPSBar()
    
    -- Criar Janela Principal
    local window = self.CreateWindow("GGMenu v3.0")
    
    -- Adicionar seções e componentes (exemplo como na imagem)
    local espSection = window:AddSection("VISUAL")
    
    local teamCheck = espSection:AddToggle("Team Check", true, function(value)
        print("Team Check:", value)
    end)
    
    local enableESP = espSection:AddToggle("Enable ESP", true, function(value)
        print("Enable ESP:", value)
    end)
    
    local showDistance = espSection:AddToggle("Show Distance", true, function(value)
        print("Show Distance:", value)
    end)
    
    local showNames = espSection:AddToggle("Show Names", true, function(value)
        print("Show Names:", value)
    end)
    
    local aimbotSection = window:AddSection("AIMBOT")
    
    aimbotSection:AddLabel("Enable Aimbot")
    local aimToggle = espSection:AddToggle("", false, function(value)
        print("Aimbot:", value)
    end)
    
    local targetPart = aimbotSection:AddDropdown("Target Part", {"Head", "Torso", "Random"}, "Head", function(value)
        print("Target Part:", value)
    end)
    
    local fovSlider = aimbotSection:AddSlider("FOV Size", 1, 360, 180, function(value)
        print("FOV Size:", value)
    end)
    
    local smoothSlider = aimbotSection:AddSlider("Smoothing Curve", 0, 1, 0.15, function(value)
        print("Smoothing:", value)
    end)
    
    local accelSlider = aimbotSection:AddSlider("Acceleration Curve", 0, 1, 0.20, function(value)
        print("Acceleration:", value)
    end)
    
    print("GGMenu v3.0 loaded!")
    print("Executor:", self.DetectExecutor())
    print("Press INSERT to toggle menu")
    
    return {
        FPSBar = fpsBar,
        Window = window,
        Toggles = {
            TeamCheck = teamCheck,
            ESP = enableESP,
            Distance = showDistance,
            Names = showNames,
            Aimbot = aimToggle
        },
        Sliders = {
            FOV = fovSlider,
            Smoothing = smoothSlider,
            Acceleration = accelSlider
        }
    }
end

return GGMenu