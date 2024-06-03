local formatString = '%s (%s) - %s bytes free'

local drives = {
    {
        mountPath = '/',
        drive = 'internal',
        freeSpace = fs.getFreeSpace('/')
    },
    {
        mountPath = '/rom',
        drive = 'ROM',
        freeSpace = fs.getFreeSpace('/rom')
    }
}

for _, v in pairs({peripheral.find('drive')}) do
    if not v.isDiskPresent() or not v.hasData() then
        goto continue
    end

    table.insert(drives, {
        mountPath = '/' .. v.getMountPath(),
        drive = peripheral.getName(v),
        freeSpace = fs.getFreeSpace(v.getMountPath())
    })

    ::continue::
end

for _, v in pairs(drives) do
    printf(formatString, v.mountPath, v.drive:gsub('_', ' '):gsub('^.', string.upper):gsub(' .', string.upper), tostring(v.freeSpace):gsub('^.', string.upper))
end
