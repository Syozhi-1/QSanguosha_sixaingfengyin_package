-- 创建Package，风云再起包拓展包
-- 由**邕州风云国战俱乐部**开发制作
sixiangfengyin = sgs.Package("sixiangfengyin", sgs.Package_GeneralPack)

sgs.LoadTranslationTable{
    ["sixiangfengyin"] = "四象封印 ",
}

-- General(Package *package, const QString &name, const QString &kingdom,int double_max_hp, bool male, bool hidden, bool never_shown)
-- General(Package 拓展包名, const QString 姓名, const QString 势力,int 血量(按阴阳鱼计算), bool 性别（true 男/false 女）, bool 是否在选将列表中隐藏, bool 是否在客户端中隐藏)
-- 创建武将 曹操 魏
-- 珠联璧合 卞夫人 典韦 许褚
sxfy_caocao = sgs.General(sixiangfengyin, "sxfy_caocao", "wei", 4, true)

sgs.LoadTranslationTable{
    ["#sxfy_caocao"] = "魏武帝",
    ["sxfy_caocao"] = "曹操",
    ["illustrator:sxfy_caocao"] = "云涯",
	["designer:sxfy_caocao"] = "邕州风云俱乐部",
    ["sxfyjianxiong"] = "奸雄",
    [":sxfyjianxiong"] = "当你受到伤害后，你可以获得对你造成伤害的牌，并摸一张牌。",
    -- 曹操
    ["$sxfyjianxiong1"] = "夫英雄者，胸怀大志，腹有良谋！",
    ["$sxfyjianxiong2"] = "燕雀安知鸿鹄之志！",
    ["~sxfy_caocao"] = "雪鬓霜鬟，大业未完。",
}

-- 创建武将 夏侯惇 魏
-- 珠联璧合 夏侯渊 于禁
sxfy_xiahoudun = sgs.General(sixiangfengyin, "sxfy_xiahoudun", "wei", 5, true)

sgs.LoadTranslationTable{
    ["#sxfy_xiahoudun"] = "独眼的罗刹",
    ["sxfy_xiahoudun"] = "夏侯惇",
    ["illustrator:sxfy_xiahoudun"] = "木美人",
	["designer:sxfy_xiahoudun"] = "邕州风云俱乐部",
    ["sxfyganglie"] = "刚烈",
    [":sxfyganglie"] = "当你受到1点伤害后，你可以进行一次判定，若结果为：红色，你对伤害来源造成1点伤害；黑色，你弃置伤害来源的一张牌。",
    -- 夏侯惇
    ["$sxfyganglie1"] = "哪个敢动我！",
    ["$sxfyganglie2"] = "伤我者，十倍奉还！",
    ["~sxfy_xiahoudun"] = "诸多败绩，有负丞相重托！",
}

-- 创建武将 张辽 魏
-- 珠联璧合 臧霸 张虎
sxfy_zhangliao = sgs.General(sixiangfengyin, "sxfy_zhangliao", "wei", 4, true)

sgs.LoadTranslationTable{
    ["#sxfy_zhangliao"] = "登锋陷阵",
    ["sxfy_zhangliao"] = "张辽",
    ["illustrator:sxfy_zhangliao"] = "枭瞳",
	["designer:sxfy_zhangliao"] = "邕州风云俱乐部",
    ["sxfytuxi"] = "突袭",
    [":sxfytuxi"] = "摸牌阶段你可以少摸任意张牌，然后获得等量名其他角色各一张手牌。",
    -- 张辽
    ["$sxfytuxi1"] = "十万围困，吾亦能破袭擒贼。",
    ["$sxfytuxi2"] = "突袭速攻，形如闪电。",
    ["~sxfy_zhangliao"] = "感丞相大恩，此生可了。",
}

-- 创建武将 许褚 魏
-- 珠联璧合 曹操
sxfy_xuchu = sgs.General(sixiangfengyin, "sxfy_xuchu", "wei", 4, true)

