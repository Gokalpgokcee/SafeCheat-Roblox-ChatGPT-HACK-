-- GOK CHEAT - Delta Compatible FPS Cheat (No Drawing, Optimized)
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptZ-Mike/Rayfield/main/Source"))()

local Window = Rayfield:CreateWindow({
    Name = "GOK CHEAT",
    LoadingTitle = "GOK CHEAT Delta",
    LoadingSubtitle = "by User",
    ConfigurationSaving = { Enabled = true, FolderName = "GOK_CHEAT", FileName = "Config" }
})

local AimbotTab = Window:CreateTab("Aimbot", "rbxassetid://4483345998")
local VisualsTab = Window:CreateTab("Visuals", "rbxassetid://4483345998")
local MiscTab = Window:CreateTab("Misc", "rbxassetid://4483345998")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")

-- Settings
local Settings = {
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        HitPart = "Head",
        Smoothness = 0,
        Keybind = Enum.UserInputType.MouseButton2
    },
    Visuals = {
        Enabled = false,
        Wallhack = false,
        TeamCheck = true
    },
    Misc = {
        NoRecoil = false,
        InfiniteAmmo = false
    }
}

-- Aimbot Tab
AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimbotEnabled",
    Callback = function(Value) Settings.Aimbot.Enabled = Value end
})

AimbotTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "AimbotTeamCheck",
    Callback = function(Value) Settings.Aimbot.TeamCheck = Value end
})

AimbotTab:CreateDropdown({
    Name = "Hit Part",
    Options = {"Head", "Torso", "HumanoidRootPart"},
    CurrentOption = "Head",
    Flag = "HitPart",
    Callback = function(Option) Settings.Aimbot.HitPart = Option end
})

AimbotTab:CreateSlider({
    Name = "Smoothness",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 0,
    Flag = "Smoothness",
    Callback = function(Value) Settings.Aimbot.Smoothness = Value end
})

AimbotTab:CreateDropdown({
    Name = "Aimbot Key",
    Options = {"Right Mouse", "Left Mouse", "Ctrl", "Alt", "Q", "E"},
    CurrentOption = "Right Mouse",
    Flag = "AimbotKey",
    Callback = function(Option)
        if Option == "Right Mouse" then Settings.Aimbot.Keybind = Enum.UserInputType.MouseButton2
        elseif Option == "Left Mouse" then Settings.Aimbot.Keybind = Enum.UserInputType.MouseButton1
        elseif Option == "Ctrl" then Settings.Aimbot.Keybind = Enum.KeyCode.LeftControl
        elseif Option == "Alt" then Settings.Aimbot.Keybind = Enum.KeyCode.LeftAlt
        elseif Option == "Q" then Settings.Aimbot.Keybind = Enum.KeyCode.Q
        elseif Option == "E" then Settings.Aimbot.Keybind = Enum.KeyCode.E end
    end
})

-- Visuals Tab
VisualsTab:CreateToggle({
    Name = "Enable Visuals",
    CurrentValue = false,
    Flag = "VisualsEnabled",
    Callback = function(Value) Settings.Visuals.Enabled = Value end
})

VisualsTab:CreateToggle({
    Name = "Wallhack (Highlight)",
    CurrentValue = false,
    Flag = "Wallhack",
    Callback = function(Value)
        Settings.Visuals.Wallhack = Value
        if Value then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    if Settings.Visuals.TeamCheck and player.Team == LocalPlayer.Team then continue end
                    if player.Character and not player.Character:FindFirstChild("WallhackHighlight") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "WallhackHighlight"
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5
                        highlight.Parent = player.Character
                    end
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("WallhackHighlight") then
                    player.Character.WallhackHighlight:Destroy()
                end
            end
        end
    end
})

VisualsTab:CreateToggle({
    Name = "Team Check (Visuals)",
    CurrentValue = true,
    Flag = "VisualsTeamCheck",
    Callback = function(Value) Settings.Visuals.TeamCheck = Value end
})

-- Misc Tab
MiscTab:CreateToggle({
    Name = "No Recoil",
    CurrentValue = false,
    Flag = "NoRecoil",
    Callback = function(Value) Settings.Misc.NoRecoil = Value end
})

MiscTab:CreateToggle({
    Name = "Infinite Ammo",
    CurrentValue = false,
    Flag = "InfiniteAmmo",
    Callback = function(Value) Settings.Misc.InfiniteAmmo = Value end
})

-- Utility Functions
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then return false end
    if Settings.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then return false end
    return true
end

local function GetClosestEnemy()
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) then
            local character = player.Character
            local part = character:FindFirstChild(Settings.Aimbot.HitPart) or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        closest = part
                        closestDist = dist
                    end
                end
            end
        end
    end
    return closest
end

-- Aimbot Loop
local aimLock = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Settings.Aimbot.Keybind or input.KeyCode == Settings.Aimbot.Keybind then
        aimLock = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Settings.Aimbot.Keybind or input.KeyCode == Settings.Aimbot.Keybind then
        aimLock = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.Enabled and aimLock then
        local target = GetClosestEnemy()
        if target then
            if Settings.Aimbot.Smoothness > 0 then
                local targetCF = CFrame.lookAt(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / Settings.Aimbot.Smoothness)
            else
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            end
        end
    end
end)

-- Wallhack update on new characters
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if Settings.Visuals.Wallhack and player ~= LocalPlayer then
            if Settings.Visuals.TeamCheck and player.Team == LocalPlayer.Team then return end
            local highlight = Instance.new("Highlight")
            highlight.Name = "WallhackHighlight"
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.Parent = character
        end
    end)
end)

-- Team check update for wallhack (reapply when team changes)
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
    if Settings.Visuals.Wallhack then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                if player.Character:FindFirstChild("WallhackHighlight") then
                    player.Character.WallhackHighlight:Destroy()
                end
                if player ~= LocalPlayer and (not Settings.Visuals.TeamCheck or player.Team ~= LocalPlayer.Team) then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "WallhackHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = player.Character
                end
            end
        end
    end
end)

-- No Recoil (basic hook - may not work on all games)
if Settings.Misc.NoRecoil then
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if key == "Recoil" or key == "CamShake" then return 0 end
        return oldIndex(self, key)
    end)
end

-- Infinite Ammo (basic hook)
if Settings.Misc.InfiniteAmmo then
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if key == "Ammo" or key == "CurrentAmmo" then return 999 end
        return oldIndex(self, key)
    end)
end

Rayfield:Notify({
    Title = "GOK CHEAT",
    Content = "Delta ready - FPS Cheat loaded!",
    Duration = 3,
    Image = 4483362458
})
