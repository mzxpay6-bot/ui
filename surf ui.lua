-- UI_Library.lua
local UILibrary = {}

-- Configurações premium
UILibrary.Config = {
    PrimaryColor = Color3.fromRGB(47, 49, 54),     -- Cinza escuro base
    SecondaryColor = Color3.fromRGB(32, 34, 37),   -- Mais escuro
    AccentColor = Color3.fromRGB(0, 170, 255),     -- Azul neon
    TextColor = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamSemibold,
    CornerRadius = UDim.new(0, 6),
    BlurEnabled = true,
    Keybinds = {},
    Version = "v2.0",
    MenuTitle = "UTILITY MENU"
}

-- Utilitários
local function ApplyGlow(frame, intensity)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Image = "rbxassetid://8992231221"
    glow.ImageColor3 = UILibrary.Config.AccentColor
    glow.BackgroundTransparency = 1
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.ImageTransparency = 0.8
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(100, 100, 100, 100)
    glow.ZIndex = 0
    glow.Parent = frame
end

-- Cria tela principal com visual moderno
function UILibrary:CreateScreen(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PremiumUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    
    -- Efeito de blur no fundo (opcional)
    if self.Config.BlurEnabled then
        local blur = Instance.new("BlurEffect")
        blur.Size = 8
        blur.Parent = game.Lighting
    end
    
    -- Frame principal com sombra
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    MainFrame.BackgroundColor3 = self.Config.PrimaryColor
    MainFrame.ClipsDescendants = true
    
    -- Cantos arredondados
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = self.Config.CornerRadius
    UICorner.Parent = MainFrame
    
    -- Efeito de borda
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(60, 62, 68)
    UIStroke.Thickness = 2
    UIStroke.Parent = MainFrame
    
    -- Efeito de glow
    ApplyGlow(MainFrame, 0.3)
    
    -- Cabeçalho
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = self.Config.SecondaryColor
    Header.BorderSizePixel = 0
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 6)
    HeaderCorner.Parent = Header
    
    -- Título do cabeçalho
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = self.Config.MenuTitle .. " | " .. title
    Title.TextColor3 = self.Config.AccentColor
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    -- Versão
    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Name = "Version"
    VersionLabel.Size = UDim2.new(0.3, 0, 1, 0)
    VersionLabel.Position = UDim2.new(0.7, 0, 0, 0)
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Text = self.Config.Version
    VersionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    VersionLabel.Font = self.Config.Font
    VersionLabel.TextSize = 14
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
    VersionLabel.Parent = Header
    
    -- Separador
    local Separator = Instance.new("Frame")
    Separator.Name = "Separator"
    Separator.Size = UDim2.new(1, -20, 0, 1)
    Separator.Position = UDim2.new(0, 10, 0, 40)
    Separator.BackgroundColor3 = self.Config.AccentColor
    Separator.BorderSizePixel = 0
    
    Header.Parent = MainFrame
    Separator.Parent = MainFrame
    
    -- Container principal
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "Content"
    ContentContainer.Size = UDim2.new(1, 0, 1, -50)
    ContentContainer.Position = UDim2.new(0, 0, 0, 50)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    
    -- Container com scroll para os painéis
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Name = "ScrollingContainer"
    ScrollingFrame.Size = UDim2.new(1, -20, 1, -20)
    ScrollingFrame.Position = UDim2.new(0, 10, 0, 10)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.ScrollBarThickness = 3
    ScrollingFrame.ScrollBarImageColor3 = self.Config.AccentColor
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.Parent = ContentContainer
    
    MainFrame.Parent = ScreenGui
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    return {
        Main = MainFrame,
        Content = ScrollingFrame,
        Header = Header,
        Screen = ScreenGui
    }
end

