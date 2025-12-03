SMODS.Atlas{
    key = 'Pokers', -- might need to add this later to all the everything as a tag ig
    path = 'Pokers_Jokers.png',
    px = 71,
    py = 95
}

-- SMODS.Atlas {
--     key = "back_atlas",
--     path = "Pokers_Back.png",
--     px = 71,
--     py = 95
-- }

-- SMODS.Atlas {
--     key = "seal_atlas",
--     path = "Pokers_Seals.png",
--     px = 71,
--     py = 95
-- }

SMODS.Atlas({
    key = 'editions_atlas',
    path = 'Pokers_Editions.png',
    px = 71,
    py = 95,
})

SMODS.Jokers{ --catastic 
    key = 'catastic',
    loc_txt = {
        name = 'Catastic',
        text = {
            'When Blind is selected,',
            'create a {C:attention}Funny Kitty{}',
            'Gains {X:mult, C:white}X#1#{} Mult for each {C:attention}Funny Kitty{}',
            '{C:inactive}(Currently {C:Xmult}X#1{C:inactive} Mult)'
        }
    },

    atlas = 'Pokers',
    pos = {x = 0, y = 0},
    rarity = 2,
    cost = 6,
    config = {extra = { Xmult = 1, creates = 1}},
    loc_vars = function(self, info_queue, card)
        local kitty_count = #SMODS.find_card("c_pokers_funnykitty")
        return { vars = { card.ability.extra.Xmult, 
        1 + kitty_count, card.ability.extra.creates}}
        -- need to figure out how to define these x amount of jokers
    end,
    calculate = function(self,card, context)
        if context.joker_main then
            local kitty_count = #SMODS.find_card("c_pokers_funnykitty")
            return {
                Xmult_mod = 1 + kitty_count,
                messsage = localize { type = 'variable', key = 'a_xmult', vars = {1 + kitty_count}}
            }
        end

        -- if context.other_card/how df do i create more kitty
        if context.setting_blind and #G.Jokers.cards + G.GAME.joker_buffer < G.Jokers.config.card_limit then 
            local jokers_to_create = math.min(card.ability.extra.creates, 
                G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
            G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
            G.E_MANAGER:add_event(Event({
                func = function()
                    for _ = 1, jokers_to_create do
                        SMODS.add_card{ key = "c_pokers_funnykitty"}
                        G.GAME.joker_buffer = 0
                    end
                    return true
                end 

                -- here is where i would put my kitty spawning logic... if i had one!!
        }))
        return {
            message = '+1 Kitty!',
            colour = G.C.XMULT,
            card = card
        }
    end
        
        if context.joker_main then
            return {
                Xmult_mod = card.ability.extra.Xmult,
                message = localize { type = 'variable', key = 'a_xmult', vars = {card.ability.extra.xmult} }
            }
        end

        for _, catastic in ipairs(SMODS.find_card("c_pokers_funnykitty")) do
        card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
        -- return {}
    end
end
}


SMODS.Jokers{ -- worldbox
    key = 'worldbox',
    loc_txt = {
        name = 'God Mode',
        text = {
            "Changes the cost of",
            "{C:attention}all shop items{} and {C:attention}rerolls{} into {C:money}$#0#",
            "and makes all {C:attention}Jokers{}",
            "in the shop{C:dark_edition}Negative{}.",
        } -- need to implement rerolls bit
    }, 
    rarity = 4,
    atlas = 'Pokers',
    pos = {x = 4, y = 0},
    soul_pos = {x = 0, y = 1},
    cost = 300,
    blueprint_compat = false,
    loc_vars = function(self,info_queue,card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_negative
        return { vars = { card.ability.extra.percent }}
    end,
    config = { extra = { percent = 100 }},
       apply = function(self)
        G.GAME.starting_params.worldbox = true
    end,
    redeem = function(self, card)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.discount_percent = card.ability.extra.percent
                for _, j in pairs(G.I.CARD) do
                    if j.set_cost then j:set_cost() end
                end
                return true
            end
        }))
    end
}
        -- first attempt at making all negative stuff
        -- local is_in_shop = G.STATE == G.STATES.Shop --prob need to come back to this. Might need event manager.
        --     function ChangeDatShop() -- dont know if this works
        --         -- local card = -- figure out how to change shop prices here and make neg prob.
        --         card:set_edition('e_negative',true)
        --         -- card:add_to_deck()
        --         G.jokers:emplace(card) -- dont know what this does
            -- end
}

-- worldbox negative shop implementation
local pok_cardsetedition = Card.set_edition
function Card.set_edition(self, edition, immediate, silent)
    pok_cardsetedition(self,edition, immediate, silent)
    if G.GAME.starting_params.worldbox and self.ability.set == 'Joker' and (edition == nil or not edition.negative) then
        self:set_edition({negative = true})
    end
