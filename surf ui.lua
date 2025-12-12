--[[  
    GGMenu UI Library
    Estilo: Cheat Premium (CS / Synapse / Onetap)
    Criado pelo ChatGPT
]]

local GGMenu = {}
GGMenu.__index = GGMenu

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

---------------------------------------------------------------------
-- FUNÇÃO DE ANIMAÇÃO
---------------------------------------------------------------------
local function Tween(object, props, time)
    TweenService:Create(object, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quint), props):Play()
end

---------------------------------------------------------------------
-- CRIAR JANELA
---------------------------------------------------------------------
function GGMenu:CreateWindow(title)
    local ui = {}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = CoreGui
    ScreenGui.IgnoreGuiInset = true

    -- Window
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 520, 0, 330)
    Main.Position = UDim2.new(0.5, -260, 0.5, -165)
    Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 160, 255)
    Stroke.Thickness = 1.2
    Stroke.Parent = Main

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Title.Text = "  " .. (title or "GGMenu")
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.Code
    Title.TextSize = 14
    Title.Parent = Main

    ui.Main = Main
    ui.Tabs = {}

    ---------------------------------------------------------------------
    -- SISTEMA DE TABS
    ---------------------------------------------------------------------
    function ui:CreateTab(name)
        local tab = {}

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0, 120, 0, 26)
        Button.Position = UDim2.new(0, (#ui.Tabs * 125), 0, 32)
        Button.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Text = name
        Button.Font = Enum.Font.Code
        Button.TextSize = 14
        Button.BorderSizePixel = 0
        Button.Parent = Main

        local Page = Instance.new("Frame")
        Page.Size = UDim2.new(1, -10, 1, -65)
        Page.Position = UDim2.new(0, 5, 0, 60)
        Page.BackgroundTransparency = 1
        Page.Visible = (#ui.Tabs == 0)
        Page.Parent = Main

        tab.Button = Button
        tab.Page = Page

        table.insert(ui.Tabs, tab)

        Button.MouseButton1Click:Connect(function()
            for _, t in ipairs(ui.Tabs) do
                t.Page.Visible = false
                Tween(t.Button, {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}, 0.15)
            end
            Page.Visible = true
            Tween(Button, {BackgroundColor3 = Color3.fromRGB(0, 140, 255)}, 0.15)
        end)

        ---------------------------------------------------------------------
        -- ELEMENTOS DO TAB
        ---------------------------------------------------------------------
        function tab:CreateSection(text)
            local s = Instance.new("TextLabel")
            s.Text = text
            s.TextColor3 = Color3.fromRGB(0, 160, 255)
            s.Font = Enum.Font.Code
            s.TextSize = 14
            s.BackgroundTransparency = 1
            s.Size = UDim2.new(1, 0, 0, 20)
            s.Parent = Page
        end

        function tab:CreateLabel(text)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -10, 0, 20)
            l.Position = UDim2.new(0, 5, 0, #Page:GetChildren() * 24)
            l.BackgroundTransparency = 1
            l.TextColor3 = Color3.fromRGB(255, 255, 255)
            l.Text = text
            l.Font = Enum.Font.Code
            l.TextSize = 14
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = Page
        end

        function tab:CreateButton(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -10, 0, 22)
            b.Position = UDim2.new(0, 5, 0, #Page:GetChildren() * 26)
            b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Text = text
            b.Font = Enum.Font.Code
            b.TextSize = 14
            b.BorderSizePixel = 0
            b.Parent = Page

            b.MouseEnter:Connect(function()
                Tween(b, {BackgroundColor3 = Color3.fromRGB(0, 140, 255)}, 0.15)
            end)
            b.MouseLeave:Connect(function()
                Tween(b, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}, 0.15)
            end)

            b.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
        end

        function tab:CreateToggle(text, default, callback)
            local t = {}
            t.state = default

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, 20)
            frame.Position = UDim2.new(0, 5, 0, #Page:GetChildren() * 24)
            frame.BackgroundTransparency = 1
            frame.Parent = Page

            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 18, 0, 18)
            box.Position = UDim2.new(0, 0, 0, 1)
            box.BackgroundColor3 = default and Color3.fromRGB(0, 160, 255) or Color3.fromRGB(40, 40, 40)
            box.BorderSizePixel = 0
            box.Parent = frame

            local txt = Instance.new("TextLabel")
            txt.Position = UDim2.new(0, 25, 0, 0)
            txt.Size = UDim2.new(1, -30, 1, 0)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = Color3.fromRGB(255, 255, 255)
            txt.Font = Enum.Font.Code
            txt.TextSize = 14
            txt.TextXAlignment = Enum.TextXAlignment.Left
            txt.Text = text
            txt.Parent = frame

            frame.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    t.state = not t.state
                    Tween(box, {
                        BackgroundColor3 = t.state and Color3.fromRGB(0, 160, 255) or Color3.fromRGB(40, 40, 40)
                    }, 0.15)
                    callback(t.state)
                end
            end)
        end

        return tab
    end

    return ui
end

return GGMenu
