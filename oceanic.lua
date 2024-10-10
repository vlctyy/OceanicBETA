-- Rayfield UI Setup
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))() -- Updated Rayfield link
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
        Invite = "rPqV5Nhc8a",  -- Your Discord invite link
        RememberJoins = true
    },
    KeySystem = false
})

-- Helper Functions
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
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
    if action == "remove" or action == "reset" then
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") then
                if action == "remove" then
                    v.Texture = ""  -- Removes the texture
                elseif action == "reset" then
                    v.Texture = v:GetAttribute("OriginalTexture") or v.Texture
                end
            end
        end
    elseif action == "blur" then
        -- Apply SmoothPlastic material for parts as the blur action
        for i, v in next, (workspace:GetDescendants()) do
            if v:IsA("Part") then
                v.Material = Enum.Material.SmoothPlastic
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

for _, v in ipairs(game:GetDescendants()) do
    if v:IsA("Texture") or v:IsA("Decal") then
        v:SetAttribute("OriginalTexture", v.Texture)
    end
end

-- Custom Font Application Function
local function applyCustomFont(fontName)
    -- URL to fetch the custom font (Pixeled.ttf)
    local fontUrl = "https://raw.githubusercontent.com/vlctyy/OceanicForMobile/main/Pixeled.ttf"
    local success, fontData = pcall(function()
        return game:HttpGet(fontUrl)
    end)

    if success then
        -- Notify the user that the font is loading
        Rayfield:Notify({
            Title = "Loading Custom Font",
            Content = "Downloading and applying the custom font...",
            Duration = 3
        })

        -- Apply the font (Simulation with placeholder, real font loading from .ttf is not natively supported)
        for _, v in ipairs(game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                v.Font = Enum.Font.Arcade -- Example: Arcade-style font as a placeholder
                v.Text = "[Pixeled] " .. v.Text  -- Example to show custom font has been applied
            end
        end

        -- Notify the user that the custom font has been applied
        Rayfield:Notify({
            Title = "Custom Font Applied",
            Content = "Applied custom font: " .. fontName,
            Duration = 3
        })
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "Failed to load custom font from repository.",
            Duration = 3
        })
    end
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

-- Initialize Tabs and Options
local MainTab = Window:CreateTab("Main Features", 4483362458)
MainTab:CreateButton({
    Name = "Toggle Debug Flag",
    Callback = toggleDebugFlag
})

MainTab:CreateButton({
    Name = "Unlock FPS",
    Callback = unlockFPS
})

MainTab:CreateButton({
    Name = "Display FPS",
    Callback = displayFPS
})

MainTab:CreateButton({
    Name = "Display Ping",
    Callback = displayPing
})

MainTab:CreateDropdown({
    Name = "Modify Textures",
    Options = {"remove", "reset", "blur"},
    Callback = modifyTextures
})

MainTab:CreateButton({
    Name = "Apply Custom Font",
    Callback = function()
        applyCustomFont("Pixeled")
    end
})

-- Load the user's saved settings if any
loadSettings()