-- Cria um painel de usuário premium
function UILibrary:CreateUserPanel(parent, player)
    local UserContainer = Instance.new("Frame")
    UserContainer.Name = "UserPanel_" .. player.Name
    UserContainer.Size = UDim2.new(1, 0, 0, 120)
    UserContainer.BackgroundColor3 = self.Config.SecondaryColor
    UserContainer.BorderSizePixel = 0
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = self.Config.CornerRadius
    UICorner.Parent = UserContainer
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(60, 62, 68)
    UIStroke.Thickness = 1
    UIStroke.Parent = UserContainer
    
    -- Avatar circular
    local AvatarContainer = Instance.new("Frame")
    AvatarContainer.Name = "AvatarContainer"
    AvatarContainer.Size = UDim2.new(0, 80, 0, 80)
    AvatarContainer.Position = UDim2.new(0, 15, 0.5, -40)
    AvatarContainer.BackgroundTransparency = 1
    
    local AvatarCircle = Instance.new("ImageLabel")
    AvatarCircle.Name = "AvatarCircle"
    AvatarCircle.Size = UDim2.new(1, 0, 1, 0)
    AvatarCircle.Image = "rbxassetid://3570695787"
    AvatarCircle.ScaleType = Enum.ScaleType.Slice
    AvatarCircle.SliceCenter = Rect.new(100, 100, 100, 100)
    AvatarCircle.ImageColor3 = self.Config.AccentColor
    AvatarCircle.BackgroundTransparency = 1
    
    local Avatar = Instance.new("ImageLabel")
    Avatar.Name = "Avatar"
    Avatar.Size = UDim2.new(1, -10, 1, -10)
    Avatar.Position = UDim2.new(0, 5, 0, 5)
    Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=420&h=420"
    Avatar.BackgroundTransparency = 1
    Avatar.Parent = AvatarCircle
    
    AvatarCircle.Parent = AvatarContainer
    AvatarContainer.Parent = UserContainer
    
    -- Informações do usuário
    local InfoFrame = Instance.new("Frame")
    InfoFrame.Name = "InfoFrame"
    InfoFrame.Size = UDim2.new(0, 300, 0, 80)
    InfoFrame.Position = UDim2.new(0, 110, 0.5, -40)
    InfoFrame.BackgroundTransparency = 1
    
    local DisplayName = Instance.new("TextLabel")
    DisplayName.Name = "DisplayName"
    DisplayName.Size = UDim2.new(1, 0, 0, 30)
    DisplayName.Text = player.DisplayName
    DisplayName.TextColor3 = self.Config.TextColor
    DisplayName.Font = Enum.Font.GothamBold
    DisplayName.TextSize = 20
    DisplayName.TextXAlignment = Enum.TextXAlignment.Left
    DisplayName.BackgroundTransparency = 1
    DisplayName.Parent = InfoFrame
    
    local UserName = Instance.new("TextLabel")
    UserName.Name = "UserName"
    UserName.Size = UDim2.new(1, 0, 0, 20)
    UserName.Position = UDim2.new(0, 0, 0, 30)
    UserName.Text = "@" .. player.Name
    UserName.TextColor3 = Color3.fromRGB(180, 180, 180)
    UserName.Font = self.Config.Font
    UserName.TextSize = 14
    UserName.TextXAlignment = Enum.TextXAlignment.Left
    UserName.BackgroundTransparency = 1
    UserName.Parent = InfoFrame
    
    local UserId = Instance.new("TextLabel")
    UserId.Name = "UserId"
    UserId.Size = UDim2.new(1, 0, 0, 20)
    UserId.Position = UDim2.new(0, 0, 0, 50)
    UserId.Text = "ID: " .. player.UserId
    UserId.TextColor3 = Color3.fromRGB(150, 150, 150)
    UserId.Font = self.Config.Font
    UserId.TextSize = 12
    UserId.TextXAlignment = Enum.TextXAlignment.Left
    UserId.BackgroundTransparency = 1
    UserId.Parent = InfoFrame
    
    InfoFrame.Parent = UserContainer
    
    -- Status indicator
    local StatusIndicator = Instance.new("Frame")
    StatusIndicator.Name = "Status"
    StatusIndicator.Size = UDim2.new(0, 10, 0, 10)
    StatusIndicator.Position = UDim2.new(1, -25, 0, 15)
    StatusIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(1, 0)
    StatusCorner.Parent = StatusIndicator
    
    StatusIndicator.Parent = UserContainer
    
    -- Atualizar o scroll container
    local totalHeight = 0
    for _, child in pairs(parent:GetChildren()) do
        if child:IsA("Frame") then
            totalHeight = totalHeight + child.Size.Y.Offset + 10
        end
    end
    
    UserContainer.Position = UDim2.new(0, 0, 0, totalHeight)
    parent.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 130)
    parent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    UserContainer.Parent = parent
    
    return UserContainer
end

-- Contador de FPS estilizado
function UILibrary:CreateFPSCounter(parent)
    local FPSCounter = Instance.new("Frame")
    FPSCounter.Name = "FPSCounter"
    FPSCounter.Size = UDim2.new(0, 100, 0, 40)
    FPSCounter.Position = UDim2.new(1, -110, 0, 10)
    FPSCounter.BackgroundColor3 = self.Config.SecondaryColor
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = self.Config.CornerRadius
    UICorner.Parent = FPSCounter
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = self.Config.AccentColor
    UIStroke.Thickness = 1
    UIStroke.Parent = FPSCounter
    
    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Name = "FPSLabel"
    FPSLabel.Size = UDim2.new(1, 0, 1, 0)
    FPSLabel.Text = "FPS: 60"
    FPSLabel.TextColor3 = self.Config.TextColor
    FPSLabel.Font = self.Config.Font
    FPSLabel.TextSize = 16
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Parent = FPSCounter
    
    local lastTime = tick()
    local frameCount = 0
    
    game:GetService("RunService").RenderStepped:Connect(function()
        frameCount = frameCount + 1
        if tick() - lastTime >= 0.5 then
            local fps = frameCount * 2
            FPSLabel.Text = "FPS: " .. fps
            
            -- Mudar cor baseado no FPS
            if fps >= 60 then
                UIStroke.Color = Color3.fromRGB(0, 255, 0)
            elseif fps >= 30 then
                UIStroke.Color = Color3.fromRGB(255, 255, 0)
            else
                UIStroke.Color = Color3.fromRGB(255, 50, 50)
            end
            
            frameCount = 0
            lastTime = tick()
        end
    end)
    
    FPSCounter.Parent = parent
