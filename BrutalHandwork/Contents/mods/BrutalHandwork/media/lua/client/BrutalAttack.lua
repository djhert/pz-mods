-- BrutalAttack is intended to be a module that can be used by anyone
--- This is a more-or-less port of the Java functions to find and perform attacks
--- Not everything is exposed to us that is used, so some liberties were taken
local BrutalAttack = {}

-- for caching, let's reuse these
local checkValid = function(player, weapon)
	return (player and instanceof(weapon, "HandWeapon"))
end

local function clamp(low, n, high) return math.min(math.max(n, low), high) end

BrutalAttack.SplitValueString = function(str)
	local t = {}
	for k, v in string.gmatch(str, "(%w+)=(%w+)") do
		t[k] = v
	end
	return t
end

-- WARNING
---- This ONLY returns the available count, as the objects this returns are not exported for use in Lua
BrutalAttack.GetAvailableTargetCount = function(player, weapon)
	local prone = ArrayList.new()
	local stand = ArrayList.new() 
	-- we want a player, and a hand weapon
	if not checkValid(player, weapon) then return end

    SwipeStatePlayer.instance():calcValidTargets(player, weapon, true, prone, stand)
	local pC = prone:size()
	local sC = stand:size()

	--prone:clear()
	--stand:clear()

	return pC, sC
end

local moodleOffset = {
	0.5, 0.2, 0.1, 0.05
}

local weaponLevelOffset = {
	0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3
}

BrutalAttack.GetWeaponLevel = function(player, weapon)
	local lvl = -1
	if weapon and player then
		local cats = weapon:getCategories()
		if cats:contains("Axe") then
			lvl = lvl + player:getPerkLevel(Perks.Axe)
		end
		if cats:contains("Spear") then
			lvl = lvl + player:getPerkLevel(Perks.Spear)
		end

		if cats:contains("SmallBlade") then
			lvl = lvl + player:getPerkLevel(Perks.SmallBlade)
		end
		if cats:contains("LongBlade") then
			lvl = lvl + player:getPerkLevel(Perks.LongBlade)
		end
		if cats:contains("Blunt") then
			lvl = lvl + player:getPerkLevel(Perks.Blunt)
		end
		if cats:contains("SmallBlunt") then
			lvl = lvl + player:getPerkLevel(Perks.SmallBlunt)
		end
		-- if cats:contains("Unarmed") then
		-- 	lvl = lvl + player:getPerkLevel(Perks.Unarmed)
		-- end
	end

	return (lvl == -1 and 0) or lvl
end


-- Yea, you see all this here? This is the FULL damage code ported from Java to Lua, made weapon agnostic.
---- This doesn't fucking work in MP though, as there is NO method to get a zombie remotely.
---- So, I cannot accurately sync hit reactions.  This causes zombies to fall for you, and walk in place for others
---- I could fix this if I could just get a zombie by its online id or something. But noooooooooooo. I can't have nice things......
-- BrutalAttack.processHitDamage = function(weapon, player, target, damage, ignoreDamage, delta)
-- 	local dmg = damage * delta
-- 	local dmg2 = (ignoreDamage and dmg/2.7) or dmg

-- 	local force = dmg2 * player:getShovingMod()
-- 	if force > 1.0 then force = 1.0 end

-- 	if not weapon:isRanged() then
-- 		force = (player:HasTrait("Strong") and force*1.4) or (player:HasTrait("Weak") and force*0.6) or force
-- 	end
	
-- 	local dist = 1.0 - ((target:DistTo(player) - weapon:getMinRange())/weapon:getMaxRange(player))
-- 	if dist > 1.0 then dist = 1.0 end

-- 	-- Apparently, this is supposed to be modified by knockbackAttackMod, but this always seems to be 1
-- 	local endurance = player:getStats():getEndurance()
-- 	if endurance < 0.5 then 
-- 		endurance = endurance * 1.3
-- 		if endurance < 0.4 then
-- 			endurance = 0.4
-- 		end
-- 	end
-- 	force = force * endurance


