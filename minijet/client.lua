do
    local ENT = {}
    ENT.Base = "base_anim"
    ENT.PrintName = "Rocket"
    ENT.Editable = false
    ENT.Spawnable = false
    ENT.AdminOnly = false
    ENT.RenderGroup = RENDERGROUP_TRANSCULENT
    local sndtrail = Sound("Missile.Accelerate")
    function ENT:Initialize()
        self.EffectData = EffectData()
        self.EffectData:SetEntity(self.Entity)
        self.EffectData:SetScale(1.5)
    end
    function ENT:Touch( ent )
        if ent:GetMoveType() == 0 and !ent:IsWorld() then return end
        if ent:GetMoveType() == 7 and ent:GetClass()=="func_breakable_surf" then return end
        local trace = {}
        trace.start = self:GetPos() + self:GetForward()
        trace.endpos = trace.start + self:GetForward() * 90000
        trace.filter = self
        local tr = util.TraceLine(trace)
        if tr.Hit and tr.HitSky then self:Remove() return end
    end
    function ENT:OnTakeDamage( dmginfo )
        self:TakePhysicsDamage( dmginfo )
    end
    local SmokeRate = 0.03
    function ENT:Draw()
        self:DrawModel()
        self.NextSmoke = self.NextSmoke or CurTime() + SmokeRate
        if self.NextSmoke < CurTime() then
            local Pos = self.Entity:LocalToWorld(Vector(-12,0,0))
            local emitter = ParticleEmitter(Pos)	
            local particle = emitter:Add("particle/particle_noisesphere", Pos)
            particle:SetVelocity(VectorRand()*5)
            particle:SetDieTime(math.Rand(1.5,1.7))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(5)
            particle:SetEndSize(math.random(10,15))
            particle:SetRoll(200)
            particle:SetRollDelta(math.random(-1,1))
            particle:SetColor(150,150,150)
            emitter:Finish()
            self.EffectData:SetOrigin(Pos)
            self.EffectData:SetAngles(self.Entity:GetAngles())
            util.Effect("MuzzleEffect", self.EffectData)
            self.NextSmoke = CurTime() + SmokeRate
        end
    end
    function ENT:OnRemove()
        self:StopSound(sndtrail)
    end
    scripted_ents.Register( ENT, "ent_rocket_epta", true )
end

do
    local ENT = {}
    ENT.Base = "base_anim"
    ENT.PrintName = "Bomb"
    ENT.Editable = false
    ENT.Spawnable = false
    ENT.AdminOnly = false
    ENT.RenderGroup = RENDERGROUP_TRANSCULENT
    function ENT:Initialize()
        self.EffectData = EffectData()
        self.EffectData:SetEntity(self.Entity)
        self.EffectData:SetScale(1.5)
    end
    function ENT:Touch( ent )
        if ent:GetMoveType() == 0 and !ent:IsWorld() then return end
        if ent:GetMoveType() == 7 and ent:GetClass()=="func_breakable_surf" then return end
        local trace = {}
        trace.start = self:GetPos() + self:GetForward()
        trace.endpos = trace.start + self:GetForward() * 90000
        trace.filter = self
        local tr = util.TraceLine(trace)
        if tr.Hit and tr.HitSky then self:Remove() return end
    end
    function ENT:OnTakeDamage( dmginfo )
        self:TakePhysicsDamage( dmginfo )
    end
    function ENT:Draw()
        self:DrawModel()
    end
    scripted_ents.Register( ENT, "ent_bomb_epta", true )
end

-- reload script check
local rme
if mj then
    rme = mj.isMe
    for k, v in next, mj.active do
        if not (k and IsValid(k)) then continue end
        mj:off(k)
    end
end

mj = {
    isMe = rme,
    active = {},
    jetModel = 'models/xqm/jetbody3.mdl',
    pilotModel = 'models/player/urban.mdl'
}

local matFire = Material( "effects/fire_cloud1" )
local matHeatWave = Material( "sprites/heatwave" )

