-- Professional UI Library
-- Inspirado no design premium do Xan UI
local UILibrary = {}

-- Serviços
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Configurações premium
UILibrary.Config = {
    PrimaryColor = Color3.fromRGB(18, 18, 22),      -- Fundo escuro
    SecondaryColor = Color3.fromRGB(28, 28, 34),    -- Cards
    TertiaryColor = Color3.fromRGB(38, 38, 45),     -- Hover
    AccentColor = Color3.fromRGB(232, 84, 84),      -- Vermelho moderno
    TextPrimary = Color3.fromRGB(245, 245, 250),
    TextSecondary = Color3.fromRGB(160, 160, 175),
    TextDim = Color3.fromRGB(90, 90, 105),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    CornerRadius = 10,
    AnimationSpeed = 0.25,
    BlurEnabled = false,
    GlowEnabled = true,
    Version = "v2.1",
    Keybinds = {},
    Theme = "Dark"
}

-- Cores para diferentes temas
UILibrary.Themes = {
    Dark = {
        Primary = Color3.fromRGB(18, 18, 22),
        Secondary = Color3.fromRGB(28, 28, 34),
        Accent = Color3.fromRGB(232, 84, 84),
        TextPrimary = Color3.fromRGB(245, 245, 250),
        TextSecondary = Color3.fromRGB(160, 160, 175)
    },
    Light = {
        Primary = Color3.fromRGB(245, 245, 250),
        Secondary = Color3.fromRGB(235, 235, 240),
        Accent = Color3.fromRGB(232, 84, 84),
        TextPrimary = Color3.fromRGB(30, 30, 35),
        TextSecondary = Color3.fromRGB(100, 100, 115)
    },
    Blue = {
        Primary = Color3.fromRGB(15, 20, 30),
        Secondary = Color3.fromRGB(25, 35, 50),
        Accent = Color3.fromRGB(0, 170, 255),
        TextPrimary = Color3.fromRGB(245, 245, 250),
        TextSecondary = Color3.fromRGB(180, 200, 220)
    }
}

-- Utilitários
local function Tween(obj, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or UILibrary.Config.AnimationSpeed,
        easingStyle or Enum.EasingStyle.Quint,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

local function Create(class, properties, children)
    local obj = Instance.new(class)
    
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then
            obj[prop] = value
        end
    end
    
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    
    if properties and properties.Parent then
        obj.Parent = properties.Parent
    end
    
    return obj
end

local function ApplyGlow(frame, color, intensity)
    if not UILibrary.Config.GlowEnabled then return end
    
    local glow = Create("ImageLabel", {
        Name = "Glow",
        Image = "rbxassetid://5028857084",
        ImageColor3 = color or UILibrary.Config.AccentColor,
        ImageTransparency = 0.92,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0, -30, 0, -30),
        ZIndex = 0
    })
    glow.Parent = frame
    return glow
end

local function CreateRoundedFrame(parent, size, position, backgroundColor, cornerRadius)
    local frame = Create("Frame", {
        Name = "RoundedFrame",
        Size = size,
        Position = position,
        BackgroundColor3 = backgroundColor or UILibrary.Config.SecondaryColor,
        BackgroundTransparency = 0,
        Parent = parent
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, cornerRadius or UILibrary.Config.CornerRadius) })
    })
    return frame
end

