local name, WoWVideoPlayer = ...

local Main = LibStub("AceAddon-3.0"):NewAddon(name, "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")

WoWVideoPlayer.Main = Main

function Main:OnInitialize()
    self:InitializeVideos()
    self:CreateGeneralWindow()
    self:CreateVideoWindow()
    
    -- Register for flight path events
    self:RegisterEvent("PLAYER_STARTED_MOVING", "OnPlayerFlightStart")
end

function Main:InitializeVideos()

    -- Video data is stored in this table
    self.videos = {}

    -- Load videos from the videos.lua file
    for _, videoConfig in ipairs(WoWVideoPlayer.videos) do

        local videoData = {
            name = videoConfig.name,
            width = videoConfig.width or 1080, -- Default to 1080 if not specified
            height = videoConfig.height or 1080, -- Default to 1080 if not specified
            fps = videoConfig.fps or 5, -- Default to 5 if not specified
            autoPlayOnFlightPath = videoConfig.autoPlayOnFlightPath or false, -- Default to false if not specified
            disableCloseWindowButton = videoConfig.disableCloseWindowButton or false, -- Default to false if not specified
            frames = {}
        }

        -- Load frames from the stored_videos folder
        local pathPrefix = "Interface\\AddOns\\WoWVideoPlayer\\stored_videos\\" .. videoConfig.name .. "\\"
        local frameIndex = 1

        while true do

            local frameName
            if frameIndex < 10 then
                frameName = "00" .. frameIndex
            elseif frameIndex < 100 then
                frameName = "0" .. frameIndex
            else
                frameName = frameIndex
            end

            -- Define the path to the frame
            local framePath = pathPrefix .. frameName .. ".jpg"

            -- Stop when no more frames are found
            --if not FileExists(framePath) then
            --if frameIndex > videoConfig.frameCount then
            if frameIndex > 1000 then
                break
            end

            -- Add the frame to the video
            table.insert(videoData.frames, framePath)
            frameIndex = frameIndex + 1
        end

        -- Calculate the total number of frames
        videoData.frameCount = #videoData.frames

        -- Add the video data to the videos table
        table.insert(self.videos, videoData)
    end
end

function Main:CreateGeneralWindow()

    local generalWindow = AceGUI:Create("Frame")

    generalWindow:SetTitle("WoW Video Player")
    generalWindow:SetStatusText("Select a video to play")
    generalWindow:SetLayout("Flow")
    generalWindow:SetWidth(400)
    generalWindow:SetHeight(300)
    generalWindow:Hide() -- Start hidden, opened via a slash command

    for _, video in ipairs(self.videos) do

        local group = AceGUI:Create("SimpleGroup")

        group:SetLayout("Flow")
        group:SetFullWidth(true)

        local label = AceGUI:Create("Label")

        label:SetText(video.name)
        label:SetWidth(250)

        group:AddChild(label)

        local playButton = AceGUI:Create("Button")

        playButton:SetText("Play")
        playButton:SetWidth(100)
        playButton:SetCallback("OnClick", function()
            self:ShowVideo(video)
        end)

        group:AddChild(playButton)

        generalWindow:AddChild(group)
    end

    self.generalFrame = generalWindow

    SLASH_WOWVIDEOPLAYER1 = "/wvp"
    SLASH_WOWVIDEOPLAYER2 = "/wowvideoplayer"
    SLASH_WOWVIDEOPLAYER3 = "/videoplayer"

    SlashCmdList["WOWVIDEOPLAYER"] = function()
        if self.generalFrame:IsShown() then
            self.generalFrame:Hide()
        else
            self.generalFrame:Show()
        end
    end
end

function Main:CreateVideoWindow()

    local videoWindow = AceGUI:Create("Frame")

    videoWindow:SetTitle("Video Player")
    videoWindow:SetLayout("Fill")
    videoWindow:SetWidth(1920)
    videoWindow:SetHeight(1080)
    videoWindow:Hide() -- Start hidden

    -- Create the texture frame
    local textureFrame = CreateFrame("Frame", nil, videoWindow.frame)
    textureFrame:SetPoint("TOPLEFT", videoWindow.frame, "TOPLEFT", 15, -25)
    textureFrame:SetPoint("BOTTOMRIGHT", videoWindow.frame, "BOTTOMRIGHT", -15, 45)

    -- Store textures in an array
    videoWindow.textures = {}
    videoWindow.textureFrame = textureFrame

    videoWindow:SetCallback("OnClose", function(widget)
        self:StopVideo()
        textureFrame:Hide()
    end)

    self.videoWindow = videoWindow
