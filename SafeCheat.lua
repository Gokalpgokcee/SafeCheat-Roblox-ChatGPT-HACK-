-- SafeCheat GUI
-- LocalScript olarak StarterPlayerScripts içine koy

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SafeCheat"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 600, 0, 350)
Main.Position = UDim2.new(0.5, -300, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundColor3 = Color3.fromRGB(35,35,35)
Title.Text = "SafeCheat"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Parent = Main

-- Category Frame
local CategoryFrame = Instance.new("Frame")
CategoryFrame.Size = UDim2.new(0,150,1,-40)
CategoryFrame.Position = UDim2.new(0,0,0,40)
CategoryFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
CategoryFrame.Parent = Main

-- Module Frame
local ModuleFrame = Instance.new("Frame")
ModuleFrame.Size = UDim2.new(1,-150,1,-40)
ModuleFrame.Position = UDim2.new(0,150,0,40)
ModuleFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
ModuleFrame.Parent = Main

-- UIListLayouts
local CatLayout = Instance.new("UIListLayout", CategoryFrame)
CatLayout.Padding = UDim.new(0,5)

local ModLayout = Instance.new("UIListLayout", ModuleFrame)
ModLayout.Padding = UDim.new(0,5)

-- Categories
local categories = {"Visual", "Combat", "Player", "Misc"}

-- Clear modules
local function ClearModules()
	for _, child in pairs(ModuleFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

-- Create Module Button
local function CreateModule(name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1,-10,0,40)
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Text = name .. " [OFF]"
	btn.Parent = ModuleFrame
	
	local enabled = false
	
	btn.MouseButton1Click:Connect(function()
		enabled = not enabled
		if enabled then
			btn.Text = name .. " [ON]"
			btn.BackgroundColor3 = Color3.fromRGB(0,170,0)
		else
			btn.Text = name .. " [OFF]"
			btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
		end
	end)
end

-- Load category modules
local function LoadCategory(category)
	ClearModules()
	
	if category == "Visual" then
		CreateModule("ESP")
		CreateModule("Fullbright")
		CreateModule("Tracers")
		
	elseif category == "Combat" then
		CreateModule("KillAura")
		CreateModule("AutoClick")
		
	elseif category == "Player" then
		CreateModule("Speed")
		CreateModule("HighJump")
		
	elseif category == "Misc" then
		CreateModule("AutoRespawn")
		CreateModule("AntiAFK")
	end
end

-- Create Category Buttons
for _, cat in ipairs(categories) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1,-10,0,40)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Text = cat
	btn.Parent = CategoryFrame
	
	btn.MouseButton1Click:Connect(function()
		LoadCategory(cat)
	end)
end

-- Toggle GUI with RightShift
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		Main.Visible = not Main.Visible
	end
end)

-- Default open category
LoadCategory("Visual")