-- Cria tela principal premium
function UILibrary:CreateScreen(title, icon)
    local ScreenGui = Create("ScreenGui", {
        Name = "PremiumUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999
    })
    
    -- Efeito de blur
    if self.Config.BlurEnabled then
        local blur = Instance.new("BlurEffect")
        blur.Size = 8
        blur.Parent = game.Lighting
    end
    
    -- Overlay de fundo
    local Overlay = Create("Frame", {
        Name = "Overlay",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.8,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 1,
        Parent = ScreenGui
    })
    
    -- Container principal
    local Container = Create("Frame", {
        Name = "Container",
        BackgroundColor3 = self.Config.PrimaryColor,
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 500, 0, 600),
        Position = UDim2.new(0.5, -250, 0.5, -300),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 10,
        Parent = ScreenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 16) }),
        Create("UIStroke", {
            Color = Color3.fromRGB(40, 40, 48),
            Thickness = 1,
            Transparency = 0
        })
    })
    
    -- Glow effect
    ApplyGlow(Container, self.Config.AccentColor, 0.1)
    
    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = self.Config.SecondaryColor,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 0,
        ZIndex = 11,
        Parent = Container
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 16),
            CornerMask = BitMask.new(15) -- Top corners only
        })
    })
    
    -- Logo e título
    local LogoContainer = Create("Frame", {
        Name = "LogoContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 120, 0, 40),
        Position = UDim2.new(0, 15, 0.5, -20),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 12,
        Parent = Header
    })
    
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = self.Config.FontBold,
        Text = title or "Premium UI",
        TextColor3 = self.Config.TextPrimary,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
        Parent = LogoContainer
    })
    
    local SubtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -12),
        Font = self.Config.FontMedium,
        Text = "by " .. (LocalPlayer.Name or "User"),
        TextColor3 = self.Config.TextDim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
        Parent = LogoContainer
    })
    
    -- Botão de fechar
    local CloseButton = Create("TextButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
        AnchorPoint = Vector2.new(1, 0.5),
        Text = "",
        ZIndex = 12,
        Parent = Header
    })
    
    local CloseIcon = Create("ImageLabel", {
        Name = "CloseIcon",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
        Image = "rbxassetid://7743878857",
        ImageColor3 = self.Config.TextDim,
        ZIndex = 13,
        Parent = CloseButton
    })
    
    -- Animações do botão de fechar
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseIcon, { ImageColor3 = self.Config.TextPrimary })
    end)
    
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseIcon, { ImageColor3 = self.Config.TextDim })
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Separador
    local Separator = Create("Frame", {
        Name = "Separator",
        BackgroundColor3 = Color3.fromRGB(40, 40, 48),
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.new(0, 10, 0, 50),
        ZIndex = 11,
        Parent = Container
    })
    
    -- Container de conteúdo
    local ContentFrame = Create("Frame", {
        Name = "ContentFrame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -60),
        Position = UDim2.new(0, 0, 0, 60),
        ZIndex = 11,
        Parent = Container
    })
    
    -- Container com scroll
    local ScrollingFrame = Create("ScrollingFrame", {
        Name = "ScrollingContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Config.AccentColor,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        ZIndex = 11,
        Parent = ContentFrame
    })
    
    -- List layout para conteúdo
    local ListLayout = Create("UIListLayout", {
        Name = "ListLayout",
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ScrollingFrame
    })
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Animar entrada
    Container.BackgroundTransparency = 1
    Container.UIStroke.Transparency = 1
    Container.Position = UDim2.new(0.5, -250, 0.5, -320)
    
    Tween(Container, {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -250, 0.5, -300)
    }, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    Tween(Container.UIStroke, { Transparency = 0 }, 0.6)
    
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    return {
        Screen = ScreenGui,
        Container = Container,
        Content = ScrollingFrame,
        Header = Header,
        Title = TitleLabel,
        CloseButton = CloseButton
    }
end

-- Cria um painel de seção
function UILibrary:CreateSection(parent, title, description)
    local SectionContainer = Create("Frame", {
        Name = "Section_" .. (title or "Untitled"),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 0),
        LayoutOrder = #parent:GetChildren(),
        Parent = parent
    })
    
    local SectionTitle = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Font = self.Config.FontBold,
        Text = title or "Section",
        TextColor3 = self.Config.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SectionContainer
    })
    
    local SectionDesc = nil
    if description then
        SectionDesc = Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 0, 0, 24),
            Font = self.Config.Font,
            Text = description,
            TextColor3 = self.Config.TextDim,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = SectionContainer
        })
        
        SectionContainer.Size = UDim2.new(1, -20, 0, 44)
    else
        SectionContainer.Size = UDim2.new(1, -20, 0, 28)
    end
    
    return SectionContainer
end

