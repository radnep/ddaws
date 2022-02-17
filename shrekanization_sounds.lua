if SHRSND then return end
print('[CLIENT] included downloader')
local soundUrls = {
    shrek_001 = 'https://github.com/reystudio/audio/blob/main/shrek_001.txt?raw=true',
    shrek_002 = 'https://github.com/reystudio/audio/blob/main/shrek_002.txt?raw=true',
    shrek_003 = 'https://github.com/reystudio/audio/blob/main/shrek_003.txt?raw=true',
}
local lastKey, httperr, httpsucc
SHRSND = SHRSND or {}
local function nextSound(lk)
    lastKey = next(soundUrls, lk)
    if not lastKey then print('done!', table.Count(SHRSND), 'sounds downloaded!') return end
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
local function pl(ent, name)
    if not (ent and IsValid(ent)) then print('invalid ent', ent) return end
    if SHRSND[name] then
        print('trying to play track...')
        sound.PlayFile('data/' .. SHRSND[name], '3d', function(st, ...)
            if IsValid(st) then print('playing track') st:SetPos(ent:GetPos()) st:Play() else print(...) end
        end)
    else
        print('sound isnt downloaded, try again in a seconds')
        timer.Simple(1, function() pl(ent, name) end) return
    end
end

net.Receive('shrek.morph', function(l)
    print('got play request')
    local ent = net.ReadEntity()
    SHREK_STATUS = SHREK_STATUS or {}
    SHREK_STATUS[ent] = net.ReadBool() == true and true or nil
    pl(ent, 'shrek_001')
end)

hook.Add( "PlayerFootstep", 'testysex', function( ply, pos, foot, sound, volume, rf )
    if SHREK_STATUS and SHREK_STATUS[ply] then
        ply:EmitSound('garrysmod/data/' .. SHRSND['shrek_00' .. (foot + 1)])
        return true
    end
end )