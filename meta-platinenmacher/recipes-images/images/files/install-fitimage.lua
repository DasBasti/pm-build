-- SWUpdate Lua hook to install a FIT image into the inactive boot slot
-- Expects the update payload filename to be available under /tmp/swu/<filename> or /tmp/<filename>

local function trim(s) return (s:gsub("^%s+",""):gsub("%s+$","")) end

function install_fitimage(image)
    local filename = image.filename or image.name
    if not filename then
        swupdate.trace("install_fitimage: no filename provided in image object")
        return false, image
    end

    -- find the payload on the host
    local candidates = {"/tmp/swu/"..filename, "/tmp/"..filename, filename}
    local src = nil
    for _, p in ipairs(candidates) do
        local f = io.open(p, "rb")
        if f then f:close(); src = p; break end
    end
    if not src then
        swupdate.trace("install_fitimage: payload not found: "..filename)
        return false, image
    end

    -- find boot device by label
    local f = io.popen("blkid -L boot 2>/dev/null")
    local bootdev = trim(f:read("*a") or "")
    f:close()
    if bootdev == "" then
        local f2 = io.popen("readlink -f /dev/disk/by-label/boot 2>/dev/null")
        bootdev = trim(f2:read("*a") or "")
        f2:close()
    end
    if bootdev == "" then
        swupdate.trace("install_fitimage: could not find boot device by label")
        return false, image
    end

    -- detect active rootfs (uses existing helper script)
    local f3 = io.popen("detect-rootfs.sh 2>/dev/null")
    local active = trim(f3:read("*a") or "")
    f3:close()
    local inactive = "B"
    if active == "copyB" then inactive = "A" end

    local target = "/fitImage-"..inactive

    local mnt = "/tmp/bootmnt."..tostring(os.time())
    os.execute("mkdir -p "..mnt)
    local rc = os.execute("mount "..bootdev.." "..mnt)
    if rc ~= 0 then
        swupdate.trace("install_fitimage: mount failed on "..bootdev)
        os.execute("rmdir "..mnt)
        return false, image
    end

    -- copy payload to inactive slot
    rc = os.execute("cp -f "..src.." "..mnt..target)
    if rc ~= 0 then
        os.execute("umount "..mnt)
        os.execute("rmdir "..mnt)
        swupdate.trace("install_fitimage: failed to copy payload to "..target)
        return false, image
    end

    -- update extlinux default to inactive label
    os.execute("sed -i 's/^default .*/default "..inactive.."/' "..mnt.."/extlinux/extlinux.conf 2>/dev/null || true")

    -- set u-boot env vars if fw_setenv is present
    os.execute("fw_setenv boot_slot "..inactive.." || true")
    os.execute("fw_setenv upgrade_available 1 || true")

    os.execute("sync")
    os.execute("umount "..mnt)
    os.execute("rmdir "..mnt)

    swupdate.trace("install_fitimage: installed "..filename.." to "..target.." and switched default to "..inactive)
    return true, image
end

return install_fitimage
