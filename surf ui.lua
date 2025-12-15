-- ======================================
-- GGMenu UI Library v6.0 (Otimizada e Modular) pelegpo
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
local ContentProvider = game:GetService("ContentProvider")

-- Configurações padrão
GGMenu.Config = {
    ToggleKey = Enum.KeyCode.Insert,
    DefaultWindowSize = UDim2.new(0, 500, 0, 550),
    FPSBarSize = UDim2.new(0, 450, 0, 32),
    SliderDragPrecision = 0.01,
    Title = "GGMenu v6.0",
    ResponsiveScale = 0.8, -- Escala responsiva para telas menores
    MaxWindowWidth = 600,
    MinWindowWidth = 400
}

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
    SearchHighlight = Color3.fromRGB(84, 232, 180, 0.3)
}

GGMenu.Fonts = {
    Title = Enum.Font.GothamBold,
    Header = Enum.Font.GothamSemibold,
    Body = Enum.Font.Gotham,
    Code = Enum.Font.Code
}

-- Cache para thumbnails
local ThumbnailCache = {}
local HoverEffects = {}

-- ======================================
-- UTILITÁRIOS OTIMIZADOS
-- ======================================
local Utils = {}

function Utils.Create(class, props, children)
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

function Utils.Tween(obj, props, duration, easingStyle, easingDirection)
    duration = duration or 0.2
    easingStyle = easingStyle or Enum.EasingStyle.Quint
    easingDirection = easingDirection or Enum.EasingDirection.Out
    local ti = TweenInfo.new(duration, easingStyle, easingDirection)
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
end

function Utils.HoverEffect(obj, normalColor, hoverColor)
    if HoverEffects[obj] then return end
    
    local conn1 = obj.MouseEnter:Connect(function()
        Utils.Tween(obj, {BackgroundColor3 = hoverColor or GGMenu.Theme.BgCardHover}, 0.15)
    end)
    
    local conn2 = obj.MouseLeave:Connect(function()
        Utils.Tween(obj, {BackgroundColor3 = normalColor}, 0.15)
    end)
    
    HoverEffects[obj] = {conn1, conn2}
end

function Utils.RemoveHoverEffect(obj)
    if HoverEffects[obj] then
        for _, conn in ipairs(HoverEffects[obj]) do
            conn:Disconnect()
        end
        HoverEffects[obj] = nil
    end
end

-- Cache de executor
local cachedExecutor = nil
function Utils.GetExecutor()
    if cachedExecutor then return cachedExecutor end
    
    local exec = "Unknown"
    pcall(function()
        local executorFuncs = {
            identifyexecutor, getexecutorname, isexecutorclosure,
            function() return _G.Executor end
        }
        
        for _, func in pairs(executorFuncs) do
            if type(func) == "function" then
                local result = func()
                if result and type(result) == "string" then
                    exec = result
                    break
                end
            end
        end
        
        -- Detecções específicas
        if ArceusX then exec = "Arceus X"
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
        end
    end)
    
    cachedExecutor = exec
    return exec
end

-- Sistema de fila circular para FPS
local CircularBuffer = {}
CircularBuffer.__index = CircularBuffer

function CircularBuffer.new(size)
    local self = setmetatable({}, CircularBuffer)
    self.size = size
    self.buffer = {}
    self.index = 1
    self.count = 0
    self.sum = 0
    return self
end

function CircularBuffer:Add(value)
    if self.count < self.size then
        table.insert(self.buffer, value)
        self.sum = self.sum + value
        self.count = self.count + 1
    else
        local old = self.buffer[self.index]
        self.sum = self.sum - old + value
        self.buffer[self.index] = value
        self.index = (self.index % self.size) + 1
    end
end

function CircularBuffer:Average()
    return self.count > 0 and (self.sum / self.count) or 0
end

-- Gerenciador de conexões
local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager

function ConnectionManager.new()
    local self = setmetatable({}, ConnectionManager)
    self.connections = {}
    return self
end

function ConnectionManager:Add(connection)
    table.insert(self.connections, connection)
    return connection
end

function ConnectionManager:Connect(signal, callback)
    local connection = signal:Connect(callback)
    self:Add(connection)
    return connection
end