-- 	if not weapon:isRangeFalloff() then
-- 		dist = 1.0
-- 	end
-- 	if not weapon:isShareDamage() then
-- 		damage = 1.0
-- 	end

-- 	if not ignoreDamage then
-- 		force = force * 2.0
-- 	end

-- 	if player:isDoShove() then
-- 		local vec = Vector2.new()
-- 		vec:set(target:getX() - player:getX(), target:getY() - player:getY())
-- 		vec:normalize()
-- 		local vec2 = Vector2.new()
-- 		vec2:set(player:getX(), player:getY())
-- 		vec2 = target:getVectorFromDirection(vec2)
-- 		local dir = vec:dot(vec2)
-- 		if dir > -0.3 then 
-- 			dmg = dmg * 1.5
-- 		end
-- 	end

-- 	dmg = (instanceof(target, "IsoPlayer") and dmg * 0.4) or dmg * 1.5 

-- 	dmg = dmg * (weaponLevelOffset[BrutalAttack.GetWeaponLevel(player, weapon)] or 0.3)

-- 	if player:isAimAtFloor() and not player:isDoShove() and not ignoreDamage then
-- 		dmg  = dmg * (math.max(5.0, weapon:getCritDmgMultiplier()))
-- 	end

-- 	if player:isCriticalHit() and not ignoreDamage then
-- 		dmg = dmg * math.max(2.0, weapon:getCritDmgMultiplier())
-- 	end

-- 	if weapon:isTwoHandWeapon() and not player:isItemInBothHands(weapon) then
-- 		dmg = dmg * 0.5
-- 	end

-- 	return dmg
-- end

-- local basehitConsequences = function(weapon, player, target, ignoreDamage, damage)
-- 	if not ignoreDamage then
-- 		if weapon:isAimedFirearm() then
-- 			target:setHealth(target:getHealth() - damage * 0.7)
-- 		else
-- 			target:setHealth(target:getHealth() - damage * 0.15)
-- 		end
-- 	end

-- 	if target:isDead() then
-- 		if target:isOnKillDone() and target:shouldDoInventory() then
-- 			target:Kill(player)
-- 		end
-- 		if target:isZombie() then
-- 			player:setZombieKills(player:getZombieKills() + 1)
-- 		end
-- 	else
-- 		if weapon:isSplatBloodOnNoDeath() then
-- 			target:splatBlood(2, 0.2)
-- 		end
-- 		if (weapon:isKnockBackOnNoDeath()) then
--             player:getXp():AddXP(Perks.Strength, 2.0)
-- 		end
-- 	end
-- end

-- local zedhitConsequences = function(weapon, player, target, ignoreDamage, damage)
-- 	if not target:isOnlyJawStab() or target:isCloseKilled() then
-- 		basehitConsequences(weapon, player, target, ignoreDamage, damage)
-- 	end
-- 	if getDebug() then
-- 		print("BRUTAL: Zombie #" .. tostring(target:getOnlineID()) .. " got hit for " .. tostring(damage))
-- 	end

-- 	target:reportEvent("wasHit")
-- 	if not ignoreDamage then
-- 		local react = player:getVariableString("ZombieHitReaction") or ""
-- 		local cats = weapon:getCategories()
-- 		if react == "Shot" then
-- 			-- Shot
-- 		elseif cats:contains("Blunt") or cats:contains("BHUnarmed") then
-- 			target:addBlood(BloodBodyPartType.FromIndex(ZombRand(BloodBodyPartType.MAX:index())), false, false, true)
-- 		elseif not cats:contains("Unarmed") then
-- 			target:addBlood(BloodBodyPartType.FromIndex(ZombRand(BloodBodyPartType.MAX:index())), false, true, true)	
-- 		end

-- 		if react == "ShotHeadFwd" and ZombRand(2) == 0 then
-- 			react = "ShotHeadFwd02"
-- 		end

