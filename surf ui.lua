--[[
    GGMenu v2 – Cheat UI Premium by ChatGPT
    (Arrastável, Minimizar, Fechar, Watermark, Animações, Tabs)

    API de uso:
    local UI = Library:CreateWindow("GGMenu")
    local Tab = UI:CreateTab("Aimbot")
    Tab:CreateToggle("Enable", false, function(v) end)
    Tab:CreateButton("Kill All", function() end)
]]

local GG = {}
GG.__index = GG

-- services
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local Player = game:GetService("Players").LocalPlayer

-- animate
local function tween(o, p, t)
	TS:Create(o, TweenInfo.new(t or .16, Enum.EasingStyle.Quint), p):Play()
end

------------------------------------------------------------------
-- CREATE WINDOW
------------------------------------------------------------------
function GG:CreateWindow(title)
	local ui = {}

	local gui = Instance.new("ScreenGui", CoreGui)
	gui.IgnoreGuiInset = true
	gui.Name = "GGMenu"

	-- main frame
	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 620, 0, 380)
	main.Position = UDim2.new(.5, -310, .5, -190)
	main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	main.BorderSizePixel = 0

	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 7)

	local stroke = Instance.new("UIStroke", main)
	stroke.Color = Color3.fromRGB(0, 140, 255)
	stroke.Thickness = 1

	------------------------------------------------------------------
	-- DRAG SYSTEM
	------------------------------------------------------------------
	local dragging, dragPos, startPos

	main.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragPos = i.Position
			startPos = main.Position
		end
	end)

	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = i.Position - dragPos
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	------------------------------------------------------------------
	-- TITLE BAR
	------------------------------------------------------------------
	local titlebar = Instance.new("TextLabel", main)
	titlebar.Size = UDim2.new(1, 0, 0, 32)
	titlebar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	titlebar.Text = "  " .. (title or "GGMenu")
	titlebar.TextColor3 = Color3.fromRGB(255, 255, 255)
	titlebar.Font = Enum.Font.Code
	titlebar.TextSize = 14
	titlebar.TextXAlignment = Enum.TextXAlignment.Left

	local close = Instance.new("TextButton", main)
	close.Size = UDim2.new(0, 40, 0, 32)
	close.Position = UDim2.new(1, -40, 0, 0)
	close.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
	close.Text = "X"
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.Font = Enum.Font.Code
	close.TextSize = 16
	close.BorderSizePixel = 0

	close.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	------------------------------------------------------------------
	-- SIDE MENU TABS (igual cheat CS)
	------------------------------------------------------------------
	local tabButtons = Instance.new("Frame", main)
	tabButtons.Size = UDim2.new(0, 130, 1, -32)
	tabButtons.Position = UDim2.new(0, 0, 0, 32)
	tabButtons.BackgroundColor3 = Color3.fromRGB(24, 24, 24)

	local tabFolder = Instance.new("Folder", main)

	ui.Tabs = {}

	function ui:CreateTab(name)
		local tab = {}

		local btn = Instance.new("TextButton", tabButtons)
		btn.Size = UDim2.new(1, 0, 0, 30)
		btn.Position = UDim2.new(0, 0, 0, #tabButtons:GetChildren() * 30)
		btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
		btn.Text = name
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.Code
		btn.TextSize = 14
		btn.BorderSizePixel = 0

		local page = Instance.new("Frame", tabFolder)
		page.Size = UDim2.new(1, -130, 1, -32)
		page.Position = UDim2.new(0, 130, 0, 32)
		page.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		page.Visible = (#ui.Tabs == 0)

		tab.Button = btn
		tab.Page = page
		table.insert(ui.Tabs, tab)

		btn.MouseButton1Click:Connect(function()
			for _, t in ipairs(ui.Tabs) do
				t.Page.Visible = false
				tween(t.Button, {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}, .16)
			end

			page.Visible = true
			tween(btn, {BackgroundColor3 = Color3.fromRGB(0, 140, 255)}, .16)
		end)

		---------------------------------------------------
		-- ELEMENTOS DE GUI (Dentro do Tab)
		---------------------------------------------------
		function tab:CreateButton(txt, callback)
			local b = Instance.new("TextButton", page)
			b.Size = UDim2.new(1, -10, 0, 26)
			b.Position = UDim2.new(0, 5, 0, #page:GetChildren() * 28)
			b.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
			b.Text = txt
			b.TextColor3 = Color3.fromRGB(255, 255, 255)
			b.Font = Enum.Font.Code
			b.TextSize = 14
			b.BorderSizePixel = 0

			b.MouseButton1Click:Connect(function()
				pcall(callback)
			end)
		end

		function tab:CreateToggle(txt, default, callback)
			local t = {}
			t.state = default

			local frame = Instance.new("Frame", page)
			frame.Size = UDim2.new(1, -10, 0, 26)
			frame.Position = UDim2.new(0, 5, 0, #page:GetChildren() * 28)
			frame.BackgroundTransparency = 1

			local box = Instance.new("Frame", frame)
			box.Size = UDim2.new(0, 20, 0, 20)
			box.Position = UDim2.new(0, 0, .5, -10)
			box.BackgroundColor3 = default and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(50, 50, 50)
			box.BorderSizePixel = 0

			local label = Instance.new("TextLabel", frame)
			label.Size = UDim2.new(1, -30, 1, 0)
			label.Position = UDim2.new(0, 30, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = txt
			label.Font = Enum.Font.Code
			label.TextColor3 = Color3.fromRGB(255,255,255)
			label.TextSize = 14
			label.TextXAlignment = Enum.TextXAlignment.Left

			frame.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					t.state = not t.state
					tween(box, {
						BackgroundColor3 = t.state and Color3.fromRGB(0,140,255) or Color3.fromRGB(50,50,50)
					}, .16)
					callback(t.state)
				end
			end)
		end

		return tab
	end

	------------------------------------------------------------------
	-- WATERMARK (FPS, PING, TIME)
	------------------------------------------------------------------
	local wm = Instance.new("TextLabel", gui)
	wm.Size = UDim2.new(0, 260, 0, 20)
	wm.Position = UDim2.new(0, 10, 1, -30)
	wm.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	wm.BorderSizePixel = 0
	wm.Font = Enum.Font.Code
	wm.TextSize = 14
	wm.TextXAlignment = Enum.TextXAlignment.Left
	wm.TextColor3 = Color3.fromRGB(255,255,255)

	Instance.new("UICorner", wm).CornerRadius = UDim.new(0,4)
	local wmStroke = Instance.new("UIStroke", wm)
	wmStroke.Color = Color3.fromRGB(0,140,255)

	RS.RenderStepped:Connect(function()
		local fps = math.floor(1 / RS.RenderStepped:Wait())
		local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		local time = os.date("%H:%M:%S")

		wm.Text = string.format("GGMenu | %s | FPS: %d | Ping: %dms | %s",
			Player.Name, fps, math.floor(ping), time
		)
	end)

	return ui
end

return GG
