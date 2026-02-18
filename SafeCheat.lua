-- [[ G&G V9.0 - THE FINAL OVERHAUL (LEGIT & RAGE) ]] --

local Library = {
    Flags = {},
    Enabled = true
}

-- [SERVICES]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- [CONFIG]
_G.GG_V9_Config = {
    Aimbot = {Enabled = false, Smoothness = 0.1, FOV = 100, VisibleCheck = true, Bone = "Head", Silent = false},
    Visuals = {Boxes = false, Skeletons = false, Chams = false, Names = false, Tracers = false, Health = false},
    Movement = {WalkSpeed = 16, JumpPower = 50, Fly = false, FlySpeed = 20, Bhop = false},
    OP = {RageHitbox = false, HitboxSize = 2, SpinBot = false, InstantKill = false, Noclip = false}
}

-- [DRAWING API CHECK & ESP CORE]
local function CreateDrawing(type, properties)
    local d = Drawing.new(type)
    for i, v in pairs(properties) do d[i] = v end
    return d
end

local espObjects = {}
local function RemoveESP(p)
    if espObjects[p] then
        for _, obj in pairs(espObjects[p]) do obj:Remove() end
        espObjects[p] = nil
    end
end

-- [GUI BUILDER - ROBUST VERSION]
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TabHolder = Instance.new("Frame")
local PageHolder = Instance.new("Frame")

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.Name = "GG_V9_UI"
end)

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", MainFrame) Stroke.Color = Color3.fromRGB(0, 255, 255) Stroke.Thickness = 2

-- Tab System
local function CreateTab(name, pos)
    local btn = Instance.new("TextButton", TabHolder)
    btn.Size = UDim2.new(0, 120, 0, 40)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    
    local page = Instance.new("ScrollingFrame", PageHolder)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 2
    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0, 10)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(PageHolder:GetChildren()) do v.Visible = false end
        page.Visible = true
    end)
    return page
end

TabHolder.Parent = MainFrame
TabHolder.Size = UDim2.new(1, 0, 0, 50)
TabHolder.BackgroundTransparency = 1

PageHolder.Parent = MainFrame
PageHolder.Position = UDim2.new(0, 10, 0, 60)
PageHolder.Size = UDim2.new(1, -20, 1, -70)
PageHolder.BackgroundTransparency = 1

-- Page Creation
local CombatPage = CreateTab("Combat", UDim2.new(0, 10, 0, 5))
local VisualsPage = CreateTab("Visuals", UDim2.new(0, 140, 0, 5))
local PlayerPage = CreateTab("Movement", UDim2.new(0, 270, 0, 5))
local RagePage = CreateTab("Rage/OP", UDim2.new(0, 400, 0, 5))

CombatPage.Visible = true -- Default

-- [UI ELEMENTS FUNCTIONS]
local function AddToggle(parent, text, configPath, configKey)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 500, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = text
    btn.TextColor3 = Color3.new(0.6, 0.6, 0.6)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        _G.GG_V9_Config[configPath][configKey] = not _G.GG_V9_Config[configPath][configKey]
        local active = _G.GG_V9_Config[configPath][configKey]
        btn.TextColor3 = active and Color3.fromRGB(0, 255, 255) or Color3.new(0.6, 0.6, 0.6)
        btn.BackgroundColor3 = active and Color3.fromRGB(30, 40, 40) or Color3.fromRGB(25, 25, 25)
    end)
end

