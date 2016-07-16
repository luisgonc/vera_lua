
--[[ Debug script --]]

local host, port = "192.168.10.17", 8080

--[[ Create the socket for the connection --]]
local socket = require("socket")
local tcp = assert(socket.tcp())

tcp:connect(host, port);

local t = os.date('*t')
local current_hour = t.hour

if (current_hour > 18) then
     tcp:send("true\n\n");
else
     tcp:send("false\n\n");
end

tcp:close()


-- ============================================================================

--[[ function that sends the state of the gate throug a socket --]]
function send_gate_status()

    --[[ Configure the Gate Chime Ip Address and Port --]]
    local gate_chime_host, gate_chime_port = "192.168.10.12", 8080

    --[[ Create the socket for the connection --]]
    local gate_chime_socket = require("socket")
    local gate_chime_tcp = assert(gate_chime_socket.tcp())

    gate_chime_tcp:connect(gate_chime_host, gate_chime_port);

    --[[ Check the Gate status and send it to the Gate chime --]]
    local gate_status = luup.variable_get("urn:micasaverde-com:serviceId:SecuritySensor1", "Tripped", 5)

    if (gate_status == "0") then
         gate_chime_tcp:send("the gate is closed");
    else
         gate_chime_tcp:send("the gate is open");
    end

    gate_chime_tcp:close()

end

send_gate_status()


-- ============================================================================

--[[ Script that will return false in a certainperiod of the day --]]

local t = os.date('*t')
local current_hour = t.hour

if(current_hour > 6 and current_hour < 23 ) then
    return false
end


--[[ ======================================================================== --]]

--[[ This will check if the Light is already ON, if True prevent the scene to run --]]
local sala_light_status = luup.variable_get("urn:upnp-org:serviceId:SwitchPower1", "Status", 13)

if (sala_light_status == "1") then
     return false
end


--[[ ======================================================================== --]]

--[[ This will double check the motion detector with a certain delay and then switch ON some lights --]]
function check_motion_qla()
    -- Check the Bedroom-QLA Motion detector status and check if should switch ON the lights
    local motion_status = luup.variable_get("urn:micasaverde-com:serviceId:SecuritySensor1", "Tripped", 21)

    if (motion_status == "1") then
        -- Update light level of the Red Light
        luup.call_action("urn:upnp-org:serviceId:Dimming1", "SetLoadLevelTarget", {newLoadlevelTarget = "50"}, 32)
        -- Update light level of the Green Light
        luup.call_action("urn:upnp-org:serviceId:Dimming1", "SetLoadLevelTarget", {newLoadlevelTarget = "0"}, 33)
        -- Update light level of the Blue Light
        luup.call_action("urn:upnp-org:serviceId:Dimming1", "SetLoadLevelTarget", {newLoadlevelTarget = "2"}, 34)
    end
end

-- Set a 3 second delay for a recheck and light switch ON if needed
luup.call_delay("check_motion_qla", 2.5)


--[[ ======================================================================== --]]


--[[ Check the Gate status and send notification --]]
function check_gate_left_open()
    local gate_status = luup.variable_get("urn:micasaverde-com:serviceId:SecuritySensor1", "Tripped", 5)

    if (gate_status == "1") then
         luup.call_action("urn:upnp-org:serviceId:VSwitch1", "SetTarget", {newTargetValue = "1"}, 29)
    end
end

-- Set a 4(240seconds) minutes delay for a recheck and send notification if needed
luup.call_delay("check_gate_left_open", 240)


--[[ ======================================================================== --]]