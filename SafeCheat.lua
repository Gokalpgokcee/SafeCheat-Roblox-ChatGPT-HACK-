-- GOK CHEAT V2 - Delta Optimized | Tüm Özellikler Aktif
loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "GOK CHEAT V2",
    LoadingTitle = "Delta Ultimate",
    LoadingSubtitle = "by Gokalp",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Settings
local Settings = {
    SilentAim = false,
    SilentAimFOV = 150,
    HitPart = "Head",
    TeamCheck = true,
    HitboxExpander = false,
    HitboxSize = 2,
    ESP_Boxes = false,
    Chams = false,
    WalkSpeed = 16,
    Noclip = false,
    AntiAFK = true
}

-- Combat Tab
CombatTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Callback = function(v) Settings.SilentAim = v end
})
CombatTab:CreateSlider({
    Name = "FOV",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 150,
    Callback = function(v) Settings.SilentAimFOV = v end
})
CombatTab:CreateDropdown({
    Name = "Hit Part",
    Options = {"Head", "Torso", "HumanoidRootPart"},
    CurrentOption = "Head",
    Callback = function(v) Settings.HitPart = v end
})
CombatTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(v) Settings.TeamCheck = v end
})
CombatTab:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Callback = function(v) Settings.HitboxExpander = v end
})
CombatTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {2, 20},
    Increment = 1,
    CurrentValue = 2,
    Callback = function(v) Settings.HitboxSize = v end
})

-- Visuals Tab
VisualsTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = false,
    Callback = function(v) Settings.ESP_Boxes = v end
})
VisualsTab:CreateToggle({
    Name = "Chams (Highlight)",
    CurrentValue = false,
    Callback = function(v) Settings.Chams = v end
})

-- Movement Tab
MovementTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) Settings.WalkSpeed = v end
})
MovementTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v) Settings.Noclip = v end
})

-- Misc Tab
MiscTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = function(v) Settings.AntiAFK = v end
})
MiscTab:CreateButton({
    Name = "FPS Boost",
    Callback = function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("PostEffect") or v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v:Destroy()
            end
        end
        workspace.DescendantAdded:Connect(function(d)
            if d:IsA("PostEffect") or d:IsA("ParticleEmitter") or d:IsA("Trail") then
                d:Destroy()
            end
        end)
        Rayfield:Notify("FPS Boost", "Gereksiz efektler temizlendi", 3)
    end
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Variables
local Target = nil
local ESPCache = {}

-- Target finder
local function IsEnemy(p)
    if p == LocalPlayer then return false end
    if not p.Character or not p.Character:FindFirstChild("Humanoid") or p.Character.Humanoid.Health <= 0 then return false end
    if Settings.TeamCheck and p.Team == LocalPlayer.Team then return false end
    return true
end

task.spawn(function()
    while task.wait(0.1) do
        if Settings.SilentAim then
            local closest = nil
            local closestDist = Settings.SilentAimFOV
            for _, p in pairs(Players:GetPlayers()) do
                if IsEnemy(p) then
                    local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("UpperTorso")
                    if root then
                        local pos, vis = Camera:WorldToViewportPoint(root.Position)
                        if vis then
                            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closest = p
                            end
                        end
                    end
                end
            end
            Target = closest
        else
            Target = nil
        end
    end
end)

-- Silent Aim hook (__namecall)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if Settings.SilentAim and Target and Target.Character then
        local hitPart = Target.Character:FindFirstChild(Settings.HitPart) or Target.Character:FindFirstChild("Head") or Target.Character:FindFirstChild("HumanoidRootPart")
        if hitPart then
            if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast" then
                -- Modify ray direction to hit target
                local origin = args[1].Origin or Camera.CFrame.Position
                local direction = (hitPart.Position - origin).Unit * 1000
                if method == "Raycast" then
                    args[2] = direction
                else
                    args[1] = Ray.new(origin, direction)
                end
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- Movement & Hitbox loop
RunService.RenderStepped:Connect(function()
    -- WalkSpeed
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
    end

    -- Noclip
    if Settings.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end

    -- Hitbox Expander
    if Settings.HitboxExpander then
        for _, p in pairs(Players:GetPlayers()) do
            if IsEnemy(p) and p.Character and p.Character:FindFirstChild("Head") then
                p.Character.Head.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                p.Character.Head.Transparency = 0.5
                p.Character.Head.CanCollide = false
                p.Character.Head.Material = Enum.Material.Neon
            end
        end
    else
        -- Reset hitbox sizes (optional, but may cause issues if other scripts modify)
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") then
                p.Character.Head.Size = Vector3.new(2, 1, 1) -- default head size? Actually default is 2,1,1? Not exactly but close
                p.Character.Head.Transparency = 0
                p.Character.Head.Material = Enum.Material.Plastic
            end
        end
    end

    -- ESP & Chams
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        if not IsEnemy(p) then
            if ESPCache[p] then
                for _, obj in pairs(ESPCache[p]) do obj:Destroy() end
                ESPCache[p] = nil
            end
            continue
        end

        if not ESPCache[p] then ESPCache[p] = {} end

        -- Box ESP
        if Settings.ESP_Boxes then
            if not ESPCache[p].Billboard then
                local bill = Instance.new("BillboardGui")
                bill.Adornee = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("UpperTorso")
                bill.Size = UDim2.new(4, 0, 5, 0)
                bill.AlwaysOnTop = true
                bill.Parent = CoreGui
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundTransparency = 1
                frame.Parent = bill
                local stroke = Instance.new("UIStroke")
                stroke.Thickness = 2
                stroke.Color = Color3.new(1, 0, 0)
                stroke.Parent = frame
                ESPCache[p].Billboard = bill
                ESPCache[p].Stroke = stroke
            end
            ESPCache[p].Billboard.Adornee = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("UpperTorso")
            ESPCache[p].Billboard.Enabled = true
        else
            if ESPCache[p].Billboard then
                ESPCache[p].Billboard:Destroy()
                ESPCache[p].Billboard = nil
            end
        end

        -- Chams
        if Settings.Chams then
            if not ESPCache[p].Highlight then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.new(1, 0, 0)
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.FillTransparency = 0.5
                hl.Parent = CoreGui
                ESPCache[p].Highlight = hl
            end
            ESPCache[p].Highlight.Adornee = p.Character
            ESPCache[p].Highlight.Enabled = true
        else
            if ESPCache[p].Highlight then
                ESPCache[p].Highlight:Destroy()
                ESPCache[p].Highlight = nil
            end
        end
    end
end)

-- Anti-AFK
if Settings.AntiAFK then
    LocalPlayer.Idled:Connect(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)
end

-- Cleanup on player leave
Players.PlayerRemoving:Connect(function(p)
    if ESPCache[p] then
        for _, obj in pairs(ESPCache[p]) do obj:Destroy() end
        ESPCache[p] = nil
    end
end)

Rayfield:Notify({
    Title = "GOK CHEAT V2",
    Content = "Delta'da çalışacak şekilde optimize edildi!",
    Duration = 5
})
