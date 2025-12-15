-- ======================================
-- GGMenu UI Library v5.3 (Melhorada e Otimizada)
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
local MarketplaceService = game:GetService("MarketplaceService")
local TextService = game:GetService("TextService")

-- Configurações
GGMenu.Theme = {
    Accent = Color3.fromRGB(232, 84, 84),
    AccentHover = Color3.fromRGB(242, 94, 94),
    BgDark = Color3.fromRGB(12, 12, 15),
    BgCard = Color3.fromRGB(18, 18, 22),
    BgCardHover = Color3.fromRGB(25, 25, 30),
    TextPrimary = Color3.fromRGB(245, 245, 250),
    TextSecondary = Color3.fromRGB(160, 160, 175),
    Border = Color3.fromRGB(35, 35, 42),
    Success = Color3.fromRGB(72, 199, 142),
    Warning = Color3.fromRGB(241, 196, 15),
    Danger = Color3.fromRGB(231, 76, 60),
    Info = Color3.fromRGB(52, 152, 219)
}

GGMenu.Fonts = {
    Title = Enum.Font.GothamBold,
    Header = Enum.Font.GothamSemibold,
    Body = Enum.Font.Gotham,
    Code = Enum.Font.Code,
    Icon = Enum.Font.FontAwesome
}

-- Cache de instâncias
local InstanceCache = {
    Windows = {},
    Components = {},
    Connections = {}
}

-- ======================================
-- UTILITÁRIOS AVANÇADOS
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

local function Tween(obj, props, duration, easing)
    duration = duration or 0.25
    local ti = TweenInfo.new(duration, easing or Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
end

-- Sistema de notificações
local Notifications = {}
function GGMenu:Notify(title, message, duration, notifType)
    duration = duration or 5
    notifType = notifType or "Info"
    
    local colors = {
        Success = self.Theme.Success,
        Warning = self.Theme.Warning,
        Danger = self.Theme.Danger,
        Info = self.Theme.Info
    }
    
    local accent = colors[notifType] or self.Theme.Info
    
    -- Criar notificação
    local notification = Create("Frame", {
        Parent = CoreGui,
        Name = "GGMenu_Notification",
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, 10, 1, -90),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = self.Theme.BgCard,
        BorderSizePixel = 0,
        ZIndex = 9999
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {Color = accent, Thickness = 2}),
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        })
    })
    
    local titleLabel = Create("TextLabel", {
        Parent = notification,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.Theme.TextPrimary,
        TextSize = 16,
        Font = self.Fonts.Header,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local messageLabel = Create("TextLabel", {
        Parent = notification,
        Size = UDim2.new(1, 0, 1, -25),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = self.Theme.TextSecondary,
        TextSize = 14,
        Font = self.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true
    })
    
    -- Animação de entrada
    notification.Position = UDim2.new(1, 10, 1, 10)
    Tween(notification, {Position = UDim2.new(1, 10, 1, -90)})
    
    -- Auto-destruir
    task.delay(duration, function()
        Tween(notification, {Position = UDim2.new(1, 10, 1, 10)}):Wait()
        notification:Destroy()
    end)
    
    return notification
end

-- Sistema de tooltips
local function CreateTooltip(parent, text)
    local tooltip = Create("TextLabel", {
        Parent = parent,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 5),
        BackgroundColor3 = GGMenu.Theme.BgDark,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 12,
        Font = GGMenu.Fonts.Body,
        Text = text,
        Visible = false,
        ZIndex = 10000,
        TextWrapped = true,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1}),
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4)
        })
    })
    
    local textSize = TextService:GetTextSize(text, 12, GGMenu.Fonts.Body, Vector2.new(200, math.huge))
    tooltip.Size = UDim2.new(0, textSize.X + 16, 0, textSize.Y + 8)
    
    return tooltip
end