local function drawflames(ent,off,ang,size,scale)
    -- local vOffset = ent:LocalToWorld( off )
    local vOffset, vStf = LocalToWorld( off, Angle(0, 0, 0), ent:GetPos(), ent:GetRenderAngles() )
    --local vNormal = ent:LocalToWorldAngles(ang):Forward()
    local uhh, vNormal = LocalToWorld( Vector(0, 0, 0), ang, ent:GetPos(), ent:GetRenderAngles() )
    vNormal = vNormal:Forward()
    local scroll = CurTime() * -10
    
    local Scale = scale or 1

    render.SetMaterial( matFire )

    render.StartBeam( 3 )
        render.AddBeam( vOffset, size * Scale, scroll, Color( 0, 0, 255, 128 ) )
        render.AddBeam( vOffset + vNormal * 60 * Scale, 32 * Scale, scroll + 1, Color( 255, 255, 255, 128 ) )
        render.AddBeam( vOffset + vNormal * 148 * Scale, 32 * Scale, scroll + 3, Color( 255, 255, 255, 0 ) )
    render.EndBeam()

    scroll = scroll * 0.5

    render.UpdateRefractTexture()
    render.SetMaterial( matHeatWave )
    render.StartBeam( 3 )
        render.AddBeam( vOffset, size * Scale, scroll, Color( 0, 0, 255, 128 ) )
        render.AddBeam( vOffset + vNormal * 32 * Scale, 32 * Scale, scroll + 2, color_white )
        render.AddBeam( vOffset + vNormal * 128 * Scale, 48 * Scale, scroll + 5, Color( 0, 0, 0, 0 ) )
    render.EndBeam()


    scroll = scroll * 1.3
    render.SetMaterial( matFire )
    render.StartBeam( 3 )
        render.AddBeam( vOffset, size * Scale, scroll, Color( 0, 0, 255, 128) )
        render.AddBeam( vOffset + vNormal * 60 * Scale, 16 * Scale, scroll + 1, Color( 255, 255, 255, 128 ) )
        render.AddBeam( vOffset + vNormal * 148 * Scale, 16 * Scale, scroll + 3, Color( 255, 255, 255, 0 ) )
    render.EndBeam()
end

local function ParentJet(ply, jet)
    jet.dad = ply
    local att = ply:LookupAttachment('anim_attachment_head')
    jet:SetParent(ply, att)
    local sex = ply:GetEyeTrace()
    jet:SetAngles( (sex.HitPos - sex.StartPos):Angle() + Angle(180, 0, -90) )
    jet:SetPos(ply:GetPos())
end

local function ParentPilot(jet, pilot)
    -- local jp = jet:GetPos()
    -- pilot.dad = jet
    -- local ang = jet.dad:EyeAngles() + Angle(0, 0, 90)
    -- ang = Angle(ang.r, ang.y, ang.p)
    -- pilot:SetParent(jet, jet.dad:LookupAttachment('anim_attachment_head'))
    -- pilot:SetAngles(ang)
    -- pilot:SetPos(jp + ang:Forward() * 18 + ang:Up() * -2 + ang:Right() * 1)
end

function mj:on(ply)
    -- ply:SetCollisionGroup(COLLISION_GROUP_WORLD)
    print('on', ply)
    local jet = ClientsideModel(self.jetModel)
    ParentJet(ply, jet)
    jet:Spawn()
    jet:SetModelScale(0.3)
    ply.csJetMdl = jet

    -- local pilot = ClientsideModel(self.pilotModel)
    -- local pos, ang = ParentPilot(jet, pilot)
    -- pilot:Spawn()
    -- pilot:SetModelScale(0.25)
    -- ply.csPilotMdl = pilot
    -- jet.pilot = pilot
    -- pilot:SetSequence(157)
    -- pilot:SetNoDraw(true)

    self.active[ply] = true
end