end

SMODS.Jokers{ -- john silksong
    key = 'silksong', -- if i could create a mashable button that increases amount of + mult that would be funny
    loc_txt = {
    name = 'Guarana!',
    text = {
        "Each played {C:attention}5{} or {C:attention}Ace{} played",
        "gives {C:mult}+#5# Mult and",
        "{C:chips}+#11#{} Chips when scored."
    },
    config = {extra = {mult = 5, chips = 11}},
    rarity = 1,
    atlas = 'Pokers',
    pos = {x = 3, y = 0},
    cost = 4,
    loc_vars = function(self,info_queue,card)
        return {vars = { card.ability.extra.mult}}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 5 or context.other_card:get_id() == 14 then
                return {
                    mult = card.ability.extra.mult,
                    chips = card.ability.extra.chips,
                    card = context.other_card,
                }
            end
        end
    end
}
}

SMODS.Jokers{ -- luffy
    key = 'Luffy',
    loc_txt = {
        name = 'Monkey D. Luffy',
        text = {
            "Decreases the cost of",
            "{C:attention}all items{} in the {C:attention}shop{}",
            "by {C:money}$#3#{} and gains {C:mult}Mult{}",
            "for each {C:money}${} saved.",
            "{C:inactive}(Currently {C:mult}#1#{C:inactive} Mult)"
            -- lowers the shop prices and adds for each dollar saved
        }
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    config = { extra = { mult = 3, mult_gain = 2, inflation = -2} },
    rarity = 3,
    pos = {x = 4, y = 0},
    cost = 10,
    loc_vars = function(self,info_queue,card)
        return { vars = {card.ability.extra.inflation, card.ability.extra.mult, card.ability.extra.mult_gain}}
    end,
    add_to_deck = function(self,card, from_debuff)
        G.GAME.inflation = G.GAME.inflation + card.ability.extra.inflation
            for l, v in pairs(G.I.CARD) do
                if v.set_cost then
                    v:set_cost()
                end
            end
        end,
    remove_from_deck = function(self,card, from_debuff)
        G.GAME.inflation = G.GAME.inflation - card.ability.extra.inflation
        for l, v in pairs(G.I.CARDS) do
            if v.set_cost then
                v:set_cost()
            end
        end
    end,
    calculate = function(self,card,context)
        if (context.buying_card or (context.open_booster and not context.card.from_tag)) and not context.blueprint and context.card ~= card then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            card_eval_status_text(card, 'extra', nil, nil, nil,
            {
                message = localize('k_upgrade_ex'), -- might need to change later (dk what the k is)
                colour = G.C.MULT
            }
        )
        end

        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Jokers{ -- big cat
    key = 'bigasscat', -- want to make it so its a randomly spawning funny kitty
    loc_text = {         -- might need to make it so funny kitty randomly triggers each round or something.^
        name = "Big Ass Cat",
        text = {
            "dude this guy is",
            "{C:attention,s:1.5}HUGE.{}",
            "{C:xmult}X#1#{} Mult"
        }
    },
    rarity = 2,
    pos = {x = 1, y = 1},
    cost = 15,
    display_size = {w = 71, l = 190},
    pixel_size = {w = 71, l = 190},
    config = {extra = {Xmult = 3}}
}

SMODS.Jokers{ --funny kitty token
    key = 'funnykitty',
    loc_txt = {
        name = 'Funny Kitty',
        text = {
            "This kitty doesn't",
            "do anything on it's own",
            'but it sure looks {C:attention}Cute :3{}'
        }
    },
    rarity = 1,
    pos =  {x = 3, y = 1},
    cost = 1,
    eternal_compat = false,
    perishable_compat = false,
    in_pool = function(self, args)
        return false
    end

    -- 	-- This searches G.GAME.pool_flags to see if Gros Michel went extinct. If so, no longer shows up in the shop.
	-- no_pool_flag = 'gros_michel_extinct2',
    -- need something like this to make sure thing doesn't show up in shop
    

--     if next(SMODS.find_card("j_modprefix_key")) then
--     -- only do something if you own a certain joker 
-- end  -- prob need this to check context for if have catastic.    
}

SMODS.Vouchers{ --generates 4 soul every 2 seconds, idk how to implement
    key = 'kingsoul', --every boss blind beaten, generate a soul card?
    pos = {x = 1, y = 0},
    config = { extra = { creates = 1}},
    loc_txt = {
    name = "Kingsoul",
    text = { "Creates a soul card after every boss blind beaten" }
    },
    redeem = function(self,card,context)
        if context.end_of_round and context.game_over == false and context.main_evail and context.beat_boss then
        local spectral_to_create = card.ability.extra.creates
        G.E_MANAGER:add_event(Event({
            func = function()
                for _ = 1, spectral_to_create do
                    SMODS.add_card("c_soul")
                end
                return true
            end
        }))
    end
end
}

SMODS.Voucher{ --could prevent cards from being debuffed 
    key = 'voidheart',
    requires = {"v_pokers_kingsoul"}, -- idk ill fix the prereq later (i just needed to add quotation marks oh my god bruh)
    pos = {x = 2, y = 0},
    config = {extra = {}},
    loc_txt = {
    name = "Voidheart",
    text = { "Prevents cards from being {C:attention}debuffed{}" }
    },
    redeem = function(self,card)
        G.E_MANAGER:add_event(Event({
            SMODS.current_mod.set_debuff == function(card)
                return 'prevent_debuff'
            end
        }))
    end
}

SMODS.Back{ --increase lucky card chances by 2 (i expect this to not work)
    key = 'luckykitty',
    pos = {x = 1, y = 0},
    unlocked = true,
    atlas = 'Pokers_Jokers',
    config = {},
    loc_txt = {
    name = "Lucky Cyat Deck",
    text = { "Increase all probabilities by 2X" }
    },
    loc_vars = function(self,info_queue,back)
        return {
            func = function(self,card, context)
                if context.mod_probability and not context.blueprint then
                    return {
                        numerator = context.numerator*2
                    }
                end
            end
        }
    end
}

SMODS.Back{ --start with worldbox joker
    key = 'godmode',
    pos = {x = 2, y = 0},
    atlas = 'Pokers_Jokers',
    config = { joker = 'c_pokers_worldbox' },
    loc_txt = {
    name = "Godmode Deck",
    text = { "Start with the {C:attention}Worldbox Joker{}" }
    },
    loc_vars = function(self,info_queue,back)
        return { 
                vars = { localize { type = 'name_text', key = self.config.joker, set = 'Joker'}
        }
    }
end
}

SMODS.Back{ -- start with a big kitty
    key = 'bigkitty',
    pos = {x = 1, y = 1},    
    atlas = 'Pokers_Jokers',
    config = { joker = 'c_pokers_bigasscat' },
    loc_txt = {
    name = "Bigasscat Deck",
    text = { "Start with the {C:attention}Bigasscat Joker{}" }
    },
    loc_vars = function(self,info_queue,back)
        return { 
                vars = { localize { type = 'name_text', key = self.config.joker, set = 'Joker'}
        }
    }
end
}

SMODS.Back{ --start with kingsoul voucher
    key = 'kingback',
    pos = {x = 1, y = 2},
    atlas = 'Pokers_Jokers',
    config = { voucher = 'c_pokers_kingsoul' },
    loc_txt = {
    name = "Kingsoul Deck",
    text = { "Start with the {C:attention}Kingsoul Voucher{}" }
    },
    loc_vars = function(self,info_queue,back)
        return { 
                vars = { localize { type = 'name_text', key = self.config.voucher, set = 'Voucher'}
        }
    }
end
}

SMODS.Edition({ --x2 mult edition
    key = 'gear_thado',
    loc_txt = {
        name = "Gear Third",
        label = "Gear Third",
        text = {
            "{C:Xmult}X#2#{} Mult upon scoring this card."
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'gear_thado', --need to create the shader (done)
    config = { Xmult = 2},
    in_shop = true,
    weight = 8, -- check what this does
    extra_cost = 4,
    apply_to_float = true,
    loc_vars = function(self)
        return {}
    end
})

SMODS.Edition({ --retrigger edition
    key = 'gear_secando',
    loc_txt = {
        name = "Gear Second",
        label = "Gear Second",
        text = {
            "{C:green}Retrigger{} this card"
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'gear_secando', --need to create the shader (done)
    config = { repetitions = 1},
    in_shop = true,
    weight = 5, -- check what this does (it changes the frequency of its appearance, lower weight equals less chance of appearing)
    extra_cost = 4,
    apply_to_float = true,
    loc_vars = function(self)
        return {}
    end
})

SMODS.Seals{ --be foil, holographic, AND polychrome/ be gear second and third?)
    key = 'Mugiwara',
    atlas = "seal_atlas",
    pos = { x = 1, y = 0 },
    config = { extra = { retriggers = 1, x_mult = 2}},
    badge_colour = HEX("efef2b"),
    loc_txt = {
        label = 'Mugiwara Seal',
        name = 'Mugiwara Seal',
        text = {
            '{C:attention}+#1#{} Retriggers',
            '{X:mult,C:white}X#2#{} Mult',
        }
    },
    loc_vars = function(self,info_queue)
        return { vars = {self.config.retriggers, self.config.x_mult}}
    end,
    calculate = function(self,card,context)
        if context.repetition then
            return { repetitions = self.config.retriggers, }
        end
        if context.main_scoring and context.cardarea == G.Play then
            return {x_mult = self.config.x_mult}
        end
    end
}