-- Cria um botão premium
function UILibrary:CreateButton(parent, text, callback, options)
    options = options or {}
    local isAccent = options.Accent or false
    local icon = options.Icon
    
    local ButtonHeight = 42
    local Button = Create("TextButton", {
        Name = "Button_" .. text,
        BackgroundColor3 = isAccent and self.Config.AccentColor or self.Config.SecondaryColor,
        Size = UDim2.new(1, 0, 0, ButtonHeight),
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = #parent:GetChildren(),
        Parent = parent
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", {
            Color = isAccent and Color3.fromRGB(200, 70, 70) or Color3.fromRGB(50, 50, 58),
            Thickness = 1
        })
    })
    
    local ButtonContent = Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Parent = Button
    })
    
    local ButtonText = Create("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = self.Config.FontBold,
        Text = text,
        TextColor3 = isAccent and Color3.new(1, 1, 1) or self.Config.TextPrimary,
        TextSize = 14,
        TextXAlignment = icon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
        Parent = ButtonContent
    })
    
    if icon then
        ButtonText.Position = UDim2.new(0, 30, 0, 0)
        ButtonText.Size = UDim2.new(1, -30, 1, 0)
        
        local IconLabel = Create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 0, 0.5, -10),
            Image = icon,
            ImageColor3 = isAccent and Color3.new(1, 1, 1) or self.Config.TextPrimary,
            Parent = ButtonContent
        })
    end
    
    -- Efeitos de hover
    Button.MouseEnter:Connect(function()
        local targetColor = isAccent and Color3.fromRGB(245, 100, 100) or self.Config.TertiaryColor
        Tween(Button, { BackgroundColor3 = targetColor })
        Tween(Button.UIStroke, { Color = isAccent and Color3.fromRGB(220, 90, 90) or Color3.fromRGB(70, 70, 78) })
    end)
    
    Button.MouseLeave:Connect(function()
        local originalColor = isAccent and self.Config.AccentColor or self.Config.SecondaryColor
        Tween(Button, { BackgroundColor3 = originalColor })
        Tween(Button.UIStroke, { Color = isAccent and Color3.fromRGB(200, 70, 70) or Color3.fromRGB(50, 50, 58) })
    end)
    
    Button.MouseButton1Click:Connect(function()
        -- Efeito de clique
        Tween(Button, { BackgroundTransparency = 0.3 }, 0.1)
        Tween(Button, { BackgroundTransparency = 0 }, 0.1, nil, nil, 0.1)
        
        if callback then
            callback()
        end
    end)
    
    return Button
end

