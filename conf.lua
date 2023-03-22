function love.conf(t)
    t.identity = "fos_emulator"                    -- The name of the save directory (string)
    t.version = "11.3"                  -- The LÖVE version this game was made for (string)
    t.console = true                   -- Attach a console (boolean, Windows only)
    t.externalstorage = true           -- True to save files (and read from the save directory) in external storage on Android (boolean) 

    t.window.icon = nil                 -- Filepath to an image to use as the window's icon (string)
    t.window.title = "Fos Emulator"         -- The window title (string)
    t.window.usedpiscale = false         -- Enable automatic DPI scaling when highdpi is set to true as well (boolean)
    t.window.resizable = true          -- Let the window be user-resizable (boolean)

    t.window.width = 550
    t.window.height = 800
end