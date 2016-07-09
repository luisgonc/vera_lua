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