-- Cria um toggle switch
function UILibrary:CreateToggle(parent, text, default, callback)
    local ToggleContainer = Create("Frame", {
        Name = "Toggle_" .. text,
        BackgroundColor3 = self.Config.SecondaryColor,
        Size = UDim2.new(1, 0, 0, 50),
        LayoutOrder = #parent:GetChildren(),
        Parent = parent
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", {
            Color = Color3.fromRGB(50, 50, 58),
            Thickness = 1
        })
    })
    
    local ToggleLabel = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        Font = self.Config.FontBold,
        Text = text,
        TextColor3 = self.Config.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ToggleContainer
    })
    
    local ToggleFrame = Create("Frame", {
        Name = "Toggle",
        BackgroundColor3 = default and self.Config.AccentColor or Color3.fromRGB(50, 50, 58),
        Size = UDim2.new(0, 48, 0, 26),
        Position = UDim2.new(1, -60, 0.5, -13),
        AnchorPoint = Vector2.new(1, 0.5),
        Parent = ToggleContainer
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    
    local ToggleKnob = Create("Frame", {
        Name = "Knob",
        BackgroundColor3 = Color3.new(1, 1, 1),
        Size = UDim2.new(0, 20, 0, 20),
        Position = default and UDim2.new(0, 25, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = ToggleFrame
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    
    local ToggleButton = Create("TextButton", {
        Name = "Button",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = ToggleContainer
    })
    
    local isToggled = default or false
    
    local function updateToggle()
        local targetPos = isToggled and UDim2.new(0, 25, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        local targetColor = isToggled and self.Config.AccentColor or Color3.fromRGB(50, 50, 58)
        
        Tween(ToggleKnob, { Position = targetPos }, 0.2, Enum.EasingStyle.Back)
        Tween(ToggleFrame, { BackgroundColor3 = targetColor }, 0.2)
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        updateToggle()
        
        if callback then
            callback(isToggled)
        end
    end)
    
    return {
        Container = ToggleContainer,
        SetValue = function(value)
            isToggled = value
            updateToggle()
        end,
        GetValue = function()
            return isToggled
        end
    }
end

-- Cria um slider
function UILibrary:CreateSlider(parent, text, min, max, default, callback)
    local SliderContainer = Create("Frame", {
        Name = "Slider_" .. text,
        BackgroundColor3 = self.Config.SecondaryColor,
        Size = UDim2.new(1, 0, 0, 70),
        LayoutOrder = #parent:GetChildren(),
        Parent = parent
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", {
            Color = Color3.fromRGB(50, 50, 58),
            Thickness = 1
        })
    })
    
    local SliderLabel = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 10),
        Font = self.Config.FontBold,
        Text = text,
        TextColor3 = self.Config.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SliderContainer
    })
    
    local ValueLabel = Create("TextLabel", {
        Name = "Value",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.3, 0, 0, 20),
        Position = UDim2.new(1, -10, 0, 10),
        AnchorPoint = Vector2.new(1, 0),
        Font = self.Config.FontMedium,
        Text = tostring(default or min),
        TextColor3 = self.Config.AccentColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = SliderContainer
    })
    
    local SliderTrack = Create("Frame", {
        Name = "Track",
        BackgroundColor3 = Color3.fromRGB(50, 50, 58),
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0, 45),
        Parent = SliderContainer
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    
    local SliderFill = Create("Frame", {
        Name = "Fill",
        BackgroundColor3 = self.Config.AccentColor,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = SliderTrack
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    
    local SliderButton = Create("TextButton", {
        Name = "Button",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 40),
        Text = "",
        Parent = SliderContainer
    })
    
    local currentValue = math.clamp(default or min, min, max)
    local isDragging = false
    
    local function updateSlider(value)
        currentValue = math.clamp(value, min, max)
        local percentage = (currentValue - min) / (max - min)
        
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        ValueLabel.Text = tostring(math.floor(currentValue))
        
        if callback then
            callback(currentValue)
        end
    end
    
    updateSlider(currentValue)
    
    SliderButton.MouseButton1Down:Connect(function()
        isDragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    SliderButton.MouseMoved:Connect(function()
        if isDragging then
            local mouse = UserInputService:GetMouseLocation()
            local trackAbsolute = SliderTrack.AbsolutePosition
            local trackSize = SliderTrack.AbsoluteSize.X
            
            local relativeX = math.clamp(mouse.X - trackAbsolute.X, 0, trackSize)
            local percentage = relativeX / trackSize
            local value = min + (max - min) * percentage
            
            updateSlider(value)
        end
    end)
    
    return {
        Container = SliderContainer,
        SetValue = updateSlider,
        GetValue = function()
            return currentValue
        end
    }
end

-- Cria um painel de usuário premium
function UILibrary:CreateUserPanel(parent, player)
    local UserContainer = Create("Frame", {
        Name = "UserPanel_" .. player.Name,
        BackgroundColor3 = self.Config.SecondaryColor,
        Size = UDim2.new(1, 0, 0, 80),
        LayoutOrder = #parent:GetChildren(),
        Parent = parent
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
        Create("UIStroke", {
            Color = Color3.fromRGB(50, 50, 58),
            Thickness = 1
        })
    })
    
    -- Avatar circular
    local AvatarContainer = Create("Frame", {
        Name = "AvatarContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(0, 10, 0.5, -30),
        Parent = UserContainer
    })
    
    local AvatarMask = Create("Frame", {
        Name = "AvatarMask",
        BackgroundColor3 = self.Config.AccentColor,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = AvatarContainer
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    
    local AvatarImage = Create("ImageLabel", {
        Name = "Avatar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=420&h=420",
        ScaleType = Enum.ScaleType.Crop,
        Parent = AvatarMask
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    
    -- Informações do usuário
    local InfoFrame = Create("Frame", {
        Name = "InfoFrame",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, -80, 1, 0),
        Position = UDim2.new(0, 80, 0, 0),
        Parent = UserContainer
    })
    
    local DisplayName = Create("TextLabel", {
        Name = "DisplayName",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 10, 0, 10),
        Font = self.Config.FontBold,
        Text = player.DisplayName,
        TextColor3 = self.Config.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = InfoFrame
    })
    
    local UserName = Create("TextLabel", {
        Name = "UserName",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 10, 0, 34),
        Font = self.Config.Font,
        Text = "@" .. player.Name,
        TextColor3 = self.Config.TextDim,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = InfoFrame
    })
    
    -- Status indicator
    local StatusIndicator = Create("Frame", {
        Name = "Status",
        BackgroundColor3 = Color3.fromRGB(0, 255, 0),
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(1, -25, 0, 15),
        Parent = UserContainer
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    
    return UserContainer
end

-- Cria um dropdown
function UILibrary:CreateDropdown(parent, text, options, default, callback)
    local DropdownContainer = Create("Frame", {
        Name = "Dropdown_" .. text,
        BackgroundColor3 = self.Config.SecondaryColor,
        Size = UDim2.new(1, 0, 0, 50),
        LayoutOrder = #parent:GetChildren(),
        ClipsDescendants = true,
        Parent = parent
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", {
            Color = Color3.fromRGB(50, 50, 58),
            Thickness = 1
        })
    })
    
    local DropdownLabel = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        Font = self.Config.FontBold,
        Text = text,
        TextColor3 = self.Config.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = DropdownContainer
    })
    
    local SelectedLabel = Create("TextLabel", {
        Name = "Selected",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.3, -30, 1, 0),
        Position = UDim2.new(1, -30, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        Font = self.Config.FontMedium,
        Text = options[default] or options[1] or "Select",
        TextColor3 = self.Config.AccentColor,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = DropdownContainer
    })
    
    local DropdownIcon = Create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -10, 0.5, -8),
        AnchorPoint = Vector2.new(1, 0.5),
        Image = "rbxassetid://7733960981",
        ImageColor3 = self.Config.TextDim,
        Rotation = 180,
        Parent = DropdownContainer
    })
    
    local DropdownButton = Create("TextButton", {
        Name = "Button",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = DropdownContainer
    })
    
    local OptionsContainer = Create("Frame", {
        Name = "OptionsContainer",
        BackgroundColor3 = self.Config.PrimaryColor,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 5),
        ClipsDescendants = true,
        Visible = false,
        Parent = DropdownContainer
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", {
            Color = Color3.fromRGB(50, 50, 58),
            Thickness = 1
        })
    })
    
    local OptionsList = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 1),
        Parent = OptionsContainer
    })
    
    local isOpen = false
    local selectedIndex = default or 1
    
    local function toggleDropdown()
        isOpen = not isOpen
        OptionsContainer.Visible = true
        
        if isOpen then
            DropdownContainer.Size = UDim2.new(1, 0, 0, 50 + (#options * 36))
            OptionsContainer.Size = UDim2.new(1, 0, 0, #options * 36)
            Tween(DropdownIcon, { Rotation = 0 }, 0.2)
        else
            DropdownContainer.Size = UDim2.new(1, 0, 0, 50)
            OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
            Tween(DropdownIcon, { Rotation = 180 }, 0.2)
            
            task.delay(0.2, function()
                OptionsContainer.Visible = false
            end)
        end
    end
    
    DropdownButton.MouseButton1Click:Connect(toggleDropdown)
    
    -- Criar opções
    for i, option in ipairs(options) do
        local OptionButton = Create("TextButton", {
            Name = "Option_" .. i,
            BackgroundColor3 = self.Config.SecondaryColor,
            Size = UDim2.new(1, 0, 0, 36),
            Text = "",
            LayoutOrder = i,
            Parent = OptionsContainer
        })
        
        Create("UICorner", { CornerRadius = UDim.new(0, 0) }, OptionButton)
        
        local OptionText = Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Font = self.Config.Font,
            Text = option,
            TextColor3 = self.Config.TextPrimary,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = OptionButton
        })
        
        OptionButton.MouseEnter:Connect(function()
            Tween(OptionButton, { BackgroundColor3 = self.Config.TertiaryColor })
        end)
        
        OptionButton.MouseLeave:Connect(function()
            Tween(OptionButton, { BackgroundColor3 = self.Config.SecondaryColor })
        end)
        
        OptionButton.MouseButton1Click:Connect(function()
            selectedIndex = i
            SelectedLabel.Text = option
            toggleDropdown()
            
            if callback then
                callback(option, i)
            end
        end)
    end
    
    return {
        Container = DropdownContainer,
        GetSelected = function()
            return options[selectedIndex], selectedIndex
        end,
        SetSelected = function(index)
            if options[index] then
                selectedIndex = index
                SelectedLabel.Text = options[index]
            end
        end
    }
end

-- Cria um contador de FPS estilizado
function UILibrary:CreateFPSCounter(parent, position)
    local FPSCounter = Create("Frame", {
        Name = "FPSCounter",
        BackgroundColor3 = self.Config.SecondaryColor,
        Size = UDim2.new(0, 80, 0, 32),
        Position = position or UDim2.new(0, 10, 0, 10),
        Parent = parent
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", {
            Color = Color3.fromRGB(50, 50, 58),
            Thickness = 1
        })
    })
    
    local FPSLabel = Create("TextLabel", {
        Name = "FPSLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = self.Config.FontBold,
        Text = "FPS: 60",
        TextColor3 = Color3.fromRGB(0, 255, 0),
        TextSize = 14,
        Parent = FPSCounter
    })
    
    local lastTime = tick()
    local frameCount = 0
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        if tick() - lastTime >= 0.5 then
            local fps = frameCount * 2
            
            FPSLabel.Text = "FPS: " .. fps
            
            -- Mudar cor baseado no FPS
            local color
            if fps >= 60 then
                color = Color3.fromRGB(0, 255, 0)
            elseif fps >= 30 then
                color = Color3.fromRGB(255, 255, 0)
            else
                color = Color3.fromRGB(255, 50, 50)
            end
            
            Tween(FPSLabel, { TextColor3 = color }, 0.3)
            
            frameCount = 0
            lastTime = tick()
        end
    end)
    
    return FPSCounter
