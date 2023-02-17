require "TimedActions/ISBaseTimedAction"

BHMeleeAttack = ISBaseTimedAction:derive("BHMeleeAttack");

local BrutalAttack = require("BrutalAttack")
BrutalHands = BrutalHands or {}

function BHMeleeAttack:isValid()
	return true
end

function BHMeleeAttack:waitToStart()
	return false
end

function BHMeleeAttack:update()
	-- we need to force the current facing direction until the animation starts
	if self.lockDir then
		self.character:setDirectionAngle(self.vec)
	end
end

-- safeguard to make sure that the action is ended
function BHMeleeAttack:beDone()
	self.character:setVariable("AttackAnim", false)
	self.character:setBlockMovement(false)
	self.character:setMeleeDelay(8)
end

function BHMeleeAttack:start()
	local prone, stand = BrutalAttack.GetAvailableTargetCount(self.character, self.weapon)
	if stand == 0 and prone > 0 then
		self:forceStop()
		-- Fall through to doing the character stomp or main attack
		self.character:DoAttack(self.chargeDelta)
		return
	end
	
	local atype = "bash"
	if self.unarmed then
		local hands = (BrutalHands.TOC and BrutalHands.TOC.getHands(self.character)) or 11
		local rand = 4
		local randoff = 1
		if hands == 00 then 
			self:forceStop()
			-- Fall through to doing the character stomp or push
			return self.character:DoAttack(self.chargeDelta)
		elseif hands == 01 then -- right only
			rand = 2
		elseif hands == 10 then -- left only
			randoff = 3
		end
		local num = ZombRand(rand)+randoff
		if num==1 then 
			atype = "rpunch1"
		elseif num==2 then
			atype = "rpunch2"
		elseif num==3 then
			atype = "lpunch2"
		else
			atype = "lpunch1"
		end
		--atype = (ZombRand(3) == 1 and "lpunch1") or "rpunch1"
	elseif self.weapon:getSubCategory() == "Stab" then 
		self.maxHit = 1
		atype = "knife"
	end

	self.character:setVariable("LCombatSpeed", self.speed)
	self.character:setVariable("AttackAnim", true)
	self:setActionAnim("LAttack")
	self:setAnimVariable("LAttackType", atype)
end

function BHMeleeAttack:animEvent(event, parameter)
	if event == 'StartAttack' then
		if self.swingSound then
			self.character:getEmitter():playSound(self.swingSound)
		end
		self.lockDir = false
	elseif event == 'SetVariable' then
		local str = BrutalAttack.SplitValueString(parameter)
		for k,v in pairs(str) do
			self.character:setVariable(k,v)
		end
	elseif event == 'AttackCollisionCheck' then
		BrutalAttack.FindAndAttackTargets(self.character, self.weapon, true)
		if isClient() then
			sendClientCommand(self.character, "BrutalAttack", "Attack", {PID=self.character:getPlayerNum(), Offhand=true, extraRange=true})
		end
	elseif event == 'BlockMovement' and SandboxVars.AttackBlockMovements then
		self.character:setBlockMovement((parameter == "TRUE" and true) or false)
	elseif event == 'EndAttack' then
		self:forceComplete()
	end
end

function BHMeleeAttack:stop()
	self:beDone()
	ISBaseTimedAction.stop(self)
end

function BHMeleeAttack:perform()
	self:beDone()
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
	triggerEvent("OnPlayerAttackFinished", self.character, self.weapon)
end

function BHMeleeAttack:new(character, weapon, chargeDelta)
	local o = ISBaseTimedAction.new(self, character)

	o.weapon = weapon
	o.speed = BrutalAttack.CalcCombatSpeed(character, weapon, false)
	o.maxTime = -1
	o.stopOnAim = false
	o.stopOnWalk = false
	o.stopOnRun = false

	o.useProgressBar = false

	o.swingSound = weapon:getSwingSound()
	o.hitSound = weapon:getZombieHitSound()

	o.vec = character:getDirectionAngle()
	-- Needed if we fall through
	o.chargeDelta = chargeDelta
	o.lockDir = true
	o.lHandAttack = true

	o.unarmed = weapon and weapon:getCategories():contains("Unarmed")

	return o
end