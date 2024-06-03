-- vim: ts=4 sts=4 sw=4 noet fdm=marker
if ... then
	local name, act = ...
	if disk.hasAudio(name) then
		if act == nil then
			print(disk.getAudioTitle(name))
		elseif act == "play" then
			disk.playAudio(name)
		elseif act == "stop" then
			disk.stopAudio(name)
		else
			print "action must be play or stop"
		end
	else
		print("no audio on " .. name)
	end
else
	local nlen = 0
	local disks = {}
	-- need to iterate disks manually, since we can't get side from wrapper
	for _, side in ipairs(peripheral.getNames()) do
		local obj = peripheral.wrap(side)
		if peripheral.getType(side) == "drive" and obj.hasAudio() then
			disks[side] = obj
			nlen = math.max(nlen, #side)
		end
	end
	for side, obj in pairs(disks) do
		print(side .. (" "):rep(nlen - #side + 2) .. obj:getAudioTitle())
	end
end
