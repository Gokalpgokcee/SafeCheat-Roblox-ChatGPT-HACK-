-- [[ G&G V15.0 - INTERNAL STEALTH (ANTI-ESP BAN) ]] --
-- Drawing API Kullanmaz, Tamamen Roblox Motoru Üzerinden Çalışır

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

_G.SafeESP = {
    Enabled = false,
    TeamCheck = true,
    ShowNames = false,
    Distance = false,
    SafeAimbot = false,
    Smoothness = 0.9, -- Çok yüksek yumuşaklık
    BypassSpeed = 16
}

local Window = Rayfield:CreateWindow({
   Name = "G&G V15.0 | ANTI-BAN STEALTH",
   LoadingTitle = "Güvenlik Katmanları Yükleniyor...",
   LoadingSubtitle = "Hazırlayan: Gökalp",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false 
})

-- [ SEKMELER ]
local StealthTab = Window:CreateTab("Bypass ESP 🛡️", 4483345998)
local LegitTab = Window:CreateTab("Legit Aim 🎯", 4483362458)

-- [ ESP SEKMESİ ]
StealthTab:CreateToggle({
   Name = "Internal Highlight ESP (En Güvenli)",
   CurrentValue = false,
   Callback = function(Value) _G.SafeESP.Enabled = Value end,
})

StealthTab:CreateToggle({
   Name = "Takım Kontrolü",
   CurrentValue = true,
   Callback = function(Value) _G.SafeESP.TeamCheck = Value end,
})

-- [ LEGIT AIM ]
LegitTab:CreateToggle({
   Name = "Human-Like Aimbot",
   CurrentValue = false,
   Callback = function(Value) _G.SafeESP.SafeAimbot = Value end,
})

LegitTab:CreateSlider({
   Name = "Aim Yumuşaklığı",
   Range = {0.8, 1},
   Increment = 0.01,
   CurrentValue = 0.9,
   Callback = function(Value) _G.SafeESP.Smoothness = Value end,
})

-- [ CORE SCRIPT ]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- BAN YEMEMEN İÇİN ÖZEL ESP SİSTEMİ
local function CreateSafeESP(p)
    if p == LocalPlayer then return end

    local function Apply(char)
        -- Drawing.new yerine Roblox'un kendi Highlight objesini kullanıyoruz (Tespit edilemez)
        local highlight = Instance.new("Highlight")
        highlight.Name = "Internal_G"
        highlight.Parent = char
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        
        -- BillboardGui ile isim (Sadece çok yakındayken görünür yapabilirsin)
        local bbg = Instance.new("BillboardGui", game:GetService("CoreGui"))
        bbg.Size = UDim2.new(0, 100, 0, 50)
        bbg.AlwaysOnTop = true
        bbg.Adornee = char:WaitForChild("HumanoidRootPart")
        
        local txt = Instance.new("TextLabel", bbg)
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.new(1, 1, 1)
        txt.TextStrokeTransparency = 0
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 10
        txt.Visible = false

        RunService.Heartbeat:Connect(function()
            if char and char:Parent() then
                local isTeam = (p.Team == LocalPlayer.Team)
                
                if _G.SafeESP.Enabled then
                    if _G.SafeESP.TeamCheck and isTeam then
                        highlight.Enabled = false
                        txt.Visible = false
                    else
                        highlight.Enabled = true
                        highlight.FillColor = isTeam and Color3.new(0,1,0) or Color3.new(1,0,0)
                        txt.Visible = _G.SafeESP.ShowNames
                        txt.Text = p.Name
                    end
                else
                    highlight.Enabled = false
                    txt.Visible = false
                end
            else
                highlight:Destroy()
                bbg:Destroy()
            end
        end)
    end

    p.CharacterAdded:Connect(Apply)
    if p.Character then Apply(p.Character) end
end

-- Mevcut oyunculara uygula
for _, p in pairs(Players:GetPlayers()) do CreateSafeESP(p) end
Players.PlayerAdded:Connect(CreateSafeESP)

-- LEGIT AIMBOT (Kamerayı titretmez, yumuşak kayar)
RunService.RenderStepped:Connect(function()
    if _G.SafeESP.SafeAimbot then
        local target = nil
        local dist = 150 -- Küçük FOV (Daha güvenli)
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                if _G.SafeESP.TeamCheck and p.Team == LocalPlayer.Team then continue end
                
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < dist then
                        -- Duvar Kontrolü (ESP banı yediysen bu hayat kurtarır)
                        local ray = Ray.new(Camera.CFrame.Position, (p.Character.Head.Position - Camera.CFrame.Position).Unit * 500)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, p.Character})
                        
                        if not hit then
                            dist = mag
                            target = p
                        end
                    end
                end
            end
        end
        
        if target then
            local lookAt = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, 1 - _G.SafeESP.Smoothness)
        end
    end
end)