function GGMenu:AddTooltip(element, text)
    local tooltip = CreateTooltip(element, text)
    
    local enterConn = element.MouseEnter:Connect(function()
        tooltip.Visible = true
        Tween(tooltip, {BackgroundTransparency = 0}, 0.2)
    end)
    
    local leaveConn = element.MouseLeave:Connect(function()
        Tween(tooltip, {BackgroundTransparency = 1}, 0.2):Wait()
        tooltip.Visible = false
    end)
    
    return {
        Destroy = function()
            enterConn:Disconnect()
            leaveConn:Disconnect()
            tooltip:Destroy()
        end,
        Update = function(newText)
            tooltip.Text = newText
            local textSize = TextService:GetTextSize(newText, 12, GGMenu.Fonts.Body, Vector2.new(200, math.huge))
            tooltip.Size = UDim2.new(0, textSize.X + 16, 0, textSize.Y + 8)
        end
    }
end

-- ======================================
-- COMPONENTES MELHORADOS
-- ======================================
function GGMenu.CreateButton(parent, text, callback)
    local button = Create("TextButton", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = GGMenu.Theme.Accent,
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Font = GGMenu.Fonts.Body,
        AutoButtonColor = false
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    button.MouseEnter:Connect(function()
        Tween(button, {BackgroundColor3 = GGMenu.Theme.AccentHover})
    end)
    
    button.MouseLeave:Connect(function()
        Tween(button, {BackgroundColor3 = GGMenu.Theme.Accent})
    end)
    
    button.MouseButton1Click:Connect(function()
        if callback then
            pcall(callback)
        end
    end)
    
    return {
        Button = button,
        SetText = function(self, newText) button.Text = newText end,
        SetDisabled = function(self, disabled)
            button.AutoButtonColor = false
            button.Active = not disabled
            button.BackgroundColor3 = disabled and GGMenu.Theme.BgCard or GGMenu.Theme.Accent
            button.TextColor3 = disabled and GGMenu.Theme.TextSecondary or Color3.new(1, 1, 1)
        end,
        Destroy = function(self) button:Destroy() end
    }
end

function GGMenu.CreateToggle(parent, text, defaultValue, callback, tooltip)
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
        
        Set = function(self, value, silent)
            self.Value = value
            Tween(toggleFrame, {BackgroundColor3 = value and GGMenu.Theme.Accent or GGMenu.Theme.BgCard})
            Tween(toggleCircle, {
                Position = value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                AnchorPoint = value and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
            })
            if callback and not silent then 
                pcall(callback, value)
            end
        end,
        
        Toggle = function(self)
            self:Set(not self.Value)
        end,
        
        GetValue = function(self) return self.Value end,
        
        Destroy = function(self)
            container:Destroy()
        end
    }
    
    -- Adicionar tooltip se fornecido
    if tooltip then
        GGMenu:AddTooltip(container, tooltip)
    end
    
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle:Toggle()
        end
    end)
    
    return toggle
end

