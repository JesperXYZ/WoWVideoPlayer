local name, WoWVideoPlayer = ...

WoWVideoPlayer.videos = {
    {
        -- Name (it has to match the exact folder name of the video in the "stored_videos" folder)
        name = "test_video_1",

        -- Video resolution (this strecteches the video frames, the original resolutions MUST be 1024x1024 or 512x512)
        width = 960,
        height = 720,

        -- Images per second (if this is inaccurate, the video will be too fast or slow and audio will be desynced)
        fps = 10,

        -- Total number of frames in the video (if this is inaccurate, the video will end too early or too late)
        totalFrameCount = 249,
        
        -- Determine if the video automatically plays when the player is on a flight path
        autoPlayOnFlightPath = true,
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