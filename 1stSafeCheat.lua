local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "G&G SafeCheat | V6 Professional",
   LoadingTitle = "Gokalp Scripting System",
   LoadingSubtitle = "by Gemini (v6.0)",
   ConfigurationSaving = { Enabled = false }
})

-- AYARLAR
local Settings = {
    -- ESP
    EspEnabled = false,
    BoxColor = Color3.fromRGB(0, 255, 0),
    Names = false,
    Distances = false,
    -- AIMBOT
    AimbotEnabled = false,
    FovRadius = 100,
    ShowFov = false,
    Smoothness = 0.2, -- 0 ile 1 arası, düşük olan daha yumuşak kitlenir
    AimPart = "HumanoidRootPart" -- "Head" yapabilirsin
}

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- FOV ÇEMBERİ (Ekran Ortasına Sabit)
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Filled = false -- İÇİ BOŞ
FovCircle.Visible = false

-- İÇİ BOŞ BOX ESP SİSTEMİ
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    local NameTag = Drawing.new("Text")
    local DistanceTag = Drawing.new("Text")
    
    RS.RenderStepped:Connect(function()
        if Settings.EspEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local Root = Player.Character.HumanoidRootPart
            local Hum = Player.Character:FindFirstChild("Humanoid")
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)

            if OnScreen then
                local SizeY = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 2.6, 0)).Y)
                local SizeX = SizeY * 0.6

                -- KUTU (İçi Boş Çerçeve)
                Box.Visible = true
                Box.Color = Settings.BoxColor
                Box.Size = Vector2.new(SizeX, SizeY)
                Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)
                Box.Thickness = 1
                Box.Filled = false -- İÇİ BOŞ

                -- İSİM VE MESAFE
                if Settings.Names then
                    NameTag.Visible = true
                    NameTag.Text = Player.Name
                    NameTag.Position = Vector2.new(Pos.X, Pos.Y - (SizeY / 2) - 15)
                    NameTag.Center = true
                    NameTag.Outline = true
                    NameTag.Size = 14
                    NameTag.Color = Color3.new(1,1,1)
                else NameTag.Visible = false end

                if Settings.Distances then
                    local Distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude)
                    DistanceTag.Visible = true
                    DistanceTag.Text = Distance .. "m"
                    DistanceTag.Position = Vector2.new(Pos.X,
                     
