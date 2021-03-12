function Initialize(Plugin)
	Plugin:SetName("OPiCraftHelper")
	Plugin:SetVersion(7)
	
	-- Register Global Variables
	-- Old LOG(), used for debugging: LOGINFO	("Global Gvar set.")
	g_PlayerDeathRecord = {}

	-- Register hooks
	cPluginManager:AddHook(cPluginManager.HOOK_KILLED, OnKilled);
	cPluginManager:AddHook(cPluginManager.HOOK_SPAWNED_MONSTER, MyOnSpawnedMonster);
	cPluginManager:AddHook(cPluginManager.HOOK_CHUNK_GENERATED, MyOnChunkGenerated);
	
	--- Register commands
	cPluginManager.BindCommand("/stats", "getstat.stat", Stats, " Get Stats");
	cPluginManager.BindCommand("/kicku", "getstat.kickall", Kall, " Kick yourself");
    cPluginManager.BindCommand("/rq", "getstat.kickall", Kall, " Kick yourself");
    cPluginManager.BindCommand("rq", "getstat.kickall", Kall, " Kick yourself");
    
	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	LOGINFO("No updates checked, not implemented.")
	return true
end


-- Stats command, could be done better but works for me.
function Stats(Split, Player)
	if (#Split ~= 1) then
		Player:SendMessage("Usage: /stats")
		return true
	end
	-- Please note that yes, i could do this with lua only but I'm WAY more comfortable with just popen:ing a script. 
	local handle = io.popen("bash /home/gpay/Server/scmd.sh") -- Please remember to change this to your own path, complaining about this part of the plooogin not working usually is because you didn't.
	local result = handle:read("*a")
	handle:close()
	Player:SendMessageSuccess(result)
	return true
end

-- Ragequit command.
function Kall(Split, Player)
		cRoot:Get():BroadcastChat(cChatColor.LightBlue .. "[Ragequit] " .. cChatColor.White .. Player:GetName() .. " wanted to take a breather.") 
		Reason = "§6§lWelcome back to reality."	
		Player:GetClientHandle():Kick(Reason)
		return true;
end

-- Check if illegal or annoying mobs have been spawned.
function MyOnSpawnedMonster(World, Monster)
		if (Monster:GetMobType() == mtSilverfish) then
			cRoot:Get():BroadcastChat(cChatColor.Rose .. "[Warning] " .. cChatColor.White .. "Silverfish spwaned?")
		end
		if (Monster:GetMobType() == mtCreeper) then
			-- Opicraft doesn't have creeppers enabled so this is a HUGE RED FLAG.
			LOGWARN("Creepper spawned, add code to handle undefined below later.")
			cRoot:Get():BroadcastChat(cChatColor.Red .. "[Warning] " .. cChatColor.White .. "Creepper spawned - This shouldn't happen.")
		end
end

-- Custom public death message, time alive and thunderbolt.
function OnKilled(Victim, TDI, DeathMessage)
-- Old, used for debugging: print(Victim:IsPlayer())
if not Victim:IsPlayer() then
			-- LOGINFO("ENTITY " .. Victim:GetClass() .. " died")
			-- cRoot:Get():BroadcastChat(cChatColor.Yellow .. "ENTITY " .. Victim:GetClass() .. " died")
		else
			--Used for debugging, left here as a note: LOGWARN("The player died, crash log or timestamp below:")
			local aliveforreal = GetTimeAlive(Victim);
			local aliveforreal = os.date('%H:%M:%S', (aliveforreal / 20)) -- TYSM sarcastic_cat ! 
			g_PlayerDeathRecord[Victim:GetUniqueID()] = Victim:GetTicksAlive();
			cRoot:Get():BroadcastChat(cChatColor.Gold .. "[Info]" .. cChatColor.White .. "Player " .. Victim:GetName() .. " died")
			cRoot:Get():BroadcastChat(cChatColor.Gold .. "[Info]" .. cChatColor.White .. "They were alive for " .. cChatColor.Rose .. aliveforreal .. " since starting this session")
			Victim:GetWorld():CastThunderbolt(Victim:GetPosition().x, Victim:GetPosition().y, Victim:GetPosition().z);

			-- This was for debugging, not really needed for now.
			-- cRoot:Get():BroadcastChat(cChatColor.Gold .. "[Info] They have existed for a total of: " .. g_PlayerDeathRecord[Victim:GetUniqueID()] .. " ticks")

			g_PlayerDeathRecord[Victim:GetUniqueID()] = Victim:GetTicksAlive();
  end
end

-- Use this function to retrieve the time a player has been alive:
function GetTimeAlive(Player)
-- LOGINFO	("Function GetTimeAlive() got called.")
  local uniqueId = Player:GetUniqueID();
  -- LOGINFO("[INFO] UUID:" .. uniqueId)
  local lastDeath = g_PlayerDeathRecord[uniqueId];
  if (lastDeath) then
	-- LOGINFO("Return " .. Player:GetTicksAlive() - lastDeath);
    return Player:GetTicksAlive() - lastDeath
  else
	-- LOGINFO	("Return " .. Player:GetTicksAlive())
    return Player:GetTicksAlive();
  end
end

-- New chunk info
function MyOnChunkGenerated(World, ChunkX, ChunkZ, ChunkDesc)
	-- Log new chunks, you might want to disable this for your own server.
	LOGINFO("[Info] New chunk generated at: " .. ChunkX .. " " .. ChunkZ)
	cRoot:Get():BroadcastChat(cChatColor.Yellow .. "[Info] " .. cChatColor.White .. "New chunk generated at: " .. cChatColor.LightGreen .. ChunkX .. " " .. ChunkZ)
end
