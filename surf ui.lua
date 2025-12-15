--[[
  UI Library otimizada - Versão compacta
  Baseada no código original de Depso/Bungie
]]

-- Variáveis globais
local Services = setmetatable({}, {
    __index = function(_, name) return game:GetService(name) end
})

local Players, UserInputService, TweenService, RunService = Services.Players, Services.UserInputService, Services.TweenService, Services.RunService
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local CoreGui = Services.CoreGui

-- Configuração principal
local library = {
    title = "Depso UI",
    company = "Depso",
    Key = Enum.KeyCode.RightShift,
    transparency = 0,
    backgroundColor = Color3.fromRGB(31, 31, 31),
    acientColor = Color3.fromRGB(167, 154, 121),
    darkGray = Color3.fromRGB(27, 27, 27),
    lightGray = Color3.fromRGB(48, 48, 48),
    Font = Enum.Font.Code,
    fontScale = 0.9, -- Novo: Escala para reduzir tamanho dos elementos
    compactMode = true -- Novo: Modo compacto ativado
}

-- Cache de instâncias para performance
local InstanceCache = {}

local function Create(cls, props)
    local obj = Instance.new(cls)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

-- Sistema de tween otimizado
local TweenInfo = TweenInfo.new
local Tweens = {
    Default = TweenInfo(0.15, Enum.EasingStyle.Sine),
    Fast = TweenInfo(0.08, Enum.EasingStyle.Linear),
    Tab = TweenInfo(0.1, Enum.EasingStyle.Sine)
}

local function ScaleValue(base)
    return library.compactMode and math.floor(base * library.fontScale) or base
end

-- Funções utilitárias
local Utils = {}

function Utils:CreateGradient(parent)
    local gradient = Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 34, 34)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 28, 28))
        },
        Rotation = 90,
        Parent = parent
    })
    return gradient
end

function Utils:CreateRoundedFrame(props)
    local frame = Create("Frame", props)
    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = frame})
    return frame
end

function Utils:CreateStroke(parent, color, thickness)
    return Create("UIStroke", {
        Parent = parent,
        Color = color or library.lightGray,
        Thickness = thickness or 1
    })
end

