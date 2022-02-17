local soundUrls = {
    shrek_001 = 'https://github.com/reystudio/audio/blob/main/shrek_001.txt?raw=true',
    shrek_002 = 'https://github.com/reystudio/audio/blob/main/shrek_002.txt?raw=true',
    shrek_003 = 'https://github.com/reystudio/audio/blob/main/shrek_003.txt?raw=true',
}
local lastKey, httperr, httpsucc
SHRSND = {}
local function nextSound(lk)
    lastKey = next(soundUrls, lk)
    if not lastKey then print('done!', table.Count(SHRSND), 'sounds downloaded!') return end
    http.Fetch(soundUrls[lastKey], httpsucc, httperr)
end
httperr = function (...) nextSound(lastKey) end
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
        sound.PlayFile('data/' .. SHRSND[name], '3d', function(st, ...)
            if IsValid(st) then st:SetPos(ent) else print(...) end
        end)
    else
        timer.Simple(1, function() pl(ent, name) end) return
    end
end
net.Receive('shrek.morph', function(l) local ent = net.ReadEntity() pl(ent, SHRSND) end)