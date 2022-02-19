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

function mj:me(mode)
    -- pilot cam hud
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