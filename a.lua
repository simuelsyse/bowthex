leme = true
AddHook("onvariant", "variant", function(v)
    if (v[0] == "OnConsoleMessage" and v[1]:find("Spammer")) or (v[0] == "OnTalkBubble" and v[2]:find("Slave")) then
        return true
    end
    if (v[0] == "OnConsoleMessage" and v[1]:find("Collected  `w(%d+) (.+) Lock")) then
        local amount, item = v[1]:match("Collected  `w(%d+) (.+) Lock")
        local valid = {
            ["Black Gem"] = "`b", ["Blue Gem"] = "`c",
            ["Diamond"] = "`1", ["World"] = "`6"
        }
        if amount and valid[item] then
            local packet = string.format(
                "action|input\ntext|Collected %s ` %s%s Lock",
                amount, valid[item], item
            )
            SendPacket(2, packet)
        end
    end
    if (v[0] == "OnTalkBubble" and v[2]:find("spun the wheel and got `(.+)`!")) then
        local number = tonumber(v[2]:match("got `(.+)`!"):sub(2, -2))
        local game = reme and "R" or qeme and "Q" or "L"
        if (reme or qeme or leme) then
            local number = qeme and (number == 0 and 1 or number) or ((reme or leme) and (number // 10 + number % 10))
            local number = (number >= 10 and number - 10 or number)
            local result = ""
            if reme or qeme then
                result = number == 1 and "[`4L`w]" or number == 0 and "[`2X3`w]" or ""
            elseif leme then
                result = (number == 2 or number == 9) and "[`4L`w]" 
                      or number == 1 and "[`2X3`w]" 
                      or number == 0 and "[`2X4`w]" 
                      or ""
            end
            local string = string.format("`w[%s : %d]%s", game, number, result)
            SendVariantList({
                [0] = "OnTalkBubble",
                [1] = v[1],
                [2] = v[2] .. string
            })
        end
        return true
    end
    if (v[0] == "OnConsoleMessage" and v[1]:find("spun the wheel and got")) then
        SendVariantList({
            [0] = "OnConsoleMessage",
            [1] = v[1]
        })
        return true
    end
    if (v[0] == "OnSDBroadcast") then
        return true
    end
    return false
end)

AddHook("onsendpacket", "sendpacket", function(t, s)
    local command = {
        "/[wdb][db]? (%d+)", 
        "/[pkb] (%s)"
    }
    if (s:match(command[1])) then
        local syntax, multiplier, amount = s:match("/([wdb][db]?)(%d*) (%d+)")
        local item = {
            w = 242, dd = 1796, b = 7188, bb = 11550
        }
        multiplier = tonumber(multiplier) or 1
        amount = tonumber(amount) or 0

        local packet = string.format(
            "action|dialog_return\ndialog_name|drop\nitem_drop|%d|\nitem_count|%d", 
            item[syntax], amount * multiplier
        )
        SendPacket(2, packet)
        return true
    end
    return false
end)
