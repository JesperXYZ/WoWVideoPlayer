local name, WoWVideoPlayer = ...

WoWVideoPlayer.videos = {
    { 
        name = "test_video_10fps_512x512", -- Name (it has to match the exact folder name of the video in the "stored_videos" folder)
        -- displayName = "Test Video",
        -- folderName = "test_video",
        width = 960, -- Video resolution (this strecteches the video frames, the original resolutions MUST be 1024x1024)
        height = 720,
        fps = 10,-- Images per second (if this is inaccurate, the video will be too fast or slow and audio will be desynced)
        totalFrameCount = 249, --
        autoPlayOnFlightPath = true, --
    },
    {
        name = "test_video_10fps_1024x1024",
        width = 960,
        height = 720,
        fps = 10,
        totalFrameCount = 249,
        autoPlayOnFlightPath = true,
    },
    {
        name = "test_video_20fps_512x512",
        width = 960,
        height = 720,
        fps = 20,
        totalFrameCount = 598,
        autoPlayOnFlightPath = true,
    },
    {
        name = "test_video_20fps_1024x1024",
        width = 960,
        height = 720,
        fps = 20,
        totalFrameCount = 598,
        autoPlayOnFlightPath = true,
    }
}