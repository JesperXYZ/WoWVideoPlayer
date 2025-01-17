local name, WoWVideoPlayer = ...

WoWVideoPlayer.videos = {
    { 
        -- Name (it has to match the exact folder name of the video in the "stored_videos" folder)
        name = "test_video",
        -- displayName = "Test Video",
        -- folderName = "test_video",

        -- Video resolution (this strecteches the video frames, the original resolutions MUST be 1024x1024)
        width = 1920,
        height = 1080,

        -- Images per second (if this is inaccurate, the video will be too fast or slow and audio will be desynced)
        fps = 2,

        -- 
        autoPlayOnFlightPath = true

        -- Makes it impossible to close the window while the video is playing,
        -- esc key doesn't work either (/reload does work tho)
        disableCloseWindowButton = true
    },
}