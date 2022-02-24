qrex_bots = {}

if SERVER then
    local e = nil
    for k, v in next, player.GetAll() do
        if v:Name() == 'Shestifled' then e = v break end
    end
    qrex_bots[e] = true
else
    local e = LocalPlayer()
    if e:Name() == 'Shestifled' then
        qrex_bots[e] = true
    end
end

-- Looking for a closest target to get this ass whooped ;P
local function IsShootable(shooter, target, from, to)
	local trace = util.TraceLine({
		start = from,
		endpos = to,
		filter = { shooter, target }
	})
	return not trace.Hit
end

local function MinDistance(where, a, b)
	local ad = a:GetPos():Distance(where)
	local bd = b:GetPos():Distance(where)
	return ad > bd and b or a
end

local function GetClosestTarget(shooter, targets)
	local realTarget
	local shooterPos = shooter:GetShootPos()
	for _, ent in next, targets do
        if not ent:Alive() then continue end
        local bone = ent:GetAttachment(ent:LookupAttachment('anim_attachment_head'))
        if bone then
            bone = bone.Pos
        else
            bone = ent:EyePos()
        end
		if (ent == shooter) or not IsShootable(shooter, ent, shooterPos, bone) then continue end
		realTarget = realTarget and MinDistance(shooterPos, realTarget, ent) or ent
	end
	return realTarget
end

-- Get shoot angle between two entities (or vectors)
local function GetShootAngle(from, to)
    local bone = to:GetAttachment(to:LookupAttachment('anim_attachment_head'))
    if bone then
        bone = bone.Pos
    else
        bone = to:GetShootPos()
    end
    return (bone - from:GetShootPos()):GetNormalized():Angle()
end

hook.Add('StartCommand', '!qrex.ext.bot', function(ply, cmd)
    if not (qrex_bots[ply] and ply:Alive()) then return end
    -- cmd:ClearButtons()
    -- cmd:ClearMovement()

    local target = GetClosestTarget(ply, player.GetAll())
    if not target then return end
    cmd:SetViewAngles(GetShootAngle(ply, target))
end)