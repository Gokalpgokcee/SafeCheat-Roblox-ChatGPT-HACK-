local Library = {} -- Basit bir kütüphane yapısı

-- Başlangıç Ayarları
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Özellik Durumları (Toggle States)
local Flags = {
    Aimbot = false,
    ESP = false,
    Speed = 16,
    Jump = 50
}

-- GUI OLUŞTURMA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SafeCheat_Main"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner", MainFrame)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "SAFE CHEAT"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

-- SEKME SİSTEMİ (Basit butonlar)
local function CreateButton(name, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.Parent = MainFrame
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(callback)
    return btn
end

--- [VISUALS - ESP] ---
local function UpdateESP()
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local highlight = v.Character:FindFirstChild("SafeESP")
            if Flags.ESP then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "SafeESP"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = v.Character
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

CreateButton("Toggle ESP", UDim2.new(0.05, 0, 0.2, 0), function()
    Flags.ESP = not Flags.ESP
    print("ESP: " .. tostring(Flags.ESP))
end)

--- [COMBAT - AIMBOT] ---
CreateButton("Aimbot", UDim2.new(0.35, 0, 0.2, 0), function()
    Flags.Aimbot = not Flags.Aimbot
    print("Aimbot: " .. tostring(Flags.Aimbot))
end)

RunService.RenderStepped:Connect(function()
    if Flags.Aimbot then
        local closestPlayer = nil
        local shortestDistance = math.huge

        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                if onScreen then
                    local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if distance < shortestDistance then
                        closestPlayer = v
                        shortestDistance = distance
                    end
                end
            end
        end

        if closestPlayer then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.HumanoidRootPart.Position)
        end
    end
    UpdateESP()
end)

--- [MISC - SPEED & JUMP] ---
CreateButton("Speed (100)", UDim2.new(0.65, 0, 0.2, 0), function()
    Player.Character.Humanoid.WalkSpeed = 100
end)

CreateButton("Inf Jump", UDim2.new(0.05, 0, 0.4, 0), function()
    game:GetService("UserInputService").JumpRequest:Connect(function()
        Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end)
end)

CreateButton("Reset Stats", UDim2.new(0.35, 0, 0.4, 0), function()
    Player.Character.Humanoid.WalkSpeed = 16
    Player.Character.Humanoid.JumpPower = 50
end)

print("Safe Cheat Aktif Edildi!")
