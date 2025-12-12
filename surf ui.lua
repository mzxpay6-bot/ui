--[[
    GGMenu Premium v3.0 - UI Library Roblox
    Com design moderno, tabs, drag, minimize, fechar, watermark
    Sistema de configurações salvas, efeitos visuais premium
]]

local Library = {}
Library.__index = Library

-- Services
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Cores do tema
local Theme = {
    Primary = Color3.fromRGB(0, 140, 255),
    Secondary = Color3.fromRGB(30, 30, 30),
    Background = Color3.fromRGB(18, 18, 18),
    Dark = Color3.fromRGB(12, 12, 12),
    Light = Color3.fromRGB(240, 240, 240),
    Success = Color3.fromRGB(40, 200, 80),
    Warning = Color3.fromRGB(255, 180, 40),
    Danger = Color3.fromRGB(255, 60, 60),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180)
}

-- Funções úteis
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        if prop ~= "Parent" then
            if type(value) == "table" and value.__instance then
                value.Parent = instance
            else
                instance[prop] = value
            end
        end
    end
    return instance
end

local function Tween(object, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tween = TS:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Sistema de notificações
local Notifications = {}
function Notifications:Show(title, message, color)
    if not Library.NotificationHolder then
        Library.NotificationHolder = CreateInstance("Frame", {
            Parent = CoreGui,
            Name = "NotificationHolder",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 300, 1, 0),
            Position = UDim2.new(1, -320, 0, 10),
            ZIndex = 100
        })
        
        CreateInstance("UIListLayout", {
            Parent = Library.NotificationHolder,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
    end
    
    local notification = CreateInstance("Frame", {
        Parent = Library.NotificationHolder,
        BackgroundColor3 = Theme.Dark,
        Size = UDim2.new(1, 0, 0, 80),
        Position = UDim2.new(1, 0, 0, 0),
        ZIndex = 101,
        LayoutOrder = #Library.NotificationHolder:GetChildren()
    })
    
    CreateInstance("UICorner", {
        Parent = notification,
        CornerRadius = UDim.new(0, 8)
    })
    
    CreateInstance("UIStroke", {
        Parent = notification,
        Color = color or Theme.Primary,
        Thickness = 2
    })
    
    -- Glow effect
    local glow = CreateInstance("ImageLabel", {
        Parent = notification,
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://8992230671",
        ImageColor3 = color or Theme.Primary,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(100, 100, 400, 400),
        ZIndex = 100
    })
    
    local accent = CreateInstance("Frame", {
        Parent = notification,
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = color or Theme.Primary,
        BorderSizePixel = 0
    })
    
    CreateInstance("UICorner", {
        Parent = accent,
        CornerRadius = UDim.new(0, 8, 0, 0)
    })
    
    local titleLabel = CreateInstance("TextLabel", {
        Parent = notification,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102
    })
    
    local messageLabel = CreateInstance("TextLabel", {
        Parent = notification,
        Size = UDim2.new(1, -20, 1, -30),
        Position = UDim2.new(0, 10, 0, 25),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 102
    })
    
    -- Animar entrada
    Tween(notification, {Position = UDim2.new(0, 0, 0, notification.Position.Y.Offset)})
    
    -- Auto remover após 5 segundos
    task.spawn(function()
        task.wait(5)
        Tween(notification, {
            Position = UDim2.new(1, 0, 0, notification.Position.Y.Offset),
            BackgroundTransparency = 1
        })
        task.wait(0.3)
        notification:Destroy()
    end)
    
    return notification
end

-- Função principal para criar janela
function Library:CreateWindow(title, config)
    local Window = {}
    setmetatable(Window, self)
    
    -- Configurações padrão
    config = config or {}
    local savedPosition = config.SavedPosition
    
    -- Criar GUI principal
    local MainGUI = CreateInstance("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenuPremium",
        IgnoreGuiInset = true,
        ResetOnSpawn = false
    })
    
    -- Container principal
    local MainContainer = CreateInstance("Frame", {
        Parent = MainGUI,
        Name = "MainContainer",
        Size = UDim2.new(0, 650, 0, 450),
        Position = savedPosition or UDim2.new(0.5, -325, 0.5, -225),
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = true
    })
    
    -- Corner e stroke
    CreateInstance("UICorner", {
        Parent = MainContainer,
        CornerRadius = UDim.new(0, 12)
    })
    
    local MainStroke = CreateInstance("UIStroke", {
        Parent = MainContainer,
        Color = Theme.Primary,
        Thickness = 1.5,
        Transparency = 0.8
    })
    
    -- Drop shadow
    local Shadow = CreateInstance("ImageLabel", {
        Parent = MainContainer,
        Image = "rbxassetid://8992230671",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(100, 100, 400, 400),
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        ZIndex = -1
    })
    
    -- Header
    local Header = CreateInstance("Frame", {
        Parent = MainContainer,
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Theme.Dark,
        BorderSizePixel = 0
    })
    
    CreateInstance("UICorner", {
        Parent = Header,
        CornerRadius = UDim.new(0, 12, 0, 0)
    })
    
    local TitleLabel = CreateInstance("TextLabel", {
        Parent = Header,
        Size = UDim2.new(0.5, -10, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = "  " .. (title or "GGMenu Premium"),
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local VersionLabel = CreateInstance("TextLabel", {
        Parent = Header,
        Size = UDim2.new(0.5, -10, 1, 0),
        Position = UDim2.new(0.5, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "v3.0 ",
        TextColor3 = Theme.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    -- Botões do header
    local ButtonContainer = CreateInstance("Frame", {
        Parent = Header,
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(1, -125, 0, 0),
        BackgroundTransparency = 1
    })
    
    local function CreateHeaderButton(text, color, callback)
        local button = CreateInstance("TextButton", {
            Parent = ButtonContainer,
            Size = UDim2.new(0, 35, 0, 35),
            Position = UDim2.new(1, -40 * (#ButtonContainer:GetChildren() + 1), 0.5, -17.5),
            BackgroundColor3 = color,
            Text = text,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            AutoButtonColor = false
        })
        
        CreateInstance("UICorner", {
            Parent = button,
            CornerRadius = UDim.new(0, 8)
        })
        
        button.MouseEnter:Connect(function()
            Tween(button, {BackgroundColor3 = Color3.fromRGB(
                math.floor(color.R * 255 * 0.8),
                math.floor(color.G * 255 * 0.8),
                math.floor(color.B * 255 * 0.8)
            )})
        end)
        
        button.MouseLeave:Connect(function()
            Tween(button, {BackgroundColor3 = color})
        end)
        
        button.MouseButton1Click:Connect(callback)
        
        return button
    end
    
    -- Botão minimizar
    local isMinimized = false
    local originalSize = MainContainer.Size
    local minimizedSize = UDim2.new(0, 650, 0, 45)
    
    CreateHeaderButton("-", Theme.Secondary, function()
        isMinimized = not isMinimized
        if isMinimized then
            Tween(MainContainer, {Size = minimizedSize})
            Tween(TabContainer, {BackgroundTransparency = 1})
            Tween(ContentContainer, {BackgroundTransparency = 1})
        else
            Tween(MainContainer, {Size = originalSize})
            Tween(TabContainer, {BackgroundTransparency = 0})
            Tween(ContentContainer, {BackgroundTransparency = 0})
        end
    end)
    
    -- Botão fechar
    CreateHeaderButton("×", Color3.fromRGB(200, 50, 50), function()
        Tween(MainContainer, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        Tween(MainContainer, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        MainGUI:Destroy()
    end)
    
    -- Sistema de drag
    local dragging = false
    local dragStart, startPos
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainContainer.Position
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainContainer.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Container de tabs e conteúdo
    local TabContainer = CreateInstance("Frame", {
        Parent = MainContainer,
        Name = "TabContainer",
        Size = UDim2.new(0, 180, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = Theme.Dark,
        BorderSizePixel = 0
    })
    
    local ContentContainer = CreateInstance("Frame", {
        Parent = MainContainer,
        Name = "ContentContainer",
        Size = UDim2.new(1, -180, 1, -45),
        Position = UDim2.new(0, 180, 0, 45),
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = true
    })
    
    -- Lista para tabs
    local TabList = CreateInstance("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    CreateInstance("UIPadding", {
        Parent = TabContainer,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5)
    })
    
    -- Lista para conteúdo das tabs
    local ContentList = CreateInstance("UIListLayout", {
        Parent = ContentContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    CreateInstance("UIPadding", {
        Parent = ContentContainer,
        PaddingTop = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15)
    })
    
    -- Scroll para conteúdo
    local ContentScrolling = CreateInstance("ScrollingFrame", {
        Parent = ContentContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Primary,
        ScrollBarImageTransparency = 0.5,
        BorderSizePixel = 0
    })
    
    ContentList.Parent = ContentScrolling
    CreateInstance("UIPadding", {
        Parent = ContentScrolling,
        PaddingTop = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15)
    })
    
    -- Watermark
    local Watermark = CreateInstance("Frame", {
        Parent = MainGUI,
        Size = UDim2.new(0, 300, 0, 28),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Theme.Dark,
        ZIndex = 100
    })
    
    CreateInstance("UICorner", {
        Parent = Watermark,
        CornerRadius = UDim.new(0, 8)
    })
    
    CreateInstance("UIStroke", {
        Parent = Watermark,
        Color = Theme.Primary,
        Thickness = 1
    })
    
    local WatermarkLabel = CreateInstance("TextLabel", {
        Parent = Watermark,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Code,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Atualizar watermark
    task.spawn(function()
        while MainGUI.Parent do
            local fps = math.floor(1 / RS.RenderStepped:Wait())
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
            local time = os.date("%H:%M:%S")
            
            WatermarkLabel.Text = string.format("GGMenu | %s | FPS: %d | Ping: %dms", 
                Players.LocalPlayer.Name, fps, math.floor(ping))
            
            RS.RenderStepped:Wait()
        end
    end)
    
    -- Sistema de tabs
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    function Window:CreateTab(name, icon)
        local Tab = {}
        Tab.Name = name
        Tab.Elements = {}
        
        -- Botão da tab
        local TabButton = CreateInstance("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(1, -10, 0, 40),
            BackgroundColor3 = Theme.Secondary,
            Text = "  " .. name,
            TextColor3 = Theme.TextSecondary,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false
        })
        
        CreateInstance("UICorner", {
            Parent = TabButton,
            CornerRadius = UDim.new(0, 8)
        })
        
        -- Página da tab
        local TabPage = CreateInstance("ScrollingFrame", {
            Parent = ContentScrolling,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Primary
        })
        
        CreateInstance("UIListLayout", {
            Parent = TabPage,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        
        CreateInstance("UIPadding", {
            Parent = TabPage,
            PaddingTop = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5)
        })
        
        Tab.Button = TabButton
        Tab.Page = TabPage
        
        -- Selecionar primeira tab
        if #Window.Tabs == 0 then
            TabButton.BackgroundColor3 = Theme.Primary
            TabButton.TextColor3 = Theme.Text
            TabPage.Visible = true
            Window.CurrentTab = Tab
        end
        
        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab == Tab then return end
            
            -- Desselecionar tab atual
            if Window.CurrentTab then
                Tween(Window.CurrentTab.Button, {
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.TextSecondary
                })
                Window.CurrentTab.Page.Visible = false
            end
            
            -- Selecionar nova tab
            Window.CurrentTab = Tab
            Tween(TabButton, {
                BackgroundColor3 = Theme.Primary,
                TextColor3 = Theme.Text
            })
            TabPage.Visible = true
        end)
        
        -- Efeito hover
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Theme.Secondary})
            end
        end)
        
        -- Elementos da tab
        function Tab:CreateSection(title)
            local Section = {}
            
            local SectionFrame = CreateInstance("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Theme.Dark,
                LayoutOrder = #TabPage:GetChildren()
            })
            
            CreateInstance("UICorner", {
                Parent = SectionFrame,
                CornerRadius = UDim.new(0, 6)
            })
            
            CreateInstance("UIStroke", {
                Parent = SectionFrame,
                Color = Theme.Primary,
                Thickness = 1,
                Transparency = 0.5
            })
            
            local SectionTitle = CreateInstance("TextLabel", {
                Parent = SectionFrame,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            Section.Frame = SectionFrame
            Section.Content = CreateInstance("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                LayoutOrder = #TabPage:GetChildren()
            })
            
            CreateInstance("UIListLayout", {
                Parent = Section.Content,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            
            CreateInstance("UIPadding", {
                Parent = Section.Content,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10)
            })
            
            function Section:CreateToggle(name, default, callback)
                local Toggle = {}
                Toggle.Value = default or false
                
                local ToggleFrame = CreateInstance("Frame", {
                    Parent = self.Content,
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Theme.Secondary,
                    LayoutOrder = #self.Content:GetChildren()
                })
                
                CreateInstance("UICorner", {
                    Parent = ToggleFrame,
                    CornerRadius = UDim.new(0, 6)
                })
                
                local ToggleLabel = CreateInstance("TextLabel", {
                    Parent = ToggleFrame,
                    Size = UDim2.new(0.7, -10, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ToggleButton = CreateInstance("Frame", {
                    Parent = ToggleFrame,
                    Size = UDim2.new(0, 50, 0, 25),
                    Position = UDim2.new(1, -65, 0.5, -12.5),
                    BackgroundColor3 = default and Theme.Success or Color3.fromRGB(60, 60, 60),
                    BackgroundTransparency = 0.2
                })
                
                CreateInstance("UICorner", {
                    Parent = ToggleButton,
                    CornerRadius = UDim.new(1, 0)
                })
                
                local ToggleCircle = CreateInstance("Frame", {
                    Parent = ToggleButton,
                    Size = UDim2.new(0, 21, 0, 21),
                    Position = default and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5),
                    BackgroundColor3 = Theme.Text,
                    AnchorPoint = Vector2.new(0, 0.5)
                })
                
                CreateInstance("UICorner", {
                    Parent = ToggleCircle,
                    CornerRadius = UDim.new(1, 0)
                })
                
                ToggleFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Toggle.Value = not Toggle.Value
                        
                        if Toggle.Value then
                            Tween(ToggleButton, {BackgroundColor3 = Theme.Success})
                            Tween(ToggleCircle, {Position = UDim2.new(1, -23, 0.5, -10.5)})
                        else
                            Tween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)})
                            Tween(ToggleCircle, {Position = UDim2.new(0, 2, 0.5, -10.5)})
                        end
                        
                        if callback then
                            callback(Toggle.Value)
                        end
                    end
                end)
                
                -- Efeito hover
                ToggleFrame.MouseEnter:Connect(function()
                    Tween(ToggleFrame, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)})
                end)
                
                ToggleFrame.MouseLeave:Connect(function()
                    Tween(ToggleFrame, {BackgroundColor3 = Theme.Secondary})
                end)
                
                return Toggle
            end
            
            function Section:CreateButton(name, callback)
                local ButtonFrame = CreateInstance("TextButton", {
                    Parent = self.Content,
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundColor3 = Theme.Secondary,
                    Text = "",
                    AutoButtonColor = false,
                    LayoutOrder = #self.Content:GetChildren()
                })
                
                CreateInstance("UICorner", {
                    Parent = ButtonFrame,
                    CornerRadius = UDim.new(0, 6)
                })
                
                local ButtonLabel = CreateInstance("TextLabel", {
                    Parent = ButtonFrame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14
                })
                
                -- Efeito hover
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.Primary})
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.Secondary})
                end)
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    if callback then
                        callback()
                    end
                end)
                
                return ButtonFrame
            end
            
            function Section:CreateSlider(name, min, max, default, callback)
                local Slider = {}
                Slider.Value = default or min
                
                local SliderFrame = CreateInstance("Frame", {
                    Parent = self.Content,
                    Size = UDim2.new(1, 0, 0, 60),
                    BackgroundTransparency = 1,
                    LayoutOrder = #self.Content:GetChildren()
                })
                
                local SliderLabel = CreateInstance("TextLabel", {
                    Parent = SliderFrame,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local SliderValue = CreateInstance("TextLabel", {
                    Parent = SliderFrame,
                    Size = UDim2.new(0, 60, 0, 20),
                    Position = UDim2.new(1, -60, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(default or min),
                    TextColor3 = Theme.Primary,
                    Font = Enum.Font.Code,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local SliderTrack = CreateInstance("Frame", {
                    Parent = SliderFrame,
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 30),
                    BackgroundColor3 = Theme.Dark
                })
                
                CreateInstance("UICorner", {
                    Parent = SliderTrack,
                    CornerRadius = UDim.new(1, 0)
                })
                
                local SliderFill = CreateInstance("Frame", {
                    Parent = SliderTrack,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Theme.Primary,
                    BorderSizePixel = 0
                })
                
                CreateInstance("UICorner", {
                    Parent = SliderFill,
                    CornerRadius = UDim.new(1, 0)
                })
                
                local SliderThumb = CreateInstance("Frame", {
                    Parent = SliderTrack,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
                    BackgroundColor3 = Theme.Text,
                    AnchorPoint = Vector2.new(0.5, 0.5)
                })
                
                CreateInstance("UICorner", {
                    Parent = SliderThumb,
                    CornerRadius = UDim.new(1, 0)
                })
                
                local dragging = false
                
                local function updateValue(x)
                    local relativeX = math.clamp((x - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * relativeX)
                    
                    Slider.Value = value
                    SliderValue.Text = tostring(value)
                    SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                    SliderThumb.Position = UDim2.new(relativeX, 0, 0.5, 0)
                    
                    if callback then
                        callback(value)
                    end
                end
                
                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateValue(input.Position.X)
                    end
                end)
                
                UIS.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateValue(input.Position.X)
                    end
                end)
                
                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                return Slider
            end
            
            function Section:CreateDropdown(name, options, default, callback)
                local Dropdown = {}
                Dropdown.Open = false
                Dropdown.Value = default or options[1]
                
                local DropdownFrame = CreateInstance("Frame", {
                    Parent = self.Content,
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = Theme.Secondary,
                    LayoutOrder = #self.Content:GetChildren(),
                    ClipsDescendants = true
                })
                
                CreateInstance("UICorner", {
                    Parent = DropdownFrame,
                    CornerRadius = UDim.new(0, 6)
                })
                
                local DropdownLabel = CreateInstance("TextLabel", {
                    Parent = DropdownFrame,
                    Size = UDim2.new(0.7, -10, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local CurrentValue = CreateInstance("TextLabel", {
                    Parent = DropdownFrame,
                    Size = UDim2.new(0.3, -30, 1, 0),
                    Position = UDim2.new(0.7, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = default or options[1],
                    TextColor3 = Theme.Primary,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local Arrow = CreateInstance("TextLabel", {
                    Parent = DropdownFrame,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -25, 0.5, -10),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = Theme.TextSecondary,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12
                })
                
                local OptionsFrame = CreateInstance("Frame", {
                    Parent = DropdownFrame,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 5),
                    BackgroundColor3 = Theme.Dark,
                    Visible = false
                })
                
                CreateInstance("UICorner", {
                    Parent = OptionsFrame,
                    CornerRadius = UDim.new(0, 6)
                })
                
                CreateInstance("UIStroke", {
                    Parent = OptionsFrame,
                    Color = Theme.Primary,
                    Thickness = 1
                })
                
                local OptionsList = CreateInstance("UIListLayout", {
                    Parent = OptionsFrame,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                for i, option in ipairs(options) do
                    local OptionButton = CreateInstance("TextButton", {
                        Parent = OptionsFrame,
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = Theme.Secondary,
                        Text = option,
                        TextColor3 = Theme.TextSecondary,
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        AutoButtonColor = false
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)})
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = Theme.Secondary})
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        Dropdown.Value = option
                        CurrentValue.Text = option
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
                        OptionsFrame.Visible = false
                        Tween(Arrow, {Rotation = 0})
                        
                        if callback then
                            callback(option)
                        end
                    end)
                end
                
                DropdownFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dropdown.Open = not Dropdown.Open
                        
                        if Dropdown.Open then
                            local optionCount = #options
                            DropdownFrame.Size = UDim2.new(1, 0, 0, 35 + (optionCount * 30) + 10)
                            OptionsFrame.Size = UDim2.new(1, 0, 0, optionCount * 30)
                            OptionsFrame.Visible = true
                            Tween(Arrow, {Rotation = 180})
                        else
                            DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
                            OptionsFrame.Visible = false
                            Tween(Arrow, {Rotation = 0})
                        end
                    end
                end)
                
                return Dropdown
            end
            
            function Section:CreateLabel(text)
                local LabelFrame = CreateInstance("Frame", {
                    Parent = self.Content,
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1,
                    LayoutOrder = #self.Content:GetChildren()
                })
                
                local Label = CreateInstance("TextLabel", {
                    Parent = LabelFrame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.TextSecondary,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                return Label
            end
            
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end
    
    -- Botão de toggle da UI (tecla Insert)
    local uiVisible = true
    UIS.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.Insert then
            uiVisible = not uiVisible
            MainGUI.Enabled = uiVisible
            Notifications:Show("GGMenu", uiVisible and "Interface ativada" or "Interface desativada", 
                uiVisible and Theme.Success or Theme.Warning)
        end
    end)
    
    -- Notificação de boas-vindas
    task.spawn(function()
        task.wait(0.5)
        Notifications:Show("GGMenu Premium", "Bem-vindo! Pressione Insert para mostrar/esconder", Theme.Primary)
    end)
    
    return Window
end

return Library