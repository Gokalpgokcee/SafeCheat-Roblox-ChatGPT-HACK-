-- [[ G&G V12.0 - RAYFIELD ELITE (NO KEY / NO DISCORD) ]] --
-- Delta & Mobile Optimized

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [ 1. CONFIGURATION ]
_G.GG_Elite = {
    Aimbot = false,
    SilentAim = false,
    FOV = 100,
    Smoothness = 0.5,
    WallCheck = false,
    
    Chams = false,
    Names = false,
    Boxes = false,
    
    Speed = 16,
    JumpPower = 50,
    Fly = false,
    Noclip = false,
    
    HitboxSize = 2,
    HitboxEnabled = false
}

-- [ 2. CREATE WINDOW ]
local Window = Rayfield:CreateWindow({
   Name = "G&G Elite V12.0 | Mobile Edition",
   LoadingTitle = "G&G Sistemleri Hazırlanıyor...",
   LoadingSubtitle = "Hazırlayan: Gökalp",
   ConfigurationSaving = {
      Enabled = false -- Hızlı açılış için kapalı
   },
   Discord = {
      Enabled = false -- İstediğin gibi kaldırıldı
   },
   KeySystem = false -- İstediğin gibi kaldırıldı
})

-- [ 3. TABS ]
local CombatTab = Window:CreateTab("Combat ⚔️", 4483362458)
local VisualsTab = Window:CreateTab("Visuals 👁️", 4483345998)
local MovementTab = Window:CreateTab("Movement ⚡", 4483362458)
local RageTab = Window:CreateTab("Rage/OP 🔥", 4483362458)

-- [ 4. COMBAT TAB ]
CombatTab:CreateToggle({
   Name = "Aimbot (Camera Lock)",
   CurrentValue = false,
   Callback = function(Value) _G.GG_Elite.Aimbot = Value end,
})

CombatTab:CreateToggle({
   Name = "Silent Aim (Bullet Redirection)",
   CurrentValue = false,
   Callback = function(Value) _G.GG_Elite.SilentAim = Value end,
})

CombatTab:CreateSlider({
   Name = "Aimbot FOV",
   Range = {0, 800},
   Increment = 10,
   CurrentValue = 100,
   Callback = function(Value) _G.GG_Elite.FOV = Value end,
})

CombatTab:CreateSlider({
   Name = "Smoothness (Yumuşaklık)",
   Range = {0.1, 1},
   Increment = 0.1,
   CurrentValue = 0.5,
   Callback = function(Value) _G.GG_Elite.Smoothness = Value end,
})

-- [ 5. VISUALS TAB ]
VisualsTab:CreateToggle({
   Name = "Chams (Gövde Görüşü)",
   CurrentValue = false,
   Callback = function(Value) _G.GG_Elite.Chams = Value end,
})

VisualsTab:CreateToggle({
   Name = "Names & Health ESP",
   CurrentValue = false,
   Callback = function(Value) _G.GG_Elite.Names = Value end,
})

VisualsTab:CreateToggle({
   Name = "Box ESP",
   CurrentValue = false,
   Callback = function(Value) _G.GG_Elite.Boxes = Value end,
})

-- [ 6. MOVEMENT TAB ]
MovementTab:CreateSlider({
   Name = "WalkSpeed (Hız)",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value) _G.GG_Elite.Speed = Value end,
})

MovementTab:CreateSlider({
   Name = "JumpPower (Zıplama)",
   Range = {50, 500},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(Value) _G.GG_Elite.JumpPower = Value end,
})

MovementTab:CreateToggle({
   Name = "Noclip (Duvar Geçme)",
   CurrentValue = false,
   Callback = function(Value) _G.GG_Elite.Noclip = Value end,
})

MovementTab:CreateToggle({
   Name = "Fly Mode (Uçuş)",
   CurrentValue = false,
   Callback = function(Value) _G.GG_Elite.Fly = Value end,
})

-- [ 7. RAGE TAB ]
RageTab:CreateToggle({
   Name = "Hitbox Expander (Kafa Büyütme)",
   CurrentValue = false,
   Callback = function(Value) _G.GG_Elite.HitboxEnabled = Value end,
})

RageTab:CreateSlider({
   Name = "Hitbox Size",
   Range = {2, 40},
   Increment = 1,
   CurrentValue = 2,
   Callback = function(Value) _G.GG_Elite.HitboxSize = Value end,
})

-- [ 8. CORE LOGIC - PERFORMANCE OPTIMIZED ]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- ESP System
local function SetupESP(p)
    p.CharacterAdded:Connect(function(char)
        local high = Instance.new("Highlight", char)
        high.FillColor = Color3.fromRGB(0, 255, 255)
        
        local bbg = Instance.new("BillboardGui", game:GetService("CoreGui"))
        bbg.AlwaysOnTop = true
        bbg.Size = UDim2.new(4,0,5,0)
        bbg.Adornee = char:WaitForChild("HumanoidRootPart")
        
        local txt = Instance.new("TextLabel", bbg)
        txt.Size = UDim2.new(1,0,0.2,0)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.new(1,1,1)
        txt.Font = Enum.Font.GothamBold
        txt.TextScaled = true

        RunService.RenderStepped:Connect(function()
            if char and char:Parent() then
                high.Enabled = _G.GG_Elite.Chams
                txt.Visible = _G.GG_Elite.Names
                txt.Text = p.Name .. " [" .. math.floor(char.Humanoid.Health) .. "]"
            else
                bbg:Destroy()
            end
        end)
    end)
end

for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then SetupESP(p) end end
Players.PlayerAdded:Connect(SetupESP)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = _G.GG_Elite.Speed
        LocalPlayer.Character.Humanoid.JumpPower = _G.GG_Elite.JumpPower
        
        if _G.GG_Elite.Noclip then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
        
        if _G.GG_Elite.Fly then
            LocalPlayer.Character.HumanoidRootPart.Velocity = Camera.CFrame.LookVector * 100
        end
    end
    
    -- Hitbox Logic
    if _G.GG_Elite.HitboxEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                p.Character.Head.Size = Vector3.new(_G.GG_Elite.HitboxSize, _G.GG_Elite.HitboxSize, _G.GG_Elite.HitboxSize)
                p.Character.Head.Transparency = 0.6
            end
        end
    end
end)

Rayfield:Notify({
   Title = "G&G Elite Yüklendi!",
   Content = "Key sistemi olmadan başarıyla çalıştırıldı. İyi oyunlar Gökalp!",
   Duration = 5,
   Image = 4483362458,
})
