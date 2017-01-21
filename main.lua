--StartDebug()
local BrettMod = RegisterMod("Brett", 1)

local host, port = "127.0.0.1", 9999
local socket = require("socket")
local udp = assert(socket.udp())
udp:setsockname(host,port)
udp:settimeout(0)
local game = Game()
local backupCharge = 6
local wasClear = true
local tcpData = "B"
local bgText = ""
local chargeText = ""

--in this version, you just have a backup D6 ability and there is no swapping of items

function BrettMod:UpdateChargeText()
    bgText =     "D6 charge: [" .. string.rep(" ", backupCharge) .. string.rep(".", 6 - backupCharge) .. "]"
    chargeText = "            " .. string.rep("#", backupCharge)
end

function BrettMod:Roll(player)
    if backupCharge >= 6 then
        player:UseActiveItem(105, true, true, true, false)
        --only NPC's have a PlaySound method? how do I play a got damn sound
        --player:PlaySound(SoundEffect.SOUND_DICE_SHARD, 1, 0, false, 1)
        backupCharge = 0
        BrettMod:UpdateChargeText()
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
        BrettMod:UpdateChargeText()
    end
    wasClear = room:IsClear()
    local data = udp:receive()
    if data ~= nil then
        tcpData = data
        -- magic response of "A" from server on input
        if data == 'A' and not player:IsHoldingItem() then
            BrettMod:Roll(player)
        end
    end
end

function BrettMod:PostRender()
    Isaac.RenderText(bgText, 50, 30, 1, 1, 1, 1.3)
    Isaac.RenderText(chargeText, 50, 30, 0.5, 1, 0.5, 1.3)
    -- Isaac.RenderText(tcpData, 50, 45, 255, 255, 255, 255)
end

function BrettMod:PlayerInit()
    backupCharge = 6
    wasClear = true
    tcpData = "B"
    BrettMod:UpdateChargeText()
end

BrettMod:AddCallback(ModCallbacks.MC_POST_UPDATE, BrettMod.MainLoop)
BrettMod:AddCallback(ModCallbacks.MC_POST_RENDER, BrettMod.PostRender)
BrettMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BrettMod.PlayerInit)