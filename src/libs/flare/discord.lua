--- Discord Rich Presence integration via FFI.
--- WARNING: Requires `discord-rpc.dll` (Windows), `libdiscord-rpc.so` (Linux),
--- or `libdiscord-rpc.dylib` (macOS) present in your project directory.
--- Download from: https://github.com/discord/discord-rpc/releases

local ffi = require("ffi")

ffi.cdef[[
    typedef struct DiscordRichPresence {
        const char* state;
        const char* details;
        int64_t startTimestamp;
        int64_t endTimestamp;
        const char* largeImageKey;
        const char* largeImageText;
        const char* smallImageKey;
        const char* smallImageText;
        const char* partyId;
        int partySize;
        int partyMax;
        const char* matchSecret;
        const char* joinSecret;
        const char* spectateSecret;
        int8_t instance;
    } DiscordRichPresence;

    void Discord_Initialize(const char* applicationId, void* handlers, int autoRegister, const char* optionalSteamId);
    void Discord_UpdatePresence(const DiscordRichPresence* presence);
    void Discord_ClearPresence();
    void Discord_RunCallbacks();
    void Discord_Shutdown();
]]

---@class Discord
---@field appId string The Discord application ID.
---@field lib ffi.namespace* The loaded discord-rpc native library.
---@field startTime number Unix timestamp of when the instance was created.
---@field active boolean Whether the connection is active.
---@field enabled boolean Whether presence updates are sent.
---@field lastPresence table? The last presence data passed to updatePresence.
local Discord = {}
Discord.__index = Discord

--- Creates a new Discord RPC instance and initializes the connection.
--- @param appId string Your Discord application ID.
--- @return Discord
function Discord.new(appId)
    local self = setmetatable({}, Discord)
    self.appId = appId
    self.lib = ffi.load("discord-rpc")
    self.startTime = os.time()
    self.active = true
    self.enabled = false
    self.lastPresence = nil
    self.lib.Discord_Initialize(appId, nil, 1, nil)
    return self
end

--- Enables or disables presence updates.
--- When enabled, restores the last presence or falls back to the menu state.
--- @param enabled boolean
function Discord:setEnabled(enabled)
    self.enabled = enabled
    if self.enabled then
        if self.lastPresence then
            self:updatePresence(self.lastPresence, true)
        else
            self:updatePresence({ details = "In Game" }, true)
        end
    else
        self:clear()
    end
end

--- Returns whether presence updates are currently enabled.
--- @return boolean
function Discord:isEnabled()
    return self.enabled
end

--- Sends a presence update to Discord.
--- @param data table Presence fields to set (state, details, largeImageKey, etc).
--- @param force boolean? If true, sends even when disabled (used internally).
function Discord:updatePresence(data, force)
    if not self.active then return end
    self.lastPresence = data
    if not self.enabled and not force then return end

    local presence = ffi.new("DiscordRichPresence")
    presence.state = data.state or nil
    presence.details = data.details or nil
    presence.startTimestamp = data.startTimestamp or self.startTime
    presence.endTimestamp = data.endTimestamp or 0
    presence.largeImageKey = data.largeImageKey or nil
    presence.largeImageText = data.largeImageText or nil
    presence.smallImageKey = data.smallImageKey or nil
    presence.smallImageText = data.smallImageText or nil
    presence.partyId = data.partyId or nil
    presence.partySize = data.partySize or 0
    presence.partyMax = data.partyMax or 0
    presence.matchSecret = data.matchSecret or nil
    presence.joinSecret = data.joinSecret or nil
    presence.spectateSecret = data.spectateSecret or nil
    presence.instance = data.instance or 0

    self.lib.Discord_UpdatePresence(presence)
end

--- Clears the current Discord presence.
function Discord:clear()
    if not self.active then return end
    self.lib.Discord_ClearPresence()
end

--- Runs Discord RPC callbacks. Call this every frame in love.update.
function Discord:update()
    if not self.active then return end
    self.lib.Discord_RunCallbacks()
end

--- Clears presence, shuts down the RPC connection, and marks the instance inactive.
function Discord:shutdown()
    if not self.active then return end
    self:clear()
    self.lib.Discord_Shutdown()
    self.active = false
end

return Discord
