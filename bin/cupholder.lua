for _, v in pairs { peripheral.find "drive" } do
	if v.isDiskPresent() and (not ... or peripheral.getName(v):find((...))) then
		print("Enabled cupholder mode for " .. peripheral.getName(v) .. ".")
		v.ejectDisk()
	end
end