end

-- Sistema de keybinds melhorado
function UILibrary:BindKey(key, callback, description)
    self.Config.Keybinds[key] = {
        Callback = callback,
        Description = description or "No description"
    }
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[key] then
            callback()
            
            -- Feedback visual
            self:CreateNotification("Keybind: " .. key .. " - " .. description)
        end
    end)
end

-- Sistema de notificações
function UILibrary:CreateNotification(message, duration)
    duration = duration or 3
    
    local ScreenGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("PremiumUI")
    if not ScreenGui then return end
    
    local Notification = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = self.Config.SecondaryColor,
        Size = UDim2.new(0, 300, 0, 60),
        Position = UDim2.new(1, 10, 1, -70),
        AnchorPoint = Vector2.new(1, 1),
        ZIndex = 100,
        Parent = ScreenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
        Create("UIStroke", {
            Color = self.Config.AccentColor,
            Thickness = 2
        })
    })
    
    ApplyGlow(Notification, self.Config.AccentColor, 0.3)
    
    local MessageLabel = Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        Font = self.Config.Font,
        Text = message,
        TextColor3 = self.Config.TextPrimary,
        TextSize = 14,
        TextWrapped = true,
        Parent = Notification
    })
    
    -- Animação de entrada
    Notification.Position = UDim2.new(1, 10, 1, -70)
    Tween(Notification, { Position = UDim2.new(1, -310, 1, -70) }, 0.3, Enum.EasingStyle.Quint)
    
    task.delay(duration, function()
        Tween(Notification, { Position = UDim2.new(1, 10, 1, -70) }, 0.3, Enum.EasingStyle.Quint)
        task.delay(0.3, function()
            Notification:Destroy()
        end)
    end)
    
    return Notification
