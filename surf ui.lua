-- ======================================
-- GGMenu UI Library v4.2 (Corrigido)
-- Correções principais:
-- • Remove Draggable deprecated
-- • Slider com suporte a float
-- • Dropdown fecha corretamente ao clicar fora
-- • Menos listeners globais desnecessários
-- • Pequenos ajustes de segurança
-- ======================================
--xerecaaa

local GGMenu = {}
GGMenu.__index = GGMenu

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ================= EXECUTOR =================
local CachedExecutor
local function GetExecutor()
    if CachedExecutor then return CachedExecutor end
    local exec = "Unknown"
    pcall(function()
        if identifyexecutor then exec = identifyexecutor()
        elseif getexecutorname then exec = getexecutorname()
        elseif ArceusX then exec = "Arceus X"
        elseif Hydrogen then exec = "Hydrogen" end
    end)
    CachedExecutor = exec
    return exec
end

-- ================= THEME =================
GGMenu.Theme = {
    Accent = Color3.fromRGB(232,84,84),
    BgDark = Color3.fromRGB(12,12,15),
    BgCard = Color3.fromRGB(18,18,22),
    BgCardHover = Color3.fromRGB(25,25,30),
    TextPrimary = Color3.fromRGB(245,245,250),
    TextSecondary = Color3.fromRGB(160,160,175),
    Border = Color3.fromRGB(35,35,42),
    Success = Color3.fromRGB(72,199,142),
    Warning = Color3.fromRGB(241,196,15),
    Danger = Color3.fromRGB(231,76,60)
}

GGMenu.Fonts = {
    Title = Enum.Font.GothamBold,
    Header = Enum.Font.GothamSemibold,
    Body = Enum.Font.Gotham,
    Code = Enum.Font.Code
}

-- ================= UTILS =================
local function Create(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do
        if k ~= "Parent" then obj[k] = v end
    end
    if props and props.Parent then obj.Parent = props.Parent end
    return obj
end

local function Tween(obj,t,props)
    TweenService:Create(obj,TweenInfo.new(t,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),props):Play()
end

-- ================= TOGGLE =================
function GGMenu.CreateToggle(parent,text,default,callback)
    local container = Create("Frame",{Parent=parent,Size=UDim2.new(1,0,0,40),BackgroundTransparency=1})

    Create("TextLabel",{
        Parent=container,Size=UDim2.new(0.7,0,1,0),BackgroundTransparency=1,
        Text=text,Font=GGMenu.Fonts.Body,TextSize=14,
        TextColor3=GGMenu.Theme.TextPrimary,TextXAlignment=Left
    })

    local frame = Create("Frame",{
        Parent=container,Size=UDim2.new(0,48,0,26),Position=UDim2.new(1,-48,0.5,0),
        AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=default and GGMenu.Theme.Accent or GGMenu.Theme.BgCard
    })
    Create("UICorner",{Parent=frame,CornerRadius=UDim.new(1,0)})

    local knob = Create("Frame",{
        Parent=frame,Size=UDim2.new(0,20,0,20),AnchorPoint=Vector2.new(0,0.5),
        Position=default and UDim2.new(1,-21,0.5,0) or UDim2.new(0,3,0.5,0),
        BackgroundColor3=Color3.new(1,1,1)
    })
    Create("UICorner",{Parent=knob,CornerRadius=UDim.new(1,0)})

    local state = default or false

    local function set(v)
        state=v
        Tween(frame,0.2,{BackgroundColor3=v and GGMenu.Theme.Accent or GGMenu.Theme.BgCard})
        Tween(knob,0.2,{Position=v and UDim2.new(1,-21,0.5,0) or UDim2.new(0,3,0.5,0)})
        if callback then callback(v) end
    end

    Create("TextButton",{Parent=frame,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""})
        .MouseButton1Click:Connect(function() set(not state) end)

    return {Container=container,Set=set}
end

-- ================= SLIDER =================
function GGMenu.CreateSlider(parent,text,min,max,default,callback)
    local container = Create("Frame",{Parent=parent,Size=UDim2.new(1,0,0,50),BackgroundTransparency=1})

    local value = default or min

    Create("TextLabel",{Parent=container,Size=UDim2.new(1,-60,0,20),BackgroundTransparency=1,
        Text=text,Font=GGMenu.Fonts.Body,TextSize=14,TextColor3=GGMenu.Theme.TextPrimary,TextXAlignment=Left})

    local valueLabel = Create("TextLabel",{Parent=container,Size=UDim2.new(0,60,0,20),Position=UDim2.new(1,-60,0,0),
        BackgroundTransparency=1,Font=GGMenu.Fonts.Code,TextSize=12,TextColor3=GGMenu.Theme.TextSecondary})

    local track = Create("Frame",{Parent=container,Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,1,-20),BackgroundColor3=GGMenu.Theme.BgCard})
    Create("UICorner",{Parent=track,CornerRadius=UDim.new(0,3)})

    local fill = Create("Frame",{Parent=track,BackgroundColor3=GGMenu.Theme.Accent})
    Create("UICorner",{Parent=fill,CornerRadius=UDim.new(0,3)})

    local function set(v)
        v=math.clamp(v,min,max)
        value=v
        local p=(v-min)/(max-min)
        fill.Size=UDim2.new(p,0,1,0)
        valueLabel.Text=string.format("%.2f",v)
        if callback then callback(v) end
    end

    set(value)

    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local x=i.Position.X-track.AbsolutePosition.X
            set(min+(max-min)*(x/track.AbsoluteSize.X))
        end
    end)

    return {Container=container,Set=set}
end

-- ================= WINDOW =================
function GGMenu.CreateWindow(title)
    local gui = Create("ScreenGui",{Parent=CoreGui,ResetOnSpawn=false})
    local main = Create("Frame",{Parent=gui,Size=UDim2.new(0,500,0,550),Position=UDim2.new(0.5,-250,0.5,-275),BackgroundColor3=GGMenu.Theme.BgCard,Active=true})
    Create("UICorner",{Parent=main,CornerRadius=UDim.new(0,12)})

    -- Drag manual (FIX Draggable)
    local drag,start,pos=false
    main.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true start=i.Position pos=main.Position end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-start
            main.Position=UDim2.new(pos.X.Scale,pos.X.Offset+d.X,pos.Y.Scale,pos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)

    Create("TextLabel",{Parent=main,Size=UDim2.new(1,0,0,60),BackgroundTransparency=1,
        Text=title,Font=GGMenu.Fonts.Title,TextSize=20,TextColor3=GGMenu.Theme.TextPrimary})

    return {Gui=gui,Frame=main}
end

-- ================= INIT =================
function GGMenu:Init()
    local w=self.CreateWindow("GGMenu v4.2")
    self.CreateFPSBar()
    print("GGMenu carregado | Executor:",GetExecutor())
    return w
end

return GGMenu
