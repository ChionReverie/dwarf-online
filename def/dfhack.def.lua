---@meta

-- Flags passed into a mod script. 
--
---@class dfhack_flags
---@field module? boolean True when the script is running in 'module mode'. Avoid side-effects when this flag is true.
---@field enable? boolean Is true when using the `enable` or `disable` command.
---@field enable_state? boolean True if the script is being enabled. 
---@field [string] boolean
dfhack_flags = {};

---@class dfhack.onStateChange
---@field [string] function
dfhack.onStateChange = {};

---@enum state_change_event 
local STATE_CHANGE_EVENT = {
    unknown = -1,
    world_loaded = 0,
    world_unloaded = 1,
    map_loaded = 2,
    map_unloaded = 3,
    viewscreen_changed = 4,
    core_initialized = 5,
    begin_unload = 6,
    paused = 7,
    unpaused = 8,
}
SC_UNKNOWN = STATE_CHANGE_EVENT.unknown;
SC_WORLD_LOADED = STATE_CHANGE_EVENT.world_loaded;
SC_WORLD_UNLOADED = STATE_CHANGE_EVENT.world_unloaded;
SC_MAP_LOADED = STATE_CHANGE_EVENT.map_loaded;
SC_MAP_UNLOADED = STATE_CHANGE_EVENT.map_unloaded;
SC_VIEWSCREEN_CHANGED = STATE_CHANGE_EVENT.viewscreen_changed;
SC_CORE_INITIALIZED = STATE_CHANGE_EVENT.core_initialized;
SC_BEGIN_UNLOAD = STATE_CHANGE_EVENT.begin_unload;
SC_PAUSED = STATE_CHANGE_EVENT.paused;
SC_UNPAUSED = STATE_CHANGE_EVENT.unpaused;

---@nodiscard
---@return boolean
function dfhack.world.isFortressMode() end