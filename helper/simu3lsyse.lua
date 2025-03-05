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
            if tonumber(amount) >= 100 and item:lower() == "diamond" then
                local Tx, Ty = GetTele()
                if Tx and Ty then
                    local packet = string.format(
                        "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|%d|\ny|%d|\nbuttonClicked|bglconvert",
                        Tx, Ty
                    )
                    for i = tonumber(amount) // 100, 0, -1 do
                        SendPacket(2, packet)
                    end
                end
            end
            local packet = string.format(
                "action|input\ntext|Collected %d ` %s%s Lock",
                amount, valid[item], item
            )
            SendPacket(2, packet)
        end
    end

    if (v[0] == "OnTalkBubble" and v[2]:find("spun the wheel and got `(.+)`!")) then
        local number = tonumber(v[2]:match("got `(.+)`!"):sub(2, -2))
        local game = reme and "R" or qeme and "Q" or "L"
        local string = ""
        
        if (reme or qeme or leme) then
            local number = qeme and (number == 0 and 1 or number) or ((reme or leme) and (number // 10 + number % 10))
            local number = tonumber(number >= 10 and tostring(number):sub(2) or number)
            local result = ""
            
            if reme or qeme then
                result = number == 1 and "[`4LOSE`w]" or number == 0 and "[`2X3`w]" or ""
            elseif leme then
                result = (number == 2 or number == 9) and "[`4LOSE`w]" 
                      or number == 1 and "[`2X3`w]" 
                      or number == 0 and "[`2X4`w]" 
                      or ""
            end
            
            string = string.format("`w[%s : %d]%s", game, tonumber(number), result)
        end
            SendVariantList({
                [0] = "OnTalkBubble",
                [1] = v[1],
                [2] = v[2] .. string
            })
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

function GetInv(itemid)
    for _, v in pairs(GetInventory()) do
        if v.id == itemid then
            return v.amount
        end
    end
    return 0
end 

function GetTele()
    for _, v in pairs(GetTiles()) do
        if v.fg == 3898 then
            return v.x, v.y
        end
    end
    return nil, nil
end

AddHook("onsendpacket", "sendpacket", function(t, s)
    local command = {
        "/[wdb][db]?(%d*) (%d+)",
        "/[pkb]%s?(.*)",
        "/[rql]"
    }

    if (s:match("action|wrench\n|netid|(%d+)")) then
        local netid = tonumber(s:match("action|wrench\n|netid|(%d+)"))
        local action = {
            ["pull"] = "pull", 
            ["kick"] = "kick", 
            ["ban"] = "world_ban"
        }
        if GetLocal().netid ~= netid then
            for k, v in pairs(action) do
                if _G[k] then
                    local packet = string.format(
                        "action|dialog_return\ndialog_name|popup\nnetID|%d|\nbuttonClicked|%s",
                        netid, v
                    )
                    SendPacket(2, packet)
                    if _G["pull"] then
                        for _, p in pairs(GetPlayerList()) do
                            if p.netid == netid then
                                local packet = string.format(
                                    "action|input\ntext|Play? Mr / Mrs.%s",
                                    p.name
                                )
                                SendPacket(2, packet)
                            end
                        end
                    end
                end
            end
            return true
        end
    end

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
        if GetInv(item[syntax][2]) < amount then
            if syntax == "b" then
                if GetInv(1796) > 99 then
                    local Tx, Ty = GetTele()
                    if Tx and Ty then
                        local packet = string.format(
                            "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|%d|\ny|%d|\nbuttonClicked|bglconvert",
                            Tx, Ty
                        )
                        SendPacket(2, packet)
                    end
                else
                    local packet = GetInv(11550) > 0 and 
                        "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl" 
                            or 
                        string.format(
                            "action|dialog_return\ndialog_name|bank_withdraw\nbgl_count|%s",
                            amount
                    )
                    SendPacket(2, packet)
                end
            else
                if syntax == "bb" then
                    local packet = GetInv(7188) >= 100 and 
                        "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl" 
                            or 
                        string.format(
                            "action|dialog_return\ndialog_name|bank_withdraw\nbgl_count|%s",
                            amount * 100
                    )
                    SendPacket(2, packet)
                else
                    local val = (syntax == "dd" and (GetInv(7188) > 0 and 7188 or 242)) or 1796
                    SendPacketRaw(false, {
                      type = 10, value = val
                    })
                end
            end
        end
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
            if not _G[action[syntax]] then
                if not name or name == "" then
                    for _, v in pairs(action) do
                        _G[v] = false
                    end
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
                            local clearname = p.name
                                              :gsub("%[.-%]", "")
                                              :gsub("`%w", "")
                                              :gsub("%p",  "")
                                              :gsub("Dr", "")
                                              :lower()
                            local packet = string.format(
                                "action|input\ntext|/%s %s",
                                action[syntax], clearname
                            )
                            SendPacket(2, packet)
                            break
                        end
                    end
                end
            else
                _G[action[syntax]] = false
                SendVariantList({
                    [0] = "OnTalkBubble",
                    [1] = netid,
                    [2] = string.format(
                        "`4Disabling `w%s modes", 
                        action[syntax]
                    ) 
                })
            end
        end
        return true
    end

    if (s:match(command[3])) then
        local syntax = s:match("/([rql])")
        local netid = GetLocal().netid
        local game = {
            ["r"] = "reme",
            ["q"] = "qeme",
            ["l"] = "leme"
        }
        if game[syntax] then
            if not _G[game[syntax]] then
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
            else
                _G[game[syntax]] = false
                SendVariantList({
                    [0] = "OnTalkBubble",
                    [1] = netid,
                    [2] = string.format(
                          "`4Disabling `w%s modes", 
                          game[syntax]
                    ) 
                })
            end
        end
        return true
    end
    return false
end)
