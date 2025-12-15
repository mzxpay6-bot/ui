-- UI_Library.lua
local UILibrary = {}

-- Configurações padrão
UILibrary.Config = {
    ThemeColor = Color3.fromRGB(0, 170, 255),
    Font = Enum.Font.Gotham,
    Keybinds = {} -- Aqui armazenaremos os keybinds
}

-- Cria a tela principal
function UILibrary:CreateScreen(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = title
    ScreenGui.ResetOnSpawn = false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 400, 0, 300)
    Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    Frame.BackgroundColor3 = self.Config.ThemeColor
    Frame.Parent = ScreenGui

    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    return Frame
end

-- Cria um painel de usuário
function UILibrary:CreateUserPanel(parent, player)
    local UserFrame = Instance.new("Frame")
    UserFrame.Size = UDim2.new(0, 200, 0, 100)
    UserFrame.Position = UDim2.new(0, 10, 0, 10)
    UserFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    UserFrame.Parent = parent

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    NameLabel.Text = player.Name
    NameLabel.TextColor3 = Color3.new(1, 1, 1)
    NameLabel.Font = self.Config.Font
    NameLabel.Parent = UserFrame

    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0.3, 0, 0.5, 0)
    Avatar.Position = UDim2.new(0.7, 0, 0, 0)
    Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
    Avatar.Parent = UserFrame
end

-- Cria contador de FPS
function UILibrary:CreateFPSCounter(parent)
    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.new(0, 100, 0, 50)
    FPSLabel.Position = UDim2.new(0, 10, 0, 120)
    FPSLabel.TextColor3 = Color3.new(1,1,1)
    FPSLabel.Font = self.Config.Font
    FPSLabel.TextSize = 20
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Parent = parent

    local lastTime = tick()
    local frameCount = 0

    game:GetService("RunService").RenderStepped:Connect(function()
        frameCount = frameCount + 1
        if tick() - lastTime >= 1 then
            FPSLabel.Text = "FPS: " .. frameCount
            frameCount = 0
            lastTime = tick()
        end
    end)
end

-- Cria um keybind
function UILibrary:BindKey(key, callback)
    self.Config.Keybinds[key] = callback

    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[key] then
            callback()
        end
    end)
end

return UILibrary
