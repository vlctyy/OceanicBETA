local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Oceanic Beta",
    LoadingTitle = "Loading Oceanic...",
    LoadingSubtitle = "Please wait while the features are loaded...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "OceanicSettings",
        FileName = "Oceanic_Config"
    },
    Discord = {
        Enabled = true,
        Invite = "rPqV5Nhc8a",
        RememberJoins = true
    },
    KeySystem = false
})

local function toggleDebugFlag()
    local fflags = game:GetService("ReplicatedStorage"):WaitForChild("FFlags", 3)
    if not fflags then return end

    local flagValue = fflags:FindFirstChild("DebugGreySky")
    if flagValue then
        flagValue.Value = not flagValue.Value
        Rayfield:Notify({
            Title = "Debug Flag",
            Content = "FFlagDebugGreySky toggled to: " .. tostring(flagValue.Value),
            Duration = 3
        })
        Window:SetConfigurationValue("DebugGreySky", flagValue.Value)
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "FFlagDebugGreySky not found",
            Duration = 3
        })
    end
end

local function unlockFPS()
    local UserSettings = game:GetService("UserSettings")
    local RenderSettings = UserSettings():GetService("RenderSettings")
    if not RenderSettings then return end

    RenderSettings.FrameRateManagerMode = Enum.FrameRateManagerMode.Uncapped
    Rayfield:Notify({
        Title = "FPS Unlocker",
        Content = "FPS has been unlocked!",
        Duration = 3
    })

    Window:SetConfigurationValue("FPSUnlockerEnabled", true)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSPingGui"
screenGui.Parent = game:GetService("CoreGui")

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FPSLabel"
fpsLabel.Size = UDim2.new(0, 200, 0, 60)  -- Increased size to 200x60
fpsLabel.Position = UDim2.new(0, -10, 0, 10)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.new(1, 1, 1)
fpsLabel.TextStrokeTransparency = 0
fpsLabel.Font = Enum.Font.SourceSans
fpsLabel.TextSize = 40  -- Increased text size to 40
fpsLabel.Parent = screenGui

local pingLabel = Instance.new("TextLabel")
pingLabel.Name = "PingLabel"
pingLabel.Size = UDim2.new(0, 100, 0, 50)
pingLabel.Position = UDim2.new(0, 165, 0, 15) -- Adjusted position to be next to the FPS counter
pingLabel.BackgroundTransparency = 1
pingLabel.TextColor3 = Color3.new(1, 1, 1)
pingLabel.TextStrokeTransparency = 0
pingLabel.Font = Enum.Font.SourceSans
pingLabel.TextSize = 24
pingLabel.Parent = screenGui

local function calculateFPS()
    local lastTime = tick()
    local frames = 0
    game:GetService("RunService").RenderStepped:Connect(function()
        frames = frames + 1
        local currentTime = tick()
        if currentTime - lastTime >= 0.1 then
            local fps = math.floor(frames / (currentTime - lastTime))
            fpsLabel.Text = "FPS: " .. tostring(fps)
            if fps < 10 then
                fpsLabel.TextColor3 = Color3.new(1, 0, 0) -- Red color for low FPS
            else
                fpsLabel.TextColor3 = Color3.new(1, 1, 1) -- White color for normal FPS
            end
            frames = 0
            lastTime = currentTime
        end
    end)
end

local function calculatePing()
    game:GetService("RunService").Heartbeat:Connect(function()
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        pingLabel.Text = "Ping: " .. tostring(math.floor(ping)) .. " ms"
        if ping > 300 then
            pingLabel.TextColor3 = Color3.new(1, 0, 0) -- Red color for high ping
        else
            pingLabel.TextColor3 = Color3.new(1, 1, 1) -- White color for normal ping
        end
    end)
end

calculateFPS()
calculatePing()

local function modifyTextures(action)
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") then
            v.Material = Enum.Material.SmoothPlastic
        end
        if v:IsA("Texture") or v:IsA("Decal") then
            if action == "remove" then
                v.Texture = ""
            elseif action == "blur" then
                v.Texture = "rbxassetid://blur_texture_id"
            elseif action == "reset" then
                v.Texture = v:GetAttribute("OriginalTexture") or v.Texture
            end
        end
    end
    Rayfield:Notify({
        Title = "Texture Modification",
        Content = "Textures have been " .. action .. "d.",
        Duration = 3
    })
    Window:SetConfigurationValue("TextureModification", action)
end

for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("Texture") or v:IsA("Decal") then
        v:SetAttribute("OriginalTexture", v.Texture)
    end
end

local function applyCustomFont(fontName)
    local fontId = "rbxassetid://123456789"
    for _, v in ipairs(game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
            v.Font = Enum.Font.SourceSans
            v.Text = "[Custom Font] " .. v.Text
        end
    end
    Rayfield:Notify({
        Title = "Custom Font Applied",
        Content = "Applied font: " .. fontName,
        Duration = 3
    })
end

local function loadSettings()
    local savedDebugFlag = Window:GetConfigurationValue("DebugGreySky")
    local fpsUnlockerEnabled = Window:GetConfigurationValue("FPSUnlockerEnabled")
    local savedTextureModification = Window:GetConfigurationValue("TextureModification")
    local savedCustomFont = Window:GetConfigurationValue("CustomFont")

    if savedDebugFlag ~= nil then
        toggleDebugFlag()
    end

    if fpsUnlockerEnabled then
        unlockFPS()
    end

    if savedTextureModification ~= nil then
        modifyTextures(savedTextureModification)
    end

    if savedCustomFont ~= nil then
        applyCustomFont(savedCustomFont)
    end
end

local FontsTab = Window:CreateTab("Fonts", 4483362458)
local ClientModsTab = Window:CreateTab("Client Mods", 4483362458)
local FastFlagsTab = Window:CreateTab("Fast Flags", 4483362458)

FontsTab:CreateButton({
    Name = "Apply Custom Font",
    Callback = function()
        applyCustomFont("Pixeled")
    end
})

ClientModsTab:CreateButton({
    Name = "Unlock FPS",
    Callback = unlockFPS
})

ClientModsTab:CreateButton({
    Name = "Display FPS and Ping",
    Callback = function()
        calculateFPS()
        calculatePing()
    end
})

ClientModsTab:CreateDropdown({
    Name = "Modify Textures",
    Options = {"remove", "reset", "blur"},
    Callback = modifyTextures
})

FastFlagsTab:CreateButton({
    Name = "Toggle Debug Flag",
    Callback = toggleDebugFlag
})

local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateButton({
    Name = "Load Saved Settings",
    Callback = loadSettings
})

SettingsTab:CreateButton({
    Name = "Save Current Settings",
    Callback = function()
        Window:SaveConfiguration()
        Rayfield:Notify({
            Title = "Settings Saved",
            Content = "Your current settings have been saved.",
            Duration = 3
        })
    end
})

Rayfield:Notify({
    Title = "Oceanic Beta",
    Content = "Oceanic has been successfully loaded!",
    Duration = 5
})
