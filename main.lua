--StartDebug()
local BrettMod = RegisterMod("BackgroundD6Mod", 1)

local rerollKey = Isaac.LoadModData(BrettMod)
if rerollKey == nil then rerollKey = "unbound" end
local keySet = false

local game = Game()
local backupCharge = 6
local wasClear = true

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
    if Input.IsButtonPressed(rerollKey, 0) then
        BrettMod:Roll(player)
    end

end

function BrettMod:PostRender()

    if Isaac.GetChallenge() == keyBindChallenge then
        if rerollKey == "unbound" then
            Isaac.RenderText("No key bound", 100, 90, 0, 1, 0, 2)
        else
            Isaac.RenderText("Current key binding (numerical code): "..rerollKey, 100, 90, 0, 1, 0, 2)
        end

        -- Wait a few seconds just in case they were mashing stuff while it was loading
        if game:GetFrameCount() > 60 then
            if keySet then
                Isaac.RenderText("Key bound! Exit the challenge now.", 100, 110, 0, 1, 0, 2)
            else
                Isaac.RenderText("Press desired key now", 100, 110, 0, 1, 0, 2)
                for i, v in pairs(Keyboard) do
                    if Input.IsButtonPressed(v, 0) then
                        Isaac.SaveModData(BrettMod, tostring(v))
                        rerollKey = v
                        keySet = true
                    end
                end
            end
        else
            keySet = false
        end
    end

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

end

function BrettMod:PlayerInit()
    backupCharge = 6
    wasClear = true
end

BrettMod:AddCallback(ModCallbacks.MC_POST_UPDATE, BrettMod.MainLoop)
BrettMod:AddCallback(ModCallbacks.MC_POST_RENDER, BrettMod.PostRender)
BrettMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BrettMod.PlayerInit)