end

-- Muda o tema da UI
function UILibrary:SetTheme(themeName)
    local theme = self.Themes[themeName]
    if not theme then return end
    
    self.Config.PrimaryColor = theme.Primary
    self.Config.SecondaryColor = theme.Secondary
    self.Config.AccentColor = theme.Accent
    self.Config.TextPrimary = theme.TextPrimary
    self.Config.TextSecondary = theme.TextSecondary
    self.Config.Theme = themeName
end

-- Cria um separador
function UILibrary:CreateSeparator(parent, margin)
    margin = margin or 20
    
    local Separator = Create("Frame", {
        Name = "Separator",
        BackgroundColor3 = Color3.fromRGB(50, 50, 58),
        Size = UDim2.new(1, -margin, 0, 1),
        Position = UDim2.new(0, margin/2, 0, 0),
        LayoutOrder = #parent:GetChildren(),
        Parent = parent
    })
    
    return Separator
end

-- Cria uma label de texto
function UILibrary:CreateLabel(parent, text, options)
    options = options or {}
    
    local Label = Create("TextLabel", {
        Name = "Label_" .. text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, options.Margin and -options.Margin or -20, 0, 20),
        Position = options.Position,
        Font = options.Bold and self.Config.FontBold or self.Config.Font,
        Text = text,
        TextColor3 = options.Color or self.Config.TextPrimary,
        TextSize = options.Size or 14,
        TextXAlignment = options.Alignment or Enum.TextXAlignment.Left,
        TextWrapped = options.Wrapped or false,
        LayoutOrder = #parent:GetChildren(),
        Parent = parent
    })
    
    if options.Description then
        Label.Size = UDim2.new(1, options.Margin and -options.Margin or -20, 0, 40)
        
        local DescLabel = Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0.5, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            Font = self.Config.Font,
            Text = options.Description,
            TextColor3 = self.Config.TextDim,
            TextSize = 12,
            TextXAlignment = options.Alignment or Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = Label
        })
    end
    
    return Label
end

return UILibrary
