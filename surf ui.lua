--[[
  UI lib modificada - Versão melhorada
  Baseada na xsx UI por bungie#0001
  Modificações por: [Seu Nome]
]]

-- / Locals
local Workspace = game:GetService("Workspace")
local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

-- / Services
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGuiService = game:GetService("CoreGui")
local ContentService = game:GetService("ContentProvider")
local TeleportService = game:GetService("TeleportService")

-- / Configuração de tema
local Theme = {
    Primary = Color3.fromRGB(159, 115, 255),
    Secondary = Color3.fromRGB(60, 60, 60),
    Background = {
        Dark = Color3.fromRGB(34, 34, 34),
        Light = Color3.fromRGB(28, 28, 28)
    },
    Text = {
        Primary = Color3.fromRGB(198, 198, 198),
        Secondary = Color3.fromRGB(170, 170, 170),
        Disabled = Color3.fromRGB(140, 140, 140)
    },
    Status = {
        Success = Color3.fromRGB(131, 255, 103),
        Error = Color3.fromRGB(255, 74, 77),
        Warning = Color3.fromRGB(255, 246, 112),
        Info = Color3.fromRGB(126, 117, 255)
    }
}

-- / Tween table & function
local TweenTable = {
    Default = {
        TweenInfo.new(0.17, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
    }
}

local function CreateTween(name, speed, style, direction, loop, reverse, delay)
    TweenTable[name] = TweenInfo.new(
        speed or 0.17,
        style or Enum.EasingStyle.Sine,
        direction or Enum.EasingDirection.InOut,
        loop or 0,
        reverse or false,
        delay or 0
    )
end

-- / Função de arrasto otimizada
local function CreateDrag(obj, latency)
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function Update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
        TweenService:Create(obj, TweenInfo.new(latency or 0.06), {Position = newPos}):Play()
    end

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            Update(input)
        end
    end)
end

-- / Biblioteca principal
local library = {
    version = "2.1.0",
    title = "xsx UI Modificada",
    fps = 0,
    rank = "private",
    _themes = {},
    _currentTheme = "default"
}

-- Adicionar temas
library._themes["default"] = Theme
library._themes["dark"] = {
    Primary = Color3.fromRGB(86, 156, 214),
    Secondary = Color3.fromRGB(45, 45, 45),
    Background = {
        Dark = Color3.fromRGB(30, 30, 30),
        Light = Color3.fromRGB(25, 25, 25)
    }
}
library._themes["light"] = {
    Primary = Color3.fromRGB(0, 122, 255),
    Secondary = Color3.fromRGB(200, 200, 200),
    Background = {
        Dark = Color3.fromRGB(240, 240, 240),
        Light = Color3.fromRGB(255, 255, 255)
    },
    Text = {
        Primary = Color3.fromRGB(0, 0, 0),
        Secondary = Color3.fromRGB(60, 60, 60)
    }
}

-- Função para mudar tema
function library:SetTheme(themeName)
    if self._themes[themeName] then
        self._currentTheme = themeName
        -- Notificar componentes para atualizar cores
        -- (implementar se necessário)
        return true
    end
    return false
end

-- Função para obter cor atual do tema
function library:GetColor(type, variant)
    local theme = self._themes[self._currentTheme]
    if type == "primary" then
        return theme.Primary
    elseif type == "secondary" then
        return theme.Secondary
    elseif type == "background" then
        return variant == "dark" and theme.Background.Dark or theme.Background.Light
    elseif type == "text" then
        return variant == "primary" and theme.Text.Primary or theme.Text.Secondary
    elseif type == "status" then
        return theme.Status[variant] or Theme.Status[variant]
    end
    return Theme.Primary
end

-- Atualizar FPS
coroutine.wrap(function()
    local fps = 0
    local lastTime = tick()
    RunService.RenderStepped:Connect(function()
        local currentTime = tick()
        fps = 1 / (currentTime - lastTime)
        lastTime = currentTime
        library.fps = math.round(fps)
    end)
end)()

-- Funções utilitárias
function library:RoundNumber(decimalPlaces, number)
    return tonumber(string.format("%." .. (decimalPlaces or 0) .. "f", number))
end

function library:GetUsername()
    return Player.Name
end

function library:GetUserId()
    return Player.UserId
end

function library:GetPlaceId()
    return game.PlaceId
end

function library:GetJobId()
    return game.JobId
end

