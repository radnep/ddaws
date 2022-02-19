--if SHRSND then return end
SHREK_STATUS = {}
print('[CLIENT] included downloader')
local modelURL = 'https://git.nahuy.life/rey/qrex-extensions/raw/branch/main/shreak3.dat'
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

downloadmodel()

net.Receive('shrek.morph', function(l)
	local ent = net.ReadEntity()
	local name = net.ReadString()
	local t = net.ReadInt(3)

	if name == 'shrek_004' then
		ent:EmitSound('shrek/swamp.mp3',160,math.Rand(80,120),1,CHAN_VOICE,0)
	end
	if name == 'shrek_001' then
		local b = net.ReadBool()
		if b then
			sound.PlayFile('sound/shrek/allstar.ogg','3d mono noplay', function(c)
				c:Play()
				ent.shreksnd = c
			end)
		else
			if ent.shreksnd and ent.shreksnd:IsValid() then
				ent.shreksnd:Stop()
			end
		end

	end
end)

hook.Add('Think', 'testysex', function()
	for k, v in pairs(SHREK_STATUS) do
		if k and IsValid(k) and k.shreksnd and k.shreksnd:IsValid() then
			k.shreksnd:SetPos(k:GetPos())
			-- local mul = math.Clamp(k:Health()/k:GetMaxHealth(),0,1)
			-- k.lolsnd:SetPlaybackRate(1+math.sin(CurTime()*(0.2+mul*1.5))*(1-mul))
			k.shreksnd:SetPlaybackRate( math.Clamp(k:Health() / k:GetMaxHealth(), .5, 1.5) )
			if k.shreksnd:GetState() == GMOD_CHANNEL_STOPPED then
				k.shreksnd:Play()
			end
		end
	end
end)

hook.Add('PlayerFootstep', 'testysex', function( ply, pos, foot, sound, volume, rf )
	print(ply)
	if SHREK_STATUS and SHREK_STATUS[ply] then
		print(ply)
		ply.stepSound = ((ply.stepSound or 0) + 1) % 2

		ply:EmitSound('shrek/step'..(ply.stepSound+1)..'.wav',160)
		return true
	end
end)
