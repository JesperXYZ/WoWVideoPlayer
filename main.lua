local name, WoWVideoPlayer = ...

local Main = LibStub("AceAddon-3.0"):NewAddon(name, "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")

WoWVideoPlayer.Main = Main

function Main:OnInitialize()
    self:InitializeVideos()
    self:CreateGeneralWindow()
    self:CreateVideoWindow()
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "CheckPlayerOnFlightPath")
end

function Main:InitializeVideos()
    -- Video data is stored in this table
    self.videos = {}

    -- Load videos from the videos.lua file
    for _, videoConfig in ipairs(WoWVideoPlayer.videos) do
        -- Initialize video data with defaults
        local videoData = {
            name = videoConfig.name,
            width = videoConfig.width or 1080,
            height = videoConfig.height or 1080,
            fps = videoConfig.fps or 5,
            totalFrameCount = videoConfig.totalFrameCount or 500,
            autoPlayOnFlightPath = videoConfig.autoPlayOnFlightPath or false,

            frames = {},
            audioPath = "Interface\\AddOns\\WoWVideoPlayer\\stored_videos\\" .. videoConfig.name .. "\\audio.mp3"
        }

        -- Load frames from the stored_videos folder
        local pathPrefix = "Interface\\AddOns\\WoWVideoPlayer\\stored_videos\\" .. videoConfig.name .. "\\"
        for frameIndex = 1, 500 do -- Limit to 500 frames
            local frameName = string.format("%03d", frameIndex)
            local framePath = pathPrefix .. frameName .. ".jpg"
            table.insert(videoData.frames, framePath)
        end

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
    generalWindow:Hide() -- Start hidden

    -- Create UI elements for each video
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
        playButton:SetCallback("OnClick", function() self:ShowVideo(video) end)
        group:AddChild(playButton)

        generalWindow:AddChild(group)
    end

    self.generalFrame = generalWindow

    -- Register slash commands to toggle the general window
    SLASH_WOWVIDEOPLAYER1, SLASH_WOWVIDEOPLAYER2, SLASH_WOWVIDEOPLAYER3 = "/wvp", "/wowvideoplayer", "/videoplayer"
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

    -- Create texture frame for rendering video frames
    local textureFrame = CreateFrame("Frame", nil, videoWindow.frame)
    textureFrame:SetPoint("TOPLEFT", videoWindow.frame, "TOPLEFT", 15, -25)
    textureFrame:SetPoint("BOTTOMRIGHT", videoWindow.frame, "BOTTOMRIGHT", -15, 45)

    videoWindow.textures = {}
    videoWindow.textureFrame = textureFrame

    videoWindow:SetCallback("OnClose", function()
        self:StopVideo()
        textureFrame:Hide()
    end)

    self.videoWindow = videoWindow
end

function Main:ShowVideo(video)
    -- Adjust window size based on video resolution and show it
    self.videoWindow:SetWidth(video.width / 2)
    self.videoWindow:SetHeight(video.height / 2)
    self.videoWindow:SetTitle(video.name)
    self.videoWindow:Show()
    self.videoWindow.textureFrame:Show()

    -- Start playing the video
    self:PlayVideo(video)

    -- Play audio
    self:PlayAudio(video.audioPath)
end

function Main:PlayVideo(video)
    if self.videoPlaybackTimer then self:StopVideo() end
    self.videoIsPlaying = true

    local currentFrame = 0
    local frameInterval = 1 / video.fps -- 30 FPS is 0.03333
    local textures = self.videoWindow.textures
    local textureFrame = self.videoWindow.textureFrame

    -- Reset and prepare textures
    for _, tex in ipairs(textures) do tex:Hide() tex:SetTexture(nil) end
    for i = 1, 3 do -- Create 3 backup textures
        textures[i] = textures[i] or textureFrame:CreateTexture(nil, "ARTWORK")
        textures[i]:SetAllPoints(textureFrame)
        textures[i]:Show()
    end

    -- Define frame playback function
    local function displayNextFrame()
        if not self.videoWindow or not self.videoWindow:IsShown() then return end
        currentFrame = currentFrame + 1
        if currentFrame > video.totalFrameCount then self:StopVideo() return end

        local activeTextureIndex = (currentFrame - 1) % #textures + 1
        textures[activeTextureIndex]:SetTexture(video.frames[currentFrame])
        for i, tex in ipairs(textures) do tex:SetDrawLayer("ARTWORK", i == activeTextureIndex and 1 or 0) end

        self.videoPlaybackTimer = C_Timer.After(frameInterval, displayNextFrame)
    end

    -- Start video playback
    displayNextFrame()
end

function Main:StopVideo()
    if self.videoPlaybackTimer then self.videoPlaybackTimer:Cancel() end
    self.videoPlaybackTimer = nil
    self.videoIsPlaying = false

    self:StopAudio()

    if self.videoWindow and self.videoWindow:IsShown() then
        self.videoWindow:Hide()
        for _, tex in ipairs(self.videoWindow.textures) do tex:Hide() tex:SetTexture(nil) end
    end
end

function Main:PlayAudio(audioPath)
    -- Stop any currently playing sound
    self:StopAudio()

    -- Play the new audio
    self.audioHandle = PlaySoundFile(audioPath, "Master")
end

function Main:StopAudio()
    if self.audioHandle then
        StopSound(self.audioHandle)
        self.audioHandle = nil
    end
end

function Main:CheckPlayerOnFlightPath()
    -- Check if the player is on a flight path and play relevant videos
    if not InCombatLockdown() and UnitOnTaxi("player") and not self.videoIsPlaying then
        self:PlayFlightPathVideos()
    end
    C_Timer.After(2, function() self:CheckPlayerOnFlightPath() end)
end

function Main:PlayFlightPathVideos()
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