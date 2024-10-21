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

local function createDraggableViewer(name, initialText)
    local viewer = Instance.new("TextLabel")
    viewer.Size = UDim2.new(0, 100, 0, 50)
    viewer.Position = UDim2.new(0.5, 0, 0.1, 0)
    viewer.Text = initialText
    viewer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    viewer.TextColor3 = Color3.fromRGB(255, 255, 255)
    viewer.TextSize = 14
    viewer.BorderSizePixel = 2
    viewer.BorderColor3 = Color3.fromRGB(0, 170, 255)
    viewer.Parent = game.Players.LocalPlayer.PlayerGui

    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        viewer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    viewer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = viewer.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    viewer.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    return viewer
end

local function displayFPS()
    local fpsViewer = createDraggableViewer("FPS Viewer", "FPS: Calculating...")
    local RunService = game:GetService("RunService")
    local lastFrameTime = tick()
    local frameCount = 0

    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        if currentTime - lastFrameTime >= 1 then
            local fps = frameCount / (currentTime - lastFrameTime)
            fpsViewer.Text = "FPS: " .. math.floor(fps)
            frameCount = 0
            lastFrameTime = currentTime
        end
    end)
end

local function displayPing()
    local pingViewer = createDraggableViewer("Ping Viewer", "Ping: Calculating...")
    local Stats = game:GetService("Stats")
    local NetworkStats = Stats:FindFirstChild("Network")

    if not NetworkStats then
        Rayfield:Notify({
            Title = "Error",
            Content = "Network stats not found.",
            Duration = 3
        })
        return
    end

    local IncomingReplicationLag = NetworkStats:FindFirstChild("IncomingReplicationLag")
    if IncomingReplicationLag then
        IncomingReplicationLag:GetPropertyChangedSignal("Value"):Connect(function()
            local ping = math.floor(IncomingReplicationLag.Value * 1000)
            pingViewer.Text = "Ping: " .. tostring(ping) .. " ms"
        end)
    end
end

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
    Name = "Display FPS",
    Callback = displayFPS
})

ClientModsTab:CreateButton({
    Name = "Display Ping",
    Callback = displayPing
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
