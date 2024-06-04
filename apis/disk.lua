---@class disk
local _disk = {}

---Checks if the peripheral is a drive
---@param name string
---@return boolean
local function isDrive(name)
    if type(name) ~= "string" then
        error("bad argument #1 (string expected, got " .. type(name) .. ")", 3)
    end

    return peripheral.getType(name) == "drive"
end

---Checks if a disk is present
---@param name string
---@return boolean
function _disk.isPresent(name)
    if isDrive(name) then
        return peripheral.call(name, "isDiskPresent")
    end

    return false
end

---Gets the label of the disk in the drive
---@param name string
---@return string|nil
function _disk.getLabel(name)
    if isDrive(name) then
        return peripheral.call(name, "getDiskLabel")
    end

    return nil
end

---Sets the label of the disk in the drive
---@param name string
---@param label string
function _disk.setLabel(name, label)
    if isDrive(name) then
        peripheral.call(name, "setDiskLabel", label)
    end
end

---Returns whether the disk holds data
---@param name string
---@return boolean
function _disk.hasData(name)
    if isDrive(name) then
        return peripheral.call(name, "hasData")
    end
    return false
end

---Returns the mount path of the disk
---@param name string
---@return string|nil
function _disk.getMountPath(name)
    if isDrive(name) then
        return peripheral.call(name, "getMountPath")
    end
    return nil
end

---Checks whether the disk holds audio
---@param name string
---@return boolean
function _disk.hasAudio(name)
    if isDrive(name) then
        return peripheral.call(name, "hasAudio")
    end
    return false
end

---Gets the name of the track on an audio disk
---@param name string
---@return string|nil
function _disk.getAudioTitle(name)
    if isDrive(name) then
        return peripheral.call(name, "getAudioTitle")
    end
    return nil
end

---Plays the track on the audio disk
---@param name string
function _disk.playAudio(name)
    if isDrive(name) then
        peripheral.call(name, "playAudio")
    end
end

---Stops the audio playing
---@param name? string
function _disk.stopAudio(name)
    if not name then
        for _, sName in ipairs(peripheral.getNames()) do
            _disk.stopAudio(sName)
        end
    else
        if isDrive(name) then
            peripheral.call(name, "stopAudio")
        end
    end
end

---Ejects the disk currently in the drive as a loose item
---@param name string
function _disk.eject(name)
    if isDrive(name) then
        peripheral.call(name, "ejectDisk")
    end
end

---Gets the ID of the inserted disk
---@param name string
---@return string|nil
function _disk.getID(name)
    if isDrive(name) then
        return peripheral.call(name, "getDiskID")
    end
    return nil
end

return _disk