-- 		if target:getEatBodyTarget() ~= nil then
-- 			if target:getVariableBoolean("onknees") then
-- 				react = "OnKnees"
-- 			else
-- 				react = "Eating"
-- 			end
-- 		end

-- 		if string.lower(react) == "floor" and target:isCurrentState(ZombieGetUpState.instance()) and target:isFallOnFront() then
-- 			react = "GettingUpFront"
-- 		end

-- 		if react ~= "" then
-- 			target:setHitReaction(react)
-- 		else
-- 			target:setStaggerBack(true)
-- 			target:setHitReaction("")
-- 			if target:getPlayerAttackPosition() == "LEFT" or target:getPlayerAttackPosition() == "RIGHT" then
-- 				player:setCriticalHit(false)
-- 			end
-- 		end
-- 	end

-- 	local tgt = target:getTarget()
-- 	if not tgt or tgt == player or target:DistToSquared(player) < 10.0 then
-- 		target:setTarget(player)
-- 	end

-- 	if player:isLocalPlayer() and not target:isRemoteZombie() then
-- 		target:setKnockedDown(player:isCriticalHit() or target:isOnFloor() or target:isAlwaysKnockedDown())
-- 	end

-- 	if not target:isOnFloor() then
-- 		local windowFence = function(x,y)
-- 			local dir = target:getDir()
-- 			if dir == IsoDirections.W then
-- 				target:setX(x + 0.9)
-- 				target:setLx(target:getX())
-- 			elseif dir == IsoDirections.E then
-- 				target:setX(x + 0.1)
-- 				target:setLx(target:getX())
-- 			elseif dir == IsoDirections.N then
-- 				target:setY(y + 0.9)
-- 				target:setLy(target:getY())
-- 			elseif dir == IsoDirections.S then
-- 				target:setY(y + 0.1)
-- 				target:setLy(target:getY())
-- 			end

-- 			target:setStaggerBack(false);
-- 			target:setKnockedDown(true);
-- 			target:setOnFloor(true);
-- 			target:setFallOnFront(true);
-- 			target:setHitReaction("FenceWindow");
-- 		end

-- 		if target:isCurrentState(ClimbOverFenceState.instance()) and target:getVariableBoolean("ClimbFenceStarted") and not target:isVariable("ClimbFenceOutcome", "fall") and not target:getVariableBoolean("ClimbFenceFlopped") then
-- 			local map = target:getStateMachineParams(ClimbOverFenceState.instance())
-- 			windowFence(map:get(3), map:get(4))
-- 		elseif target:isCurrentState(ClimbThroughWindowState.instance()) and target:getVariableBoolean("ClimbWindowStarted") and not target:isVariable("ClimbWindowOutcome", "fall") and not target:getVariableBoolean("ClimbWindowFlopped") then
-- 			local map = target:getStateMachineParams(ClimbThroughWindowState.instance())
-- 			windowFence(map:get(12), map:get(13))
-- 		end
-- 	end

-- 	local crawler = false
-- 	if target:isBecomeCrawler() then
-- 		crawler = true
-- 	elseif target:isCrawling() or BrutalAttack.isLastStand or target:isDead() or target:isCloseKilled() then
-- 		crawler = false
-- 	else
-- 		if not player:isAimAtFloor() and player:isDoShove() then
-- 			crawler = false
-- 		elseif player:isAimAtFloor() and player:isDoShove() then
-- 			crawler = (ZombRand((target:isHitLegsWhileOnFloor() and 7) or 15) % 2) == 0
-- 		end
-- 	end
-- 	if crawler then
-- 		target:setBecomeCrawler(true)
-- 	end

-- end

-- local playerhitConsequences = function(weapon, player, target, ignoreDamage, damage)
-- end

-- BrutalAttack.hitConsequences = function(weapon, player, target, ignoreDamage, damage)
-- 	if instanceof(target, "IsoPlayer") then
-- 		playerhitConsequences(weapon, player, target, ignoreDamage, damage)
-- 	else
-- 		zedhitConsequences(weapon, player, target, ignoreDamage, damage)
-- 	end
-- end