sgs.LoadTranslationTable{
    ["#sxfy_xuchu"] = "虎痴",
    ["sxfy_xuchu"] = "许褚",
    ["illustrator:sxfy_xuchu"] = "鬼画府",
	["designer:sxfy_xuchu"] = "邕州风云俱乐部",
    ["sxfyluoyi"] = "裸衣",
    [":sxfyluoyi"] = "摸牌阶段结束后，你可以弃置一张牌，然后本回合你为伤害来源的【杀】或【决斗】伤害+1。",
    -- 许褚
    ["$sxfyluoyi1"] = "大丈夫，自当赤膊相见！",
    ["$sxfyluoyi2"] = "阳刚才是男人的浪漫！",
    ["~sxfy_xuchu"] = "这力量还需要加练！",
}

-- ============================================================
-- 技能实现
-- 说明：本包的技能全部在本文件内自行实现，不调用官版技能的任何实现，
--       以便与官版武将完全解耦（即使机制相同，也是独立的技能对象与判定逻辑）。
-- ============================================================

-- 【奸雄】当你受到伤害后，你可以获得对你造成伤害的牌，并摸一张牌。
sxfyjianxiong = sgs.CreateTriggerSkill{
    name = "sxfyjianxiong",
    events = {sgs.Damaged},
    can_trigger = function (self, event, room, player, data)
        if player == nil or not player:isAlive() or not player:hasSkill(self:objectName()) then
            return "", ""
        end
        local damage = data:toDamage()
        -- 无牌可拿（如【闪电】等无来源伤害）不触发
        if damage.card == nil then return "", "" end
        -- 造成伤害的牌必须还停在处理区，否则已经进弃牌堆，没有东西可拿
        local table_ids = room:getCardIdsOnTable(damage.card)
        if table_ids:length() < 1 then return "", "" end
        local subcards = damage.card:getSubcards()
        if subcards:length() > 0 and subcards:length() ~= table_ids:length() then
            return "", ""
        end
        return self:objectName(), player:objectName()
    end,
    on_cost = function (self, event, room, player, data, who)
        return room:askForSkillInvoke(who, self:objectName(), sgs.QVariant())
    end,
    on_effect = function (self, event, room, player, data, who)
        local damage = data:toDamage()
        room:broadcastSkillInvoke(self:objectName(), who)
        who:obtainCard(damage.card)
        who:drawCards(1, self:objectName())
        return false
    end,
}

-- 【刚烈】当你受到1点伤害后，你可以进行一次判定：
--   红色 —— 你对伤害来源造成1点伤害；黑色 —— 你弃置伤害来源的一张牌。
sxfyganglie = sgs.CreateTriggerSkill{
    name = "sxfyganglie",
    events = {sgs.Damaged},
    can_trigger = function (self, event, room, player, data)
        if player == nil or not player:isAlive() or not player:hasSkill(self:objectName()) then
            return "", ""
        end
        local damage = data:toDamage()
        -- 没有伤害来源就没有刚烈的对象
        if damage.from == nil then return "", "" end
        if damage.from:objectName() == player:objectName() then return "", "" end
        if damage.damage < 1 then return "", "" end
        return self:objectName(), player:objectName()
    end,
    on_cost = function (self, event, room, player, data, who)
        return room:askForSkillInvoke(who, self:objectName(), sgs.QVariant())
    end,
    on_effect = function (self, event, room, player, data, who)
        local damage = data:toDamage()
        local source = damage.from
        local times = damage.damage
        room:broadcastSkillInvoke(self:objectName(), who)
        -- 「受到1点伤害后」：受到几点伤害就判定几次
        for i = 1, times do
            if not who:isAlive() then break end
            if source == nil or not source:isAlive() then break end
            local judge = sgs.JudgeStruct()
            judge.who = who
            judge.pattern = ".|red"
            judge.good = true
            judge.reason = self:objectName()
            room:judge(judge)
            if source ~= nil and source:isAlive() then
                if judge:isGood() then
                    -- 红色：对伤害来源造成1点伤害
                    room:damage(sgs.DamageStruct(self:objectName(), who, source, 1))
                elseif (not source:isKongcheng()) or source:getEquips():length() > 0 then
                    -- 黑色：弃置伤害来源的一张牌
                    local card_id = room:askForCardChosen(who, source, "he", self:objectName(), false, sgs.Card_MethodDiscard)
                    if card_id ~= nil and card_id >= 0 then
                        room:throwCard(card_id, source, who, self:objectName())
                    end
                end
            end
        end
        return false
    end,
}