end

-- Cria um botão estilizado
function UILibrary:CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Name = "Button_" .. text
    Button.Size = UDim2.new(1, -20, 0, 40)
    Button.Position = UDim2.new(0, 10, 0, 0)
    Button.Text = ""
    Button.BackgroundColor3 = self.Config.SecondaryColor
    Button.AutoButtonColor = false
    Button.ClipsDescendants = true
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = self.Config.CornerRadius
    UICorner.Parent = Button
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(60, 62, 68)
    UIStroke.Thickness = 1
    UIStroke.Parent = Button
    
    -- Efeito hover
    local HoverEffect = Instance.new("Frame")
    HoverEffect.Name = "HoverEffect"
    HoverEffect.Size = UDim2.new(1, 0, 1, 0)
    HoverEffect.BackgroundColor3 = self.Config.AccentColor
    HoverEffect.BackgroundTransparency = 0.9
    HoverEffect.ZIndex = -1
    HoverEffect.Visible = false
    HoverEffect.Parent = Button
    
    -- Texto do botão
    local ButtonText = Instance.new("TextLabel")
    ButtonText.Name = "Text"
    ButtonText.Size = UDim2.new(1, 0, 1, 0)
    ButtonText.Text = text
    ButtonText.TextColor3 = self.Config.TextColor
    ButtonText.Font = self.Config.Font
    ButtonText.TextSize = 16
    ButtonText.BackgroundTransparency = 1
    ButtonText.Parent = Button
    
    -- Interações
    Button.MouseEnter:Connect(function()
        HoverEffect.Visible = true
        UIStroke.Color = self.Config.AccentColor
        game.TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 47, 52)
        }):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        HoverEffect.Visible = false
        UIStroke.Color = Color3.fromRGB(60, 62, 68)
        game.TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Config.SecondaryColor
        }):Play()
    end)
    
    Button.MouseButton1Click:Connect(function()
        game.TweenService:Create(Button, TweenInfo.new(0.1), {
            BackgroundColor3 = self.Config.AccentColor
        }):Play()
        wait(0.1)
        game.TweenService:Create(Button, TweenInfo.new(0.1), {
            BackgroundColor3 = self.Config.SecondaryColor
        }):Play()
        
        if callback then
            callback()
        end
    end)
    
    -- Posicionamento automático
    local totalHeight = 0
    for _, child in pairs(parent:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then
            totalHeight = totalHeight + child.Size.Y.Offset + 10
        end
    end
    
    Button.Position = UDim2.new(0, 10, 0, totalHeight)
    parent.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 50)
    parent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    Button.Parent = parent
    
    return Button
end

-- Sistema de keybinds melhorado
function UILibrary:BindKey(key, callback, description)
    self.Config.Keybinds[key] = {
        Callback = callback,
        Description = description or "No description"
    }
    
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[key] then
            callback()
            
            -- Feedback visual
            local notification = self:CreateNotification("Keybind Activated: " .. description)
            task.spawn(function()
                wait(2)
                notification:Destroy()
            end)
        end
    end)
end

-- Sistema de notificações
function UILibrary:CreateNotification(message)
    local ScreenGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("PremiumUI")
    if not ScreenGui then return end
    
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(0, 300, 0, 60)
    Notification.Position = UDim2.new(1, 10, 1, -70)
    Notification.BackgroundColor3 = self.Config.SecondaryColor
    Notification.ZIndex = 100
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = self.Config.CornerRadius
    UICorner.Parent = Notification
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = self.Config.AccentColor
    UIStroke.Thickness = 2
    UIStroke.Parent = Notification
    
    ApplyGlow(Notification, 0.5)
    
    local Message = Instance.new("TextLabel")
    Message.Size = UDim2.new(1, -20, 1, -20)
    Message.Position = UDim2.new(0, 10, 0, 10)
    Message.Text = message
    Message.TextColor3 = self.Config.TextColor
    Message.Font = self.Config.Font
    Message.TextSize = 14
    Message.TextWrapped = true
    Message.BackgroundTransparency = 1
    Message.Parent = Notification
    
    Notification.Parent = ScreenGui
    
    -- Animação de entrada
    Notification.Position = UDim2.new(1, 10, 1, -70)
    game.TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        Position = UDim2.new(1, -310, 1, -70)
    }):Play()
    
    return Notification
end

-- Toggle para habilitar/desabilitar blur
function UILibrary:ToggleBlur(enabled)
    local blur = game.Lighting:FindFirstChildOfClass("BlurEffect")
    if enabled then
        if not blur then
            blur = Instance.new("BlurEffect")
            blur.Size = 8
            blur.Parent = game.Lighting
        end
    else
        if blur then
            blur:Destroy()
        end
    end
end

-- Atualizar tema dinamicamente
function UILibrary:UpdateTheme(newPrimary, newSecondary, newAccent)
    self.Config.PrimaryColor = newPrimary or self.Config.PrimaryColor
    self.Config.SecondaryColor = newSecondary or self.Config.SecondaryColor
    self.Config.AccentColor = newAccent or self.Config.AccentColor
end

return UILibrary
