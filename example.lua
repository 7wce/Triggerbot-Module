local Module = loadstring(game:HttpGet("https://raw.githubusercontent.com/7wce/Triggerbot-Module/refs/heads/main/triggerbot.lua"))()

Module:Start(function(player)
    -- you can add your own function to this
    -- but for example purposes, we'll gonna use print
    print(player.Name)
end)

Module:Stop()
