-- ======================================
-- GGMenu UI Library v5.3 (Melhorada)
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
    Danger = Color3.fromRGB(231, 76, 60),
    Info = Color3.fromRGB(52, 152, 219)
}

GGMenu.Fonts = {
    Title = Enum.Font.GothamBold,
    Header = Enum.Font.GothamSemibold,
    Body = Enum.Font.Gotham,
    Code = Enum.Font.Code,
    Monospace = Enum.Font.RobotoMono
}

-- Armazenamento de binds
GGMenu.Keybinds = {}
GGMenu.Notifications = {}
GGMenu.Settings = {
    AutoSave = false,
    SaveKey = "GGMenu_Settings_v5"
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
    duration = duration or 0.2
    local ti = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
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

-- ======================================
-- NOVOS COMPONENTES
-- ======================================

-- Sistema de Notificações
function GGMenu:Notify(title, message, duration, color)
    duration = duration or 5
    color = color or GGMenu.Theme.Accent
    
    local screenGui = Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_Notification_" .. HttpService:GenerateGUID(false),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999
    })
    
    local notification = Create("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, 10, 0.3, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {Color = color, Thickness = 2})
    })
    
    local titleLabel = Create("TextLabel", {
        Parent = notification,
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = color,
        TextSize = 16,
        Font = GGMenu.Fonts.Header,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local messageLabel = Create("TextLabel", {
        Parent = notification,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = GGMenu.Theme.TextSecondary,
        TextSize = 13,
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    
    -- Animação de entrada
    notification.Position = UDim2.new(1, 10, 0.3, 0)
    Tween(notification, {Position = UDim2.new(1, -320, 0.3, 0)}, 0.3)
    
    -- Animação de saída
    delay(duration, function()
        Tween(notification, {Position = UDim2.new(1, 10, 0.3, 0)}, 0.3)
        wait(0.3)
        screenGui:Destroy()
    end)
    
    return notification
end

-- Sistema de Keybinds
function GGMenu:BindKey(keyName, defaultKey, callback)
    local bindId = #GGMenu.Keybinds + 1
    
    local keybind = {
        Id = bindId,
        Name = keyName,
        Key = defaultKey,
        Callback = callback,
        Listening = false
    }
    
    GGMenu.Keybinds[bindId] = keybind
    
    -- Conectar input
    local connection = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == keybind.Key then
            callback()
        end
    end)
    
    keybind.Connection = connection
    
    return {
        SetKey = function(self, newKey)
            keybind.Key = newKey
            if connection then
                connection:Disconnect()
            end
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.KeyCode == newKey then
                    callback()
                end
            end)
            keybind.Connection = connection
        end,
        
        Remove = function(self)
            if connection then
                connection:Disconnect()
            end
            GGMenu.Keybinds[bindId] = nil
        end,
        
        GetKey = function(self)
            return keybind.Key
        end
    }
end

-- Color Picker Simples
function GGMenu.CreateColorPicker(parent, text, defaultColor, callback)
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
    
    local colorButton = Create("TextButton", {
        Parent = container,
        Size = UDim2.new(0, 80, 0, 30),
        Position = UDim2.new(1, -80, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = defaultColor,
        Text = "",
        AutoButtonColor = false
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    -- Preview de cor
    local colorText = Create("TextLabel", {
        Parent = colorButton,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = string.format("#%02X%02X%02X", 
            math.floor(defaultColor.R * 255),
            math.floor(defaultColor.G * 255),
            math.floor(defaultColor.B * 255)),
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 12,
        Font = GGMenu.Fonts.Code,
        TextStrokeTransparency = 0.5
    })
    
    -- Modal para seleção de cor
    local colorModal = nil
    
    local function showColorPicker()
        if colorModal then
            colorModal:Destroy()
            colorModal = nil
            return
        end
        
        colorModal = Create("Frame", {
            Parent = container,
            Size = UDim2.new(0, 200, 0, 200),
            Position = UDim2.new(1, -200, 1, 5),
            BackgroundColor3 = GGMenu.Theme.BgDark,
            BorderSizePixel = 0,
            ZIndex = 1000
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
            Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
        })
        
        -- Cores pré-definidas
        local presetColors = {
            Color3.fromRGB(232, 84, 84),    -- Vermelho
            Color3.fromRGB(72, 199, 142),   -- Verde
            Color3.fromRGB(52, 152, 219),   -- Azul
            Color3.fromRGB(155, 89, 182),   -- Roxo
            Color3.fromRGB(241, 196, 15),   -- Amarelo
            Color3.fromRGB(230, 126, 34),   -- Laranja
            Color3.fromRGB(255, 255, 255),  -- Branco
            Color3.fromRGB(0, 0, 0)         -- Preto
        }
        
        local colorNames = {"Vermelho", "Verde", "Azul", "Roxo", "Amarelo", "Laranja", "Branco", "Preto"}
        
        for i, color in ipairs(presetColors) do
            local colorBtn = Create("TextButton", {
                Parent = colorModal,
                Size = UDim2.new(0, 40, 0, 40),
                Position = UDim2.new(0, ((i-1) % 4) * 50 + 10, 0, math.floor((i-1) / 4) * 50 + 10),
                BackgroundColor3 = color,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 1001
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
            })
            
            colorBtn.MouseButton1Click:Connect(function()
                colorButton.BackgroundColor3 = color
                colorText.Text = string.format("#%02X%02X%02X",
                    math.floor(color.R * 255),
                    math.floor(color.G * 255),
                    math.floor(color.B * 255))
                
                if callback then
                    callback(color)
                end
                
                colorModal:Destroy()
                colorModal = nil
            end)
        end
        
        -- Input manual de cor
        local hexLabel = Create("TextLabel", {
            Parent = colorModal,
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.new(0, 10, 0, 170),
            BackgroundTransparency = 1,
            Text = "HEX:",
            TextColor3 = GGMenu.Theme.TextSecondary,
            TextSize = 12,
            Font = GGMenu.Fonts.Code,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 1001
        })
        
        local hexInput = Create("TextBox", {
            Parent = colorModal,
            Size = UDim2.new(1, -80, 0, 25),
            Position = UDim2.new(0, 45, 0, 165),
            BackgroundColor3 = GGMenu.Theme.BgCard,
            TextColor3 = GGMenu.Theme.TextPrimary,
            Text = colorText.Text,
            TextSize = 12,
            Font = GGMenu.Fonts.Code,
            PlaceholderText = "#FFFFFF",
            ZIndex = 1001
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
            Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
        })
        
        hexInput.FocusLost:Connect(function()
            local hex = hexInput.Text:gsub("#", "")
            if #hex == 6 then
                local r = tonumber(hex:sub(1, 2), 16) or 0
                local g = tonumber(hex:sub(3, 4), 16) or 0
                local b = tonumber(hex:sub(5, 6), 16) or 0
                
                local color = Color3.fromRGB(r, g, b)
                colorButton.BackgroundColor3 = color
                colorText.Text = "#" .. hex
                
                if callback then
                    callback(color)
                end
            end
        end)
    end
    
    colorButton.MouseButton1Click:Connect(showColorPicker)
    
    -- Fechar ao clicar fora
    local clickConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and colorModal then
            local mousePos = UserInputService:GetMouseLocation()
            local framePos = colorModal.AbsolutePosition
            local frameSize = colorModal.AbsoluteSize
            
            if not (mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
                   mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y) then
                colorModal:Destroy()
                colorModal = nil
            end
        end
    end)
    
    local colorPicker = {
        Container = container,
        GetColor = function() return colorButton.BackgroundColor3 end,
        SetColor = function(color) 
            colorButton.BackgroundColor3 = color
            colorText.Text = string.format("#%02X%02X%02X",
                math.floor(color.R * 255),
                math.floor(color.G * 255),
                math.floor(color.B * 255))
            if callback then callback(color) end
        end,
        Destroy = function(self)
            clickConnection:Disconnect()
            container:Destroy()
        end
    }
    
    return colorPicker
end

-- Componente de Botão
function GGMenu.CreateButton(parent, text, callback)
    local container = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = 0
    })
    
    local button = Create("TextButton", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 35),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = GGMenu.Theme.Accent,
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Font = GGMenu.Fonts.Header,
        AutoButtonColor = false
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    button.MouseEnter:Connect(function()
        Tween(button, {BackgroundColor3 = Color3.fromRGB(
            math.min(GGMenu.Theme.Accent.R * 255 + 20, 255) / 255,
            math.min(GGMenu.Theme.Accent.G * 255 + 20, 255) / 255,
            math.min(GGMenu.Theme.Accent.B * 255 + 20, 255) / 255
        )})
    end)
    
    button.MouseLeave:Connect(function()
        Tween(button, {BackgroundColor3 = GGMenu.Theme.Accent})
    end)
    
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    local buttonObj = {
        Container = container,
        SetText = function(self, text) button.Text = text end,
        SetColor = function(self, color) 
            button.BackgroundColor3 = color
            button.MouseEnter:Connect(function()
                Tween(button, {BackgroundColor3 = Color3.fromRGB(
                    math.min(color.R * 255 + 20, 255) / 255,
                    math.min(color.G * 255 + 20, 255) / 255,
                    math.min(color.B * 255 + 20, 255) / 255
                )})
            end)
        end,
        Destroy = function(self) container:Destroy() end
    }
    
    return buttonObj
end

-- ======================================
-- COMPONENTES BASE (ORIGINAIS ATUALIZADOS)
-- ======================================
function GGMenu.CreateToggle(parent, text, defaultValue, callback)
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
        
        Set = function(self, value)
            self.Value = value
            Tween(toggleFrame, {BackgroundColor3 = value and GGMenu.Theme.Accent or GGMenu.Theme.BgCard})
            Tween(toggleCircle, {Position = value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)})
            if callback then callback(value) end
        end,
        
        Toggle = function(self)
            self:Set(not self.Value)
        end,
        
        Destroy = function(self)
            container:Destroy()
        end
    }
    
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle:Toggle()
        end
    end)
    
    return toggle
