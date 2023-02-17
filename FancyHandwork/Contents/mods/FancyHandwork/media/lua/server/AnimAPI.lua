-- Animation Framework for Project Zomboid
---- Code inspired and modifed from "Tsarlib"

-- next release, this will be removed!

if not isClient() and not isServer() or AnimationFramework then return end
AnimationFramework = true

-- local AF_InitGlobaModData = function(mod, pack)
--   if not ModData.exists("animapi") then
-- 		local t = ModData.create("animapi")
-- 	end
-- end

-- local AF_ReceiveGlobalModData = function(mod, pack)
--   if mod ~= "animapi" then return; end;
--     if not pack then
-- 		print("ERROR: OnReceiveGlobalModData in AF_ReceiveGlobalModData " .. (pack or "missing packet."))
-- 	else
--     ModData.add(mod, pack)
--   end
-- end

-- local AF_CleanGlobalModData = function()
--   local md = ModData.getOrCreate("animapi")
--   for id, _ in pairs(md) do
--     local player = getPlayerByOnlineID(id)
--       if not player then
--         md[id] = nil
--       end
--     end
-- end

-- Events.OnInitGlobalModData.Add(AF_InitGlobaModData)
-- Events.OnReceiveGlobalModData.Add(AF_ReceiveGlobalModData)
-- Events.EveryHours.Add(AF_CleanGlobalModData)

-- Well, this global moddata is no longer needed.  So lets do a bit of cleanup
---- I'll remove this eventually
Events.OnGameBoot.Add(function() 
  if ModData.exists("animapi") then
    ModData.remove("animapi")
  end
end)