end

function Main:ShowVideo(video)

    -- Adjust window size based on video resolution
    self.videoWindow:SetWidth(video.width / 2)
    self.videoWindow:SetHeight(video.height / 2)

    -- Set the title and show the video window
    self.videoWindow:SetTitle(video.name)
    self.videoWindow:Show()
    self.videoWindow.textureFrame:Show()

    -- Start playing the video
    self:PlayVideo(video)
end

function Main:PlayVideo(video)

    if self.videoPlaybackTimer then
        self:StopVideo()
    end

    local currentFrame = 0
    local frameCount = video.frameCount
    local fps = video.fps
    local frameInterval = 1 / fps -- 30 FPS is equivalent to 0.03333

    -- Determine the number of textures needed
    local textureCount = 2
    if fps > 5 then
        textureCount = 3
    elseif fps > 10 then
        textureCount = 4
    elseif fps > 15 then
        textureCount = 5
    elseif fps > 20 then
        textureCount = 6
    end

    -- Create textures dynamically
    local textures = self.videoWindow.textures
    local textureFrame = self.videoWindow.textureFrame

    -- Remove any existing textures
    for _, tex in ipairs(textures) do
        tex:Hide()
        tex:SetTexture(nil)
    end

    -- Create the required number of textures
    for i = 1, textureCount do
        if not textures[i] then
            local newTexture = textureFrame:CreateTexture(nil, "ARTWORK")
            newTexture:SetAllPoints(textureFrame)
            textures[i] = newTexture
        end
        textures[i]:Show()
    end

    -- Playback logic
    local activeTextureIndex = 1

    local function displayNextFrame()
        if not self.videoWindow or not self.videoWindow:IsShown() then
            return
        end
    
        -- Update the current frame
        currentFrame = currentFrame + 1
    
        -- Check if we've reached the end of the video
        if currentFrame > frameCount then
            self:StopVideo() -- Stop video playback
            for i, tex in ipairs(textures) do
                tex:Hide()
            end
            self.videoWindow:Hide() -- Close the video window
            return
        end
    
        -- Load the next frame onto the active texture
        local frameTexture = video.frames[currentFrame]
        local activeTexture = textures[activeTextureIndex]
        activeTexture:SetTexture(frameTexture)
    
        -- Set the active texture to the top layer
        for i, tex in ipairs(textures) do
            if i == activeTextureIndex then
                tex:SetDrawLayer("ARTWORK", 1) -- Active texture on top
            else
                tex:SetDrawLayer("ARTWORK", 0) -- Inactive textures below
            end
        end
    
        -- Advance to the next texture
        activeTextureIndex = activeTextureIndex + 1
        if activeTextureIndex > textureCount then
            activeTextureIndex = 1
        end
    
        -- Schedule the next frame
        self.videoPlaybackTimer = C_Timer.After(frameInterval, displayNextFrame)
    end

    -- Start playing the video
    displayNextFrame()
end

function Main:StopVideo()
    if self.videoPlaybackTimer then
        self.videoPlaybackTimer:Cancel()
        self.videoPlaybackTimer = nil
    end
end

function Main:OnPlayerFlightStart()
    -- Check if the player is in combat
    if not InCombatLockdown() then
        -- Check if the player is on a flight path
        if UnitOnTaxi("player") then
            -- Collect all videos with autoPlayOnFlightPath enabled
            local autoPlayVideos = {}
            for _, video in ipairs(self.videos) do
                if video.autoPlayOnFlightPath then
                    table.insert(autoPlayVideos, video)
                end
            end

            -- If there are eligible videos, select a random one
            if #autoPlayVideos > 0 then
                local selectedVideo
                repeat
                    selectedVideo = autoPlayVideos[math.random(#autoPlayVideos)]
                until selectedVideo ~= self.lastPlayedVideo or #autoPlayVideos == 1
                
                -- Play the selected video
                self:ShowVideo(selectedVideo)

                -- Store the last played video
                self.lastPlayedVideo = selectedVideo
            end
        end
    end
end
