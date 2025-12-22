function check_bootloader_version(image)
    local current_version = os.getenv("bootloader_version") or "0.0"
    local update_version = os.getenv("BOOTLOADER_VERSION") or "0.0"

    swupdate.trace(string.format("Current bootloader version: %s", current_version))
    swupdate.trace(string.format("Update bootloader version: %s", update_version))

    -- Parse version strings (assuming format: YYYY.MM or YYYY.MM.PATCH)
    local function parse_version(ver)
        local parts = {}
        for part in string.gmatch(ver, "[^.]+") do
            table.insert(parts, tonumber(part) or 0)
        end
        return parts
    end

    local current = parse_version(current_version)
    local update = parse_version(update_version)

    -- Compare versions
    for i = 1, math.max(#current, #update) do
        local c = current[i] or 0
        local u = update[i] or 0
        if u > c then
            swupdate.trace("Bootloader update required: newer version available")
            return true, image
        elseif u < c then
            swupdate.trace("Bootloader update skipped: current version is newer")
            return false, image
        end
    end

    swupdate.trace("Bootloader update skipped: versions are identical")
    return false, image
end

return check_bootloader_version
