
local lastTimer = 0;
local DLLPath = lfs.writedir()..'Scripts\\Hooks\\'
package.cpath = package.cpath..';'..DLLPath..'?.dll;'

log.write('OH6GunnerExport',log.INFO,'LoadDLL' )
local gunnerExport = require('OH6GunnerDataExport')
log.write('OH6GunnerExport',log.INFO,'DLL loaded' )

local terrain = require('terrain')




local OH6_GunnerExport = {}

function OH6_GunnerExport.onSimulationStart()	
	log.write('OH6GunnerExport',log.INFO,'Gunner Export init' )
end

function OH6_GunnerExport.onSimulationStop()
	log.write('OH6GunnerExport',log.INFO,'Gunner Export stop')
end

function is_hostile(a, b)
	return a.CoalitionID ~= b.CoalitionID
end

function send_stuff()
	local endTime = os.clock()
	-- send all DCS_objects (data string starts with "A")
	local own_id = Export.LoGetPlayerPlaneId()
	local own_data = Export.LoGetSelfData()
	
	if own_data == nil then 
		return
	end
	--log.write('OH6GunnerExport type:',log.INFO,own_data.Type.level2)
	
	local ox = own_data.Position.x
	local oy = own_data.Position.y
	local oz = own_data.Position.z

	local startTime = os.clock()
	--local t = Export.LoGetModelTime()

	--log.write('OH6GunnerExport t:',log.INFO,t)
	local mmo = Export.LoGetWorldObjects()
	local count =0
	gunnerExport.start()
	for k,v in pairs(mmo) do
	
		if v.GroupName ~= nil then
			if is_hostile(own_data, v) then
				local vx = v.Position.x
				local vy = v.Position.y
				local vz = v.Position.z
				
				sqr_dist = (ox-vx)*(ox-vx)+(oy-vy)*(oy-vy)+(oz-vz)*(oz-vz)
				if sqr_dist < 4000000 then --2000*2000 m 
					local los = terrain.isVisible(ox, oy, oz, vx,vy,vz)
					if los then

						gunnerExport.sendData(k, v.Type.level2, vx, vy, vz)
						if count >=50 then 
							break;
						end
					end
				end
			end
				
		end
	end

	gunnerExport.finish()
	
	local endTime = os.clock()
		
end

function OH6_GunnerExport.onSimulationFrame()
	local t = Export.LoGetModelTime()
	if t > 5 then 
		local now = DCS.getRealTime()
		if now >= lastTimer + 0.05 then
			send_stuff()
			lastTimer = now;
		end
	end
end

DCS.setUserCallbacks(OH6_GunnerExport)

net.log("OH6_Gunner Loaded...")


