AddHook("onvariant", "variant", function(v)
    if (v[0] == "OnConsoleMessage" and v[1]:find("Spammer")) or 
       (v[0] == "OnTalkBubble" and v[2]:find("Slave")) then
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
            local number = (number >= 10 and tostring(number):sub(2) or number)
            local result = ""
            
            if reme or qeme then
                result = tonumber(number) == 1 and "[`4LOSE`w]" or tonumber(number) == 0 and "[`2X3`w]" or ""
            elseif leme then
                result = (number == 2 or number == 9) and "[`4LOSE`w]" 
                      or number == 1 and "[`2X3`w]" 
                      or number == 0 and "[`2X4`w]" 
                      or ""
            end
            
            local string = string.format("`w[%s : %d]%s", game, tonumber(number), result)
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

for _, v in pairs({ 
    "reme", "qeme", "leme", "pull", "kick", "ban"
}) do 
    _G[v] = (v == "reme" and true or false)
end

AddHook("onsendpacket", "sendpacket", function(t, s)
    local command = {
        "/[wdb][db]?(%d*) (%d+)",
        "/[pkb]%s?(.*)",
        "/[rql]"
    }

    if (s:match(command[1])) then
        local syntax, multiplier, amount = s:match("/([wdb][db]?)(%d*) (%d+)")
        local item = {
            ["bb"] = {"`bBlack Gem", 11550}, ["b"] = {"`cBlue Gem", 7188},
            ["dd"] = {"`1Diamond", 1796}, ["w"] = {"`6World", 242}
        }
        multiplier = tonumber(multiplier) or 1
        amount = tonumber(amount) or 0

        local packet = {
            string.format(
                "action|dialog_return\ndialog_name|drop\nitem_drop|%d|\nitem_count|%d", 
                item[syntax][2], amount * multiplier
            ),
            string.format(
                "action|input\ntext|Dropped %d %s Lock",
                amount * multiplier, item[syntax][1]
            )
        }
        for i = 2, 1, -1 do
            SendPacket(2, packet[i])
        end
        return true
    end

    if (s:match(command[2])) then
        local syntax, name = s:match("/([pkb])%s?(.*)")
        local netid = GetLocal().netid
        local action = {
            ["p"] = "pull",
            ["k"] = "kick",
            ["b"] = "ban"
        }
        if action[syntax] then
            for _, v in pairs(action) do
                _G[v] = false
            end
            if not name or name == "" then
                _G[action[syntax]] = not _G[action[syntax]]
                SendVariantList({
                    [0] = "OnTalkBubble",
                    [1] = netid,
                    [2] = _G[action[syntax]] and string.format(
                        "`4Disabling `wother modes, `2Enabling `wfast %s mode", 
                        action[syntax]
                    ) or "`4All modes disabled"
                })
            else
                for _, p in pairs(GetPlayerList()) do
                    if p.name:lower():find(name:lower()) then
                        local clearname = p.name:gsub("`%w", ""):gsub("%p",  ""):gsub("Dr", ""):gsub("%[.-%]", ""):lower()
                        local packet = string.format(
                            "action|input\ntext|/%s %s",
                            action[syntax], clearname
                        )
                        SendPacket(2, packet)
                        break
                    end
                end
            end
        end
        return true
    end

    if (s:match(command[3])) then
        local syntax = s:match("/([rql])")
        local game = {
            ["r"] = "reme",
            ["q"] = "qeme",
            ["l"] = "leme"
        }
        if game[syntax] then
            local netid = GetLocal().netid
            for _, v in pairs(game) do
                _G[v] = false
            end
            _G[game[syntax]] = not _G[game[syntax]]
            SendVariantList({
                [0] = "OnTalkBubble",
                [1] = netid,
                [2] = _G[game[syntax]] and string.format(
                    "`4Disabling `wother modes, `2Enabling `w%s mode", 
                    game[syntax]
                ) or "`4All modes disabled"
            })
        end
        return true
    end
    return false
end)