function mj:off(ply)
    print('off', ply)
    -- ply:SetCollisionGroup(COLLISION_GROUP_NONE)
    -- ply:SetNoDraw(false)
    -- ply.csPilotMdl:Remove()
    ply.csJetMdl:Remove()
    self.active[ply] = nil
end

local function pilotcam( ply, pos, angles, fov )
    if not ply or not ply.csJetMdl or not IsValid(ply.csJetMdl) then return end
	local view = {
		origin = ply.csJetMdl:GetPos() + ply:EyeAngles():Forward() * -150 + ply.csJetMdl:EyeAngles():Right() * 45 + ply.csJetMdl:EyeAngles():Up() * 15,
		angles = angles,
		fov = fov,
		drawviewer = true
	}

	return view
end

local fv = {
	x = 10, y = 10, w = 250, h = 250
}

local clr_no = Color(150, 150, 150)
local clr_ok = Color(255, 255, 255)
local clr_super = Color(150, 70, 70)

local timeOn = nil
local fadingOn = 1
local showing = 60
local fadingOff = 1

local fontsize = 16

surface.CreateFont('sexy_fonty_1', {
	font = 'Roboto',
	size = fontsize
})

surface.CreateFont('sexy_fonty_2', {
	font = 'Roboto',
	size = fontsize,
	blursize = 2
})

local function btext(text, x, y, alpha)
	for _x = -1, 1 do
		for _y = -1, 1 do
			draw.SimpleText(text, 'sexy_fonty_2', x + _x, y + _y, Color(0, 0, 0, alpha*255))
		end
	end
	draw.SimpleText(text, 'sexy_fonty_1', x, y, Color(255, 255, 255, alpha*255))
end

local function showHints(x, y)
    if not timeOn then return end
	local alpha
	local ct = CurTime()
	
	local t_on = { timeOn, timeOn + fadingOn }
	local t_s = { t_on[2], t_on[1] + showing }
	local t_off = { t_s[2], t_s[2] + fadingOff }
	
	if ct > t_off[2] then return end
	
	if ct > t_on[1] and ct <= t_on[2] then
		alpha = 1 - ((t_on[2] - ct) / fadingOn)
	elseif ct > t_s[1] and ct <= t_s[2] then
		alpha = 1
	elseif ct > t_off[1] and ct <= t_off[2] then
		alpha = (t_off[2] - ct) / fadingOff
	else
		alpha = 0
	end
	
	btext('How to use:', x, y, alpha)
	for k, v in next, {
		'- W, A, S, D, SPACE, CTRL - movement',
		'- ALT - brake, SHIFT - boost movement buttons',
		nil,
		'- LMB - Drop a bomb',
		'- RMB - Shoot a rocket',
		'- Hold RELOAD + Press LMB or RMB - shoots without cooldowns',
		nil,
		'Hint closes in ' .. math.floor(t_off[2] - ct)
	} do
		btext(v, x, y + fontsize * k, alpha)
	end
end

