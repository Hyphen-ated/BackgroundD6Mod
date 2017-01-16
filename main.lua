--StartDebug()
local BrettMod = RegisterMod("Brett", 1)

local host, port = "127.0.0.1", 9999
local socket = require("socket")
local tcp = assert(socket.tcp())
local game = Game()
local backupCharge = 6
local backupId = 105
local wasClear = true
local tcpData = "B"

function BrettMod:SwitchActive(player)
  currentActive = player:GetActiveItem()
  currentCharge = player:GetActiveCharge()
  player:AddCollectible(backupId, backupCharge, false)
  backupId = currentActive
  backupCharge = currentCharge
end


function BrettMod:MainLoop()
  -- TODO this should maybe be in player init? i cant get that to work
  tcp:connect(host, port)
  local player = game:GetPlayer(0) 
  local room = game:GetRoom()
  if not wasClear and room:IsClear() then
    -- TODO respect rules of various battery items
    -- TODO dont go past max charge. built in way of looking up max charge broken
    backupCharge = backupCharge + 1
  end
  wasClear = room:IsClear()
  if tcp ~= nil then
    -- TODO learn how sockets/tcp works at all
    tcp:send("Ok")
    local data = tcp:receive(1)
    if data ~= nil then
      tcpData = data
      -- magic response of "A" from server on input
      if data == 'A' then
        BrettMod:SwitchActive(player)
      end
    end
  end
end

function BrettMod:PostRender()
  -- TODO say item name. the built in way of looking this up in the api is broken
  bgText = string.format("%s (%s charges)",backupId,backupCharge)
  Isaac.RenderText(bgText, 50, 35, 255, 255, 255, 255)
end


BrettMod:AddCallback(ModCallbacks.MC_POST_UPDATE, BrettMod.MainLoop)
BrettMod:AddCallback(ModCallbacks.MC_POST_RENDER, BrettMod.PostRender)