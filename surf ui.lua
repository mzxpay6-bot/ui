--========================================================--
--==================== GGMenu UI Library ==================--
--========================================================--

local GGMenu = {}
GGMenu.__index = GGMenu

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

--========================================================--
--====================== CONFIG ===========================--
--========================================================--

local SETTINGS = {
    Accent = Color3.fromRGB(0, 170, 255),
    Background = Color3.fromRGB(20, 20, 20),
    Secondary = Color3.fromRGB(30, 30, 30),
    TextColor = Color3.fromRGB(255, 255, 255),
    OpenKey = Enum.KeyCode.Insert,
}

--========================================================--
--==================== MAIN WINDOW ========================--
--========================================================--

function GGMenu:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GGMenu"
    ScreenGui.Parent = game:GetService("CoreGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 450, 0, 300)
    Main.Position = UDim2.new(0.5, -225, 0.5, -150)
    Main.BackgroundColor3 = SETTINGS.Background
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = SETTINGS.Accent
    Stroke.Thickness = 1
    Stroke.Parent = Main

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundColor3 = SETTINGS.Secondary
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Main
    TopBar.Active = true
    TopBar.Draggable = true

    local Title = Instance.new("TextLabel")
    Title.Text = title
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = SETTINGS.TextColor
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    -- MINIMIZE
    local Minimize = Instance.new("TextButton")
    Minimize.Size = UDim2.new(0, 30, 1, 0)
    Minimize.Position = UDim2.new(1, -60, 0, 0)
    Minimize.BackgroundTransparency = 1
    Minimize.Text = "-"
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextColor3 = SETTINGS.TextColor
    Minimize.Parent = TopBar

    -- CLOSE
    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0, 30, 1, 0)
    Close.Position = UDim2.new(1, -30, 0, 0)
    Close.BackgroundTransparency = 1
    Close.Text = "X"
    Close.Font = Enum.Font.GothamBold
    Close.TextColor3 = Color3.fromRGB(255, 70, 70)
    Close.Parent = TopBar

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, -30)
    Content.Position = UDim2.new(0, 0, 0, 30)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local TabsFrame = Instance.new("Frame")
    TabsFrame.Size = UDim2.new(0, 120, 1, 0)
    TabsFrame.BackgroundColor3 = SETTINGS.Secondary
    TabsFrame.BorderSizePixel = 0
    TabsFrame.Parent = Content

    local UIList = Instance.new("UIListLayout")
    UIList.Parent = TabsFrame
    UIList.Padding = UDim.new(0, 2)

    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1, -120, 1, 0)
    Pages.Position = UDim2.new(0, 120, 0, 0)
    Pages.BackgroundTransparency = 1
    Pages.Parent = Content

    -- MINIMIZE FUNCTION
    local minimized = false
    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        Pages.Visible = not minimized
    end)

    -- CLOSE FUNCTION
    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- GLOBAL KEY TO OPEN UI
    local open = true
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == SETTINGS.OpenKey then
            open = not open
            ScreenGui.Enabled = open
        end
    end)

    return {
        TabsFrame = TabsFrame,
        Pages = Pages,
        CreateTab = function(self, name)
            local Tab = Instance.new("TextButton")
            Tab.Size = UDim2.new(1, -4, 0, 30)
            Tab.BackgroundColor3 = SETTINGS.Background
            Tab.Text = name
            Tab.Font = Enum.Font.Gotham
            Tab.TextColor3 = SETTINGS.TextColor
            Tab.Parent = TabsFrame

            local Page = Instance.new("ScrollingFrame")
            Page.Size = UDim2.new(1, 0, 1, 0)
            Page.BackgroundTransparency = 1
            Page.Visible = false
            Page.CanvasSize = UDim2.new(0,0,0,0)
            Page.Parent = Pages

            local Layout = Instance.new("UIListLayout")
            Layout.Parent = Page
            Layout.Padding = UDim.new(0, 10)

            Tab.MouseButton1Click:Connect(function()
                for _, p in ipairs(Pages:GetChildren()) do
                    if p:IsA("ScrollingFrame") then p.Visible = false end
                end
                Page.Visible = true
            end)

            return {
                Page = Page,
                CreateButton = function(_, text, callback)
                    local Btn = Instance.new("TextButton")
                    Btn.Size = UDim2.new(1, -10, 0, 30)
                    Btn.BackgroundColor3 = SETTINGS.Secondary
                    Btn.Text = text
                    Btn.Font = Enum.Font.Gotham
                    Btn.TextColor3 = SETTINGS.TextColor
                    Btn.Parent = Page

                    Btn.MouseButton1Click:Connect(callback)
                end,
                CreateLabel = function(_, text)
                    local L = Instance.new("TextLabel")
                    L.Size = UDim2.new(1, -10, 0, 20)
                    L.BackgroundTransparency = 1
                    L.Text = text
                    L.Font = Enum.Font.Gotham
                    L.TextColor3 = SETTINGS.TextColor
                    L.Parent = Page
                end
            }
        end
    }
end

--========================================================--
--==================== FPS BAR ============================--
--========================================================--

local BottomGui = Instance.new("ScreenGui", game.CoreGui)
local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(0, 320, 0, 25)
Bar.Position = UDim2.new(0, 10, 1, -35)
Bar.BackgroundColor3 = SETTINGS.Background
Bar.BorderSizePixel = 0
Bar.Parent = BottomGui

local Stroke = Instance.new("UIStroke")
Stroke.Color = SETTINGS.Accent
Stroke.Thickness = 1
Stroke.Parent = Bar

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, -10, 1, 0)
Label.Position = UDim2.new(0, 5, 0, 0)
Label.BackgroundTransparency = 1
Label.TextColor3 = SETTINGS.TextColor
Label.Font = Enum.Font.Code
Label.TextSize = 14
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.Parent = Bar

RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    local time = os.date("%H:%M:%S")

    Label.Text = string.format("GGMenu | %s | FPS: %s | Ping: %sms | %s",
        LocalPlayer.Name,
        fps,
        math.floor(ping),
        time
    )
end)

return GGMenu
