--- Various overrides for functions that need animations.
-- Vehicles Edition

------------------
-- Just add our low "boop" animation and hold it
local _ISDeflateTire_start = ISDeflateTire.start
function ISDeflateTire:start()
    _ISDeflateTire_start(self)
    self:setActionAnim("VehicleWorkOnTire")
end

local _ISInflateTire_start = ISInflateTire.start
function ISInflateTire:start()
	_ISInflateTire_start(self)
    self:setActionAnim("VehicleWorkOnTire")
end

local doorType = {
    ["DoorRear"] = 0,
    ["EngineDoor"] = 2,
    ["TrunkDoor"] = 1    
}

local _ISOpenVehicleDoor_start = ISOpenVehicleDoor.start
function ISOpenVehicleDoor:start()
    _ISOpenVehicleDoor_start(self)
    self.action:setUseProgressBar((SandboxVars.FancyHandwork and not SandboxVars.FancyHandwork.HideVehicleWalkProgressBar) or false)
    if not self.seat or not self.character:isSeatedInVehicle() then
        self:setActionAnim((self.part:getDoor() and doorType[self.part:getId()] and "FH_Boop_Dual") or ((ZombRand(3) == 1) and "FH_BoopL") or "FH_Boop")
        -- Doors with animations break if set higher
        self.action:setTime(10)
    end
end

local _ISCloseVehicleDoor_start = ISCloseVehicleDoor.start
function ISCloseVehicleDoor:start()
    _ISCloseVehicleDoor_start(self)
    self.action:setUseProgressBar((SandboxVars.FancyHandwork and not SandboxVars.FancyHandwork.HideVehicleWalkProgressBar) or false)
    if not self.seat or not self.character:isSeatedInVehicle() then
        local trunkorhood = doorType[self.part:getId()]
        self:setActionAnim((self.part:getDoor() and trunkorhood and "FH_Boop_Dual") or ((ZombRand(3) == 1) and "FH_BoopL") or "FH_Boop")
        if trunkorhood then
            self:setAnimVariable("BoopPosition", "High")
            -- Doors with animations break if set higher
            self.action:setTime(10)
        else
            -- Doors with animations break if this is set higher, but any lower and the hand just "flickers" a bit
            self.action:setTime(8)
        end
        
    end
end

local _ISTakeEngineParts_start = ISTakeEngineParts.start
function ISTakeEngineParts:start()
    _ISTakeEngineParts_start(self)
    self:setOverrideHandModels(self.item, nil)
    self:setActionAnim("FH_CarWrenchRepair")
end

local _ISRepairEngine_start = ISRepairEngine.start
function ISRepairEngine:start()
    _ISRepairEngine_start(self)
	self:setOverrideHandModels(self.item, nil)
    self:setActionAnim("FH_CarWrenchRepair")
end

local _ISInstallVehiclePart_start = ISInstallVehiclePart.start
function ISInstallVehiclePart:start()
    _ISInstallVehiclePart_start(self)
    if self.part:getId():contains("Suspension") then
        self:setActionAnim("VehicleWorkOnTire")
    elseif self.part:getId():contains("Door") then
        self:setActionAnim("FH_CarWrenchRepair")
    end
end

local _ISUninstallVehiclePart_start = ISUninstallVehiclePart.start
function ISUninstallVehiclePart:start()
    _ISUninstallVehiclePart_start(self)
    if self.part:getId():contains("Suspension") then
        self:setActionAnim("VehicleWorkOnTire")
    elseif self.part:getId():contains("Door") then
        self:setActionAnim("FH_CarWrenchRepair")
    end
end

local _ISUnlockVehicleDoor_start = ISUnlockVehicleDoor.start
function ISUnlockVehicleDoor:start()
    -- Have to call my stuff first, because start just forceCompletes in vanilla
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.vehicle, extra = 0 }))
    _ISUnlockVehicleDoor_start(self)
end

local _ISLockVehicleDoor_perform = ISLockVehicleDoor.perform
function ISLockVehicleDoor:perform()
    -- But then, this one works like a normal TimedAction. Consistent much? xD
    _ISLockVehicleDoor_perform(self)
    ISTimedActionQueue.add(FHBoopAction:new(self.character, { item = self.vehicle, extra = 0 }))
end

local _ISEnterVehicle_start = ISEnterVehicle.start
function ISEnterVehicle:start()
    _ISEnterVehicle_start(self)
    self.action:setUseProgressBar((SandboxVars.FancyHandwork and not SandboxVars.FancyHandwork.HideDoorProgressBar) or false)
end

local _ISExitVehicle_start = ISExitVehicle.start
function ISExitVehicle:start()
    _ISExitVehicle_start(self)
    self.action:setUseProgressBar((SandboxVars.FancyHandwork and not SandboxVars.FancyHandwork.HideDoorProgressBar) or false)
end

local _ISPathFindAction_start = ISPathFindAction.start
function ISPathFindAction:start()
    _ISPathFindAction_start(self)
    self.action:setUseProgressBar((SandboxVars.FancyHandwork and not SandboxVars.FancyHandwork.HideVehicleWalkProgressBar) or false)
end