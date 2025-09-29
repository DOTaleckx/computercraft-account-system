--[[
    Kiosk configuration has the Player Detector (Advanced Peripherals mod) placed on TOP of the computer the kiosk runs on.
    You can change this by changing what the playerDetector variable is assigned to, just change peripheral.wrap("top") to whatever side your player detector is on.
    
    Further, to extract the current user's username, we use playerDetector.getPlayersInRange(2)[1] to find the player who is at the kiosk.
    This user detection kinda sucks, I'll work on another way and upload it whenever I find it.

    TODO: account management screen
]]

local db = require("userdb")
local playerDetector = peripheral.wrap("top")
local kioskUser = playerDetector.getPlayersInRange(2)[1]

local function isValidPin(pin)
    return #pin == 4 and pin:match("^%d%d%d%d$") ~= nil
end

if not kioskUser then
    print("No user detected! Please step closer to the terminal.")
    sleep(5)
    return
end

term.clear()
term.setCursorPos(1,1)
print("Welcome to the PLACEHOLDER Kiosk!")
print("Version 1.0 (09/29/2025)")

local user = db.get(kioskUser)
local displayName

if user and user.preferredName then
     displayName = user.preferredName
    elseif user and user.username then
     displayName = user.username
end

local function handlePinSet(username)
    local pinSet = false
    while not pinSet do
        print("Please set a 4-digit PIN code.")
        print("Do NOT share this with anyone-- our staff will never ask!")
        local pin = read("*")
        
        if not isValidPin(pin) then
            print("PIN must be exactly 4 digits. Please try again.")
            sleep(1)
        else
            print("Confirm your PIN:")
            local pinConfirmation = read("*")
            if pin == pinConfirmation then
                db.setPin(username, pin)
                print("PIN set!")
                sleep(1)
                pinSet = true
            else
                print("PIN mismatch")
                sleep(1)
            end
        end
    end    
end

local function handleRegistration()
    print(kioskUser, "not found in our system, would you like to create an account? (y/n)")
    local registerChoice = read()
    if registerChoice:lower() == "y" then
        --greet user and create acc
        print("Excellent, welcome to our system!")
        db.create(kioskUser)
        sleep(1)
        
        --PIN setting
        handlePinSet(kioskUser)
            
        --preferred name option
        print("Would you like to set a preferred name? (y/n)")
        local pNameChoice = read()
        if pNameChoice:lower() == "y" then
            print("Enter your preferred name: ")
            local preferredName = read()
            db.setPreferredName(kioskUser, preferredName)
            print("Preferred name set!")
            sleep(1)
           else
            print("No preferred name set, have a great day!")
            sleep(3)
        end
      else
          print("Have a great day!")
          sleep(3)
    end
end

local function handleLegacyAccountPins(username)
    print("Welcome back,", displayName)
    sleep(1)
    print("The system now requires 4-digit PIN numbers for security.")
    sleep(1)
    handlePinSet(username)
end

local function showAccountManagement(username)
    print("Placeholder account management screen :)")
    sleep(5)
end

if not user then
    handleRegistration()
    elseif not user.pinHash then
        handleLegacyAccountPins(user.username)
    else
        showAccountManagement(user.username)
end
