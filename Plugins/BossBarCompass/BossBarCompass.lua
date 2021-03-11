function Initialize(Plugin)
	Plugin:SetName("BossBarCompass")
	Plugin:SetVersion(1)

	-- Register hooks
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_MOVING, BossBarCompass);
	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

-- This rounding comes from DamageText btw
function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- BossBarCompass
function BossBarCompass(Player, OldPosition, NewPosition, PreviousIsOnGround)
	local position = "" .. round(Player:GetPosition().x) .. "  " .. round(Player:GetPosition().y) .. "  " .. round(Player:GetPosition().z)
	local text = cCompositeChat(position, mtCustom);
	Player:GetClientHandle():SendBossBarAdd(4444, text, 0, BossBarColor.Yellow, BossBarDivisionType.None, false, false, false);
end