hook.Add('HUDPaint', 'mj.pilot', function()
    local me = LocalPlayer()
	if not (mj and mj.active and mj.active[me]) then return end
	local jet = me.csJetMdl
	local ang = jet:GetRenderAngles()
	local f = jet:GetPos()
	local t = f + ang:Right() * 120 + ang:Up() * 35 + ang:Forward() * -1
	
	surface.SetDrawColor(30, 30, 30, 255)
	surface.DrawOutlinedRect(fv.x - 1, fv.y - 1, fv.w + 2, fv.h + 2)
	
	render.RenderView( {
		origin = t,
		angles = (f - t):Angle(),
		x = fv.x, y = fv.y,
		w = fv.w, h = fv.h,
		fov = 45
	} )
	
	local speed = math.floor(me:GetVelocity():Length() / 23.5)
	local h = util.TraceLine({
		start = me:GetPos(),
		endpos = me:GetPos() + Vector(0, 0, -25000)
	})
	h = h.Hit and math.floor(h.HitPos:Distance(me:GetPos()) / 23.5) or '?'
	local mv = {
		up = me:KeyDown(IN_JUMP),
		down = me:KeyDown(IN_DUCK),
		left = me:KeyDown(IN_MOVELEFT),
		right = me:KeyDown(IN_MOVERIGHT),
		forward = me:KeyDown(IN_FORWARD),
		back = me:KeyDown(IN_BACK),
		boost = me:KeyDown(IN_SPEED),
		brake = me:KeyDown(IN_WALK),
	}
	local atk = {
		turret = me:KeyDown(IN_ATTACK),
		rocket = me:KeyDown(IN_ATTACK2),
		boost = me:KeyDown(IN_RELOAD)
	}
	local offset_mv = {
		x = fv.x + fv.w * .25,
		y = fv.y + fv.y + fv.h * .67
	}
	draw.SimpleText('Jet Speed: ' .. speed .. ' mph' .. (mv.boost and ' + Boost' or '') .. (mv.brake and ' - Break' or ''), 'ChatFont', fv.x + 2, fv.y + 2, color_white)
	draw.SimpleText('Height: ' .. h .. ' m', 'ChatFont', fv.x + 2, fv.y + 2 + 15, color_white)
	draw.RoundedBox( 8, offset_mv.x, offset_mv.y, 25, 25, Color(30, 30, 30) )
	draw.SimpleText( 'D', 'ChatFont', offset_mv.x + 12, offset_mv.y + 12, mv.right and clr_ok or clr_no, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.RoundedBox( 8, offset_mv.x - 27, offset_mv.y, 25, 25, Color(30, 30, 30) )
	draw.SimpleText( 'S', 'ChatFont', offset_mv.x + 13 - 27, offset_mv.y + 12, mv.back and clr_ok or clr_no, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.RoundedBox( 8, offset_mv.x - 54, offset_mv.y, 25, 25, Color(30, 30, 30) )
	draw.SimpleText( 'A', 'ChatFont', offset_mv.x + 13 - 54, offset_mv.y + 12, mv.left and clr_ok or clr_no, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.RoundedBox( 8, offset_mv.x - 27, offset_mv.y - 27, 25, 25, Color(30, 30, 30) )
	draw.SimpleText( 'W', 'ChatFont', offset_mv.x + 13 - 27, offset_mv.y + 12 - 27, mv.forward and clr_ok or clr_no, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.RoundedBox( 8, offset_mv.x - 54, offset_mv.y + 27, 39, 20, Color(30, 30, 30) )
	draw.SimpleText( 'UP', 'DebugFixed', offset_mv.x + 11 - 46, offset_mv.y + 11 + 25, mv.up and clr_ok or clr_no, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.RoundedBox( 8, offset_mv.x - 13, offset_mv.y + 27, 39, 20, Color(30, 30, 30) )
	draw.SimpleText( 'DOWN', 'DebugFixed', offset_mv.x + 6, offset_mv.y + 11 + 25, mv.down and clr_ok or clr_no, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.RoundedBox( 8, offset_mv.x - 54, offset_mv.y + 48, 39, 20, Color(30, 30, 30) )
	draw.SimpleText( 'BOOST', 'DebugFixed', offset_mv.x + 11 - 46, offset_mv.y + 11 + 46, mv.boost and clr_ok or clr_no, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.RoundedBox( 8, offset_mv.x - 13, offset_mv.y + 48, 39, 20, Color(30, 30, 30) )
	draw.SimpleText( 'BRAKE', 'DebugFixed', offset_mv.x + 6, offset_mv.y + 11 + 46, mv.brake and clr_ok or clr_no, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	local offset_atk = {
		x = fv.x + fv.w * .63,
		y = fv.y + fv.h * .78
	}
	draw.RoundedBox( 8, offset_atk.x, offset_atk.y, 25 + 60, 25, atk.boost and clr_super or Color(30, 30, 30) )
	draw.SimpleText( 'ROCKET', 'ChatFont', offset_atk.x + 12 + 30, offset_atk.y + 12, atk.rocket and clr_ok or clr_no, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.RoundedBox( 8, offset_atk.x, offset_atk.y + 27, 25 + 60, 25, atk.boost and clr_super or Color(30, 30, 30) )
	draw.SimpleText( 'BOMB', 'ChatFont', offset_atk.x + 12 + 30, offset_atk.y + 12 + 27, atk.turret and clr_ok or clr_no, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    showHints(fv.x, fv.y + fv.h + 10)
end)

function mj:me(mode)
    -- pilot cam hud
    if mode then timeOn = CurTime() end
    hook[mode and 'Add' or 'Remove']('CalcView', 'mj.pcam', pilotcam)
    self[mode and 'on' or 'off'](self, LocalPlayer())
end

local function force()
    local user = LocalPlayer()
    local dir = EyeAngles()
    if user:KeyDown(IN_WALK) then
        user:SetVelocity(-(user:GetVelocity()/50))
        return
    end
    local boost = 0.5
    if user:KeyDown(IN_SPEED) then
        boost = 1
    end
    if user:KeyDown(IN_JUMP) then
        user:SetVelocity( dir:Up() * 20 * boost )
    end
    if user:KeyDown(IN_DUCK) then
        user:SetVelocity( dir:Up() * -20 * boost )
    end
    if user:KeyDown(IN_FORWARD) then
        user:SetVelocity( dir:Forward() * 20 * boost )
    end
    if user:KeyDown(IN_BACK) then
        user:SetVelocity( dir:Forward() * -20 * boost )
    end
    if user:KeyDown(IN_MOVELEFT) then
        user:SetVelocity( dir:Right() * -20 * boost )
    end
    if user:KeyDown(IN_MOVERIGHT) then
        user:SetVelocity( dir:Right() * 20 * boost )
    end
end

function mj.Tick()
    local self = mj
    for k, v in next, mj.active do
        if k and IsValid(k) then
            local jet = k.csJetMdl
            -- local pilot = k.csPilotMdl
            if jet:GetParent() ~= k then
                ParentJet(k, jet)
            end
            if k == LocalPlayer() then
                force()
            end
            
            -- if pilot:GetParent() ~= jet then
            --     ParentPilot(jet, pilot)
            -- end
        end
    end
end

function mj.PreDrawOpaqueRenderables()
    for k, v in next, mj.active do
        if k and IsValid(k) then
            --local self = k.csPilotMdl
            --local ppos = self:GetAngles() + Angle(20, 0, 0)
            --local normal = ppos:Up()
            --local position = normal:Dot( self:GetPos() + self:GetUp() * 3 )
            --local oldState = render.EnableClipping(true)
            --render.PushCustomClipPlane( normal, position )
            --    self:SetupBones()
            --    self:DrawModel()
            --render.PopCustomClipPlane()
            --render.EnableClipping(oldState)
            local ang = k:EyeAngles() + Angle(0, 90, 0)
            ang = Angle(ang.r, ang.y, ang.p)
            k.csJetMdl:SetRenderAngles(ang)
            --k.csPilotMdl:SetRenderAngles(ang)
            drawflames(k.csJetMdl,Vector(0,30,0),Angle(0, 90, 0),5,math.Clamp(k:GetVelocity():Length() / 100, 0, 10))
        end
    end
end

-- reload script check
if rme then mj:me(true) end

net.Receive('mj.main', function(len)
    local isJet = net.ReadBit()
    local isActor = net.ReadBit()
    print('net', isJet, isActor)
    if isActor == 1 then
        print('net run me')
        mj:me(isJet == 1)
    else
        print('net run mj on/off')
        mj[isJet == 1 and 'on' or 'off']( mj, net.ReadEntity() )
    end
end)

hook.Add('Think', 'mj.tick', mj.Tick)
hook.Add('PreDrawOpaqueRenderables', 'mj.render', mj.PreDrawOpaqueRenderables)