function ConnectionManager:DisconnectAll()
    for _, connection in ipairs(self.connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    self.connections = {}
end

-- ======================================
-- NOVO: COMPONENTE DE AVATAR DO JOGADOR
-- ======================================
function GGMenu.CreatePlayerAvatar(parent, player, size)
    local connectionManager = ConnectionManager.new()
    local defaultAvatar = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    
    local container = Utils.Create("Frame", {
        Parent = parent,
        Size = size or UDim2.new(0, 50, 0, 50),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BorderSizePixel = 0
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Utils.Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    local imageLabel = Utils.Create("ImageLabel", {
        Parent = container,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = defaultAvatar,
        ScaleType = Enum.ScaleType.Crop
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 7)})
    })
    
    -- Adicionar hover effect
    Utils.HoverEffect(container, GGMenu.Theme.BgCard, GGMenu.Theme.BgCardHover)
    
    local function loadThumbnail()
        if not player or not player.UserId then
            imageLabel.Image = defaultAvatar
            return
        end
        
        local cacheKey = tostring(player.UserId) .. "_HeadShot"
        
        -- Verificar cache
        if ThumbnailCache[cacheKey] then
            imageLabel.Image = ThumbnailCache[cacheKey]
            return
        end
        
        -- Carregar thumbnail de forma assíncrona
        task.spawn(function()
            local success, result = pcall(function()
                return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            
            if success and result and type(result) == "string" then
                ThumbnailCache[cacheKey] = result
                imageLabel.Image = result
            else
                imageLabel.Image = defaultAvatar
            end
        end)
    end
    
    -- Carregar thumbnail inicial
    loadThumbnail()
    
    local avatar = {
        Container = container,
        Image = imageLabel,
        Player = player,
        _connections = connectionManager,
        
        SetPlayer = function(self, newPlayer)
            self.Player = newPlayer
            loadThumbnail()
        end,
        
        SetSize = function(self, newSize)
            container.Size = newSize
        end,
        
        Destroy = function(self)
            self._connections:DisconnectAll()
            Utils.RemoveHoverEffect(container)
            container:Destroy()
        end
    }
    
    return avatar
end

-- ======================================
-- NOVO: CAMPO DE PESQUISA (SEARCH BAR)
-- ======================================
function GGMenu.CreateSearchBar(parent, placeholder, callback, options)
    local connectionManager = ConnectionManager.new()
    options = options or {}
    
    local container = Utils.Create("Frame", {
        Parent = parent,
        Size = options.Size or UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BorderSizePixel = 0
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Utils.Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    -- Ícone de pesquisa
    local searchIcon = Utils.Create("ImageLabel", {
        Parent = container,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(964, 324),
        ImageRectSize = Vector2.new(36, 36),
        ImageColor3 = GGMenu.Theme.TextSecondary
    })
    
    local textBox = Utils.Create("TextBox", {
        Parent = container,
        Size = UDim2.new(1, -40, 1, -4),
        Position = UDim2.new(0, 35, 0, 2),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = placeholder or "Search...",
        PlaceholderColor3 = GGMenu.Theme.TextSecondary,
        TextColor3 = GGMenu.Theme.TextPrimary,
        Font = GGMenu.Fonts.Body,
        TextSize = 14,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Botão de limpar
    local clearButton = Utils.Create("ImageButton", {
        Parent = container,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -30, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(284, 4),
        ImageRectSize = Vector2.new(24, 24),
        ImageColor3 = GGMenu.Theme.TextSecondary,
        Visible = false
    })
    
    -- Hover effects
    Utils.HoverEffect(container, GGMenu.Theme.BgCard, GGMenu.Theme.BgCardHover)
    Utils.HoverEffect(clearButton, Color3.new(1,1,1), GGMenu.Theme.Accent)
    
    -- Função para atualizar visibilidade do botão limpar
    local function updateClearButton()
        clearButton.Visible = string.len(textBox.Text) > 0
    end
    
    -- Eventos
    connectionManager:Connect(textBox:GetPropertyChangedSignal("Text"), function()
        updateClearButton()
        if callback then
            callback(textBox.Text)
        end
    end)
    
    connectionManager:Connect(clearButton.MouseButton1Click, function()
        textBox.Text = ""
        textBox:CaptureFocus()
    end)
    
    connectionManager:Connect(textBox.Focused, function()
        Utils.Tween(textBox, {TextColor3 = GGMenu.Theme.Accent}, 0.2)
        Utils.Tween(searchIcon, {ImageColor3 = GGMenu.Theme.Accent}, 0.2)
    end)
    
    connectionManager:Connect(textBox.FocusLost, function()
        Utils.Tween(textBox, {TextColor3 = GGMenu.Theme.TextPrimary}, 0.2)
        Utils.Tween(searchIcon, {ImageColor3 = GGMenu.Theme.TextSecondary}, 0.2)
    end)
    
    local searchBar = {
        Container = container,
        TextBox = textBox,
        _connections = connectionManager,
        
        GetText = function(self)
            return textBox.Text
        end,
        
        SetText = function(self, text)
            textBox.Text = text
            updateClearButton()
        end,
        
        Clear = function(self)
            self:SetText("")
        end,
        
        Focus = function(self)
            textBox:CaptureFocus()
        end,
        
        Destroy = function(self)
            self._connections:DisconnectAll()
            Utils.RemoveHoverEffect(container)
            Utils.RemoveHoverEffect(clearButton)
            container:Destroy()
        end
    }
    
    return searchBar
end

-- ======================================
-- NOVO: SISTEMA DE FILTRAGEM PARA LISTAS
-- ======================================
function GGMenu.CreateFilteredList(parent, items, createItemFunc, options)
    local connectionManager = ConnectionManager.new()
    options = options or {}
    
    local container = Utils.Create("Frame", {
        Parent = parent,
        Size = options.Size or UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    })
    
    -- Search bar
    local searchBar = GGMenu.CreateSearchBar(container, options.SearchPlaceholder or "Search...", nil, {
        Size = UDim2.new(1, 0, 0, 36)
    })
    
    -- Lista com scroll
    local scrollFrame = Utils.Create("ScrollingFrame", {
        Parent = container,
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = GGMenu.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    })
    
    local itemsContainer = Utils.Create("Frame", {
        Parent = scrollFrame,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1
    })
    
    local listLayout = Utils.Create("UIListLayout", {
        Parent = itemsContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, options.ItemSpacing or 5)
    })
    
    local filteredItems = {}
    
    -- Função para criar/atualizar lista
    local function updateList(filterText)
        -- Limpar itens antigos
        for _, item in ipairs(filteredItems) do
            if item.Destroy then
                item:Destroy()
            else
                item:Destroy()
            end
        end
        filteredItems = {}
        
        -- Filtrar itens
        local filtered = {}
        if filterText and filterText ~= "" then
            local lowerFilter = filterText:lower()
            for _, item in ipairs(items) do
                if string.find(tostring(item):lower(), lowerFilter) then
                    table.insert(filtered, item)
                end
            end
        else
            filtered = items
        end
        
        -- Criar itens visuais
        for i, item in ipairs(filtered) do
            local itemUI = createItemFunc(item, i)
            itemUI.Parent = itemsContainer
            itemUI.LayoutOrder = i
            table.insert(filteredItems, itemUI)
        end
        
        -- Atualizar tamanho do canvas
        task.wait()
        local totalHeight = (#filtered * (options.ItemHeight or 40)) + 
                           ((#filtered - 1) * (options.ItemSpacing or 5))
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    end
    
    -- Conectar search bar
    connectionManager:Connect(searchBar.TextBox:GetPropertyChangedSignal("Text"), function()
        updateList(searchBar.TextBox.Text)
    end)
    
    -- Atualizar lista inicial
    updateList("")
    
    local filteredList = {
        Container = container,
        SearchBar = searchBar,
        ScrollFrame = scrollFrame,
        ItemsContainer = itemsContainer,
        _connections = connectionManager,
        
        UpdateItems = function(self, newItems)
            items = newItems
            updateList(searchBar.TextBox.Text)
        end,
        
        GetFilteredItems = function(self)
            return filteredItems
        end,
        
        ClearFilter = function(self)
            searchBar:Clear()
        end,
        
        Destroy = function(self)
            self._connections:DisconnectAll()
            searchBar:Destroy()
            for _, item in ipairs(filteredItems) do
                if item.Destroy then
                    item:Destroy()
                end
            end
            container:Destroy()
        end
    }
    
    return filteredList
end

-- ======================================
-- COMPONENTES BASE OTIMIZADOS (com melhorias)
-- ======================================
function GGMenu.CreateToggle(parent, text, defaultValue, callback)
    local connectionManager = ConnectionManager.new()
    
    local container = Utils.Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = parent:GetChildren() and #parent:GetChildren() + 1 or 1
    })
    
    local label = Utils.Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = 14,
        Font = GGMenu.Fonts.Body,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleFrame = Utils.Create("Frame", {
        Parent = container,
        Size = UDim2.new(0, 48, 0, 26),
        Position = UDim2.new(1, -48, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = defaultValue and GGMenu.Theme.Accent or GGMenu.Theme.BgCard,
        BorderSizePixel = 0
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Utils.Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    local toggleCircle = Utils.Create("Frame", {
        Parent = toggleFrame,
        Size = UDim2.new(0, 20, 0, 20),
        Position = defaultValue and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(defaultValue and 1 or 0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    -- Hover effect
    Utils.HoverEffect(toggleFrame, 
        defaultValue and GGMenu.Theme.Accent or GGMenu.Theme.BgCard,
        defaultValue and Color3.fromRGB(232, 100, 100) or GGMenu.Theme.BgCardHover)
    
    local toggle = {
        Value = defaultValue or false,
        Container = container,
        _connections = connectionManager,
        
        Set = function(self, value)
            self.Value = value
            Utils.Tween(toggleFrame, {BackgroundColor3 = value and GGMenu.Theme.Accent or GGMenu.Theme.BgCard})
            Utils.Tween(toggleCircle, {Position = value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)})
            
            -- Atualizar hover color
            Utils.RemoveHoverEffect(toggleFrame)
            Utils.HoverEffect(toggleFrame, 
                value and GGMenu.Theme.Accent or GGMenu.Theme.BgCard,
                value and Color3.fromRGB(232, 100, 100) or GGMenu.Theme.BgCardHover)
            
            if callback then callback(value) end
        end,
        
        Toggle = function(self)
            self:Set(not self.Value)
        end,
        
        Destroy = function(self)
            self._connections:DisconnectAll()
            Utils.RemoveHoverEffect(toggleFrame)
            container:Destroy()
        end
    }
    
    connectionManager:Connect(toggleFrame.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle:Toggle()
        end
    end)
    
    return toggle
end

-- ... (os outros componentes mantêm a mesma estrutura, apenas adicionando hover effects)

-- ======================================
-- JANELA COM RESPONSIVIDADE MELHORADA
-- ======================================
function GGMenu.CreateWindow(title)
    local connectionManager = ConnectionManager.new()
    
    local screenGui = Utils.Create("ScreenGui", {
        Parent = CoreGui,
        Name = "GGMenu_Window",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 2000
    })
    
    -- Calcular tamanho responsivo
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local responsiveScale = math.clamp(
        viewportSize.X / 1920 * GGMenu.Config.ResponsiveScale,
        0.7, 1.2
    )
    
    local windowSize = UDim2.new(
        0, math.clamp(500 * responsiveScale, GGMenu.Config.MinWindowWidth, GGMenu.Config.MaxWindowWidth),
        0, 550 * responsiveScale
    )
    
    local mainFrame = Utils.Create("Frame", {
        Parent = screenGui,
        Size = windowSize,
        Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        BorderSizePixel = 0
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Utils.Create("UIStroke", {Color = GGMenu.Theme.Accent, Thickness = 2})
    })
    
    -- Header (área de drag)
    local header = Utils.Create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 60 * responsiveScale),
        BackgroundColor3 = GGMenu.Theme.BgDark,
        BorderSizePixel = 0
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 12, 0, 0)})
    })
    
    local titleLabel = Utils.Create("TextLabel", {
        Parent = header,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = math.floor(20 * responsiveScale),
        Font = GGMenu.Fonts.Title,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Botão de fechar com hover effect
    local closeButton = Utils.Create("TextButton", {
        Parent = header,
        Size = UDim2.new(0, 32 * responsiveScale, 0, 32 * responsiveScale),
        Position = UDim2.new(1, -40 * responsiveScale, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = GGMenu.Theme.BgCard,
        Text = "×",
        TextColor3 = GGMenu.Theme.TextPrimary,
        TextSize = math.floor(24 * responsiveScale),
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, {
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Utils.Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
    })
    
    Utils.HoverEffect(closeButton, GGMenu.Theme.BgCard, GGMenu.Theme.Danger)
    
    -- ... (resto do código da janela mantido, com ajustes de scale)

    -- Sistema de temas dinâmico
    local function applyThemeToWindow()
        -- Aplicar tema a todos os componentes da janela
        mainFrame.UIStroke.Color = GGMenu.Theme.Accent
        header.BackgroundColor3 = GGMenu.Theme.BgDark
        titleLabel.TextColor3 = GGMenu.Theme.TextPrimary
        closeButton.BackgroundColor3 = GGMenu.Theme.BgCard
        closeButton.TextColor3 = GGMenu.Theme.TextPrimary
        closeButton.UIStroke.Color = GGMenu.Theme.Border
        
        -- Aplicar tema às tabs
        for _, tabData in pairs(tabs) do
            tabData.Button.BackgroundColor3 = currentTab == tabId and GGMenu.Theme.Accent or GGMenu.Theme.BgCard
            tabData.Button.TextColor3 = currentTab == tabId and Color3.new(1,1,1) or GGMenu.Theme.TextSecondary
            tabData.Button.UIStroke.Color = GGMenu.Theme.Border
        end
    end

    -- ... (no final da função CreateWindow, retornar interface estendida)

    return {
        Gui = screenGui,
        Frame = mainFrame,
        Tabs = {},
        _connections = connectionManager,
        
        -- Funções existentes...
        AddTab = function(self, tabName) ... end,
        SetVisible = function(self, visible) ... end,
        ToggleVisible = function(self) ... end,
        
        -- NOVAS FUNÇÕES
        ApplyTheme = applyThemeToWindow,
        
        SetSize = function(self, size)
            mainFrame.Size = size
            -- Recalcular posição para manter centralizado
            mainFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
        end,
        
        SetResponsive = function(self, enabled)
            if enabled then
                -- Conectar para redimensionar quando a tela mudar
                connectionManager:Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
                    local viewportSize = workspace.CurrentCamera.ViewportSize
                    local responsiveScale = math.clamp(
                        viewportSize.X / 1920 * GGMenu.Config.ResponsiveScale,
                        0.7, 1.2
                    )
                    
                    local newSize = UDim2.new(
                        0, math.clamp(500 * responsiveScale, GGMenu.Config.MinWindowWidth, GGMenu.Config.MaxWindowWidth),
                        0, 550 * responsiveScale
                    )
                    
                    self:SetSize(newSize)
                end)
            end
        end,
        
        Destroy = function(self) ... end
    }
end

-- ======================================
-- SISTEMA DE TEMA DINÂMICO GLOBAL
-- ======================================
local activeComponents = {}
local themeListeners = {}

function GGMenu.RegisterThemeListener(component)
    table.insert(themeListeners, component)
end

function GGMenu.UnregisterThemeListener(component)
    for i, listener in ipairs(themeListeners) do
        if listener == component then
            table.remove(themeListeners, i)
            break
        end
    end
end

function GGMenu.ApplyThemeToAll()
    for _, listener in ipairs(themeListeners) do
        if listener.ApplyTheme then
            pcall(listener.ApplyTheme, listener)
        end
    end
end

function GGMenu.SetTheme(newTheme)
    -- Atualizar tema global
    for key, value in pairs(newTheme) do
        if GGMenu.Theme[key] ~= nil then
            GGMenu.Theme[key] = value
        end
    end
    
    -- Aplicar a todos os componentes registrados
    GGMenu.ApplyThemeToAll()
end

-- ======================================
-- EXEMPLO DE USO DOS NOVOS COMPONENTES
-- ======================================
function GGMenu.Demo()
    local ui = GGMenu:Init({
        Title = "GGMenu v6.0 Demo",
        ShowFPSBar = true,
        ShowStatusPanel = true
    })
    
    local mainTab = ui.Window:AddTab("Main")
    
    -- Adicionar avatar do jogador local
    local avatarSection = mainTab:AddSection("Player Avatar")
    local avatar = GGMenu.CreatePlayerAvatar(avatarSection.Container, Players.LocalPlayer)
    avatar.Container.Parent = avatarSection.Container
    
    -- Adicionar search bar
    local searchSection = mainTab:AddSection("Player Search")
    local search = GGMenu.CreateSearchBar(searchSection.Container, "Search players...", function(text)
        print("Searching for:", text)
    })
    search.Container.Parent = searchSection.Container
    
    -- Exemplo de lista filtrada
    local playersTab = ui.Window:AddTab("Players")
    local playersSection = playersTab:AddSection("Online Players")
    
    -- Criar lista de jogadores
    local playerItems = {}
    for _, player in pairs(Players:GetPlayers()) do
        table.insert(playerItems, player)
    end
    
    local filteredList = GGMenu.CreateFilteredList(playersSection.Container, playerItems, function(player, index)
        local item = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundColor3 = index % 2 == 0 and GGMenu.Theme.BgCard or GGMenu.Theme.BgDark,
            BorderSizePixel = 0
        }, {
            Utils.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
            Utils.Create("UIStroke", {Color = GGMenu.Theme.Border, Thickness = 1})
        })
        
        -- Avatar pequeno
        local avatar = GGMenu.CreatePlayerAvatar(item, player, UDim2.new(0, 40, 0, 40))
        avatar.Container.Position = UDim2.new(0, 5, 0.5, 0)
        avatar.Container.AnchorPoint = Vector2.new(0, 0.5)
        
        -- Nome do jogador
        local nameLabel = Utils.Create("TextLabel", {
            Parent = item,
            Size = UDim2.new(1, -50, 1, 0),
            Position = UDim2.new(0, 50, 0, 0),
            BackgroundTransparency = 1,
            Text = player.Name,
            TextColor3 = GGMenu.Theme.TextPrimary,
            TextSize = 14,
            Font = GGMenu.Fonts.Body,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        Utils.HoverEffect(item, 
            index % 2 == 0 and GGMenu.Theme.BgCard or GGMenu.Theme.BgDark,
            GGMenu.Theme.BgCardHover)
        
        return item
    end, {
        SearchPlaceholder = "Filter players...",
        ItemHeight = 50,
        ItemSpacing = 8
    })
    
    filteredList.Container.Parent = playersSection.Container
    
    -- Botão para mudar tema
    local settingsTab = ui.Window:AddTab("Settings")
    local themeSection = settingsTab:AddSection("Theme")
    
    themeSection:AddToggle("Dark Mode", true, function(value)
        if value then
            GGMenu.SetTheme({
                BgDark = Color3.fromRGB(12, 12, 15),
                BgCard = Color3.fromRGB(18, 18, 22),
                TextPrimary = Color3.fromRGB(245, 245, 250)
            })
        else
            GGMenu.SetTheme({
                BgDark = Color3.fromRGB(240, 240, 245),
                BgCard = Color3.fromRGB(255, 255, 255),
                TextPrimary = Color3.fromRGB(20, 20, 25)
            })
        end
    end)
    
    return ui
end

-- ======================================
-- INICIALIZAÇÃO MODULAR OTIMIZADA
-- ======================================
function GGMenu:Init(options)
    -- ... (código de inicialização mantido)
    
    -- Registrar janela no sistema de temas
    if components.Window then
        GGMenu.RegisterThemeListener(components.Window)
    end
    
    -- Ativar responsividade
    if components.Window and (config.Responsive == nil or config.Responsive == true) then
        components.Window:SetResponsive(true)
    end
    
    return components
end

-- Versão minimalista para usar apenas componentes
function GGMenu:CreateLibrary()
    return {
        -- Componentes básicos
        CreateWindow = GGMenu.CreateWindow,
        CreateFPSBar = GGMenu.CreateFPSBar,
        CreateStatusPanel = GGMenu.CreateStatusPanel,
        CreateToggle = GGMenu.CreateToggle,
        CreateSlider = GGMenu.CreateSlider,
        CreateDropdown = GGMenu.CreateDropdown,
        
        -- Novos componentes
        CreatePlayerAvatar = GGMenu.CreatePlayerAvatar,
        CreateSearchBar = GGMenu.CreateSearchBar,
        CreateFilteredList = GGMenu.CreateFilteredList,
        
        -- Sistema de temas
        SetTheme = GGMenu.SetTheme,
        RegisterThemeListener = GGMenu.RegisterThemeListener,
        UnregisterThemeListener = GGMenu.UnregisterThemeListener,
        
        -- Utilitários
        Theme = GGMenu.Theme,
        Fonts = GGMenu.Fonts,
        Config = GGMenu.Config,
        Utils = Utils,
        
        -- Demo
        Demo = GGMenu.Demo
    }
end

return GGMenu