function GGMenu.CreateSlider(parent, text, min, max, defaultValue, callback, isFloat, tooltip)
    local isFloat = isFloat or (defaultValue or min) % 1 ~= 0
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        LayoutOrder = 0
    })
    
    local topRow = Create("Frame", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1
    })
    
    local label = Create("TextLabel", {
        Parent = topRow,
        Size = UDim2.new(1, -60, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 14,
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local valueLabel = Create("TextLabel", {
        Parent = topRow,
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -60, 0, 0),
        BackgroundTransparency = 1,
        Text = isFloat and string.format("%.2f", defaultValue or min) or tostring(defaultValue or min),
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
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 3)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    local sliderFill = Create("Frame", {
        Parent = sliderTrack,
        Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = GGMenu.Theme.Accent,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 3)})
    })
    
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
    
    -- Adicionar tooltip se fornecido
    if tooltip then
        GGMenu:AddTooltip(container, tooltip)
    end
    
    local slider = {
        Value = defaultValue or min,
        Min = min,
        Max = max,
        Container = container,
        IsFloat = isFloat,
        
        Set = function(self, value, silent)
            value = math.clamp(value, min, max)
            self.Value = value
            local percent = (value - min) / (max - min)
            
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderButton.Position = UDim2.new(percent, -8, 0.5, 0)
            valueLabel.Text = self.IsFloat and string.format("%.2f", value) or tostring(math.floor(value))
            
            if callback and not silent then 
                pcall(callback, value)
            end
        end,
        
        GetValue = function(self) return self.Value end,
        
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
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    local inputChangedConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    local inputEndedConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Armazenar conexões
    table.insert(InstanceCache.Connections, inputChangedConn)
    table.insert(InstanceCache.Connections, inputEndedConn)
    
    return slider
end

function GGMenu.CreateDropdown(parent, text, options, defaultValue, callback, tooltip)
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
    
    -- Adicionar tooltip se fornecido
    if tooltip then
        GGMenu:AddTooltip(container, tooltip)
    end
    
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
            Tween(dropdownFrame, {Size = UDim2.new(0.5, 0, 0, 0)}, 0.2):Wait()
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
                Size = UDim2.new(0.5, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0, 35),
                BackgroundColor3 = GGMenu.Theme.BgDark,
                BorderSizePixel = 0,
                ZIndex = 100,
                ClipsDescendants = true
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
            })
            
            Tween(dropdownFrame, {Size = UDim2.new(0.5, 0, 0, math.min(#options * 32, 160))})
            
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
                    Tween(optionBtn, {BackgroundColor3 = GGMenu.Theme.BgCard})
                end)
                
                optionBtn.MouseLeave:Connect(function()
                    Tween(optionBtn, {BackgroundColor3 = GGMenu.Theme.BgDark})
                end)
                
                optionBtn.MouseButton1Click:Connect(function()
                    dropdownButton.Text = option
                    closeDropdown()
                    if callback then 
                        pcall(callback, option)
                    end
                end)
            end
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(toggleDropdown)
    
    -- Fechar ao clicar fora
    local clickConnection = UserInputService.InputBegan:Connect(function(input)
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
        GetValue = function() return dropdownButton.Text end,
        SetValue = function(value) 
            dropdownButton.Text = value
            if callback then 
                pcall(callback, value)
            end
        end,
        UpdateOptions = function(newOptions)
            options = newOptions
            closeDropdown()
        end,
        Destroy = function(self)
            clickConnection:Disconnect()
            container:Destroy()
        end
    }
    
    table.insert(InstanceCache.Connections, clickConnection)
    
    return dropdown
end

-- Componente de Input de Texto
function GGMenu.CreateTextBox(parent, text, placeholder, callback, tooltip)
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = 0
    })
    
    local label = Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0.4, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 14,
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local textBox = Create("TextBox", {
        Parent = container,
        Size = UDim2.new(0.6, 0, 0, 32),
        Position = UDim2.new(0.4, 0, 0, 0),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 13,
        Font = GGMenu.Fonts.Body,
        PlaceholderText = placeholder,
        PlaceholderColor3 = GGMenu.Theme.TextSecondary,
        ClearTextOnFocus = false,
        Text = ""
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    -- Adicionar tooltip se fornecido
    if tooltip then
        GGMenu:AddTooltip(container, tooltip)
    end
    
    textBox.Focused:Connect(function()
        Tween(textBox, {BackgroundColor3 = GGMenu.Theme.BgCardHover})
    end)
    
    textBox.FocusLost:Connect(function(enterPressed)
        Tween(textBox, {BackgroundColor3 = GGMenu.Theme.BgCard})
        if (enterPressed or not textBox:IsFocused()) and callback then
            pcall(callback, textBox.Text)
        end
    end)
    
    return {
        Container = container,
        TextBox = textBox,
        GetValue = function() return textBox.Text end,
        SetValue = function(value) textBox.Text = value end,
        SetPlaceholder = function(text) textBox.PlaceholderText = text end,
        Destroy = function(self) container:Destroy() end
    }
end

-- ======================================
-- FPS BAR MELHORADA
-- ======================================
function GGMenu.CreateFPSBar(position, size)
    local screenGui = Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_FPSBar",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000
    })
    
    local bar = Create("Frame", {
        Parent = screenGui,
        Size = size or UDim2.new(0, 450, 0, 32),
        Position = position or UDim2.new(0, 10, 1, -42),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {Color = GGMenu.Theme.Accent, Thickness = 1.2})
    })
    
    local textLabel = Create("TextLabel", {
        Parent = bar,
        Size = UDim2.new(1, -15, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "GGMenu v5.3 | Loading...",
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
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    -- Sistema de arrastar manual
    local dragging = false
    local dragStart, startPos
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = bar.Position
        end
    end)
    
    local dragConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            bar.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    local endConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Armazenar conexões
    table.insert(InstanceCache.Connections, dragConn)
    table.insert(InstanceCache.Connections, endConn)
    
    -- Atualização FPS
    local last = tick()
    local fps = 60
    local fpsSamples = {}
    local executor = GetExecutor()
    
    local updateConnection = RunService.RenderStepped:Connect(function()
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
        
        -- Pegar uso de memória
        local memory = 0
        pcall(function()
            memory = math.floor(Stats:GetTotalMemoryUsageMb())
        end)
        
        local timeStr = os.date("%H:%M:%S")
        textLabel.Text = string.format(
            "GGMenu v5.3 | %s | %d FPS | %d ms | %d MB | %s | %s",
            Players.LocalPlayer.Name, fps, ping, memory, timeStr, executor
        )
    end)
    
    table.insert(InstanceCache.Connections, updateConnection)
    
    local fpsBar = {
        Gui = screenGui,
        Bar = bar,
        SetVisible = function(self, visible) screenGui.Enabled = visible end,
        Destroy = function(self) 
            screenGui:Destroy()
            for _, conn in pairs({dragConn, endConn, updateConnection}) do
                if conn then conn:Disconnect() end
            end
        end
    }
    
    return fpsBar
end

-- ======================================
-- JANELA COM TABS MELHORADA
-- ======================================
function GGMenu.CreateWindow(title, size, position)
    local screenGui = Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_Window_" .. HttpService:GenerateGUID(false):sub(1, 8),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 2000
    })
    
    local mainFrame = Create("Frame", {
        Parent = screenGui,
        Size = size or UDim2.new(0, 500, 0, 550),
        Position = position or UDim2.new(0.5, -250, 0.5, -275),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Create("UIStroke", {Color = GGMenu.Theme.Accent, Thickness = 2})
    })
    
    -- Header (área de drag)
    local header = Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = GGMenu.Theme.BgDark,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 12, 0, 0)})
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
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    closeButton.MouseEnter:Connect(function()
        Tween(closeButton, {BackgroundColor3 = GGMenu.Theme.Danger, TextColor3 = Color3.new(1, 1, 1)})
    end)
    
    closeButton.MouseLeave:Connect(function()
        Tween(closeButton, {BackgroundColor3 = GGMenu.Theme.BgCard, TextColor3 = GGMenu.Theme.TextPrimary})
    end)
    
    -- Sistema de drag manual
    local dragging = false
    local dragStart, startPos
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    local dragConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    local endConn = UserInputService.InputEnded:Connect(function(input)
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
    
    local tabsList = Create("Frame", {
        Parent = tabsContainer,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1
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
    local windowVisible = false -- Começa invisível
    
    -- Funções da janela
    local window = {
        Gui = screenGui,
        Frame = mainFrame,
        Tabs = {},
        
        AddTab = function(self, tabName, icon)
            local tabId = #tabs + 1
            
            -- Criar botão da tab
            local tabButton = Create("TextButton", {
                Parent = tabsList,
                Size = UDim2.new(0, 80, 1, 0),
                Position = UDim2.new(0, (#tabs * 85), 0, 0),
                BackgroundColor3 = GGMenu.Theme.BgCard,
                Text = icon and icon .. " " .. tabName or tabName,
                TextColor3 = GGMenu.Theme.TextSecondary,
                TextSize = 13,
                Font = icon and GGMenu.Fonts.Icon or GGMenu.Fonts.Body,
                AutoButtonColor = false
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
            })
            
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
                tabContent.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
            end)
            
            -- Função para mostrar/ocultar tab
            local function showTab()
                -- Esconder todas as tabs
                for _, tabData in pairs(tabs) do
                    tabData.Content.Visible = false
                    Tween(tabData.Button, {
                        BackgroundColor3 = GGMenu.Theme.BgCard,
                        TextColor3 = GGMenu.Theme.TextSecondary
                    })
                end
                
                -- Mostrar esta tab
                tabContent.Visible = true
                Tween(tabButton, {
                    BackgroundColor3 = GGMenu.Theme.Accent,
                    TextColor3 = Color3.new(1, 1, 1)
                })
                
                currentTab = tabId
            end
            
            -- Evento do botão
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
            
            function tabInterface:AddSection(title, description)
                local section = Create("Frame", {
                    Parent = componentsContainer,
                    Size = UDim2.new(1, 0, 0, description and 50 or 35),
                    BackgroundTransparency = 1,
                    LayoutOrder = 0
                })
                
                Create("TextLabel", {
                    Parent = section,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = title:upper(),
                    TextColor3 = GGMenu.Theme.Accent,
                    TextSize = 14,
                    Font = GGMenu.Fonts.Header,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                if description then
                    Create("TextLabel", {
                        Parent = section,
                        Size = UDim2.new(1, 0, 1, -25),
                        Position = UDim2.new(0, 0, 0, 25),
                        BackgroundTransparency = 1,
                        Text = description,
                        TextColor3 = GGMenu.Theme.TextSecondary,
                        TextSize = 12,
                        Font = GGMenu.Fonts.Body,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true
                    })
                end
                
                local sectionInterface = {}
                
                function sectionInterface:AddButton(text, callback, tooltip)
                    local button = GGMenu.CreateButton(componentsContainer, text, callback)
                    if tooltip then
                        GGMenu:AddTooltip(button.Button, tooltip)
                    end
                    button.Button.LayoutOrder = 0
                    return button
                end
                
                function sectionInterface:AddToggle(text, default, callback, tooltip)
                    local toggle = GGMenu.CreateToggle(componentsContainer, text, default, callback, tooltip)
                    toggle.Container.LayoutOrder = 0
                    return toggle
                end
                
                function sectionInterface:AddSlider(text, min, max, default, callback, isFloat, tooltip)
                    local slider = GGMenu.CreateSlider(componentsContainer, text, min, max, default, callback, isFloat, tooltip)
                    slider.Container.LayoutOrder = 0
                    return slider
                end
                
                function sectionInterface:AddDropdown(text, options, default, callback, tooltip)
                    local dropdown = GGMenu.CreateDropdown(componentsContainer, text, options, default, callback, tooltip)
                    dropdown.Container.LayoutOrder = 0
                    return dropdown
                end
                
                function sectionInterface:AddTextBox(text, placeholder, callback, tooltip)
                    local textbox = GGMenu.CreateTextBox(componentsContainer, text, placeholder, callback, tooltip)
                    textbox.Container.LayoutOrder = 0
                    return textbox
                end
                
                function sectionInterface:AddLabel(text, color)
                    local label = Create("TextLabel", {
                        Parent = componentsContainer,
                        Size = UDim2.new(1, 0, 0, 25),
                        LayoutOrder = 0,
                        BackgroundTransparency = 1,
                        Text = text,
                        TextColor3 = color or GGMenu.Theme.TextSecondary,
                        TextSize = 13,
                        Font = GGMenu.Fonts.Body,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true
                    })
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
                
                function sectionInterface:AddDivider()
                    local divider = Create("Frame", {
                        Parent = componentsContainer,
                        Size = UDim2.new(1, 0, 0, 1),
                        LayoutOrder = 0,
                        BackgroundColor3 = GGMenu.Theme.Border,
                        BorderSizePixel = 0
                    }, {
                        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
                    })
                    return divider
                end
                
                return sectionInterface
            end
            
            function tabInterface:AddButton(text, callback, tooltip)
                local button = GGMenu.CreateButton(componentsContainer, text, callback)
                if tooltip then
                    GGMenu:AddTooltip(button.Button, tooltip)
                end
                button.Button.LayoutOrder = 0
                return button
            end
            
            function tabInterface:AddToggle(text, default, callback, tooltip)
                local toggle = GGMenu.CreateToggle(componentsContainer, text, default, callback, tooltip)
                toggle.Container.LayoutOrder = 0
                return toggle
            end
            
            function tabInterface:AddSlider(text, min, max, default, callback, isFloat, tooltip)
                local slider = GGMenu.CreateSlider(componentsContainer, text, min, max, default, callback, isFloat, tooltip)
                slider.Container.LayoutOrder = 0
                return slider
            end
            
            function tabInterface:AddDropdown(text, options, default, callback, tooltip)
                local dropdown = GGMenu.CreateDropdown(componentsContainer, text, options, default, callback, tooltip)
                dropdown.Container.LayoutOrder = 0
                return dropdown
            end
            
            function tabInterface:AddTextBox(text, placeholder, callback, tooltip)
                local textbox = GGMenu.CreateTextBox(componentsContainer, text, placeholder, callback, tooltip)
                textbox.Container.LayoutOrder = 0
                return textbox
            end
            
            function tabInterface:AddLabel(text, color)
                local label = Create("TextLabel", {
                    Parent = componentsContainer,
                    Size = UDim2.new(1, 0, 0, 25),
                    LayoutOrder = 0,
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = color or GGMenu.Theme.TextSecondary,
                    TextSize = 13,
                    Font = GGMenu.Fonts.Body,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true
                })
                return label
            end
            
            function tabInterface:AddSpacer(height)
                local spacer = Create("Frame", {
                    Parent = componentsContainer,
                    Size = UDim2.new(1, 0, 0, height or 20),
                    LayoutOrder = 0,
                    BackgroundTransparency = 1
                })
                return spacer
            end
            
            function tabInterface:AddDivider()
                local divider = Create("Frame", {
                    Parent = componentsContainer,
                    Size = UDim2.new(1, 0, 0, 1),
                    LayoutOrder = 0,
                    BackgroundColor3 = GGMenu.Theme.Border,
                    BorderSizePixel = 0
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(1, 0)})
                })
                return divider
            end
            
            function tabInterface:GetContainer()
                return componentsContainer
            end
            
            return tabInterface
        end,
        
        SetVisible = function(self, visible)
            mainFrame.Visible = visible
            windowVisible = visible
            if visible then
                Tween(mainFrame, {Size = size or UDim2.new(0, 500, 0, 550)}, 0.3)
            end
        end,
        
        Toggle = function(self)
            self:SetVisible(not windowVisible)
        end,
        
        Minimize = function(self)
            Tween(mainFrame, {Size = UDim2.new(0, 500, 0, 60)}, 0.3)
        end,
        
        Maximize = function(self)
            Tween(mainFrame, {Size = size or UDim2.new(0, 500, 0, 550)}, 0.3)
        end,
        
        SetPosition = function(self, position)
            mainFrame.Position = position
        end,
        
        SetSize = function(self, newSize)
            size = newSize
            mainFrame.Size = newSize
        end,
        
        Destroy = function(self)
            dragConn:Disconnect()
            endConn:Disconnect()
            screenGui:Destroy()
        end
    }
    
    -- Fechar janela
    closeButton.MouseButton1Click:Connect(function()
        window:SetVisible(false)
    end)
    
    -- Começar invisível
    window:SetVisible(false)
    
    -- Adicionar ao cache
    table.insert(InstanceCache.Windows, window)
    
    return window
end

-- ======================================
-- BIND DE TECLAS MELHORADO
-- ======================================
local activeBinds = {}

function GGMenu:BindKey(keyCode, callback, description)
    local bindId = HttpService:GenerateGUID(false)
    
    local bind = {
        Id = bindId,
        Key = keyCode,
        Callback = callback,
        Description = description
    }
    
    table.insert(activeBinds, bind)
    
    -- Notificar bind criado
    if description then
        self:Notify("Keybind Created", description .. " bound to " .. tostring(keyCode), 3, "Info")
    end
    
    return {
        Unbind = function()
            for i, b in ipairs(activeBinds) do
                if b.Id == bindId then
                    table.remove(activeBinds, i)
                    break
                end
            end
        end,
        Update = function(newKey, newCallback)
            bind.Key = newKey or bind.Key
            bind.Callback = newCallback or bind.Callback
        end
    }
end

-- Detectar pressionamento
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    for _, bind in ipairs(activeBinds) do
        if input.KeyCode == bind.Key then
            pcall(bind.Callback)
        end
    end
end)

-- ======================================
-- CONFIG MANAGER
-- ======================================
GGMenu.ConfigManager = {
    Configs = {},
    CurrentConfig = "default",
    
    Save = function(self, name)
        local config = {
            Windows = {},
            Components = {}
        }
        
        -- Salvar posições das janelas
        for _, window in ipairs(InstanceCache.Windows) do
            table.insert(config.Windows, {
                Position = window.Frame.Position,
                Size = window.Frame.Size
            })
        end
        
        self.Configs[name] = config
        GGMenu:Notify("Config Saved", "Configuration '" .. name .. "' saved successfully!", 3, "Success")
        return true
    end,
    
    Load = function(self, name)
        if not self.Configs[name] then
            GGMenu:Notify("Config Error", "Configuration '" .. name .. "' not found!", 3, "Danger")
            return false
        end
        
        local config = self.Configs[name]
        
        -- Carregar posições das janelas
        for i, window in ipairs(InstanceCache.Windows) do
            if config.Windows[i] then
                window:SetPosition(config.Windows[i].Position)
                window:SetSize(config.Windows[i].Size)
            end
        end
        
        self.CurrentConfig = name
        GGMenu:Notify("Config Loaded", "Configuration '" .. name .. "' loaded!", 3, "Success")
        return true
    end,
    
    Delete = function(self, name)
        if self.Configs[name] then
            self.Configs[name] = nil
            GGMenu:Notify("Config Deleted", "Configuration '" .. name .. "' deleted!", 3, "Info")
            return true
        end
        return false
    end,
    
    GetList = function(self)
        local list = {}
        for name, _ in pairs(self.Configs) do
            table.insert(list, name)
        end
        return list
    end
}

-- ======================================
-- INICIALIZAÇÃO MODULAR
-- ======================================
function GGMenu:Init(options)
    options = options or {}
    local showFPSBar = options.FPSBar ~= false
    local defaultKeybind = options.ToggleKey or Enum.KeyCode.Insert
    
    local components = {}
    
    -- FPS Bar (opcional)
    if showFPSBar then
        components.FPSBar = self.CreateFPSBar()
    end
    
    -- Janela (começa invisível)
    components.Window = self.CreateWindow("GGMenu v5.3")
    
    -- Hotkey para mostrar/ocultar
    local toggleKeybind = self:BindKey(defaultKeybind, function()
        components.Window:Toggle()
    end, "Toggle Menu")
    
    -- Configuração padrão
    local configTab = components.Window:AddTab("Config", "⚙️")
    local configSection = configTab:AddSection("Configuration", "Manage UI settings and configurations")
    
    -- Salvar configuração
    local saveTextBox = configSection:AddTextBox("Save Config", "config_name", function(name)
        if name and name ~= "" then
            self.ConfigManager:Save(name)
        end
    end, "Enter configuration name")
    
    configSection:AddButton("Save Current Config", function()
        local name = saveTextBox:GetValue()
        if name and name ~= "" then
            self.ConfigManager:Save(name)
        else
            self:Notify("Config Error", "Please enter a configuration name", 3, "Warning")
        end
    end, "Save current UI state")
    
    -- Lista de configurações salvas
    local configs = self.ConfigManager:GetList()
    local configDropdown = configSection:AddDropdown("Load Config", configs, configs[1] or "none", function(selected)
        if selected ~= "none" then
            self.ConfigManager:Load(selected)
        end
    end, "Select a saved configuration")
    
    configSection:AddButton("Refresh Config List", function()
        configDropdown.UpdateOptions(self.ConfigManager:GetList())
    end, "Refresh list of saved configurations")
    
    -- Atualizar tema
    local themeSection = configTab:AddSection("Theme", "Customize UI colors")
    
    themeSection:AddLabel("Accent Color", self.Theme.Accent)
    themeSection:AddLabel("Background Color", self.Theme.BgDark)
    themeSection:AddLabel("Text Color", self.Theme.TextPrimary)
    
    -- Informações
    local infoTab = components.Window:AddTab("Info", "ℹ️")
    local infoSection = infoTab:AddSection("GGMenu v5.3", "Advanced UI Library for Roblox")
    
    infoSection:AddLabel("Version: 5.3")
    infoSection:AddLabel("Status: Running")
    infoSection:AddLabel("Toggle Key: " .. tostring(defaultKeybind))
    infoSection:AddLabel("Executor: " .. GetExecutor())
    infoSection:AddSpacer(10)
    infoSection:AddLabel("Features:")
    infoSection:AddLabel("- Fully customizable UI")
    infoSection:AddLabel("- Smooth animations")
    infoSection:AddLabel("- Tooltip system")
    infoSection:AddLabel("- Notification system")
    infoSection:AddLabel("- Configuration manager")
    infoSection:AddLabel("- Draggable elements")
    
    -- Conectar para limpeza
    components.DestroyAll = function()
        toggleKeybind.Unbind()
        
        -- Desconectar todas as conexões
        for _, conn in ipairs(InstanceCache.Connections) do
            pcall(function() conn:Disconnect() end)
        end
        
        -- Destruir todos os componentes
        for _, window in ipairs(InstanceCache.Windows) do
            pcall(function() window:Destroy() end)
        end
        
        if components.FPSBar then
            components.FPSBar:Destroy()
        end
        
        InstanceCache.Windows = {}
        InstanceCache.Connections = {}
        InstanceCache.Components = {}
        
        self:Notify("GGMenu", "UI Library unloaded successfully", 3, "Info")
    end
    
    print("GGMenu v5.3 loaded successfully!")
    print("Executor:", GetExecutor())
    print("Press " .. tostring(defaultKeybind) .. " to show/hide menu")
    
    self:Notify("GGMenu v5.3", "UI Library loaded successfully!", 5, "Success")
    
    return components
end

-- ======================================
-- FUNÇÃO DE EXPORTAÇÃO
-- ======================================
function GGMenu:CreateLibrary()
    return {
        -- Componentes principais
        CreateWindow = GGMenu.CreateWindow,
        CreateFPSBar = GGMenu.CreateFPSBar,
        
        -- Componentes básicos
        CreateToggle = GGMenu.CreateToggle,
        CreateSlider = GGMenu.CreateSlider,
        CreateDropdown = GGMenu.CreateDropdown,
        CreateButton = GGMenu.CreateButton,
        CreateTextBox = GGMenu.CreateTextBox,
        
        -- Utilidades
        Notify = function(...) return GGMenu:Notify(...) end,
        BindKey = function(...) return GGMenu:BindKey(...) end,
        AddTooltip = function(...) return GGMenu:AddTooltip(...) end,
        
        -- Gerenciamento
        ConfigManager = GGMenu.ConfigManager,
        
        -- Temas e fontes
        Theme = GGMenu.Theme,
        Fonts = GGMenu.Fonts,
        
        -- Inicialização
        Init = function(...) return GGMenu:Init(...) end
    }
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

return GGMenu:CreateLibrary()
