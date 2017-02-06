--StartDebug()
local BrettMod = RegisterMod("BackgroundD6Mod", 1)

local host, port = "127.0.0.1", 9999
local socket = require("socket")
local udp = assert(socket.udp())
udp:setsockname(host,port)
udp:settimeout(0)
local game = Game()
local backupCharge = 6
local wasClear = true
local tcpData = "B"
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

--in this version, you just have a backup D6 ability and there is no swapping of items

function BrettMod:Roll(player)
    if backupCharge >= 6 then
        player:UseActiveItem(105, true, true, true, false)
        --only NPC's have a PlaySound method? how do I play a got damn sound
        --player:PlaySound(SoundEffect.SOUND_DICE_SHARD, 1, 0, false, 1)
        backupCharge = 0
    end
end


function BrettMod:MainLoop()
    -- TODO this should maybe be in player init? i cant get that to work
    -- tcp:connect(host, port)
    local player = game:GetPlayer(0)
    local room = game:GetRoom()

    if not wasClear and room:IsClear() then
        local increase = 1;
        local shape = room:GetRoomShape()
        if shape >= RoomShape.ROOMSHAPE_2x2 and shape <= RoomShape.ROOMSHAPE_LBR then
            increase = 2
        end
        backupCharge = math.min(backupCharge + increase, 6)
    end
    wasClear = room:IsClear()
    local data = udp:receive()
    if data ~= nil then
        tcpData = data
        -- magic response of "A" from server on input
        if data == 'A' then
            BrettMod:Roll(player)
        end
    end
end

function BrettMod:PostRender()

    local barX = 55;
    local barY = 50;
    d6Sprite:Update()
    d6Sprite:Render(Vector(40, 50), Vector(0, 0), Vector(0, 0))

    barBack:Update()
    barBack:Render(Vector(barX, barY), Vector(0, 0), Vector(0, 0))

    barMeter:Update()
    local meterClip = 26 - (backupCharge * 4)
    barMeter:Render(Vector(barX, barY), Vector(0, meterClip), Vector(0, 0))

    barLines:Update()
    barLines:Render(Vector(barX, barY), Vector(0, 0), Vector(0, 0))
--    local ents = Isaac:GetRoomEntities()
--    for i=1,#ents do
--        if i > 6 then
--            return
--        end
--        local ent = ents[i]
--        local str = "bad"
--        local sprite = ent:GetSprite()
--        if sprite then
--            str = sprite:GetFilename()
--        end
--        str = str .. " " .. ent.Type .. " " .. ent.SubType
--        Isaac.RenderText(str, 50, 20 + 10 * i , 1, 1, 1, 1.3)
--    end
end

function BrettMod:PlayerInit()
    backupCharge = 6
    wasClear = true
    tcpData = "B"
end

BrettMod:AddCallback(ModCallbacks.MC_POST_UPDATE, BrettMod.MainLoop)
BrettMod:AddCallback(ModCallbacks.MC_POST_RENDER, BrettMod.PostRender)
BrettMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BrettMod.PlayerInit)