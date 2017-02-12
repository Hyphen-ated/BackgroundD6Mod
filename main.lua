local BuiltInD6Mod = RegisterMod("BuiltInD6", 1)

--"data" contains all the things that we persist in isaac's ModData system
local data = {rerollKey=84, rerollKeyName="T", backupCharge=6 }

function loadInfo()
    local savedInfo = Isaac.LoadModData(BuiltInD6Mod)
    if savedInfo ~= nil and savedInfo:len() > 1 then
        Isaac.DebugString("Found saved BuiltInD6 info. It is: " ..savedInfo)
        local count = 0
        for x in string.gmatch(savedInfo, ",") do
            count = count + 1
        end
        if count == 1 then
            --if there is only one comma, that means they upgraded from the old version
            data.rerollKey, data.rerollKeyName = savedInfo:match("([^,]+),([^,]+)")
            return
        end

        savedThings = {}
        for thing in string.gmatch(savedInfo, "([^,]+),%s*") do
            table.insert(savedThings, thing)
        end

        if #savedThings >= 2 then
            data.rerollKey = savedThings[1]
            data.rerollKeyName = savedThings[2]
        end
        if #savedThings == 3 then
            data.backupCharge = savedThings[3]
        end
    end
end

loadInfo()

function saveInfo()
    --serialize these things separated by commas (and with a comma at the end)
    Isaac.SaveModData(BuiltInD6Mod, tostring(data.rerollKey .. "," .. data.rerollKeyName .. "," .. data.backupCharge .. ","))
end

local keySet = false

local game = Game()
local wasClear = true
local lastFrameCount = 0
local keyBindChallenge = Isaac.GetChallengeIdByName("Change Keybind For Built-In D6");

local d6Sprite = Sprite()
d6Sprite:Load("gfx/backgroundd6.anm2", true)
d6Sprite:Play("anim", true)
local barBack = Sprite()
barBack:Load("gfx/ui/ui_chargebar.anm2", true)
barBack:Play("BarEmpty", true)
local barMeter = Sprite()
barMeter:Load("gfx/ui/ui_chargebar.anm2", true)
barMeter:Play("BarFull", true)
local barLines = Sprite()
barLines:Load("gfx/ui/ui_chargebar.anm2", true)
barLines:Play("BarOverlay6", true)

function BuiltInD6Mod:Roll(player)
    if data.backupCharge >= 6 then
        player:UseActiveItem(105, true, true, true, false)
        --only NPC's have a PlaySound method? how do I play a got damn sound
        --player:PlaySound(SoundEffect.SOUND_DICE_SHARD, 1, 0, false, 1)
        data.backupCharge = 0
        saveInfo()
    end
end


function BuiltInD6Mod:MainLoop()

    local player = game:GetPlayer(0)
    if game:GetFrameCount() == 1 then
        data.backupCharge = 6
        saveInfo()
    end
    local room = game:GetRoom()
    local roomClear = room:IsClear()
    local frameCount = room:GetFrameCount()
    --check to see if the room became cleared, and we are still in the same room
    --(there was a bug where you could bomb from a nonclear to a clear room and charge.
    -- framecount goes to 0 when you change room, so it fixes that)
    if not wasClear and roomClear and frameCount >= lastFrameCount then
        local increase = 1;
        local shape = room:GetRoomShape()
        if shape >= RoomShape.ROOMSHAPE_2x2 and shape <= RoomShape.ROOMSHAPE_LBR then
            increase = 2
        end
        data.backupCharge = math.min(data.backupCharge + increase, 6)
        saveInfo()
    end
    wasClear = roomClear
    lastFrameCount = frameCount

    if Input.IsButtonPressed(data.rerollKey, 0) then
        BuiltInD6Mod:Roll(player)
    end

end

function BuiltInD6Mod:PostRender()
    if Isaac.GetChallenge() == keyBindChallenge then
        if data.rerollKey == -1 then
            Isaac.RenderText("Reroll key not bound", 100, 90, 0, 1, 0, 2)
        else
            Isaac.RenderText("Reroll key bound to: ".. data.rerollKeyName .. " (code: " .. data.rerollKey .. ")", 100, 90, 0, 1, 0, 2)
        end

        -- Wait a moment just in case they were mashing stuff while it was loading
        if game:GetFrameCount() > 5 then
            if keySet then
                Isaac.RenderText("Key bound! Exit the challenge now.", 100, 110, 0, 1, 0, 2)
            else
                Isaac.RenderText("Press desired key now", 100, 110, 0, 1, 0, 2)
                for k, v in pairs(Keyboard) do
                    if Input.IsButtonPressed(v, 0) then
                        data.rerollKey = v
                        data.rerollKeyName = k:sub(5)
                        saveInfo()
                        keySet = true
                    end
                end
            end
        else
            keySet = false
        end
    end

    --draw the d6 image
    local barX = 55;
    local barY = 50;
    d6Sprite:Update()
    d6Sprite:Render(Vector(40, 50), Vector(0, 0), Vector(0, 0))

    --draw the charge bar. 3 pieces: the background, the bar itself (clipped appropriately) and the segment lines on top
    barBack:Update()
    barBack:Render(Vector(barX, barY), Vector(0, 0), Vector(0, 0))

    barMeter:Update()
    local meterClip = 26 - (data.backupCharge * 4)
    barMeter:Render(Vector(barX, barY), Vector(0, meterClip), Vector(0, 0))

    barLines:Update()
    barLines:Render(Vector(barX, barY), Vector(0, 0), Vector(0, 0))

end

function BuiltInD6Mod:PlayerInit()
    wasClear = true
end

BuiltInD6Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, BuiltInD6Mod.MainLoop)
BuiltInD6Mod:AddCallback(ModCallbacks.MC_POST_RENDER, BuiltInD6Mod.PostRender)
BuiltInD6Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BuiltInD6Mod.PlayerInit)



