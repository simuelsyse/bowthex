local file = {
    path = "/storage/emulated/0/Android/media/com.rtsoft.growtopia/.simu3lsyse.rttex"
}
local gazzete = {
      
    "add_label_with_icon|big|`9Simu3lsyse Helper Gazzete!|left|11550|",
    "add_smalltext|`whttps://discord.gg/N59BWcYxeG|",
    "add_spacer|small|",
    "add_image_button|banner|" .. file.path .. "|simu3lsyse|mumu|",
    "add_spacer|small|",
    "add_label_with_icon|small|`9Thank you for choosing Simu3lsyse as Your Helper!|left|7074|",
    "add_smalltext|`wNote : `9This script is all free! please do not resell it at any circumstantes|",
    "add_spacer|small|",
    "add_label_with_icon|small|`2Changelogs :|left|9472|",
    "add_spacer|small|",
    "add_label_with_icon|small|`9Make the Script Online|left|482|",
    "add_spacer|small|",
    "add_label_with_icon|small|`9Improvise the UI|left|482|",
    "add_spacer|small|",
    "end_dialog|simu3lsyse||ENJOY!|"
}
SendVariantList({[0] = "OnDialogRequest", [1] = table.concat(gazzete, "\n")})

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

    if (v[1]== "Telephone") then
        return true
    end
    return false
end)

for _, v in pairs({ 
    "reme", "qeme", "leme", "pull", "kick", "ban"
}) do 
    _G[v] = (v == "reme")
end

_S = {s_q = nil, s_i = nil}
_V = {s_i = {}, f_i = {}}
_D = {m_p = 40, d_p = 1}

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

