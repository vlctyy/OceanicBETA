-- Updated Rayfield UI Setup
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Oceanic Beta",
    LoadingTitle = "Loading Oceanic...",
    LoadingSubtitle = "Please wait while the features are loaded...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "OceanicSettings", -- Folder to save the config file
        FileName = "Oceanic_Config" -- Config file name
    },
    Discord = {
        Enabled = false,
        Invite = "https://www.youtube.com/@RontuYT", -- Link to your YouTube channel
        RememberJoins = false
    },
    KeySystem = false
})

-- Efficient Function Definitions
local function toggleDebugFlag()
    local fflags = game:GetService("ReplicatedStorage"):WaitForChild("FFlags", 3) -- Timeout to prevent infinite wait
    if not fflags then return end

    local flagValue = fflags:FindFirstChild("DebugGreySky")
    if flagValue then
        flagValue.Value = not flagValue.Value
        Rayfield:Notify({
            Title = "Debug Flag",
            Content = "FFlagDebugGreySky toggled to: " .. tostring(flagValue.Value),
            Duration = 3
        })
        Window:SetConfigurationValue("DebugGreySky", flagValue.Value) -- Save the flag state
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

    -- Set FPS to uncapped if possible
    RenderSettings.FrameRateManagerMode = Enum.FrameRateManagerMode.Uncapped
    Rayfield:Notify({
        Title = "FPS Unlocker",
        Content = "FPS has been unlocked!",
        Duration = 3
    })

    Window:SetConfigurationValue("FPSUnlockerEnabled", true) -- Save the FPS unlocker state
end

local function displayFPS()
    local RunService = game:GetService("RunService")
    local lastFrameTime = tick()
    local frameCount = 0
    local fps = 0

    -- Connect to RenderStepped with minimal processing
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        if currentTime - lastFrameTime >= 2 then -- Update FPS every 2 seconds to reduce frequency
            fps = frameCount / 2 -- Average FPS over 2 seconds
            frameCount = 0
            lastFrameTime = currentTime
            Rayfield:Notify({
                Title = "FPS Viewer",
                Content = "Current FPS: " .. tostring(fps),
                Duration = 2
            })
        end
    end)
end

local function displayPing()
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
            Rayfield:Notify({
                Title = "Ping Viewer",
                Content = "Current Ping: " .. tostring(ping) .. " ms",
                Duration = 2
            })
        end)
    end
end

local function modifyTextures(action)
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("Texture") or v:IsA("Decal") then
            if action == "remove" then
                v.Texture = ""  -- Removes the texture
            elseif action == "blur" then
                v.Texture = "rbxassetid://blur_texture_id" -- Replace with blurred texture ID
            elseif action == "reset" then
                v.Texture = v:GetAttribute("OriginalTexture") or v.Texture -- Resets to the original texture
            end
        end
    end
    Rayfield:Notify({
        Title = "Texture Modification",
        Content = "Textures have been " .. action .. "d.",
        Duration = 3
    })
    Window:SetConfigurationValue("TextureModification", action) -- Save the texture modification state
end

-- Save original textures
for _, v in ipairs(game:GetDescendants()) do
    if v:IsA("Texture") or v:IsA("Decal") then
        v:SetAttribute("OriginalTexture", v.Texture) -- Store the original texture
    end
end

-- Load custom font logic
local function applyCustomFont(fontName)
    if fontName == "pixeled" then
        local pixeledFont = "rbxassetid://your_pixelfont_asset_id" -- Replace with actual asset ID
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                v.Font = pixeledFont
            end
        end
        Rayfield:Notify({
            Title = "Custom Font Applied",
            Content = "Custom font 'pixeled' applied to UI elements.",
            Duration = 3
        })
    end
end

-- Load saved settings
local function loadSettings()
    local savedDebugFlag = Window:GetConfigurationValue("DebugGreySky")
    local fpsUnlockerEnabled = Window:GetConfigurationValue("FPSUnlockerEnabled")
    local savedTextureModification = Window:GetConfigurationValue("TextureModification")
    local savedCustomFont = Window:GetConfigurationValue("CustomFont")

    if savedDebugFlag ~= nil then
        toggleDebugFlag(savedDebugFlag) -- Apply saved debug flag state
    end

    if fpsUnlockerEnabled then
        unlockFPS() -- Apply saved FPS unlocker state
    end

    if savedTextureModification ~= nil then
        modifyTextures(savedTextureModification) -- Apply saved texture modification state
    end

    if savedCustomFont ~= nil then
        applyCustomFont(savedCustomFont) -- Apply saved custom font state
    end
end

-- UI Elements
local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateButton({
    Name = "Toggle FFlagDebugGreySky",
    Callback = function()
        toggleDebugFlag()
    end
})

Tab:CreateButton({
    Name = "Enable FPS Unlocker",
    Callback = function()
        unlockFPS()
    end
})

Tab:CreateButton({
    Name = "Display FPS Viewer",
    Callback = function()
        displayFPS()
    end
})

Tab:CreateButton({
    Name = "Display Ping Viewer",
    Callback = function()
        displayPing()
    end
})

Tab:CreateDropdown({
    Name = "Texture Modification",
    Options = {"remove", "blur", "reset"},
    Callback = function(selected)
        modifyTextures(selected)
    end
})

Tab:CreateDropdown({
    Name = "Custom Font",
    Options = {"pixeled"}, -- Add more font options if available
    Callback = function(selected)
        applyCustomFont(selected)
    end
})

-- Load the saved settings when the script starts
loadSettings()

-- Notify when Oceanic Beta is successfully loaded
Rayfield:Notify({
    Title = "Oceanic Beta",
    Content = "Oceanic Beta loaded successfully!",
    Duration = 5
})
