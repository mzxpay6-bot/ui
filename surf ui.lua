--// GGMenu UI Library
local GG = {}
GG.__index = GG

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// Funções auxiliares
local function Create(Class, Props)
    local obj = Instance.new(Class)
    for k,v in pairs(Props) do
        obj[k] = v
    end
    return obj
end

local function Tween(obj, props, speed)
    speed = speed or 0.15
    game:GetService("TweenService"):Create(obj, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play()
end

--// Criar Window
function GG:Window(title)
    local UI = {}

    local ScreenGui = Create("ScreenGui", {
        Parent = CoreGui,
        ResetOnSpawn = false
    })

    local Main = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Size = UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.5, -250, 0.5, -175)
    })

    Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0,8)})
    
    -- Drag
    local dragging, dragPos, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragPos = input.Position
            startPos = Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragPos
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Header
    local Header = Create("Frame", {
        Parent = Main,
        Size = UDim2.new(1,0,0,40),
        BackgroundColor3 = Color3.fromRGB(35,35,35)
    })
    Create("UICorner", {Parent = Header, CornerRadius = UDim.new(0,8)})

    Create("TextLabel", {
        Parent = Header,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255,255,255),
        Position = UDim2.new(0,10,0,0),
        Size = UDim2.new(1,-50,1,0),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local Close = Create("TextButton", {
        Parent = Header,
        Text = "X",
        Size = UDim2.new(0,40,1,0),
        Position = UDim2.new(1,-40,0,0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255,70,70),
        Font = Enum.Font.GothamBold,
        TextSize = 18
    })
    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local TabsHolder = Create("Frame", {
        Parent = Main,
        Size = UDim2.new(0,120,1,-40),
        Position = UDim2.new(0,0,0,40),
        BackgroundColor3 = Color3.fromRGB(30,30,30)
    })
    Create("UICorner", {Parent = TabsHolder, CornerRadius = UDim.new(0,8)})
    
    local TabsLayout = Create("UIListLayout", {
        Parent = TabsHolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,5)
    })

    local Pages = Create("Frame", {
        Parent = Main,
        Size = UDim2.new(1,-130,1,-50),
        Position = UDim2.new(0,130,0,45),
        BackgroundTransparency = 1
    })

    -- Criar Tab
    function UI:Tab(name)
        local Tab = {}
        
        local Button = Create("TextButton", {
            Parent = TabsHolder,
            BackgroundColor3 = Color3.fromRGB(35,35,35),
            Size = UDim2.new(1,-10,0,35),
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(200,200,200)
        })
        Create("UICorner", {Parent = Button, CornerRadius = UDim.new(0,6)})

        local Page = Create("ScrollingFrame", {
            Parent = Pages,
            Size = UDim2.new(1,0,1,0),
            CanvasSize = UDim2.new(0,0,0,0),
            ScrollBarThickness = 3,
            BackgroundTransparency = 1,
            Visible = false
        })

        local PageLayout = Create("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0,10)
        })

        Button.MouseButton1Click:Connect(function()
            for _,pg in pairs(Pages:GetChildren()) do
                if pg:IsA("ScrollingFrame") then
                    pg.Visible = false
                end
            end
            Page.Visible = true
        end)

        Page.Visible = #Pages:GetChildren() == 1

        -- COMPONENTES
        function Tab:Label(text)
            local lbl = Create("TextLabel", {
                Parent = Page,
                Size = UDim2.new(1,-10,0,25),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                Text = text,
                TextColor3 = Color3.fromRGB(255,255,255),
                TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        function Tab:Button(text, callback)
            callback = callback or function()end
            local btn = Create("TextButton", {
                Parent = Page,
                Size = UDim2.new(1,-10,0,35),
                BackgroundColor3 = Color3.fromRGB(40,40,40),
                Text = text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(255,255,255)
            })
            Create("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
            btn.MouseButton1Click:Connect(callback)
        end

        function Tab:Toggle(text, default, callback)
            default = default or false
            callback = callback or function()end

            local ToggleFrame = Create("Frame", {
                Parent = Page,
                Size = UDim2.new(1,-10,0,35),
                BackgroundColor3 = Color3.fromRGB(40,40,40)
            })
            Create("UICorner", {Parent = ToggleFrame, CornerRadius = UDim.new(0,6)})

            local Label = Create("TextLabel", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.8,0,1,0),
                Position = UDim2.new(0,10,0,0),
                Text = text,
                TextColor3 = Color3.fromRGB(255,255,255),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Switch = Create("Frame", {
                Parent = ToggleFrame,
                Size = UDim2.new(0,18,0,18),
                Position = UDim2.new(1,-28,0.5,-9),
                BackgroundColor3 = default and Color3.fromRGB(0,170,255) or Color3.fromRGB(70,70,70)
            })
            Create("UICorner", {Parent = Switch, CornerRadius = UDim.new(1,0)})

            local on = default
            ToggleFrame.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    on = not on
                    Tween(Switch, {BackgroundColor3 = on and Color3.fromRGB(0,170,255) or Color3.fromRGB(70,70,70)})
                    callback(on)
                end
            end)
        end

        return Tab
    end

    -- Watermark (FPS / Ping / Hora)
    local Bar = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0,330,0,25),
        Position = UDim2.new(0,10,1,-35),
        BackgroundColor3 = Color3.fromRGB(20,20,20)
    })
    Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(0,6)})
    Create("UIStroke", {Parent = Bar, Color = Color3.fromRGB(0,170,255), Thickness = 1})

    local WMText = Create("TextLabel", {
        Parent = Bar,
        Size = UDim2.new(1,-10,1,0),
        Position = UDim2.new(0,5,0,0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255,255,255),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    RunService.RenderStepped:Connect(function()
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        local time = os.date("%H:%M:%S")
        
        WMText.Text = string.format("GGMenu | %s | FPS: %s | Ping: %sms | %s", LocalPlayer.Name, fps, math.floor(ping), time)
    end)

    return UI
end

return GG