-- BrutalAttack.OnWeaponHitCharacter = function(player, target, weapon, damage)
-- 	if not instanceof(weapon, "HandWeapon") or not instanceof(player, "IsoPlayer") or not instanceof(target, "IsoGameCharacter") then return false end
-- 	if weapon:isRanged() then return false end -- not implemented
-- 	local vec2 = Vector2.new()
-- 	vec2:set(target:getX()-player:getX(), target:getY()-player:getY())
-- 	local delta = BrutalAttack.calcDelta(player, weapon, vec2)
-- 	BrutalAttack.weaponHitCharacter(player, target, weapon, damage, false, delta)
-- 	return true
-- end

-- BrutalAttack.weaponHitCharacter = function(player, target, weapon, damage, ignoreDamage ,delta)
-- 	if target:avoidDamage() then 
-- 		target:setAvoidDamage(false)
-- 		return 0
-- 	end
-- 	local ignoreDamage = target:getNoDamage()
-- 	if ignoreDamage then 
-- 		target:setNoDamage(false)
-- 	end

-- 	if instanceof(target, "IsoSurvivor") then
-- 		local enemyList = target:getEnemyList()
-- 		if enemyList and not enemyList:contains(player) then
-- 			enemyList:add(player)
-- 		end
-- 	end

-- 	target:setStaggerTimeMod(weapon:getPushBackMod() * weapon:getKnockbackMod(player) * player:getShovingMod())
	
-- 	player:addWorldSoundUnlessInvisible(5, 1, false)

-- 	local vec2 = Vector2.new()
-- 	vec2:set(target:getX() - player:getX(), target:getY() - player:getY())
-- 	vec2:normalize()
-- 	vec2:set(vec2:getX() * weapon:getPushBackMod(), vec2:getY() * weapon:getPushBackMod())
-- 	-- Literally everything that I can find uses -30 for the HitAngleMod, including modded items.  This parameter does not have a 'get', so lets just use -30
-- 	vec2:rotate(-30)
-- 	target:setHitDir(vec2)

-- 	target:setAttackedBy(player)

-- 	local finalDamage = BrutalAttack.processHitDamage(weapon, player, target, damage, ignoreDamage, delta)
-- 	local weight = 0
-- 	if weapon:isTwoHandWeapon() and player:isItemInBothHands(weapon) then
-- 		weight = weapon:getWeight()/0.15
-- 	end
-- 	weight = (weapon:getWeight() * 0.28 * weapon:getFatigueMod(player) * target:getFatigueMod() * weapon:getEnduranceMod() * 0.30 + weight) * 0.04

-- 	if instanceof(player, "IsoPlayer") and player:isAimAtFloor() and player:isDoShove() then
-- 		weight = weight * 2.0
-- 	end

-- 	local enduranceDmg = finalDamage * ((weapon:isAimedFirearm() and 0.7) or 0.15)
-- 	enduranceDmg = ((target:getHealth() < enduranceDmg and target:getHealth()) or enduranceDmg)/weapon:getMaxDamage()
-- 	if enduranceDmg > 1.0 then enduranceDmg = 1.0 end
-- 	enduranceDmg = (target:isCloseKilled() and 0.2) or enduranceDmg

-- 	if weapon:isUseEndurance() then
-- 		enduranceDmg = ((finalDamage <= 0) and 1.0) or enduranceDmg
-- 		player:getStats():setEndurance(player:getStats():getEndurance() - (weight * enduranceDmg))
-- 	end

-- 	--BrutalAttack.hitConsequences(weapon, player, target, ignoreDamage, finalDamage)
-- 	target:hitConsequences(weapon, player, ignoreDamage, finalDamage, false)

-- 	if target:isZombie() then
-- 		if not target:isRemoteZombie() then
-- 			target:addAggro(player, finalDamage)
-- 		end

-- 		target:setTargetSeenTime(0)
-- 		if not target:isDead() and not target:isOnFloor() and not ignoreDamage and weapon:getScriptItem():getCategories():contains("Blade") then
-- 			target:setHitForce(0.5)
-- 			target:changeState(StaggerBackState.instance())
-- 		end
-- 	end

