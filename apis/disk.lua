local _disk = {}

local function isDrive(name)
    if type(name) ~= "string" then
        error("bad argument #1 (string expected, got " .. type(name) .. ")", 3)
    end
    return peripheral.getType(name) == "drive"
end

function _disk.isPresent(name)
    if isDrive(name) then
        return peripheral.call(name, "isDiskPresent")
    end
    return false
end

function _disk.getLabel(name)
    if isDrive(name) then
        return peripheral.call(name, "getDiskLabel")
    end
    return nil
end

function _disk.setLabel(name, label)
    if isDrive(name) then
        peripheral.call(name, "setDiskLabel", label)
    end
end

function _disk.hasData(name)
    if isDrive(name) then
        return peripheral.call(name, "hasData")
    end
    return false
end

function _disk.getMountPath(name)
    if isDrive(name) then
        return peripheral.call(name, "getMountPath")
    end
    return nil
end

function _disk.hasAudio(name)
    if isDrive(name) then
        return peripheral.call(name, "hasAudio")
    end
    return false
end

function _disk.getAudioTitle(name)
    if isDrive(name) then
        return peripheral.call(name, "getAudioTitle")
    end
    return nil
end

function _disk.playAudio(name)
    if isDrive(name) then
        peripheral.call(name, "playAudio")
    end
end

function _disk.stopAudio(name)
    if not name then
        for _, sName in ipairs(peripheral.getNames()) do
            stopAudio(sName)
        end
    else
        if isDrive(name) then
            peripheral.call(name, "stopAudio")
        end
    end
end

function _disk.eject(name)
    if isDrive(name) then
        peripheral.call(name, "ejectDisk")
    end
end

function _disk.getID(name)
    if isDrive(name) then
        return peripheral.call(name, "getDiskID")
    end
    return nil
end

return _disk
