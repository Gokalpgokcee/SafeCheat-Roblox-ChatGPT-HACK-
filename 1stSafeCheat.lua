local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "G&G SafeCheat | V5 Ultra",
   LoadingTitle = "Gokalp Advanced Systems",
   LoadingSubtitle = "by Gemini (v5.0)",
   ConfigurationSaving = { Enabled = false }
})

-- AYARLAR
local Settings = {
    -- ESP
    EspEnabled = false,
    BoxColor = Color3.fromRGB(0, 255, 0),
    BoxOpacity = 0.5, -- Kutuların iç doluluk saydamlığı
    Names = false,
    -- AIMBOT
    AimbotEnabled = false,
    FovRadius = 100,
    ShowFov = false,
    Sensitivity = 0.2,
    -- MISC
    WalkSpeed = 16,
    JumpPower = 50
}

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- FOV ÇEMBERİ (Tıkladığın/Dokunduğun Yerde Çıkması İçin)
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Filled = false
FovCircle.Visible = false

-- DOLU ESP SİSTEMİ
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    local NameTag = Drawing.new("Text")
    
    RS.RenderStepped:Connect(function()
        if Settings.EspEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local Root = Player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)

            if OnScreen then
                local SizeY = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 2.6, 0)).Y)
                local SizeX = SizeY * 0.6

                -- KUTU (Filled/Dolu Özelliği)
                Box.Visible = true
                Box.Color = Settings.BoxColor
                Box.Size = Vector2.new(SizeX, SizeY)
                Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)
                Box.Thickness = 1
                Box.Filled = true -- İÇİ DOLU
                Box.Transparency = Settings.BoxOpacity -- Saydamlık ayarı

                if Settings.Names then
                    NameTag.Visible = true
                    NameTag.Text = Player.Name
                    NameTag.Position = Vector2.new(Pos.X, Pos.Y - (SizeY / 2) - 15)
                    NameTag.Center = true
                    NameTag.Outline = true
                    NameTag.Size = 14
                    NameTag.Color = Color3.new(1,1,1)
                else NameTag.Visible = false end
            else
                Box.Visible = false
                NameTag.Visible = false
            end
        else
            Box.Visible = false
            NameTag.Visible = false
            if not Player.Parent then
                Box:Remove(); NameTag:Remove()
            end
        end
    end)
end

-- AIMBOT HEDEF BULUCU
local function GetClosest()
    local Target = nil
    local Dist = Settings.FovRadius
    local MousePos = UIS:GetMouseLocation()

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            local Mag = (Vector2.new(MousePos.X, MousePos.Y) - Vector2.new(Pos.X, Pos.Y)).Magnitude
            if Mag < Dist and OnScreen then
                Target = v
                Dist = Mag
            end
        end
    end
    return Target
end

-- ANA DÖNGÜ (Dinamik FOV ve Aimbot)
RS.RenderStepped:Connect(function()
    -- FOV Çemberini farenin/parmağın olduğu yere taşı
    local MouseLocation = UIS:GetMouseLocation()
    FovCircle.Position = Vector2.new(MouseLocation.X, MouseLocation.Y)
    FovCircle.Radius = Settings.FovRadius
    FovCircle.Visible = Settings.ShowFov

    -- Aimbot
    if Settings.AimbotEnabled then
        local T = GetClosest()
        if T then
            local TPos = Camera:WorldToViewportPoint(T.Character.HumanoidRootPart.Position)
            mousemoverel((TPos.X - MouseLocation.X) * Settings.Sensitivity, (TPos.Y - MouseLocation.Y) * Settings.Sensitivity)
        end
    end

    -- Karakter Ayarları
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.
         
