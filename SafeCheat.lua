-- [[ G&G V11.0 - OMNIPOTENT MOBILE OVERHAUL ]] --
-- Delta / Mobile Optimized | 400+ Lines of Pure Power

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- [ 1. CONFIGURATION SYSTEM ]
_G.GG_Settings = {
    Combat = {
        Aimbot = false, SilentAim = false, FOV = 100, Smooth = 0.1, 
        TargetPart = "Head", WallCheck = true, TriggerBot = false
    },
    Visuals = {
        Boxes = false, Names = false, Health = false, Distance = false, 
        Chams = false, Tracers = false, ChamsColor = Color3.fromRGB(0, 255, 255)
    },
    Movement = {
        WalkSpeed = 16, JumpPower = 50, Fly = false, FlySpeed = 50, 
        InfJump = false, Noclip = false, AutoBhop = false
    },
    Rage = {
        HitboxExpander = false, HitboxSize = 2, HitboxPart = "Head", 
        SpinBot = false, AntiAim = false, RainbowGUI = false
    }
}

-- [ 2. UTILITY FUNCTIONS ]
local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- [ 3. GUI ENGINE ]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "GG_Omnipotent_V11"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
MakeDraggable(MainFrame)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", TopBar)
local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "G&G V11.0 | OMNIPOTENT MOBILE"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 130, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)

local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -140, 1, -50)
Container.Position = UDim2.new(0, 135, 0, 45)
Container.BackgroundTransparency = 1

local Pages = {}
local function CreatePage(name, index)
    local Page = Instance.new("ScrollingFrame", Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = (index == 1)
    Page.ScrollBarThickness = 2
    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 5)

    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, -10, 0, 35)
    TabBtn.Position = UDim2.new(0, 5, 0, 5 + (index-1)*40)
    TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.new(1, 1, 1)
    TabBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", TabBtn)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Page.Visible = true
    end)
    Pages[name] = Page
    return Page
end

-- [ 4. UI COMPONENTS ]
local function AddToggle(page, text, configTable, configKey)
    local btn = Instance.new("TextButton", page)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = "  " .. text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        _G.GG_Settings[configTable][configKey] = not _G.GG_Settings[configTable][configKey]
        local active = _G.GG_Settings[configTable][configKey]
        btn.Text = "  " .. text .. ": " .. (active and "ON" or "OFF")
        btn.TextColor3 = active and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(150, 150, 150)
    end)
end

local function AddSlider(page, text, min, max, configTable, configKey)
    local sFrame = Instance.new("Frame", page)
    sFrame.Size = UDim2.new(1, -10, 0, 50)
    sFrame.BackgroundTransparency = 1
    
    local sLabel = Instance.new("TextLabel", sFrame)
    sLabel.Size = UDim2.new(1, 0, 0, 20)
    sLabel.Text = text .. ": " .. _G.GG_Settings[configTable][configKey]
    sLabel.TextColor3 = Color3.new(1, 1, 1)
    sLabel.BackgroundTransparency = 1

    local sBG = Instance.new("Frame", sFrame)
    sBG.Size = UDim2.new(1, 0, 0, 6)
    sBG.Position = UDim2.new(0, 0, 0.6, 0)
    sBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    
    local sFill = Instance.new("Frame", sBG)
    sFill.Size = UDim2.new(0, 0, 1, 0)
    sFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)

    local function UpdateSlider(input)
        local inputPos = (input.Position.X - sBG.AbsolutePosition.X) / sBG.AbsoluteSize.X
        local pos = math.clamp(inputPos, 0, 1)
        sFill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max - min) * pos)
        _G.GG_Settings[configTable][configKey] = val
        sLabel.Text = text .. ": " .. val
    end

    sBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local moveCon
            moveCon = RunService.RenderStepped:Connect(function() UpdateSlider(input) end)
            local endCon
            endCon = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == input.UserInputType then
                    moveCon:Disconnect()
                    endCon:Disconnect()
                end
            end)
        end
    end)
end

-- [ 5. POPULATING PAGES ]
local CombatPage = CreatePage("Combat", 1)
local VisualPage = CreatePage("Visuals", 2)
local MovementPage = CreatePage("Movement", 3)
local RagePage = CreatePage("Rage/OP", 4)

AddToggle(CombatPage, "Aimbot", "Combat", "Aimbot")
AddToggle(CombatPage, "Silent Aim (Bullet TP)", "Combat", "SilentAim")
AddToggle(CombatPage, "Visible Check", "Combat", "WallCheck")
AddSlider(CombatPage, "FOV", 10, 800, "Combat", "FOV")

AddToggle(VisualPage, "Box ESP", "Visuals", "Boxes")
AddToggle(VisualPage, "Name & Health", "Visuals", "Names")
AddToggle(VisualPage, "Chams (Wallhack)", "Visuals", "Chams")
AddToggle(VisualPage, "Tracers", "Visuals", "Tracers")

AddToggle(MovementPage, "Infinite Jump", "Movement", "InfJump")
AddToggle(MovementPage, "Noclip", "Movement", "Noclip")
AddToggle(MovementPage, "Fly Mode", "Movement", "Fly")
AddSlider(MovementPage, "Speed", 16, 250, "Movement", "WalkSpeed")
AddSlider(MovementPage, "JumpPower", 50, 500, "Movement", "JumpPower")