-- 【突袭】摸牌阶段你可以少摸任意张牌，然后获得等量名其他角色各一张手牌。
sxfytuxi = sgs.CreateTriggerSkill{
    name = "sxfytuxi",
    events = {sgs.DrawNCards, sgs.AfterDrawNCards},
    can_trigger = function (self, event, room, player, data)
        if player == nil or not player:isAlive() or not player:hasSkill(self:objectName()) then
            return "", ""
        end
        if event == sgs.DrawNCards then
            if data:toInt() < 1 then return "", "" end
            -- 至少要有手牌的其他角色，否则没有可选目标
            for _, p in sgs.qlist(room:getOtherPlayers(player)) do
                if p:isAlive() and not p:isKongcheng() then
                    return self:objectName(), player:objectName()
                end
            end
            return "", ""
        else
            -- 摸牌阶段结束时结算「获得手牌」
            if player:getTag("sxfytuxi_targets"):toString() ~= "" then
                return self:objectName(), player:objectName()
            end
            return "", ""
        end
    end,
    on_cost = function (self, event, room, player, data, who)
        if event == sgs.AfterDrawNCards then return true end
        local n = data:toInt()
        local targets = sgs.SPlayerList()
        for _, p in sgs.qlist(room:getOtherPlayers(player)) do
            if p:isAlive() and not p:isKongcheng() then
                targets:append(p)
            end
        end
        if targets:isEmpty() then return false end
        local max_num = math.min(n, targets:length())
        local choosees = room:askForPlayersChosen(who, targets, self:objectName(), 0, max_num, "@sxfytuxi-card", true)
        if choosees:isEmpty() then return false end
        room:sortByActionOrder(choosees)
        local names = {}
        for _, p in sgs.qlist(choosees) do
            table.insert(names, p:objectName())
        end
        who:setTag("sxfytuxi_targets", sgs.QVariant(table.concat(names, "|")))
        return true
    end,
    on_effect = function (self, event, room, player, data, who)
        if event == sgs.DrawNCards then
            local count = 0
            for _ in string.gmatch(who:getTag("sxfytuxi_targets"):toString(), "[^|]+") do
                count = count + 1
            end
            -- 少摸等量的牌
            data:setValue(math.max(0, data:toInt() - count))
            room:broadcastSkillInvoke(self:objectName(), who)
            room:notifySkillInvoked(who, self:objectName())
            return false
        end
        -- 摸牌阶段结束：依次获得所选角色各一张手牌
        local names = who:getTag("sxfytuxi_targets"):toString()
        who:setTag("sxfytuxi_targets", sgs.QVariant(""))
        for name in string.gmatch(names, "[^|]+") do
            local target = room:findPlayer(name, true)
            if target ~= nil and target:isAlive() and who:canGetCard(target, "h") then
                local card_id = room:askForCardChosen(who, target, "h", self:objectName(), false, sgs.Card_MethodGet)
                if card_id ~= nil and card_id >= 0 then
                    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION,
                        who:objectName(), target:objectName(), self:objectName(), "")
                    room:obtainCard(who, sgs.Sanguosha:getCard(card_id), reason, true)
                end
            end
        end
        return false
    end,
}