function library:Rejoin()
    TeleportService:TeleportToPlaceInstance(self:GetPlaceId(), self:GetJobId(), self:GetUserId())
end

function library:Copy(text)
    if pcall(function() return syn end) then
        syn.write_clipboard(text)
    elseif pcall(function() return setclipboard end) then
        setclipboard(text)
    else
        -- Fallback para Roblox
        local clip = Instance.new("TextBox")
        clip.Text = text
        clip.Parent = CoreGuiService
        clip:CaptureFocus()
        clip:SelectAll()
        clip:ReleaseFocus()
        clip:Destroy()
    end
end

-- Sistema de notificações melhorado
function library:InitNotifications()
    -- Destruir notificações existentes
    for _, v in pairs(CoreGuiService:GetChildren()) do
        if v.Name == "xsxNotifications" then
            v:Destroy()
        end
    end

    local Notifications = Instance.new("ScreenGui")
    Notifications.Name = "xsxNotifications"
    Notifications.Parent = CoreGuiService
    Notifications.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local notificationsLayout = Instance.new("UIListLayout")
    notificationsLayout.Parent = Notifications
    notificationsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notificationsLayout.Padding = UDim.new(0, 4)
    notificationsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notificationsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    local notificationsPadding = Instance.new("UIPadding")
    notificationsPadding.Parent = Notifications
    notificationsPadding.PaddingTop = UDim.new(0, 18)
    notificationsPadding.PaddingRight = UDim.new(0, 18)

    CreateTween("notification_show", 0.2)
    CreateTween("notification_hide", 0.2)
    CreateTween("notification_progress", 5, Enum.EasingStyle.Linear)

    local Notification = {}
    
    function Notification:Notify(title, text, duration, notificationType, callback)
        title = title or "Notificação"
        text = text or ""
        duration = duration or 5
        notificationType = notificationType or "info"
        callback = callback or function() end

        -- Cores baseadas no tipo
        local colors = {
            info = library:GetColor("status", "Info"),
            success = library:GetColor("status", "Success"),
            warning = library:GetColor("status", "Warning"),
            error = library:GetColor("status", "Error")
        }
        local barColor = colors[notificationType] or library:GetColor("primary")

        -- Criar notificação
        local notificationFrame = Instance.new("Frame")
        local notificationCorner = Instance.new("UICorner")
        local notificationBackground = Instance.new("Frame")
        local backgroundCorner = Instance.new("UICorner")
        local backgroundGradient = Instance.new("UIGradient")
        local notificationLayout = Instance.new("UIListLayout")
        local notificationPadding = Instance.new("UIPadding")
        local titleLabel = Instance.new("TextLabel")
        local textLabel = Instance.new("TextLabel")
        local progressBar = Instance.new("Frame")
        local progressCorner = Instance.new("UICorner")
        local progressGradient = Instance.new("UIGradient")

        -- Configurar elementos
        notificationFrame.Name = "notification"
        notificationFrame.Parent = Notifications
        notificationFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        notificationFrame.BackgroundTransparency = 1
        notificationFrame.Size = UDim2.new(0, 300, 0, 0)
        notificationFrame.ClipsDescendants = true

        notificationCorner.CornerRadius = UDim.new(0, 6)
        notificationCorner.Parent = notificationFrame

        notificationBackground.Name = "background"
        notificationBackground.Parent = notificationFrame
        notificationBackground.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        notificationBackground.BackgroundTransparency = 1
        notificationBackground.Size = UDim2.new(1, 0, 1, 0)

        backgroundCorner.CornerRadius = UDim.new(0, 6)
        backgroundCorner.Parent = notificationBackground

        backgroundGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, library:GetColor("background", "dark")),
            ColorSequenceKeypoint.new(1, library:GetColor("background", "light"))
        })
        backgroundGradient.Rotation = 90
        backgroundGradient.Parent = notificationBackground

        notificationLayout.Parent = notificationBackground
        notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
        notificationLayout.Padding = UDim.new(0, 8)

        notificationPadding.Parent = notificationBackground
        notificationPadding.PaddingLeft = UDim.new(0, 12)
        notificationPadding.PaddingRight = UDim.new(0, 12)
        notificationPadding.PaddingTop = UDim.new(0, 12)
        notificationPadding.PaddingBottom = UDim.new(0, 12)

        titleLabel.Name = "title"
        titleLabel.Parent = notificationBackground
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.Code
        titleLabel.Text = title
        titleLabel.TextColor3 = library:GetColor("text", "primary")
        titleLabel.TextSize = 16
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextYAlignment = Enum.TextYAlignment.Top
        titleLabel.Size = UDim2.new(1, 0, 0, 20)

        textLabel.Name = "text"
        textLabel.Parent = notificationBackground
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.Code
        textLabel.Text = text
        textLabel.TextColor3 = library:GetColor("text", "secondary")
        textLabel.TextSize = 14
        textLabel.TextWrapped = true
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top

        -- Calcular altura
        local textSize = TextService:GetTextSize(
            text, 
            14, 
            Enum.Font.Code, 
            Vector2.new(276, math.huge)
        )
        
        local totalHeight = 44 + textSize.Y
        notificationFrame.Size = UDim2.new(0, 300, 0, totalHeight)

        -- Barra de progresso
        progressBar.Name = "progressBar"
        progressBar.Parent = notificationBackground
        progressBar.BackgroundColor3 = barColor
        progressBar.Size = UDim2.new(0, 0, 0, 2)
        progressBar.Position = UDim2.new(0, 0, 1, -2)
        progressBar.AnchorPoint = Vector2.new(0, 1)

        progressCorner.CornerRadius = UDim.new(0, 1)
        progressCorner.Parent = progressBar

        progressGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, barColor),
            ColorSequenceKeypoint.new(1, barColor)
        })
        progressGradient.Parent = progressBar

        -- Animações
        notificationFrame.BackgroundTransparency = 1
        notificationBackground.BackgroundTransparency = 1
        titleLabel.TextTransparency = 1
        textLabel.TextTransparency = 1
        progressBar.BackgroundTransparency = 1

        -- Animação de entrada
        local enterTween = TweenService:Create(
            notificationFrame, 
            TweenTable["notification_show"], 
            {BackgroundTransparency = 0, Size = UDim2.new(0, 300, 0, totalHeight)}
        )
        
        local bgTween = TweenService:Create(
            notificationBackground, 
            TweenTable["notification_show"], 
            {BackgroundTransparency = 0}
        )
        
        local titleTween = TweenService:Create(
            titleLabel, 
            TweenTable["notification_show"], 
            {TextTransparency = 0}
        )
        
        local textTween = TweenService:Create(
            textLabel, 
            TweenTable["notification_show"], 
            {TextTransparency = 0}
        )
        
        local progressTween = TweenService:Create(
            progressBar, 
            TweenTable["notification_show"], 
            {BackgroundTransparency = 0}
        )

        enterTween:Play()
        bgTween:Play()
        titleTween:Play()
        textTween:Play()
        progressTween:Play()

        -- Animação da barra de progresso
        local progressWidthTween = TweenService:Create(
            progressBar, 
            TweenTable["notification_progress"], 
            {Size = UDim2.new(1, 0, 0, 2)}
        )
        
        progressWidthTween:Play()

        -- Remover após duração
        delay(duration, function()
            local exitTween = TweenService:Create(
                notificationFrame, 
                TweenTable["notification_hide"], 
                {BackgroundTransparency = 1, Size = UDim2.new(0, 300, 0, 0)}
            )
            
            exitTween:Play()
            
            exitTween.Completed:Wait()
            notificationFrame:Destroy()
            callback()
        end)

        -- Funções de controle
        local notificationFunctions = {}
        
        function notificationFunctions:Update(newText)
            textLabel.Text = newText
            
            -- Recalcular altura
            local newTextSize = TextService:GetTextSize(
                newText, 
                14, 
                Enum.Font.Code, 
                Vector2.new(276, math.huge)
            )
            
            local newHeight = 44 + newTextSize.Y
            
            TweenService:Create(
                notificationFrame, 
                TweenTable["notification_show"], 
                {Size = UDim2.new(0, 300, 0, newHeight)}
            ):Play()
            
            return self
        end
        
        function notificationFunctions:Close()
            local exitTween = TweenService:Create(
                notificationFrame, 
                TweenTable["notification_hide"], 
                {BackgroundTransparency = 1, Size = UDim2.new(0, 300, 0, 0)}
            )
            
            exitTween:Play()
            
            exitTween.Completed:Wait()
            notificationFrame:Destroy()
            
            return self
        end
        
        function notificationFunctions:ChangeType(newType)
            local colors = {
                info = library:GetColor("status", "Info"),
                success = library:GetColor("status", "Success"),
                warning = library:GetColor("status", "Warning"),
                error = library:GetColor("status", "Error")
            }
            
            local newColor = colors[newType] or library:GetColor("primary")
            
            TweenService:Create(
                progressBar, 
                TweenTable["notification_show"], 
                {BackgroundColor3 = newColor}
            ):Play()
            
            return self
        end
        
        return notificationFunctions
    end
    
    return Notification
