local name, WoWVideoPlayer = ...

WoWVideoPlayer.videos = {
    { 
        -- Name (it has to match the exact folder name of the video in the "stored_videos" folder)
        name = "test_video_10fps_512x512",
        -- displayName = "Test Video",
        -- folderName = "test_video",

        -- Video resolution (this strecteches the video frames, the original resolutions MUST be 1024x1024)
        width = 960,
        height = 720,

        -- Images per second (if this is inaccurate, the video will be too fast or slow and audio will be desynced)
        fps = 10,

        -- 
        autoPlayOnFlightPath = true,

        -- Makes it impossible to close the window while the video is playing,
        -- esc key doesn't work either (/reload does work tho)
        disableCloseWindowButton = true
    },
    {
        name = "test_video_10fps_1024x1024",
        width = 960,
        height = 720,
        fps = 10,
        autoPlayOnFlightPath = true,
        disableCloseWindowButton = true,
    },
    {
        name = "test_video_20fps_512x512",
        width = 960,
        height = 720,
        fps = 20,
        autoPlayOnFlightPath = true,
        disableCloseWindowButton = true,
    },
    {
        name = "test_video_20fps_1024x1024",
        width = 960,
        height = 720,
        fps = 20,
        autoPlayOnFlightPath = true,
        disableCloseWindowButton = true,
    }
}