local name, WoWVideoPlayer = ...

local Main = LibStub("AceAddon-3.0"):NewAddon(name)
local AceGUI = LibStub("AceGUI-3.0")

WoWVideoPlayer.Main = Main

function Main:OnInitialize()
    self:InitializeVideos()
    self:CreateGeneralWindow()
    self:CreateVideoWindow()
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
            frames = {}
        }

        --local pathPrefix = "|TInterface\\Addons\\WoWVideoPlayer\\stored_videos\\" .. videoConfig.name .. "\\"
        --local framePath = pathPrefix .. frameIndex .. ":".. videoConfig.height .. ":" .. videoConfig.width .. ":0:0|t"

        -- Load frames from the stored_videos folder
        local pathPrefix = "Interface\\AddOns\\WoWVideoPlayer\\stored_videos\\" .. videoConfig.name .. "\\"
        local frameIndex = 1

        while true do

            -- Define the path to the frame
            local framePath = pathPrefix .. frameIndex .. ".jpg"

            -- Stop when no more frames are found
            --if not FileExists(framePath) then
            --if frameIndex > videoConfig.frameCount then
            if frameIndex > 200 then
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

    local textureFrame = CreateFrame("Frame", nil, videoWindow.frame)
    local videoTexture = textureFrame:CreateTexture(nil, "ARTWORK")

    -- Adjust the size of the textureFrame to be slightly smaller than the videoWindow
    local padding = 10 -- Adjust the padding value as needed for desired border visibility
    textureFrame:SetPoint("TOPLEFT", videoWindow.frame, "TOPLEFT", padding, -padding)
    textureFrame:SetPoint("BOTTOMRIGHT", videoWindow.frame, "BOTTOMRIGHT", -padding, padding)

    videoTexture:SetAllPoints(textureFrame)
    textureFrame:Hide()

    videoWindow.videoTexture = videoTexture
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

    local function displayNextFrame()

        if not self.videoWindow or not self.videoWindow:IsShown() then
            return
        end

        currentFrame = currentFrame + 1
        if currentFrame > frameCount then
            currentFrame = 1 -- Loop video
        end

        local frameTexture = video.frames[currentFrame]
        self.videoWindow.videoTexture:SetTexture(frameTexture)

        self.videoPlaybackTimer = C_Timer.After(frameInterval, displayNextFrame)
    end

    displayNextFrame()
end

function Main:StopVideo()
    if self.videoPlaybackTimer then
        self.videoPlaybackTimer:Cancel()
        self.videoPlaybackTimer = nil
    end
end
