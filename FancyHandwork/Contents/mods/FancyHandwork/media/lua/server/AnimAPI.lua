-- Animation Framework for Project Zomboid
---- Code inspired and modifed from "Tsarlib"

if not isClient() and not isServer() then return end

local AF_InitGlobaModData = function(mod, pack)
  if not ModData.exists("animapi") then
		local t = ModData.create("animapi")
	end
end

local AF_ReceiveGlobalModData = function(mod, pack)
  if mod ~= "animapi" then return; end;
    if not pack then
		print("ERROR: OnReceiveGlobalModData in AF_ReceiveGlobalModData " .. (pack or "missing packet."))
	else
    ModData.add(mod, pack)
  end
end

local AF_CleanGlobalModData = function()
  local md = ModData.getOrCreate("animapi")
  for id, _ in pairs(md) do
    local player = getPlayerByOnlineID(id)
      if not player then
        md[id] = nil
      end
    end
end

Events.OnInitGlobalModData.Add(AF_InitGlobaModData)
Events.OnReceiveGlobalModData.Add(AF_ReceiveGlobalModData)
Events.EveryHours.Add(AF_CleanGlobalModData)