end

function GGMenu.CreateSlider(parent, text, min, max, defaultValue, callback)
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
    
    local slider = {
        Value = defaultValue or min,
        Min = min,
        Max = max,
        Container = container,
        IsFloat = isFloat,
        
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

function GGMenu.CreateDropdown(parent, text, options, defaultValue, callback)
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
    
    local function toggleDropdown()
        if dropdownOpen then
            closeDropdown()
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
                    if callback then callback(option) end
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
            if callback then callback(value) end
        end,
        Destroy = function(self)
            clickConnection:Disconnect()
            container:Destroy()
        end
    }
    
    return dropdown
end

-- ======================================
-- FPS BAR (ATUALIZADA)
-- ======================================
function GGMenu.CreateFPSBar()
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
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {Color = GGMenu.Theme.Accent, Thickness = 1.2})
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
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    -- Botão para minimizar
    local minimizeBtn = Create("TextButton", {
        Parent = bar,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -40, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        Text = "-",
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Visible = false
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 4)})
    })
    
    local minimized = false
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            bar.Size = UDim2.new(0, 32, 0, 32)
            textLabel.Visible = false
            minimizeBtn.Text = "+"
            GGMenu:Notify("FPS Bar", "FPS Bar minimizada", 2, GGMenu.Theme.Info)
        else
            bar.Size = UDim2.new(0, 450, 0, 32)
            textLabel.Visible = true
            minimizeBtn.Text = "-"
        end
    end)
    
    -- Sistema de arrastar manual
    local dragging = false
    local dragStart, startPos
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = bar.Position
            minimizeBtn.Visible = true
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
            wait(1)
            minimizeBtn.Visible = false
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
    
    local fpsBar = {
        Gui = screenGui,
        Bar = bar,
        SetVisible = function(self, visible) screenGui.Enabled = visible end,
        Destroy = function(self) screenGui:Destroy() end,
        Minimize = function(self) minimizeBtn.MouseButton1Click:Fire() end
    }
    
    return fpsBar