-- 	return finalDamage
-- end

-- BrutalAttack.Hit = function(weapon, player, target, damage, ignoreDamage, delta)
-- 	if not instanceof(weapon, "HandWeapon") or not instanceof(player, "IsoPlayer") or not instanceof(target, "IsoGameCharacter") then return end
-- 	if not ignoreDamage and target:isZombie() then
-- 		target:setHitTime(target:getHitTime()+1)
-- 		if target:getHitTime() >= 4 then
-- 			damage = damage * ((target:getHitTime()-2) * 1.50)
-- 		end
-- 	end

-- 	-- Set the shove damage. probably un-needed, but lets do it anyways
-- 	if player:isDoShove() and not player:isAimAtFloor() then
-- 		ignoreDamage = true
-- 		delta = delta * 1.5
-- 	end

-- 	triggerEvent("OnWeaponHitCharacter", player, target, weapon, damage)
-- 	triggerEvent("OnPlayerGetDamage", target, "WEAPONHIT", damage)

-- 	BrutalAttack.weaponHitCharacter(player, target, weapon, damage, ignoreDamage, delta)

-- 	triggerEvent("OnWeaponHitXp", player, weapon, target, damage)
-- end

BrutalAttack.calcDelta = function(player, weapon, vec2)
	local delta = 1.0
	if weapon:isRangeFalloff() then
		delta = 1.0
	elseif weapon:isRanged() then
		delta = 0.5
	else
		delta = vec2:getLength() / weapon:getMaxRange(player)
	end
	delta = delta * 2.0
	if delta < 0.3 then delta = 1 end

	-- I'm tired.  I've written 3 methods for calculating damage, only to run into an issue.
	--- So we're just going to correct it using math and the `delta` parameter
	---- We must correct for the offhand weapon skill here
	---- first, we divide by the primary hand's skill offset; later, this is counter-acted by the offset being multiplied
	delta = delta / (weaponLevelOffset[BrutalAttack.GetWeaponLevel(player, player:getPrimaryHandItem())] or 0.3)
	-- then we multiply the real skill offset
	delta = delta * (weaponLevelOffset[BrutalAttack.GetWeaponLevel(player, weapon)] or 0.3)

	return delta
end