-- 【裸衣】摸牌阶段结束后，你可以弃置一张牌，然后本回合你为伤害来源的【杀】或【决斗】伤害+1。
sxfyluoyi = sgs.CreateTriggerSkill{
    name = "sxfyluoyi",
    events = {sgs.EventPhaseEnd, sgs.TurnStart, sgs.ConfirmDamage},
    can_trigger = function (self, event, room, player, data)
        if player == nil or not player:isAlive() then return "", "" end
        if event == sgs.TurnStart then
            -- 新回合开始，清掉上一回合的裸衣状态
            if player:getMark("#sxfyluoyi") > 0 then
                room:setPlayerMark(player, "#sxfyluoyi", 0)
            end
            return "", ""
        elseif event == sgs.EventPhaseEnd then
            if not player:hasSkill(self:objectName()) then return "", "" end
            if player:getPhase() == sgs.Player_Finish then
                -- 回合结束，清掉裸衣状态
                if player:getMark("#sxfyluoyi") > 0 then
                    room:setPlayerMark(player, "#sxfyluoyi", 0)
                end
                return "", ""
            end
            -- 「摸牌阶段结束后」发起
            if player:getPhase() ~= sgs.Player_Draw then return "", "" end
            if player:getCards("he"):length() < 1 then return "", "" end
            return self:objectName(), player:objectName()
        else
            -- ConfirmDamage：自己用【杀】/【决斗】造成伤害时 +1
            if not player:hasSkill(self:objectName()) then return "", "" end
            if player:getMark("#sxfyluoyi") < 1 then return "", "" end
            local damage = data:toDamage()
            if damage.from == nil or damage.from:objectName() ~= player:objectName() then return "", "" end
            if damage.chain or damage.transfer then return "", "" end
            if damage.card == nil then return "", "" end
            if not (damage.card:isKindOf("Slash") or damage.card:isKindOf("Duel")) then return "", "" end
            return self:objectName(), player:objectName()
        end
    end,
    on_cost = function (self, event, room, player, data, who)
        if event ~= sgs.EventPhaseEnd then return true end
        if not room:askForSkillInvoke(who, self:objectName(), sgs.QVariant()) then return false end
        -- 弃置一张牌；不弃就不生效
        return room:askForDiscard(who, self:objectName(), 1, 1, false, true, "@sxfyluoyi-card")
    end,
    on_effect = function (self, event, room, player, data, who)
        if event == sgs.EventPhaseEnd then
            room:setPlayerMark(who, "#sxfyluoyi", 1)
            room:broadcastSkillInvoke(self:objectName(), who)
            room:sendCompulsoryTriggerLog(who, self:objectName(), false)
            return false
        end
        local damage = data:toDamage()
        damage.damage = damage.damage + 1
        data:setValue(damage)
        return false
    end,
}

sgs.LoadTranslationTable{
    ["@sxfytuxi-card"] = "你可以少摸等量的牌，获得等量名其他角色各一张手牌",
    ["@sxfyluoyi-card"] = "弃置一张牌，本回合你为伤害来源的【杀】和【决斗】伤害+1",
}

sxfy_caocao:addSkill(sxfyjianxiong)
sxfy_xiahoudun:addSkill(sxfyganglie)
sxfy_zhangliao:addSkill(sxfytuxi)
sxfy_xuchu:addSkill(sxfyluoyi)

-- 珠联璧合（按包内注释填写）
sxfy_caocao:addCompanion("bianhuanghou")
sxfy_caocao:addCompanion("dianwei")
sxfy_caocao:addCompanion("sxfy_xuchu")
sxfy_xiahoudun:addCompanion("xiahouyuan")
sxfy_xiahoudun:addCompanion("yujin")
sxfy_zhangliao:addCompanion("zangba")
sxfy_xuchu:addCompanion("sxfy_caocao")

--最后返回包含这个Package对象的表
return {sixiangfengyin}