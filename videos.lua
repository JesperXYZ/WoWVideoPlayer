local name, WoWVideoPlayer = ...

WoWVideoPlayer.videos = {
    { 
        name = "test_video_1", -- Name (it has to match the exact folder name of the video in the "stored_videos" folder)
        -- displayName = "Test Video",
        -- folderName = "test_video",
        width = 960, -- Video resolution (this strecteches the video frames, the original resolutions MUST be 1024x1024 or 512x512)
        height = 720,
        fps = 10,-- Images per second (if this is inaccurate, the video will be too fast or slow and audio will be desynced)
        totalFrameCount = 249, --
        autoPlayOnFlightPath = true, --
    },
    {
        name = "test_video_2",
        width = 1920,
        height = 1080,
        fps = 15,
        totalFrameCount = 299,
        autoPlayOnFlightPath = true
    },
    {
        name = "test_video_3",
        width = 1280,
        height = 720,
        fps = 12,
        totalFrameCount = 239,
        autoPlayOnFlightPath = true
    }
}