BrutalAttack.calcDamage = function(player, weapon, target, count)
	local vec2 = Vector2.new()
	vec2:set(target:getX()-player:getX(), target:getY()-player:getY())
	local delta = BrutalAttack.calcDelta(player, weapon, vec2)

	local minDamage = weapon:getMinDamage() -- var50
	local maxDamage = weapon:getMaxDamage() -- var28
	local deltaDamage = maxDamage - minDamage -- var52
	local twoHand = not weapon:isTwoHandWeapon() or player:isItemInBothHands(weapon) -- var54

	local initDamage = 0 -- var51
	if deltaDamage == 0.0 then
		initDamage = minDamage
	else
		initDamage = minDamage + (ZombRand(maxDamage*1000.0)/1000.0)
	end
	
	if not weapon:isRanged() then
		initDamage = initDamage * weapon:getDamageMod(player) * player:getHittingMod()
		if not twoHand and maxDamage > minDamage then
			initDamage = initDamage - minDamage
		end
	end


	-- local damage = 0 --var34
	-- local forward = target:getForwardDirection()
	-- vec2:normalize()
	-- forward:normalize()
	-- damage = vec2.dot(forward)
	-- local	 fromBehind = damage > 0.50

	local damage = 0
	for i=0,BodyPartType.ToIndex(BodyPartType.MAX) - 1 do
		damage = damage + player:getBodyDamage():getBodyParts():get(i):getPain()
	end
	if damage > 10.0 then
		initDamage = initDamage/clamp(damage/10.0, 1.0, 30.0)
	end

	if player:HasTrait("Underweight") then
		initDamage = initDamage * 0.8
	end

	if player:HasTrait("VeryUnderweight") then
		initDamage = initDamage * 0.6
	end

	if player:HasTrait("Emaciated") then
		initDamage = initDamage * 0.4
	end

	-- this way, the other items hit get less damage, i get it
	damage = initDamage/(count/2.0)

	if player:isAttackWasSuperAttack() then 
		damage = damage * 5.0
	end

	if weapon:isRanged() and player:getPerkLevel(Perks.Aiming) < 6 and player:getMoodles():getMoodleLevel(MoodleType.Panic) > 2 then
		damage = damage - (player:getMoodles():getMoodleLevel(MoodleType.Panic) * 0.2)
	end

	if not weapon:isRanged() and player:getMoodles():getMoodleLevel(MoodleType.Panic) > 1 then
		damage = damage - (player:getMoodles():getMoodleLevel(MoodleType.Panic) * 0.1)
	end

	if player:getMoodles():getMoodleLevel(MoodleType.Stress) > 1 then
		damage = damage - (player:getMoodles():getMoodleLevel(MoodleType.Stress) * 0.1)
	end

	if damage < 0 then damage = 0.1 end

	if not weapon:isRanged() then
		damage = damage * (moodleOffset[player:getMoodles():getMoodleLevel(MoodleType.Endurance)] or 1.0)
		damage = damage * (moodleOffset[player:getMoodles():getMoodleLevel(MoodleType.Tired)] or 1.0)
	end

	-- local part = ZombRand(BodyPartType.ToIndex(BodyPartType.Hand_L), BodyPartType.ToIndex(BodyPartType.Neck) + 1)
	-- local def = target:getBodyPartClothingDefense(part, false, weapon:isRanged())/2.0
	-- def = def + target:getBodyPartClothingDefense(part, true, weapon:isRanged())
	-- if def > 70.0 then def = 70.0 end
	-- damage = damage * math.abs(1.0-def/100.0)

	-- triggerEvent("OnHitZombie", target, player, part, weapon)

	return damage, delta
end