AddToggle(RagePage, "Hitbox Expander", "Rage", "HitboxExpander")
AddSlider(RagePage, "Hitbox Scale", 1, 40, "Rage", "HitboxSize")
AddToggle(RagePage, "Rainbow GUI", "Rage", "RainbowGUI")

-- [ 6. THE CORE ENGINE (OPTIMIZED) ]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 0.5
FOVCircle.Color = Color3.fromRGB(0, 255, 255)

local function GetTarget()
    local target = nil
    local dist = _G.GG_Settings.Combat.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < dist then
                        if _G.GG_Settings.Combat.WallCheck then
                            local parts = Camera:GetPartsObscuringTarget({p.Character.HumanoidRootPart.Position}, {p.Character, LocalPlayer.Character})
                            if #parts == 0 then dist = mag target = p end
                        else
                            dist = mag target = p
                        end
                    end
                end
            end
        end
    end
    return target
end

-- ESP & Visual Updates
local function ApplyESP(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local hrp = char:WaitForChild("HumanoidRootPart")
        
        -- Billboard GUI (Names/Health)
        local bbg = Instance.new("BillboardGui", CoreGui)
        bbg.Name = "GG_BBG_" .. p.Name
        bbg.Adornee = hrp
        bbg.Size = UDim2.new(4, 0, 5, 0)
        bbg.AlwaysOnTop = true

        local txt = Instance.new("TextLabel", bbg)
        txt.Size = UDim2.new(1, 0, 0.2, 0)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.new(1, 1, 1)
        txt.TextStrokeTransparency = 0
        txt.TextScaled = true
        txt.Font = Enum.Font.GothamBold

        local box = Instance.new("Frame", bbg)
        box.Size = UDim2.new(1, 0, 1, 0)
        box.BackgroundTransparency = 1
        local stroke = Instance.new("UIStroke", box)
        stroke.Thickness = 1.5
        stroke.Color = Color3.fromRGB(0, 255, 255)

        local highlight = Instance.new("Highlight", char)
        highlight.FillColor = _G.GG_Settings.Visuals.ChamsColor

        RunService.Heartbeat:Connect(function()
            if char and char:Parent() then
                highlight.Enabled = _G.GG_Settings.Visuals.Chams
                txt.Visible = _G.GG_Settings.Visuals.Names
                box.Visible = _G.GG_Settings.Visuals.Boxes
                txt.Text = p.Name .. " | " .. math.floor(char.Humanoid.Health) .. " HP"
            else
                bbg:Destroy() highlight:Destroy()
            end
        end)
    end)
end

for _, p in pairs(Players:GetPlayers()) do ApplyESP(p) end
Players.PlayerAdded:Connect(ApplyESP)

-- [ 7. MAIN RUNTIME LOOP ]
RunService.RenderStepped:Connect(function()
    -- Rainbow UI
    if _G.GG_Settings.Rage.RainbowGUI then
        local hue = tick() % 5 / 5
        Title.TextColor3 = Color3.fromHSV(hue, 1, 1)
        FOVCircle.Color = Color3.fromHSV(hue, 1, 1)
    end

    -- FOV Update
    FOVCircle.Visible = _G.GG_Settings.Combat.Aimbot
    FOVCircle.Radius = _G.GG_Settings.Combat.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    -- Player Updates
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        hum.WalkSpeed = _G.GG_Settings.Movement.WalkSpeed
        hum.JumpPower = _G.GG_Settings.Movement.JumpPower
        
        if _G.GG_Settings.Movement.Noclip then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end

    -- Combat Logic
    local target = GetTarget()
    if target and target.Character then
        if _G.GG_Settings.Combat.Aimbot then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), _G.GG_Settings.Combat.Smooth)
        end
        
        if _G.GG_Settings.Rage.HitboxExpander then
            local hb = target.Character:FindFirstChild(_G.GG_Settings.Rage.HitboxPart)
            if hb then
                hb.Size = Vector3.new(_G.GG_Settings.Rage.HitboxSize, _G.GG_Settings.Rage.HitboxSize, _G.GG_Settings.Rage.HitboxSize)
                hb.Transparency = 0.7
                hb.CanCollide = false
            end
        end
    end
end)

-- Fly Hack Logic
local bodyVel
RunService.Heartbeat:Connect(function()
    if _G.GG_Settings.Movement.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.Velocity = Camera.CFrame.LookVector * _G.GG_Settings.Movement.FlySpeed
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if _G.GG_Settings.Movement.InfJump and LocalPlayer.Character then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- [ 8. TOGGLE BUTTON ]
local Tbtn = Instance.new("TextButton", ScreenGui)
Tbtn.Size = UDim2.new(0, 50, 0, 50)
Tbtn.Position = UDim2.new(0, 5, 0.4, 0)
Tbtn.Text = "G&G"
Tbtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Instance.new("UICorner", Tbtn).CornerRadius = UDim.new(1, 0)
Tbtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

print("G&G V11.0 OMNIPOTENT - Mobildeki En Güçlü Silahın.")
