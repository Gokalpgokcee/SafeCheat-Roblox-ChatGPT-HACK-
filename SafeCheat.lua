-- GOK CHEAT V6 - DELTA MOBILE UYUMLU
-- HATASIZ, SADE, OPTİMİZE

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
    Name = "GOK CHEAT V6",
    LoadingTitle = "Delta Mobile Optimized",
    LoadingSubtitle = "by Gokalp",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", "rbxassetid://4483345998")
local VisualsTab = Window:CreateTab("Visuals", "rbxassetid://4483345998")
local MovementTab = Window:CreateTab("Movement", "rbxassetid://4483362458")

-- ==================================================
-- AYARLAR
-- ==================================================
local Settings = {
    Aimbot = false,
    AimbotFOV = 180,
    AimbotSmooth = 5,
    AimbotPart = "Head",
    TeamCheck = true,
    VisibleCheck = true,
    Hitbox = false,
    HitboxSize = 3,
    ESP = false,
    ESPName = false,
    Walkspeed = 16,
    AntiAFK = true
}

-- ==================================================
-- COMBAT TAB
-- ==================================================
CombatTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(v) Settings.Aimbot = v end
})

CombatTab:CreateSlider({
    Name = "FOV",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 180,
    Flag = "FOV",
    Callback = function(v) Settings.AimbotFOV = v end
})

CombatTab:CreateSlider({
    Name = "Smoothness",
    Range = {1, 20},
    Increment = 1,
    CurrentValue = 5,
    Flag = "Smooth",
    Callback = function(v) Settings.AimbotSmooth = v end
})

CombatTab:CreateDropdown({
    Name = "Hit Part",
    Options = {"Head", "Torso", "HumanoidRootPart"},
    CurrentOption = "Head",
    Flag = "HitPart",
    Callback = function(v) Settings.AimbotPart = v end
})

CombatTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "TeamCheck",
    Callback = function(v) Settings.TeamCheck = v end
})

CombatTab:CreateToggle({
    Name = "Visible Check",
    CurrentValue = true,
    Flag = "VisibleCheck",
    Callback = function(v) Settings.VisibleCheck = v end
})

CombatTab:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Flag = "Hitbox",
    Callback = function(v) Settings.Hitbox = v end
})

CombatTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {2, 10},
    Increment = 1,
    CurrentValue = 3,
    Flag = "HitboxSize",
    Callback = function(v) Settings.HitboxSize = v end
})

-- ==================================================
-- VISUALS TAB
-- ==================================================
VisualsTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(v) Settings.ESP = v end
})

VisualsTab:CreateToggle({
    Name = "ESP Names",
    CurrentValue = false,
    Flag = "ESPName",
    Callback = function(v) Settings.ESPName = v end
})

-- ==================================================
-- MOVEMENT TAB
-- ==================================================
MovementTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(v) Settings.Walkspeed = v end
})

MovementTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Flag = "AntiAFK",
    Callback = function(v) Settings.AntiAFK = v end
})

MovementTab:CreateButton({
    Name = "FPS Boost",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") then v:Destroy() end
        end
        Rayfield:Notify({Title = "FPS Boost", Content = "Efektler temizlendi", Duration = 3})
    end
})

-- ==================================================
-- SERVISLER
-- ==================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ==================================================
-- FONKSIYONLAR
-- ==================================================
local function IsEnemy(p)
    if p == LocalPlayer then return false end
    if not p.Character or not p.Character:FindFirstChild("Humanoid") then return false end
    if p.Character.Humanoid.Health <= 0 then return false end
    if Settings.TeamCheck and p.Team == LocalPlayer.Team then return false end
    return true
end

local function GetClosestEnemy()
    local closest = nil
    local closestDist = Settings.AimbotFOV
    
    for _, p in ipairs(Players:GetPlayers()) do
        if IsEnemy(p) then
            local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("UpperTorso")
            if root then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < closestDist then
                        if Settings.VisibleCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (root.Position - Camera.CFrame.Position).Unit * 1000)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                            if hit and hit:IsDescendantOf(p.Character) then
                                closest = p
                                closestDist = dist
                            end
                        else
                            closest = p
                            closestDist = dist
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- ==================================================
-- AIMBOT LOOP
-- ==================================================
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local target = GetClosestEnemy()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(Settings.AimbotPart) or target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                if Settings.AimbotSmooth > 1 then
                    local targetCF = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / Settings.AimbotSmooth)
                else
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
                end
            end
        end
    end
end)

-- ==================================================
-- HITBOX LOOP
-- ==================================================
RunService.Heartbeat:Connect(function()
    if Settings.Hitbox then
        for _, p in ipairs(Players:GetPlayers()) do
            if IsEnemy(p) and p.Character and p.Character:FindFirstChild("Head") then
                p.Character.Head.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                p.Character.Head.Transparency = 0.5
            end
        end
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") then
                p.Character.Head.Size = Vector3.new(2, 1, 1)
                p.Character.Head.Transparency = 0
            end
        end
    end
end)

-- ==================================================
-- ESP LOOP
-- ==================================================
RunService.Heartbeat:Connect(function()
    if Settings.ESP and Settings.ESPName then
        for _, p in ipairs(Players:GetPlayers()) do
            if IsEnemy(p) then
                local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("UpperTorso")
                if root then
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local bill = Instance.new("BillboardGui")
                        bill.Adornee = root
                        bill.Size = UDim2.new(0, 100, 0, 30)
                        bill.StudsOffset = Vector3.new(0, 3, 0)
                        bill.AlwaysOnTop = true
                        bill.Parent = LocalPlayer.PlayerGui
                        
                        local text = Instance.new("TextLabel")
                        text.Text = p.Name
                        text.Size = UDim2.new(1, 0, 1, 0)
                        text.BackgroundTransparency = 1
                        text.TextColor3 = Color3.new(1, 0, 0)
                        text.TextStrokeTransparency = 0
                        text.TextScaled = true
                        text.Parent = bill
                        
                        task.delay(0.1, function()
                            if bill then bill:Destroy() end
                        end)
                    end
                end
            end
        end
    end
end)

-- ==================================================
-- WALKSPEED LOOP
-- ==================================================
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Walkspeed
    end
end)

-- ==================================================
-- ANTI-AFK
-- ==================================================
if Settings.AntiAFK then
    LocalPlayer.Idled:Connect(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)
end

-- ==================================================
-- BASLANGIC MESAJI
-- ==================================================
Rayfield:Notify({
    Title = "GOK CHEAT V6",
    Content = "Delta Mobile icin optimize edildi",
    Duration = 3
})

print("GOK CHEAT V6 YUKLENDI - Shadow hatasi cozuldu")