-- Função de arrasto otimizada
local function EnableDrag(obj)
    local dragging, dragInput, dragStart, startPos
    local dragSpeed = 0.1
    
    local function update(input)
        local delta = input.Position - dragStart
        TweenService:Create(obj, Tweens.Fast, {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                               startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
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
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            update(input)
        end
    end)
end

-- Inicialização principal
function library:Init(config)
    -- Aplicar configurações
    for k, v in pairs(config or {}) do self[k] = v end
    
    -- Criar interface principal
    local screen = Create("ScreenGui", {
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Frame principal (tamanho reduzido)
    local mainFrame = Utils:CreateRoundedFrame({
        Parent = screen,
        BackgroundColor3 = self.backgroundColor,
        BackgroundTransparency = self.transparency,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, ScaleValue(500), 0, ScaleValue(350)), -- Reduzido
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true
    })
    
    EnableDrag(mainFrame)
    Utils:CreateStroke(mainFrame)
    Utils:CreateGradient(mainFrame)
    
    -- Barra superior
    local topBar = Create("Frame", {
        Parent = mainFrame,
        BackgroundColor3 = self.darkGray,
        Size = UDim2.new(1, 0, 0, ScaleValue(25)), -- Reduzido
        BorderSizePixel = 0
    })
    
    Create("UIStroke", {
        Parent = topBar,
        Color = self.lightGray,
        Thickness = 1
    })
    
    local title = Create("TextLabel", {
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, ScaleValue(8), 0, 0),
        Size = UDim2.new(1, -ScaleValue(16), 1, 0),
        Font = self.Font,
        Text = self.title,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = ScaleValue(14), -- Reduzido
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true
    })
    
    -- Barra colorida
    local accentBar = Create("Frame", {
        Parent = mainFrame,
        BackgroundColor3 = self.acientColor,
        Position = UDim2.new(0, 0, 0, ScaleValue(25)),
        Size = UDim2.new(1, 0, 0, ScaleValue(2)),
        BorderSizePixel = 0
    })
    
    -- Container para abas e conteúdo
    local container = Create("Frame", {
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, ScaleValue(27)),
        Size = UDim2.new(1, 0, 1, -ScaleValue(27))
    })
    
    -- Painel de abas (lateral reduzida)
    local tabPanel = Create("Frame", {
        Parent = container,
        BackgroundColor3 = self.darkGray,
        Position = UDim2.new(0, ScaleValue(8), 0, ScaleValue(8)),
        Size = UDim2.new(0, ScaleValue(120), 1, -ScaleValue(40)), -- Reduzido
        ClipsDescendants = true
    })
    
    Utils:CreateStroke(tabPanel)
    Utils:CreateGradient(tabPanel)
    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = tabPanel})
    
    local tabList = Create("UIListLayout", {
        Parent = tabPanel,
        Padding = UDim.new(0, ScaleValue(4)),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local tabPadding = Create("UIPadding", {
        Parent = tabPanel,
        PaddingTop = UDim.new(0, ScaleValue(4)),
        PaddingLeft = UDim.new(0, ScaleValue(4))
    })
    
    -- Container de conteúdo
    local contentFrame = Create("Frame", {
        Parent = container,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, ScaleValue(136), 0, ScaleValue(8)), -- Ajustado
        Size = UDim2.new(1, -ScaleValue(144), 1, -ScaleValue(40)), -- Ajustado
        ClipsDescendants = true
    })
    
    -- Botão de pânico
    local panicBtn = Create("TextButton", {
        Parent = mainFrame,
        Text = "Panic",
        BackgroundColor3 = self.darkGray,
        BackgroundTransparency = self.transparency,
        Position = UDim2.new(0, ScaleValue(8), 1, -ScaleValue(28)),
        Size = UDim2.new(0, ScaleValue(120), 0, ScaleValue(22)), -- Reduzido
        Font = self.Font,
        TextColor3 = Color3.fromRGB(190, 190, 190),
        TextSize = ScaleValue(13), -- Reduzido
        AutoButtonColor = false
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = panicBtn})
    Utils:CreateStroke(panicBtn)
    
    -- Armazenar elementos
    self.mainFrame = mainFrame
    self.tabPanel = tabPanel
    self.contentFrame = contentFrame
    self.currentTab = nil
    self.tabs = {}
    
    -- Toggle da interface
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.Key then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
    
    -- Sistema de abas
    function self:NewTab(name)
        name = name or "Tab"
        
        -- Botão da aba
        local tabBtn = Create("TextButton", {
            Parent = tabPanel,
            Text = name,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -ScaleValue(8), 0, ScaleValue(20)), -- Reduzido
            Font = self.Font,
            TextColor3 = Color3.fromRGB(170, 170, 170),
            TextSize = ScaleValue(13), -- Reduzido
            AutoButtonColor = false
        })
        
        -- Conteúdo da aba
        local tabContent = Create("ScrollingFrame", {
            Parent = contentFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 1,
            ScrollBarImageColor3 = self.acientColor,
            Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        local contentList = Create("UIListLayout", {
            Parent = tabContent,
            Padding = UDim.new(0, ScaleValue(4)),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        local contentPadding = Create("UIPadding", {
            Parent = tabContent,
            PaddingTop = UDim.new(0, ScaleValue(4)),
            PaddingLeft = UDim.new(0, ScaleValue(4))
        })
        
        -- Selecionar primeira aba
        if not self.currentTab then
            tabContent.Visible = true
            tabBtn.TextColor3 = self.acientColor
            self.currentTab = name
        end
        
        -- Evento de clique
        tabBtn.MouseButton1Click:Connect(function()
            self.currentTab = name
            
            -- Esconder todas as abas
            for _, content in pairs(self.tabs) do
                content.Visible = false
            end
            
            -- Mostrar aba atual
            tabContent.Visible = true
            
            -- Atualizar cores dos botões
            for btnName, btn in pairs(self.tabPanel:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, Tweens.Tab, {
                        TextColor3 = Color3.fromRGB(170, 170, 170)
                    }):Play()
                end
            end
            
            TweenService:Create(tabBtn, Tweens.Tab, {
                TextColor3 = self.acientColor
            }):Play()
        end)
        
        -- Armazenar referências
        self.tabs[name] = tabContent
        
        -- Sistema de elementos da aba
        local Elements = {}
        
        -- Toggle simples
        function Elements:Toggle(text, default, callback)
            local toggleFrame = Create("Frame", {
                Parent = tabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -ScaleValue(8), 0, ScaleValue(20)) -- Reduzido
            })
            
            local toggleBtn = Create("TextButton", {
                Parent = toggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                AutoButtonColor = false
            })
            
            local toggleBox = Utils:CreateRoundedFrame({
                Parent = toggleFrame,
                BackgroundColor3 = self.darkGray,
                BackgroundTransparency = self.transparency,
                Size = UDim2.new(0, ScaleValue(16), 0, ScaleValue(16)) -- Reduzido
            })
            
            Utils:CreateStroke(toggleBox)
            
            local toggleIndicator = Create("Frame", {
                Parent = toggleBox,
                BackgroundColor3 = self.acientColor,
                BackgroundTransparency = default and 0 or 1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = default and UDim2.new(0, ScaleValue(10), 0, ScaleValue(10)) or UDim2.new(0, 0, 0, 0),
                AnchorPoint = Vector2.new(0.5, 0.5)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 2),
                Parent = toggleIndicator
            })
            
            local toggleLabel = Create("TextLabel", {
                Parent = toggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, ScaleValue(24), 0, 0),
                Size = UDim2.new(1, -ScaleValue(24), 1, 0),
                Font = self.Font,
                Text = text,
                TextColor3 = Color3.fromRGB(190, 190, 190),
                TextSize = ScaleValue(13), -- Reduzido
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            -- Evento de toggle
            local state = default or false
            toggleBtn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(toggleIndicator, Tweens.Fast, {
                    BackgroundTransparency = state and 0 or 1,
                    Size = state and UDim2.new(0, ScaleValue(10), 0, ScaleValue(10)) or UDim2.new(0, 0, 0, 0)
                }):Play()
                
                if callback then callback(state) end
            end)
            
            -- Interface de controle
            local Control = {}
            function Control:Set(value)
                state = value
                TweenService:Create(toggleIndicator, Tweens.Fast, {
                    BackgroundTransparency = state and 0 or 1,
                    Size = state and UDim2.new(0, ScaleValue(10), 0, ScaleValue(10)) or UDim2.new(0, 0, 0, 0)
                }):Play()
                
                if callback then callback(state) end
                return Control
            end
            
            function Control:Get()
                return state
            end
            
            return Control
        end
        
        -- Botão simples
        function Elements:Button(text, callback)
            local button = Create("TextButton", {
                Parent = tabContent,
                Text = text,
                BackgroundColor3 = self.darkGray,
                BackgroundTransparency = self.transparency,
                Size = UDim2.new(1, -ScaleValue(8), 0, ScaleValue(22)), -- Reduzido
                Font = self.Font,
                TextColor3 = Color3.fromRGB(190, 190, 190),
                TextSize = ScaleValue(13), -- Reduzido
                AutoButtonColor = false
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = button})
            Utils:CreateStroke(button)
            
            -- Efeitos hover
            button.MouseEnter:Connect(function()
                TweenService:Create(button, Tweens.Fast, {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                }):Play()
            end)
            
            button.MouseLeave:Connect(function()
                TweenService:Create(button, Tweens.Fast, {
                    BackgroundColor3 = self.darkGray
                }):Play()
            end)
            
            -- Clique
            button.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            
            return button
        end
        
        -- Slider otimizado
        function Elements:Slider(text, min, max, default, callback)
            local sliderFrame = Create("Frame", {
                Parent = tabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -ScaleValue(8), 0, ScaleValue(40)) -- Reduzido
            })
            
            local label = Create("TextLabel", {
                Parent = sliderFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ScaleValue(18)), -- Reduzido
                Font = self.Font,
                Text = text,
                TextColor3 = Color3.fromRGB(190, 190, 190),
                TextSize = ScaleValue(13), -- Reduzido
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local valueLabel = Create("TextLabel", {
                Parent = sliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, ScaleValue(18)),
                Size = UDim2.new(1, 0, 0, ScaleValue(16)), -- Reduzido
                Font = self.Font,
                Text = tostring(default or min),
                TextColor3 = Color3.fromRGB(140, 140, 140),
                TextSize = ScaleValue(12), -- Reduzido
                TextXAlignment = Enum.TextXAlignment.Right
            })
            
            local sliderTrack = Utils:CreateRoundedFrame({
                Parent = sliderFrame,
                BackgroundColor3 = self.darkGray,
                BackgroundTransparency = self.transparency,
                Position = UDim2.new(0, 0, 0, ScaleValue(36)),
                Size = UDim2.new(1, 0, 0, ScaleValue(8)) -- Reduzido
            })
            
            local sliderFill = Create("Frame", {
                Parent = sliderTrack,
                BackgroundColor3 = self.acientColor,
                Size = UDim2.new((default or min) / (max or 100), 0, 1, 0),
                BorderSizePixel = 0
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 3),
                Parent = sliderFill
            })
            
            -- Controle do slider
            local currentValue = default or min
            local isDragging = false
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                currentValue = math.floor(min + (max - min) * pos)
                
                valueLabel.Text = tostring(currentValue)
                TweenService:Create(sliderFill, Tweens.Fast, {
                    Size = UDim2.new(pos, 0, 1, 0)
                }):Play()
                
                if callback then callback(currentValue) end
            end
            
            sliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    updateSlider(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
                    updateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end)
            
            -- Interface de controle
            local Control = {}
            function Control:Set(value)
                currentValue = math.clamp(value, min, max)
                local pos = (currentValue - min) / (max - min)
                
                valueLabel.Text = tostring(currentValue)
                TweenService:Create(sliderFill, Tweens.Fast, {
                    Size = UDim2.new(pos, 0, 1, 0)
                }):Play()
                
                if callback then callback(currentValue) end
                return Control
            end
            
            function Control:Get()
                return currentValue
            end
            
            return Control
        end
        
        -- Dropdown simplificado
        function Elements:Dropdown(text, options, default, callback)
            local dropdownFrame = Create("Frame", {
                Parent = tabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -ScaleValue(8), 0, ScaleValue(22)) -- Reduzido
            })
            
            local dropdownBtn = Create("TextButton", {
                Parent = dropdownFrame,
                Text = text,
                BackgroundColor3 = self.darkGray,
                BackgroundTransparency = self.transparency,
                Size = UDim2.new(1, 0, 0, ScaleValue(22)), -- Reduzido
                Font = self.Font,
                TextColor3 = Color3.fromRGB(190, 190, 190),
                TextSize = ScaleValue(13), -- Reduzido
                AutoButtonColor = false
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = dropdownBtn})
            Utils:CreateStroke(dropdownBtn)
            
            local valueLabel = Create("TextLabel", {
                Parent = dropdownBtn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, ScaleValue(8), 0, 0),
                Size = UDim2.new(1, -ScaleValue(16), 1, 0),
                Font = self.Font,
                Text = default or "Select",
                TextColor3 = Color3.fromRGB(140, 140, 140),
                TextSize = ScaleValue(12), -- Reduzido
                TextXAlignment = Enum.TextXAlignment.Right
            })
            
            local dropdownList = Create("Frame", {
                Parent = dropdownBtn,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                Position = UDim2.new(0, 0, 1, ScaleValue(4)),
                Size = UDim2.new(1, 0, 0, ScaleValue(100)),
                Visible = false,
                ClipsDescendants = true
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = dropdownList})
            Utils:CreateStroke(dropdownList)
            
            local listLayout = Create("UIListLayout", {
                Parent = dropdownList,
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            -- Populate options
            for _, option in ipairs(options or {}) do
                local optionBtn = Create("TextButton", {
                    Parent = dropdownList,
                    Text = option,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, ScaleValue(20)), -- Reduzido
                    Font = self.Font,
                    TextColor3 = Color3.fromRGB(170, 170, 170),
                    TextSize = ScaleValue(12), -- Reduzido
                    AutoButtonColor = false
                })
                
                optionBtn.MouseButton1Click:Connect(function()
                    valueLabel.Text = option
                    dropdownList.Visible = false
                    if callback then callback(option) end
                end)
            end
            
            -- Toggle dropdown
            dropdownBtn.MouseButton1Click:Connect(function()
                dropdownList.Visible = not dropdownList.Visible
            end)
            
            local Control = {}
            function Control:Set(value)
                valueLabel.Text = value
                if callback then callback(value) end
                return Control
            end
            
            function Control:Get()
                return valueLabel.Text
            end
            
            return Control
        end
        
        -- Separador
        function Elements:Separator()
            local separator = Create("Frame", {
                Parent = tabContent,
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, -ScaleValue(8), 0, ScaleValue(1)),
                BorderSizePixel = 0
            })
            
            return separator
        end
        
        -- Label
        function Elements:Label(text)
            local label = Create("TextLabel", {
                Parent = tabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -ScaleValue(8), 0, ScaleValue(20)), -- Reduzido
                Font = self.Font,
                Text = text,
                TextColor3 = Color3.fromRGB(190, 190, 190),
                TextSize = ScaleValue(13), -- Reduzido
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            return label
        end
        
        return Elements
    end
    
    -- Funções principais
    function self:Toggle()
        mainFrame.Visible = not mainFrame.Visible
        return self
    end
    
    function self:Hide()
        mainFrame.Visible = false
        return self
    end
    
    function self:Show()
        mainFrame.Visible = true
        return self
    end
    
    function self:Destroy()
        screen:Destroy()
        return self
    end
    
    return self
end

return library