end

-- ======================================
-- JANELA COM TABS (ATUALIZADA)
-- ======================================
function GGMenu.CreateWindow(title)
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
        BorderSizePixel = 0
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
    
    -- Botão de minimizar
    local minimizeButton = Create("TextButton", {
        Parent = header,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -80, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        Text = "−",
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    minimizeButton.MouseEnter:Connect(function()
        Tween(minimizeButton, {BackgroundColor3 = GGMenu.Theme.Warning})
    end)
    
    minimizeButton.MouseLeave:Connect(function()
        Tween(minimizeButton, {BackgroundColor3 = GGMenu.Theme.BgCard})
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
    local windowVisible = false
    local minimized = false
    
    -- Função para minimizar
    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            mainFrame.Size = UDim2.new(0, 500, 0, 100)
            contentArea.Visible = false
            tabsContainer.Visible = false
            minimizeButton.Text = "+"
            GGMenu:Notify("Menu", "Menu minimizado", 2, GGMenu.Theme.Info)
        else
            mainFrame.Size = UDim2.new(0, 500, 0, 550)
            contentArea.Visible = true
            tabsContainer.Visible = true
            minimizeButton.Text = "−"
        end
    end)
    
    -- Funções da janela
    local window = {
        Gui = screenGui,
        Frame = mainFrame,
        Tabs = {},
        
        AddTab = function(self, tabName)
            local tabId = #tabs + 1
            
            -- Criar botão da tab
            local tabButton = Create("TextButton", {
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
                tabContent.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
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
            
            function tabInterface:AddSection(title)
                local section = Create("Frame", {
                    Parent = componentsContainer,
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1,
                    LayoutOrder = 0
                })
                
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
                
                local sectionInterface = {}
                
                function sectionInterface:AddToggle(text, default, callback)
                    local toggle = GGMenu.CreateToggle(componentsContainer, text, default, callback)
                    toggle.Container.LayoutOrder = 0
                    return toggle
                end
                
                function sectionInterface:AddSlider(text, min, max, default, callback)
                    local slider = GGMenu.CreateSlider(componentsContainer, text, min, max, default, callback)
                    slider.Container.LayoutOrder = 0
                    return slider
                end
                
                function sectionInterface:AddDropdown(text, options, default, callback)
                    local dropdown = GGMenu.CreateDropdown(componentsContainer, text, options, default, callback)
                    dropdown.Container.LayoutOrder = 0
                    return dropdown
                end
                
                function sectionInterface:AddButton(text, callback)
                    local button = GGMenu.CreateButton(componentsContainer, text, callback)
                    button.Container.LayoutOrder = 0
                    return button
                end
                
                function sectionInterface:AddColorPicker(text, defaultColor, callback)
                    local colorPicker = GGMenu.CreateColorPicker(componentsContainer, text, defaultColor, callback)
                    colorPicker.Container.LayoutOrder = 0
                    return colorPicker
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
                
                return sectionInterface
            end
            
            function tabInterface:AddToggle(text, default, callback)
                return GGMenu.CreateToggle(componentsContainer, text, default, callback)
            end
            
            function tabInterface:AddSlider(text, min, max, default, callback)
                return GGMenu.CreateSlider(componentsContainer, text, min, max, default, callback)
            end
            
            function tabInterface:AddDropdown(text, options, default, callback)
                return GGMenu.CreateDropdown(componentsContainer, text, options, default, callback)
            end
            
            function tabInterface:AddButton(text, callback)
                return GGMenu.CreateButton(componentsContainer, text, callback)
            end
            
            function tabInterface:AddColorPicker(text, defaultColor, callback)
                return GGMenu.CreateColorPicker(componentsContainer, text, defaultColor, callback)
            end
            
            function tabInterface:AddLabel(text)
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
            
            return tabInterface
        end,
        
        SetVisible = function(self, visible)
            mainFrame.Visible = visible
            windowVisible = visible
        end,
        
        Minimize = function(self)
            minimizeButton.MouseButton1Click:Fire()
        end,
        
        Destroy = function(self)
            screenGui:Destroy()
        end
    }
    
    -- Fechar janela
    closeButton.MouseButton1Click:Connect(function()
        window:SetVisible(false)
        GGMenu:Notify("Menu", "Menu fechado (INSERT para abrir)", 3, GGMenu.Theme.Info)
    end)
    
    -- Começar invisível
    window:SetVisible(false)
    
    return window
end

-- ======================================
-- INICIALIZAÇÃO MODULAR
-- ======================================
function GGMenu:Init(showFPSBar)
    showFPSBar = showFPSBar ~= false
    
    local components = {}
    
    -- FPS Bar (opcional)
    if showFPSBar then
        components.FPSBar = self.CreateFPSBar()
    end
    
    -- Janela (começa invisível)
    components.Window = self.CreateWindow("GGMenu v5.3")
    
    -- Hotkey para mostrar/ocultar (INSERT)
    local toggleConnection = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            components.Window:SetVisible(not components.Window.Frame.Visible)
        end
    end)
    
    -- Exemplo de bind key
    self:BindKey("ToggleMenu", Enum.KeyCode.Insert, function()
        components.Window:SetVisible(not components.Window.Frame.Visible)
    end)
    
    -- Notificação de inicialização
    self:Notify("GGMenu v5.3", "Carregado com sucesso!\nPressione INSERT para abrir", 5, self.Theme.Success)
    
    -- Conectar para limpeza
    components.DestroyAll = function()
        toggleConnection:Disconnect()
        
        -- Limpar todos os binds
        for _, bind in pairs(self.Keybinds) do
            if bind.Connection then
                bind.Connection:Disconnect()
            end
        end
        
        if components.FPSBar then
            components.FPSBar:Destroy()
        end
        if components.Window then
            components.Window:Destroy()
        end
        
        self:Notify("GGMenu", "Descarregado", 3, self.Theme.Info)
    end
    
    print("GGMenu v5.3 loaded!")
    print("Executor:", GetExecutor())
    print("Press INSERT to show/hide menu")
    
    return components
end

-- Função para criar interface rápida
function GGMenu:QuickMenu(title, tabs)
    local UI = self:Init(true)
    
    for tabName, tabConfig in pairs(tabs) do
        local tab = UI.Window:AddTab(tabName)
        
        for _, element in ipairs(tabConfig) do
            if element.type == "section" then
                local section = tab:AddSection(element.title)
                
                for _, item in ipairs(element.items) do
                    if item.type == "toggle" then
                        section:AddToggle(item.text, item.default, item.callback)
                    elseif item.type == "slider" then
                        section:AddSlider(item.text, item.min, item.max, item.default, item.callback)
                    elseif item.type == "dropdown" then
                        section:AddDropdown(item.text, item.options, item.default, item.callback)
                    elseif item.type == "button" then
                        section:AddButton(item.text, item.callback)
                    elseif item.type == "color" then
                        section:AddColorPicker(item.text, item.default, item.callback)
                    end
                end
            end
        end
    end
    
    return UI
end

-- Versão minimalista para usar apenas componentes
function GGMenu:CreateLibrary()
    return {
        CreateWindow = GGMenu.CreateWindow,
        CreateFPSBar = GGMenu.CreateFPSBar,
        CreateToggle = GGMenu.CreateToggle,
        CreateSlider = GGMenu.CreateSlider,
        CreateDropdown = GGMenu.CreateDropdown,
        CreateButton = GGMenu.CreateButton,
        CreateColorPicker = GGMenu.CreateColorPicker,
        Notify = GGMenu.Notify,
        BindKey = GGMenu.BindKey,
        Theme = GGMenu.Theme,
        Fonts = GGMenu.Fonts
    }
end

return GGMenu
