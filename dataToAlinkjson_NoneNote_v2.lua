function
    function string.insert(str1, str2, pos)
        return str1:sub(1, pos) .. str2 .. str1:sub(pos + 1)
    end
    function hex2dec(data)
        data = tonumber('0x' .. data)
        return data
    end
    function calc_crc(string)
        if string.len(string) % 2 ~= 0 then
            string = '0' .. string
        end
        data = {}
        i = 1
        while i <= string.len(string) do
            byte = string.sub(string, i, i + 1)
            table.insert(data, tonumber(byte, 16))
            i = i + 2
        end
        crc = 0xFFFF
        for _, pos in ipairs(data) do
            crc = bit.bxor(crc, pos)
            for i = 1, 8 do
                if bit.band(crc, 1) ~= 0 then
                    crc = bit.rshift(crc, 1)
                    crc = bit.bxor(crc, 0xA001)
                else
                    crc = bit.rshift(crc, 1)
                end
            end
        end
        -- 修改格式化字符串将低8位放在前面
        local hex_crc = string.format("%04X", crc):sub(3, 4) .. string.format("%04X", crc):sub(1, 2)
        return hex_crc -- 返回CRC校验码
    end
    local datain = ...
    local checkFlag = 1
    local params = {}
    local dataOrign = string.sub(datain, 1, 3)
    local data = string.sub(datain, 4)
    if (dataOrign == "111" and calc_crc(data) == "0000") then
        params.LOV = tonumber(string.format("%.2f", hex2dec(string.sub(data, 6, 14)) * 0.0001))
        params.LOA = tonumber(string.format("%.2f", hex2dec(string.sub(data, 15, 22)) * 0.0001))
        params.ActivePower_1 = tonumber(string.format("%.3f", hex2dec(string.sub(data, 23, 30)) * 0.0001))
        params.ActiveEnergy_1 = tonumber(string.format("%.3f", hex2dec(string.sub(data, 31, 38)) * 0.0001))
        params.PowerFactor_1 = tonumber(string.format("%.3f", hex2dec(string.sub(data, 39, 46)) * 0.001))
        params.CO2Emissions_1 = tonumber(string.format("%.3f", hex2dec(string.sub(data, 47, 54)) * 0.0001))
        params.EMStem_1 = tonumber(string.format("%.2f", hex2dec(string.sub(data, 55, 62)) * 0.01))
        params.Frequency_1 = tonumber(string.format("%.2f", hex2dec(string.sub(data, 63, 70)) * 0.01))
    elseif (dataOrign == "000" and calc_crc(data) == "0000") then
        params.LTV = tonumber(string.format("%.2f", hex2dec(string.sub(data, 6, 14)) * 0.0001))
        params.LTA = tonumber(string.format("%.2f", hex2dec(string.sub(data, 15, 22)) * 0.0001))
        params.ActivePower_2 = tonumber(string.format("%.3f", hex2dec(string.sub(data, 23, 30)) * 0.0001))
        params.ActiveEnergy_2 = tonumber(string.format("%.3f", hex2dec(string.sub(data, 31, 38)) * 0.0001))
        params.PowerFactor_2 = tonumber(string.format("%.3f", hex2dec(string.sub(data, 39, 46)) * 0.001))
        params.CO2Emissions_2 = tonumber(string.format("%.3f", hex2dec(string.sub(data, 47, 54)) * 0.0001))
        params.EMStem_2 = tonumber(string.format("%.2f", hex2dec(string.sub(data, 55, 62)) * 0.01))
        params.Frequency_2 = tonumber(string.format("%.2f", hex2dec(string.sub(data, 63, 70)) * 0.01))
    elseif (dataOrign == "001") then
        -- 00189122377123
        params.Temperature = tonumber(string.insert(string.sub(data, 1, 4), ".", 2))
        params.Humidity = tonumber(string.insert(string.sub(data, 5, 8), ".", 2))
        params.BoxSwitch = tonumber(string.sub(data, 9, 9))
        params.CRLOsta = tonumber(string.sub(data, 10, 10))
        params.CRLTsta = tonumber(string.sub(data, 11, 11))
    elseif (dataOrign == "101") then
        params.Relay1ChangeStateRemainingTime = data
    elseif (dataOrign == "010") then
        params.Relay2ChangeStateRemainingTime = data
    else
        checkFlag = 0
    end
    local timestamp = os.time()
    local jsonData = {
        id = "001",
        params = params,
        dataOrign = dataOrign,
        timestamp = timestamp,
        checkFlag = checkFlag,
        version = "1.0",
        method = "thing.event.property.post"
    }
    jsonData = json.encode(jsonData)
    return jsonData
end