function VendScanner()
    _G.scanned = false
    local function ScanAllVend()
        if _G.scanned then
            return
        else
            local id = {}
            for _, v in pairs(GetTiles()) do
                if v.fg == 9268 then
                    local ex = v.extra
                    if ex.owner ~= 0 and ex.lastupdate ~= 0 then
                        if not id[ex.lastupdate] or 
                           math.abs(ex.owner) < math.abs(id[ex.lastupdate].price) 
                        then
                            id[ex.lastupdate] = {
                                itemid = ex.lastupdate,
                                price = ex.owner,
                                x = v.x, y = v.y
                            }
                        end
                    end
                end
            end
            _V.s_i = {}
            for _, v in pairs(id) do
                table.insert(_V.s_i, v)
            end
        end
    end
    
    local function FindSpecificVend()
        ScanAllVend()
        _V.f_i = {}
        for _, v in pairs(_V.s_i) do
            local query = _S.s_q:gsub("%s", ".*"):lower()
            local data = GetItemInfo(v.itemid).name
            if data:lower():find(query) then
                _S.s_i = v
                local packet = string.format(
                    "action|input\ntext|Finding `2%s",
                    data
                )
                SendPacket(2, packet)
                return
            end
        end
        local packet = string.format(
            "action|input\ntext|The item you looking for is `4NOT LISTED!"
        )
        SendPacket(2, packet)
    end
    
    local function SendResult()
        local display = _V.s_i
        local dialog = {
            "add_quick_exit|",
            "add_label_with_icon|big|`wList `2Scanned `wVend|left|9268|",
            "add_smalltext|`9Find an item that you looking for!|",
            "add_spacer|small|",
            "add_label_with_icon|small|`wLookin for `4SPECIFIC `witem?|left|6016|",
            "add_text_input|query|`wSearch item :||32|",
            "add_spacer|small|",
            "add_small_font_button|search|`9Search It!|noflags|0|0|",
            "add_spacer|small|",
            "add_label_with_icon|small|`wScanned Vend :|left|9268|",
            "add_spacer|small|"
        }
        if _S.s_q and _S.s_q:match("%S") then
            _V.f_i = {}
            local query = _S.s_q:gsub("%s+", ".*"):lower()
            for _, v in pairs(_V.s_i) do
                local data = GetItemInfo(v.itemid).name
                if data:lower():find(query) then
                    table.insert(_V.f_i, v)
                end
            end
            display = _V.f_i
        end
        _D.d_p = math.max(1, math.min(_D.d_p, 40))
        local page = math.ceil(#display / 40)
        if #display ~= 0 then
            local s = (_D.d_p - 1) * 40 + 1
            local e = math.min(s + 39, #display)
            for i = s, e do
                pformat = (display[i].price < 0) and
                    string.format(
                      "`4On Sale `2%d `w%s for `91 World Lock",
                      math.abs(display[i].price),
                      GetItemInfo(display[i].itemid).name
                    )
                          or
                    string.format(
                      "`4On Sale `2%s `wfor `9%d World Locks",
                      GetItemInfo(display[i].itemid).name,
                      display[i].price
                    )
                table.insert(dialog, string.format(
                    "add_label_with_icon_button|small|%s|left|%d|%d|\nadd_spacer|small|",
                    pformat, display[i].itemid, i
                ))
            end
            for k, v in pairs({
                npage = _D.d_p < 40, 
                ppage = _D.d_p > 1
            }) do  
                if v then  
                    table.insert(dialog, string.format(
                        "add_small_font_button|%s|`9%s Page|noflags|0|0|", 
                        k, k == "npage" and "Next" or "Previous"
                    ))  
                end  
            end
        else
            table.insert(dialog, "add_smalltext|`4Vend that you looking for not available!|")  
        end
        table.insert(dialog, "end_dialog|vscan|All good.||")
        SendVariantList({ 
            [0] = "OnDialogRequest", 
            [1] = table.concat(dialog, "\n") 
        })
    end
    return {
        SAV = ScanAllVend, FSV = FindSpecificVend, SR = SendResult
    }
end

AddHook("onsendpacket", "sendpacket", function(t, s)
    local command = {
        "/[wdb][db]?(%d*) (%d+)",
        "/[pkb]%s?(.*)",
        "/[rql]",
        "/[v]%s?(.*)",
        "/cmd"
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
                                    "action|input\ntext|`2Play? `9Mr / Mrs.%s",
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

        local packet = string.format(
            "action|input\ntext|Dropped %d %s Lock",
            amount * multiplier, item[syntax][1]
        )   
        _G.dropdata = {
            amount * multiplier,
            item[syntax][2]
        }
        if GetInv(item[syntax][2]) < amount then
            if syntax == "b" then
                local packet = GetInv(11550) > 0 and 
                    "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl" 
                        or 
                    string.format(
                        "action|dialog_return\ndialog_name|bank_withdraw\nbgl_count|%s",
                        amount
                )
                SendPacket(2, packet)
            else
                if syntax == "bb" then
                    if GetInv(11550) == 0 then
                        local packet = string.format(
                            "action|dialog_return\ndialog_name|bank_withdraw\nbgl_count|%s",
                            amount * 100
                        )   
                        SendPacket(2, packet)
                    end
                end
            end
        end
        SendPacket(2, packet)
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
                            action[syntax]:upper()
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
                        action[syntax]:upper()
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
                        game[syntax]:upper()
                    ) or "`4All modes disabled"
                })
            else
                _G[game[syntax]] = false
                SendVariantList({
                    [0] = "OnTalkBubble",
                    [1] = netid,
                    [2] = string.format(
                          "`4Disabling `w%s modes", 
                          game[syntax]:upper()
                    ) 
                })
            end
        end
        return true
    end
    
    if s:match("action|dialog_return\ndialog_name|vscan\nbuttonClicked|search") then
        local query = s:match("query|(.*)")
        if query and query:match("%S") then  
            _S.s_q= query:gsub("%s+", ".*"):lower()
        else
            _S.s_q = nil  
        end
        VendScanner().SR()
        return true
    end

    if s:match("action|dialog_return\ndialog_name|vscan\nbuttonClicked|(%d+)") then
        local index = tonumber(s:match("buttonClicked|(%d+)"))
        _S.s_i = _V.f_i[index] or _V.s_i[index]
        return true
    end

    if s:match("action|dialog_return\ndialog_name|vscan\nbuttonClicked|(%a+)") then
        local button = s:match("buttonClicked|(%a+)")
        if button == "npage" then
            _D.d_p = _D.d_p + 1
        else
            _D.d_p = _D.d_p - 1
        end
        VendScanner().SR()
        return true
    end
    
    if (s:match(command[4])) then
        local syntax, query = s:match("/([v])%s?(.*)")
        _G.scanned = true
        _S.s_q = query 
        if query ~= "" then
            VendScanner().FSV()
        else
            VendScanner().SAV()
            VendScanner().SR()
        end
        return true
    end

    if (s:match(command[5])) then
        local dialog = {
            "add_quick_exit|",
            "add_label_with_icon|big|`wList `2Command|left|5956|",
            "add_smalltext|`9All the command that you can use!|",
            "add_spacer|small|",
            "add_label_with_icon|small|`wFast Wrench or Shortcut command : `9/p /k /b|left|32|",
            "add_smalltext|`4Note : Just type /p to activate fast wrench mode|",
            "add_smalltext|`2Usage : /p (player name) or /p|",
            "add_spacer|small|",
            "add_label_with_icon|small|`wDrop command : `9/w /dd /b /bb|left|5260|",
            "add_smalltext|`2Usage : /dd(multiplier) (amount)|",
            "add_spacer|small|",
            "add_label_with_icon|small|`wGame command : `9/r /q /l|left|758|",
            "add_smalltext|`2Usage : /r|",
            "add_spacer|small|",
            "add_label_with_icon|small|`wVendscanner : `9/v|left|9268|",
            "add_smalltext|`4Note : You can just type /v to scan all the vend|",
            "add_smalltext|`2Usage : /v (item name)|",
            "add_spacer|small|",
            "end_dialog|cmd||Thank You!|"
        }
        SendVariantList({ 
            [0] = "OnDialogRequest", 
            [1] = table.concat(dialog, "\n") 
        })
        return true
    end
    return false
end)

RunThread(function()
    while true do
        Sleep(100)
        for _, v in pairs({7188, 1796, 242}) do
            if GetInv(v) > 99 then
                if v == 7188 then
                    local packet = "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl" 
                    SendPacket(2, packet)
                else
                    if v == 1796 then
                        local Tx, Ty = GetTele()
                        if Tx and Ty then
                            local packet = string.format(
                                "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|%d|\ny|%d|\nbuttonClicked|bglconvert",
                                Tx, Ty
                            )
                            SendPacket(2, packet)
                        end
                    else
                        SendPacketRaw({
                            type = 10, 
                            value = 242
                        })
                    end
                end
            end
            Sleep(100)
        end
        if _G.dropdata ~= nil then
            local packet = string.format(
                "action|dialog_return\ndialog_name|drop\nitem_drop|%d|\nitem_count|%d", 
                _G.dropdata[2], _G.dropdata[1]
            )
            SendPacket(2, packet)
            _G.dropdata = nil
        end
        if _S.s_i then
            FindPath(_S.s_i.x, _S.s_i.y)
            VendScanner().SAV()
            _S.s_i = nil
        end 
    end
end)