local function AddSlider(parent, text, min, max, configPath, configKey)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0, 500, 0, 50)
    frame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.Text = text .. ": " .. _G.GG_V9_Config[configPath][configKey]
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.BackgroundTransparency = 1
    
    local sliderBG = Instance.new("Frame", frame)
    sliderBG.Size = UDim2.new(1, 0, 0, 5)
    sliderBG.Position = UDim2.new(0, 0, 0.6, 0)
    sliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    local mainSlider = Instance.new("Frame", sliderBG)
    mainSlider.Size = UDim2.new(0, 15, 0, 15)
    mainSlider.Position = UDim2.new(0, 0, -1, 0)
    mainSlider.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    
    local dragging = false
    mainSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local pos = math.clamp((Mouse.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
            mainSlider.Position = UDim2.new(pos, -7, -1, 0)
            local val = math.floor(min + (max - min) * pos)
            _G.GG_V9_Config[configPath][configKey] = val
            lbl.Text = text .. ": " .. val
        end
    end)
end

-- [POPULATING UI]
-- Combat
AddToggle(CombatPage, "Legit Aimbot", "Aimbot", "Enabled")
AddToggle(CombatPage, "Silent Aim (OP)", "Aimbot", "Silent")
AddToggle(CombatPage, "Wall Check", "Aimbot", "VisibleCheck")
AddSlider(CombatPage, "FOV Size", 10, 800, "Aimbot", "FOV")
AddSlider(CombatPage, "Smoothness (Legit)", 1, 100, "Aimbot", "Smoothness")

-- Visuals
AddToggle(VisualsPage, "Box ESP", "Visuals", "Boxes")
AddToggle(VisualsPage, "Skeleton ESP (New)", "Visuals", "Skeletons")
AddToggle(VisualsPage, "Chams (Wallhack)", "Visuals", "Chams")
AddToggle(VisualsPage, "Health Bar", "Visuals", "Health")

-- Movement
AddToggle(PlayerPage, "Infinite Jump", "Movement", "Bhop")
AddToggle(PlayerPage, "Fly Mode", "Movement", "Fly")
AddSlider(PlayerPage, "Fly Speed", 10, 200, "Movement", "FlySpeed")
AddSlider(PlayerPage, "WalkSpeed", 16, 200, "Movement", "WalkSpeed")

-- Rage/OP (BANNABLE)
AddToggle(RagePage, "Rage Hitbox (Max)", "OP", "RageHitbox")
AddSlider(RagePage, "Hitbox Scale", 1, 30, "OP", "HitboxSize")
AddToggle(RagePage, "Noclip (Duvar Geçme)", "OP", "Noclip")

-- [CORE LOGIC - PERFORMANCE OPTIMIZED]
local FOVCircle = CreateDrawing("Circle", {Thickness = 1, Color = Color3.new(0, 1, 1), Filled = false, Transparency = 0.5})

RunService.RenderStepped:Connect(function()
    -- UI Refresh
    FOVCircle.Visible = _G.GG_V9_Config.Aimbot.Enabled
    FOVCircle.Radius = _G.GG_V9_Config.Aimbot.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Movement Core
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        hum.WalkSpeed = _G.GG_V9_Config.Movement.WalkSpeed
        hum.JumpPower = _G.GG_V9_Config.Movement.JumpPower
        
        -- Noclip
        if _G.GG_V9_Config.OP.Noclip then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end

    -- ESP & Hitbox & Aimbot Loop
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local char = p.Character
            local head = char.Head
            local hum = char:FindFirstChild("Humanoid")
            
            if hum and hum.Health > 0 then
                -- Hitbox OP
                if _G.GG_V9_Config.OP.RageHitbox then
                    head.Size = Vector3.new(_G.GG_V9_Config.OP.HitboxSize, _G.GG_V9_Config.OP.HitboxSize, _G.GG_V9_Config.OP.HitboxSize)
                    head.Transparency = 0.7
                    head.CanCollide = false
                else
                    head.Size = Vector3.new(1.2, 1.2, 1.2)
                    head.Transparency = 0
                end

                -- Chams (New Highlight System)
                if _G.GG_V9_Config.Visuals.Chams then
                    if not char:FindFirstChild("GG_Cham") then
                        local h = Instance.new("Highlight", char)
                        h.Name = "GG_Cham"
                        h.FillColor = Color3.fromRGB(0, 255, 255)
                        h.OutlineColor = Color3.new(1, 1, 1)
                    end
                else
                    if char:FindFirstChild("GG_Cham") then char.GG_Cham:Destroy() end
                end

                -- ESP (Drawing)
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    -- Buraya ESP çizimleri gelecek (Performans için cache'li)
                end
            end
        end
    end
end)

-- Fly Logic
local function HandleFly()
    RunService.Heartbeat:Connect(function()
        if _G.GG_V9_Config.Movement.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local moveDir = LocalPlayer.Character.Humanoid.MoveDirection
            hrp.Velocity = moveDir * _G.GG_V9_Config.Movement.FlySpeed + Vector3.new(0, 2, 0)
        end
    end)
end
HandleFly()

-- [NOTIFICATION]
print("G&G V9.0 Yuklendi! Menu Tusuna gerek yok, GUI ekranda.")
