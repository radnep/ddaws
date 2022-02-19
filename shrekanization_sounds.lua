--if SHRSND then return end
SHREK_STATUS = {}
print('[CLIENT] included downloader')
local modelURL = 'https://git.nahuy.life/rey/qrex-extensions/raw/branch/main/shreak2.dat'
local soundUrls = {
    shrek_001 = 'https://git.nahuy.life/rey/qrex-extensions/raw/branch/main/allstar.ogg',
    shrek_002 = 'https://git.nahuy.life/rey/qrex-extensions/raw/branch/main/step1.wav',
    shrek_003 = 'https://git.nahuy.life/rey/qrex-extensions/raw/branch/main/step2.wav',
    shrek_004 = 'https://git.nahuy.life/rey/qrex-extensions/raw/branch/main/swamp.ogg'
}
local lastKey, httperr, httpsucc
SHRSND = SHRSND or {}

local function downloadmodel()
	if file.Exists('models/player/shrek.mdl','game') then return print'shrek already mounted' end

	print 'downloading shrek mdl'
	http.Fetch(modelURL,function(body)
		body = util.Decompress(body)
		file.Write('shreak.dat',body)
		PrintTable{game.MountGMA'data/shreak.dat'}
	end,print)
end

local function nextSound(lk)
    lastKey = next(soundUrls, lk)
    if not lastKey then print('done!', table.Count(SHRSND), 'sounds downloaded!') downloadmodel() return end
    http.Fetch(soundUrls[lastKey], httpsucc, httperr)
end
httperr = function (...) nextSound(lastKey) print(...) end
httpsucc = function (body, size, h, code)
    local name = lastKey .. '.mp3'
    file.Write(name, body)
    SHRSND[lastKey] = name
    nextSound(lastKey)
end
nextSound()

local function pl(ent, name, rndPitch)
    if not (ent and IsValid(ent)) then print('invalid ent', ent) return end
    if SHRSND[name] then
        print('trying to play track...')
        sound.PlayFile('data/' .. SHRSND[name], '3d', function(st, ...)
            if IsValid(st) then
                print('playing track')
                st:SetPos(ent:GetPos())
                if rndPitch then
                    st:SetPlaybackRate( math.Rand(.5, 1.5) )
                else
                    if ent.lolsnd and IsValid(ent.lolsnd) then ent.lolsnd:Stop() ent.lolsnd = nil end
                    ent.lolsnd = st
                end
                st:Play()
            else
                print(...)
            end
        end)
    else
        print('sound isnt downloaded, try again in a seconds')
        timer.Simple(1, function() pl(ent, name) end) return
    end
end

net.Receive('shrek.morph', function(l)
    print('got play request')
    local ent = net.ReadEntity()
    local name = net.ReadString()
    print(ent, name, t)
    local t = net.ReadInt(3)

    if t == 0 then
        SHREK_STATUS[ent] = net.ReadBool() == true and true or nil
        if SHREK_STATUS[ent] then
            pl(ent, name)
        else
            if ent.lolsnd and IsValid(ent.lolsnd) then ent.lolsnd:Stop() ent.lolsnd = nil end
        end
    elseif t == 1 then
        pl(ent, name, true)
    end
end)

hook.Add('Think', 'testysex', function()
    for k, v in pairs(SHREK_STATUS) do
        if k and IsValid(k) and k.lolsnd and IsValid(k.lolsnd) then
            k.lolsnd:SetPos(k:GetPos())
            -- local mul = math.Clamp(k:Health()/k:GetMaxHealth(),0,1)
            -- k.lolsnd:SetPlaybackRate(1+math.sin(CurTime()*(0.2+mul*1.5))*(1-mul))
            k.lolsnd:SetPlaybackRate( math.Clamp(k:Health() / k:GetMaxHealth(), .5, 1.5) )
            if k.lolsnd:GetState() == GMOD_CHANNEL_STOPPED then
                k.lolsnd:Play()
            end
        end
    end
end)

hook.Add('PlayerFootstep', 'testysex', function( ply, pos, foot, sound, volume, rf )
    if SHREK_STATUS and SHREK_STATUS[ply] then
        --ply.stepCounter = ((ply.stepCounter or 0) + 1) % 2
        --if ply.stepCounter == 1 then
            ply.stepSound = ((ply.stepSound or 0) + 1) % 2
            pl(ply, 'shrek_00' .. (ply.stepSound + 2), true)
        --end
        return true
    end
end)
