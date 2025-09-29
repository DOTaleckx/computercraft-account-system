--Declare vars, set filename to user db file
local users = {}
local filename = "users.db"
local github = require("github")

local function save()
    local f = fs.open(filename,"w")
    f.write(textutils.serialize(users))
    f.close()
end

local function load()
    if fs.exists(filename) then
        local f = fs.open(filename,"r")
        users = textutils.unserialize(f.readAll()) or {}
        f.close()
    end
end

--generateID will get the max user ID and add one for new ID
local function generateID()
    local max = 0
    for _, user in pairs(users) do
        if user.id > max then max = user.id end
    end
    return max + 1
end

local function now()
    return os.day() .. "/" .. os.time()
end

local function get(username)
    return users[username]
end

local function create(username)
    if users[username] then return false end
    users[username] = {
        id = generateID(),
        username = username,
        preferredName = nil,
        pinHash = nil,
        lastSeen = now()
    }
    save()
end

local function updateLastSeen(username)
    if users[username] then
        users[username].lastSeen = now()
        save()
    end
end

local function setPreferredName(username, name)
    if users[username] then
        users[username].preferredName = name
        save()
        return true
    end
    return false
end

local function setPin(username, pin)
    if users[username] then
        users[username].pinHash = github.sha256(pin)
        save()
        return true
    else
        return false
    end
end

local function verifyPin(username, pin)
    local user = users[username]
    if user and user.pinHash then
        return user.pinHash == github.sha256(pin)
    end
    return false
end

local function getAll()
    return users
end

load()

return {
    get = get,
    create = create,
    updateLastSeen = updateLastSeen,
    setPreferredName = setPreferredName,
    setPin = setPin,
    verifyPin = verifyPin,
    getAll = getAll,
    save = save
}        