local addToHitList = function(list, obj, player, weapon, extraRange, vec)
	if obj and obj:isZombie() and obj:isAlive() then
		obj:getPosition(vec)
		if player:IsAttackRange(weapon, obj, vec, extraRange) then
			-- Add our zed, cache the distance to the player
			list[#list+1] = { obj = obj, dist = obj:DistTo(player) }
			if isDebugEnabled() then
				print("Found: " .. tostring(#list) .. " | Distance: " .. tostring(list[#list].dist))
			end
		end
	end
end

local directions = {
	[0] = IsoDirections.N,
	[1] = IsoDirections.NW,
	[2] = IsoDirections.W,
	[3] = IsoDirections.SW,
	[4] = IsoDirections.S,
	[5] = IsoDirections.SE,
	[6] = IsoDirections.E,
	[7] = IsoDirections.NE,
}

local getAttackSquares = function(player)
	local psquare = player:getSquare()
	if not psquare then return nil end
	local squares = {psquare}
	local currentDir = player:getDir():index()
	local leftIndex = currentDir+1
	if leftIndex > 7 then leftIndex=0 end
	--local middleIndex = currentDir
	local rightIndex = currentDir-1
	if rightIndex < 0 then rightIndex=7 end
	-- this should collect any additional squares, only if we nothing is in the way
	local sq = psquare:getAdjacentSquare(directions[leftIndex])
	if sq and not sq:isBlockedTo(psquare) then
		squares[#squares+1] = sq
	end
	sq = psquare:getAdjacentSquare(directions[currentDir])
	if sq and not sq:isBlockedTo(psquare) then
		squares[#squares+1] = sq
	end
	sq = psquare:getAdjacentSquare(directions[rightIndex])
	if sq and not sq:isBlockedTo(psquare) then
		squares[#squares+1] = sq
	end
	return squares
end

-- Finds and performs the attack on players in weapon range
BrutalAttack.FindAndAttackTargets = function(player, weapon, extraRange)
	-- we want a player, and a hand weapon
	if not checkValid(player, weapon) then return end

	-- honor the max hit
	local maxHit = (SandboxVars.MultiHitZombies and weapon:getMaxHitCount()) or 1

	-- this seems to be the default sooooooooo
	if extraRange == nil then extraRange = true end

	-- We do everything so we can attack non-zeds too
	--local objs = getCell():getObjectList()
	local found = {}
	local psquare = player:getSquare()
	if not psquare then return end -- can't attack
	local attackSquares = getAttackSquares(player)
	if not attackSquares then return end -- no squares?
	local vec = Vector3.new() -- reuse this
	for i=1, #attackSquares do
		local objs = attackSquares[i]:getMovingObjects()
		if objs then
			for j=0, objs:size()-1 do
				addToHitList(found, objs:get(j), player, weapon, extraRange, vec)
			end
		end
	end

	if #found > 0 then
		-- sort our found list by the closest zed
		table.sort(found, function(a,b)
			if a.obj:isZombie() then return true end
			if b.obj:isZombie() then return false end
			return a.dist < b.dist
		end)
		local count = 1 
		local sound = false
		for _,v in ipairs(found) do
			-- hit em!
			local damage, dmgDelta = BrutalAttack.calcDamage(player, weapon, v.obj, count)
			if isDebugEnabled() then
				print("Damage: " .. tostring(damage) .. " | Delta: " .. tostring(dmgDelta))
			end
			v.obj:Hit(weapon, player, damage, false, dmgDelta)

			--v.zed:splatBloodFloor()
			if not sound then 
				-- if we haven't played the sound yet, do so
				sound = true
				local zSound = weapon:getZombieHitSound()
				if zSound then v.obj:playSound(zSound) end
			end
			
			-- stop at maxhit
			if count >= maxHit then break end
			count = count + 1
		end

		luautils.weaponLowerCondition(weapon, player)
	else
		-- Swing and collide with anything not a zed
		SwipeStatePlayer.instance():ConnectSwing(player, weapon)
	end
end

BrutalAttack.CalcCombatSpeed = function(player, weapon, right)

	-- we want a player, and a hand weapon
	if not checkValid(player, weapon) then return nil end
	local speed = weapon:getBaseSpeed()

	local other 
	if right then 
		other = player:getSecondaryHandItem()
	else
		other = player:getPrimaryHandItem()
	end

	if weapon:isTwoHandWeapon() and weapon ~= other then
		speed = speed * 0.77
	end
	
	if player:HasTrait("Axeman") and weapon:getCategories():contains("Axe") then
		speed = speed * player:getChopTreeSpeed()
	end

	speed = speed - (player:getMoodles():getMoodleLevel(MoodleType.Endurance) * 0.07)
	speed = speed - (player:getMoodles():getMoodleLevel(MoodleType.HeavyLoad) * 0.07)
	speed = speed + (player:getWeaponLevel() * 0.03)
	speed = speed + (player:getPerkLevel(Perks.Fitness) * 0.02)

	if instanceof(other, "InventoryContainer") then
		speed = speed * 0.95
	end

	local md = player:getModData()
	-- our calculation is still just a bit too fast.  So lets actually reduce it a bit instead of increasing:
	speed = speed * ZombRandFloat(1.1, 1.2)
	speed = speed * ((md.BrutalHandwork and md.BrutalHandwork.CombatSpeed) or 1)
	speed = speed * BrutalAttack.getArmsInjurySpeedModifier(player, right)

	if player:getBodyDamage() and player:getBodyDamage():getThermoregulator() then
		speed = speed * player:getBodyDamage():getThermoregulator():getCombatModifier()
	end

	speed = math.min(1.6, speed)
	speed = math.max(0.8, speed)
	
	speed = speed * GameTime.getAnimSpeedFix()

	return speed
end

BrutalAttack.calcInjurySpeed = function(part, pain) 
	if part:haveBullet() then return 1.0 end

	local scratch = part:getScratchSpeedModifier()
	local cut = part:getCutSpeedModifier()
	local burn = part:getBurnSpeedModifier()
	local wound = part:getDeepWoundSpeedModifier()
	local temp = 0.0

	if part:getScratchTime() > 2.0 or part:getCutTime() > 5.0 or part:getBurnTime() > 0 
			or part:getDeepWoundTime() > 0 or part:isSplint() or part:getFractureTime() > 0 
			or part:getBiteTime() > 0 then
		temp = (part:getScratchTime()/scratch) + (part:getCutTime()/cut) + (part:getBurnTime()/burn) + (part:getDeepWoundTime()/wound)
		temp = temp + (part:getBiteTime()/20.0)
		if part:bandaged() then 
			temp = temp/2.0
		end
		if part:getFractureTime() > 0 then
			local frac = 0.4
			if part:getFractureTime() > 20 then
				frac = 1.0
			elseif part:getFractureTime() > 10 then
				frac = 0.7
			end
			if part:getSplintFactor() > 0 then
				frac = frac - 0.2
				frac = frac - math.min(part:getSplintFactor()/10.0, 0.8)
			end
			temp = math.max(0, frac)
		end

		if pain and part:getPain() > 20 then
			temp = temp + (part:getPain()/10.0)
		end
	end
	return temp
end

BrutalAttack.getArmsInjurySpeedModifier = function(player, right)
	local out = 1.0
	local temp = 0.0
	local part
	if right then
		part = player:getBodyDamage():getBodyPart(BodyPartType.Hand_R)
		temp = BrutalAttack.calcInjurySpeed(part, true)
		if temp > 0 then 
			out = out - temp
		end

		part = player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R)
		temp = BrutalAttack.calcInjurySpeed(part, true)
		if temp > 0 then 
			out = out - temp
		end

		part = player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R)
		temp = BrutalAttack.calcInjurySpeed(part, true)
		if temp > 0 then 
			out = out - temp
		end
	else
		part = player:getBodyDamage():getBodyPart(BodyPartType.Hand_L)
		temp = BrutalAttack.calcInjurySpeed(part, true)
		if temp > 0 then 
			out = out - temp
		end

		part = player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L)
		temp = BrutalAttack.calcInjurySpeed(part, true)
		if temp > 0 then 
			out = out - temp
		end

		part = player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L)
		temp = BrutalAttack.calcInjurySpeed(part, true)
		if temp > 0 then 
			out = out - temp
		end
	end
	return out
end

local onPlayerUpdateClothes = function(player)
	-- recalc attack speeds
	local speed = 1.0
	local items = player:getWornItems()
	for i=0, items:size()-1 do
		local item = items:get(i):getItem()
		if instanceof(item, "Clothing") then
			speed = speed + item:getCombatSpeedModifier() - 1.0
		end
		-- if instanceof(item, "InventoryContainer") then
		-- 	speed = speed + ((item:getActualWeight()/100.0) + 0.1) - 1.0
		-- end
	end
	player:getModData().BrutalHandwork = player:getModData().BrutalHandwork or {}
	player:getModData().BrutalHandwork.CombatSpeed = speed
end

local onPlayerCreate = function(player)
	local character = getSpecificPlayer(player)
	-- i know this is preserved, but i want to reset it
    character:getModData().BrutalHandwork = {
        wasShove = false,
		leftAttack = false,

        combo = 1,
    }
end

local setup = function()
	Events.OnCreatePlayer.Add(onPlayerCreate)
	Events.OnClothingUpdated.Add(onPlayerUpdateClothes)
	
	BrutalAttack.BareHands = InventoryItemFactory.CreateItem("Base.Fisticuffs")
	--BrutalAttack.BareHands = InventoryItemFactory.CreateItem("Base.BareHands")
	--BrutalAttack.isLastStand = getCore():getGameMode()=="LastStand"
end

BrutalAttack.setupGameEvents = function()
	Events.OnGameBoot.Remove(setup)
	Events.OnGameBoot.Add(setup)
end

return BrutalAttack