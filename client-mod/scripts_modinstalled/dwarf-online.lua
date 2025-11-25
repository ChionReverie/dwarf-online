--- Main file for dwarf-online

--@enable=true
--@module=true

--[====[
dwarf-online
============

Tags: gameplay

Cross-fortress trading through the network.

]====]

local utils = require('utils')
local argparse = require('argparse')
local repeatUtil = require('repeat-util')

local GLOBAL_KEY = 'dwarf-online'

---@return dwarf-online.state_table
local function get_default_state()
    return {
        enabled = false,
        host = "127.0.0.1:8080",
        timeout = 1.0,
    }
end

--- @class dwarf-online.state_table
--- @field enabled boolean
--- @field host string Host address and optional port (example: `127.0.0.1:8080` )
--- @field timeout number Seconds to wait before closing a stale connection
state = state or get_default_state()

--- @return boolean
function isEnabled()
    return state.enabled
end

local function persist_state()
    dfhack.persistent.saveSiteData(GLOBAL_KEY, state)
end

local function do_enable()
    -- 
end

local function do_disable()
    -- 
end

--- @param sc state_change_event
dfhack.onStateChange[GLOBAL_KEY] = function(sc)
    if sc == SC_MAP_UNLOADED then
        do_disable()

        dfhack.onStateChange[GLOBAL_KEY] = nil
        return
    end

    if sc ~= SC_MAP_LOADED or not dfhack.world.isFortressMode() then
        return
    end

    state = get_default_state()
    utils.assign(state, dfhack.persistent.getSiteData(GLOBAL_KEY, state))
    if state.enabled then
        do_enable()
    end
end

local function printHelpAndStatus()
    print(dfhack.script_help())
    print()
    print(('Dwarf online is currently %s'):format(
        state.enabled and 'enabled' or 'disabled'
    ))
end

------
--- The following always runs when the script is loaded.
------

-- Module mode
if dfhack_flags.module then
    return
end

-- Enable mod
if dfhack_flags.enable then
    if dfhack_flags.enable_state then
        state.enabled = true
        do_enable()
    else
        state.enabled = false
        do_disable()
    end

    persist_state()
    return
end

-- Command line arguments
local args = {...};
if #args == 0 then
    printHelpAndStatus()
    return
end


local request_queue = reqscript('internal/request_queue').exports --[[@as request_queue]]
local queue = request_queue.Queue:new()


local switches = argparse.processArgs(args, utils.invert { 'health-check' })

local json = require('json')

---@param entry request_queue.Entry
local on_success = function (entry)
    local result = json.decode(entry.response.body)
    if result and result.message then
        dfhack.gui.writeToGamelog(("Server status: %s"):format(result.message))
    end
end

---@param entry request_queue.Entry
---@param error dwarf_online.Error
local on_failure = function (entry, error)
    if error then
        dfhack.gui.writeToGamelog(error:build_message())
    end
    if entry.status == "timeout" then
        dfhack.gui.writeToGamelog("Received no response")
        return
    end
end

function do_health_check()
    local dwarf_online_api = reqscript('internal/api').exports --[[@as dwarf_online_api]]
    local api = dwarf_online_api.Api:create(state.host, queue)
    if api.err then
        print(api.err:build_message())
        return
    end
    local handle = api.ok:fetch("GET", "/health-fake", on_success, on_failure)
    if handle.err then
        print(handle.err:build_message())
        return
    end
end

if switches['health-check'] then
    do_health_check()
end

local function do_check_queue()
    queue:resolve_responses()
end
repeatUtil.scheduleEvery("dwarf-online/check-queue", 5, "frames", do_check_queue)

return