end

-- Função para criar UI principal
function library:Init(options)
    options = options or {}
    local toggleKey = options.toggleKey or Enum.KeyCode.RightAlt
    local defaultTitle = options.title or "xsx UI"

    -- Limpar UIs existentes
    for _, v in pairs(CoreGuiService:GetChildren()) do
        if v.Name == "xsxUIMain" then
            v:Destroy()
        end
    end

    -- Criar UI principal
    local screen = Instance.new("ScreenGui")
    screen.Name = "xsxUIMain"
    screen.Parent = CoreGuiService
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "mainFrame"
    mainFrame.Parent = screen
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = library:GetColor("secondary")
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Visible = false

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 6)
    mainCorner.Parent = mainFrame

    -- Background interno
    local innerFrame = Instance.new("Frame")
    innerFrame.Name = "innerFrame"
    innerFrame.Parent = mainFrame
    innerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    innerFrame.BackgroundColor3 = library:GetColor("background", "dark")
    innerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    innerFrame.Size = UDim2.new(1, -4, 1, -4)

    local innerGradient = Instance.new("UIGradient")
    innerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, library:GetColor("background", "dark")),
        ColorSequenceKeypoint.new(1, library:GetColor("background", "light"))
    })
    innerGradient.Rotation = 90
    innerGradient.Parent = innerFrame

    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, 4)
    innerCorner.Parent = innerFrame

    -- Header
    local header = Instance.new("Frame")
    header.Name = "header"
    header.Parent = innerFrame
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 40)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "title"
    titleLabel.Parent = header
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.Code
    titleLabel.Text = defaultTitle
    titleLabel.TextColor3 = library:GetColor("text", "primary")
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)

    -- Barra de separação
    local separator = Instance.new("Frame")
    separator.Name = "separator"
    separator.Parent = innerFrame
    separator.BackgroundColor3 = library:GetColor("primary")
    separator.BorderSizePixel = 0
    separator.Position = UDim2.new(0, 0, 0, 40)
    separator.Size = UDim2.new(1, 0, 0, 2)

    -- Área de conteúdo
    local contentArea = Instance.new("Frame")
    contentArea.Name = "contentArea"
    contentArea.Parent = innerFrame
    contentArea.BackgroundTransparency = 1
    contentArea.Position = UDim2.new(0, 0, 0, 42)
    contentArea.Size = UDim2.new(1, 0, 1, -42)

    -- Sistema de tabs
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "tabContainer"
    tabContainer.Parent = contentArea
    tabContainer.BackgroundTransparency = 1
    tabContainer.Size = UDim2.new(1, 0, 1, 0)

    -- Botões de tab (lateral esquerda)
    local tabButtons = Instance.new("ScrollingFrame")
    tabButtons.Name = "tabButtons"
    tabButtons.Parent = tabContainer
    tabButtons.BackgroundTransparency = 1
    tabButtons.Size = UDim2.new(0, 150, 1, 0)
    tabButtons.ScrollBarThickness = 0
    tabButtons.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local tabButtonsLayout = Instance.new("UIListLayout")
    tabButtonsLayout.Parent = tabButtons
    tabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabButtonsLayout.Padding = UDim.new(0, 4)

    local tabButtonsPadding = Instance.new("UIPadding")
    tabButtonsPadding.Parent = tabButtons
    tabButtonsPadding.PaddingLeft = UDim.new(0, 8)
    tabButtonsPadding.PaddingTop = UDim.new(0, 8)

    -- Conteúdo das tabs
    local tabContent = Instance.new("Frame")
    tabContent.Name = "tabContent"
    tabContent.Parent = tabContainer
    tabContent.BackgroundTransparency = 1
    tabContent.Position = UDim2.new(0, 158, 0, 0)
    tabContent.Size = UDim2.new(1, -158, 1, 0)

    -- Sistema de arrasto
    CreateDrag(mainFrame, 0.04)

    -- Toggle da UI
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == toggleKey then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)

    -- API principal
    local api = {
        _tabs = {},
        _currentTab = nil
    }

    function api:CreateTab(name, icon)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "tab_" .. name
        tabButton.Parent = tabButtons
        tabButton.BackgroundTransparency = 1
        tabButton.Font = Enum.Font.Code
        tabButton.Text = name
        tabButton.TextColor3 = library:GetColor("text", "secondary")
        tabButton.TextSize = 14
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.Size = UDim2.new(1, -16, 0, 30)
        tabButton.AutoButtonColor = false

        local tabContentFrame = Instance.new("ScrollingFrame")
        tabContentFrame.Name = "content_" .. name
        tabContentFrame.Parent = tabContent
        tabContentFrame.BackgroundTransparency = 1
        tabContentFrame.Size = UDim2.new(1, 0, 1, 0)
        tabContentFrame.Visible = false
        tabContentFrame.ScrollBarThickness = 2
        tabContentFrame.ScrollBarImageColor3 = library:GetColor("primary")
        tabContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Parent = tabContentFrame
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 8)

        local contentPadding = Instance.new("UIPadding")
        contentPadding.Parent = tabContentFrame
        contentPadding.PaddingLeft = UDim.new(0, 8)
        contentPadding.PaddingRight = UDim.new(0, 8)
        contentPadding.PaddingTop = UDim.new(0, 8)
        contentPadding.PaddingBottom = UDim.new(0, 8)

        -- Selecionar primeira tab
        if not api._currentTab then
            api._currentTab = name
            tabButton.TextColor3 = library:GetColor("primary")
            tabContentFrame.Visible = true
        end

        -- Evento de clique
        tabButton.MouseButton1Click:Connect(function()
            -- Esconder todas as tabs
            for _, frame in pairs(tabContent:GetChildren()) do
                if frame:IsA("ScrollingFrame") then
                    frame.Visible = false
                end
            end

            -- Resetar cores dos botões
            for _, btn in pairs(tabButtons:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenTable["Default"][1], {
                        TextColor3 = library:GetColor("text", "secondary")
                    }):Play()
                end
            end

            -- Mostrar tab selecionada
            tabContentFrame.Visible = true
            TweenService:Create(tabButton, TweenTable["Default"][1], {
                TextColor3 = library:GetColor("primary")
            }):Play()

            api._currentTab = name
        end)

        -- Efeito hover
        tabButton.MouseEnter:Connect(function()
            if api._currentTab ~= name then
                TweenService:Create(tabButton, TweenTable["Default"][1], {
                    TextColor3 = library:GetColor("text", "primary")
                }):Play()
            end
        end)

        tabButton.MouseLeave:Connect(function()
            if api._currentTab ~= name then
                TweenService:Create(tabButton, TweenTable["Default"][1], {
                    TextColor3 = library:GetColor("text", "secondary")
                }):Play()
            end
        end)

        -- API da tab
        local tabApi = {}

        function tabApi:AddLabel(text)
            local label = Instance.new("TextLabel")
            label.Parent = tabContentFrame
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Code
            label.Text = text
            label.TextColor3 = library:GetColor("text", "primary")
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Size = UDim2.new(1, 0, 0, 20)
            label.TextWrapped = true

            local labelApi = {}
            function labelApi:SetText(newText)
                label.Text = newText
                return self
            end
            return labelApi
        end

        function tabApi:AddButton(text, callback)
            local buttonFrame = Instance.new("Frame")
            buttonFrame.Parent = tabContentFrame
            buttonFrame.BackgroundTransparency = 1
            buttonFrame.Size = UDim2.new(1, 0, 0, 30)

            local button = Instance.new("TextButton")
            button.Parent = buttonFrame
            button.BackgroundColor3 = library:GetColor("secondary")
            button.Size = UDim2.new(1, 0, 1, 0)
            button.Font = Enum.Font.Code
            button.Text = text
            button.TextColor3 = library:GetColor("text", "primary")
            button.TextSize = 14
            button.AutoButtonColor = false

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 4)
            buttonCorner.Parent = button

            -- Efeitos
            button.MouseEnter:Connect(function()
                TweenService:Create(button, TweenTable["Default"][1], {
                    BackgroundColor3 = library:GetColor("primary"),
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                }):Play()
            end)

            button.MouseLeave:Connect(function()
                TweenService:Create(button, TweenTable["Default"][1], {
                    BackgroundColor3 = library:GetColor("secondary"),
                    TextColor3 = library:GetColor("text", "primary")
                }):Play()
            end)

            -- Click
            if callback then
                button.MouseButton1Click:Connect(callback)
            end

            local buttonApi = {}
            function buttonApi:SetText(newText)
                button.Text = newText
                return self
            end
            return buttonApi
        end

        function tabApi:AddToggle(text, defaultValue, callback)
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Parent = tabContentFrame
            toggleFrame.BackgroundTransparency = 1
            toggleFrame.Size = UDim2.new(1, 0, 0, 30)

            local toggleButton = Instance.new("TextButton")
            toggleButton.Parent = toggleFrame
            toggleButton.BackgroundTransparency = 1
            toggleButton.Size = UDim2.new(1, 0, 1, 0)
            toggleButton.Font = Enum.Font.Code
            toggleButton.Text = ""
            toggleButton.AutoButtonColor = false

            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Parent = toggleButton
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Font = Enum.Font.Code
            toggleLabel.Text = text
            toggleLabel.TextColor3 = library:GetColor("text", "primary")
            toggleLabel.TextSize = 14
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Size = UDim2.new(1, -40, 1, 0)

            local toggleSwitch = Instance.new("Frame")
            toggleSwitch.Parent = toggleButton
            toggleSwitch.BackgroundColor3 = library:GetColor("secondary")
            toggleSwitch.Size = UDim2.new(0, 40, 0, 20)
            toggleSwitch.Position = UDim2.new(1, -45, 0.5, -10)
            toggleSwitch.AnchorPoint = Vector2.new(1, 0.5)

            local switchCorner = Instance.new("UICorner")
            switchCorner.CornerRadius = UDim.new(1, 0)
            switchCorner.Parent = toggleSwitch

            local toggleDot = Instance.new("Frame")
            toggleDot.Parent = toggleSwitch
            toggleDot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            toggleDot.Size = UDim2.new(0, 16, 0, 16)
            toggleDot.Position = UDim2.new(0, 2, 0.5, -8)
            toggleDot.AnchorPoint = Vector2.new(0, 0.5)

            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = toggleDot

            local state = defaultValue or false

            -- Atualizar visual baseado no estado
            local function updateVisual()
                if state then
                    TweenService:Create(toggleSwitch, TweenTable["Default"][1], {
                        BackgroundColor3 = library:GetColor("primary")
                    }):Play()
                    
                    TweenService:Create(toggleDot, TweenTable["Default"][1], {
                        Position = UDim2.new(1, -18, 0.5, -8),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    }):Play()
                else
                    TweenService:Create(toggleSwitch, TweenTable["Default"][1], {
                        BackgroundColor3 = library:GetColor("secondary")
                    }):Play()
                    
                    TweenService:Create(toggleDot, TweenTable["Default"][1], {
                        Position = UDim2.new(0, 2, 0.5, -8),
                        BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                    }):Play()
                end
            end

            updateVisual()

            -- Click
            toggleButton.MouseButton1Click:Connect(function()
                state = not state
                updateVisual()
                if callback then
                    callback(state)
                end
            end)

            -- Efeito hover
            toggleButton.MouseEnter:Connect(function()
                TweenService:Create(toggleLabel, TweenTable["Default"][1], {
                    TextColor3 = library:GetColor("primary")
                }):Play()
            end)

            toggleButton.MouseLeave:Connect(function()
                TweenService:Create(toggleLabel, TweenTable["Default"][1], {
                    TextColor3 = library:GetColor("text", "primary")
                }):Play()
            end)

            local toggleApi = {}
            function toggleApi:SetState(newState)
                state = newState
                updateVisual()
                return self
            end
            
            function toggleApi:GetState()
                return state
            end
            
            return toggleApi
        end

        -- Adicione mais componentes conforme necessário...

        return tabApi
    end

    -- Mostrar UI
    CreateTween("ui_show", 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    function api:Show()
        mainFrame.Visible = true
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, -50)
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        
        TweenService:Create(mainFrame, TweenTable["ui_show"], {
            Size = UDim2.new(0, 600, 0, 400),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
    end

    function api:Hide()
        TweenService:Create(mainFrame, TweenTable["Default"][1], {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, -50)
        }):Play()
        
        wait(0.2)
        mainFrame.Visible = false
    end

    function api:Destroy()
        screen:Destroy()
    end

    return api
end

return library