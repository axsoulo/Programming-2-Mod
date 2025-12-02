SMODS.Atlas{
    key = 'Pokers', -- might need to add this later to all the everything as a tag ig
    path = 'Jokers.png',
    px = 71,
    py = 95
}

SMODS.Jokers{
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
    config = {extra = { Xmult = 1, }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult, 
        1 + card.ability.extra.Xmult*funnykittyamount}},
        -- need to figure out how to define these x amount of jokers.
    end,
    calculate = function(self,card, context)

        -- if context.other_card/how df do i create more kitty
        if context.setting_blind then 
            return {
                -- here is where i would put my kitty spawning logic... if i had one!!
        }
    end
        
        if context.joker_main then
            return {
                Xmult_mod = card.ability.extra.Xmult,
                message = localize { type = 'variable', key = 'a_xmult', vars = {card.ability.extra.xmult} }
            }
        end
        card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
        return {
            message = '+1 Kitty!',
            colour = G.C.XMULT,
            card = card
        }
    end
}

SMODS.Jokers{
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
    pos =  {x = 2, y = 0},
    cost = 1,
    eternal_compat = false,

    -- 	-- This searches G.GAME.pool_flags to see if Gros Michel went extinct. If so, no longer shows up in the shop.
	-- no_pool_flag = 'gros_michel_extinct2',
    -- need something like this to make sure thing doesn't show up in shop

}

SMODS.Jokers{
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
        return {vars = { card.ability.extra.mult, card.abillity.extra.mult}}
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
},

SMODS.Jokers{
    key = 'worldbox',
    loc_txt = {
        name = 'God Mode',
        text = {
            "Changes the cost of",
            "{C:attention}all shop items{} and {C:attention}rerolls{} into {C:money}$#0#",
            "and makes all {C:attention}Jokers{}",
            "in the shop{C:dark_edition}Negative{}.",
        }
    },
    rarity = 4,
    atlas = 'Pokers',
    pos = {x = 4, y = 0},
    soul_pos = {x = 0, y = 1},
    cost = 300,
    blueprint_compat = false,
    loc_vars = function(self,info_queue,card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_negative
    end,
    calculate = function(self,card,context)
        if context.shop then --prob need to come back to this. Might need event manager.
            function ChangeDatShop() -- dont know if this works
                local card = -- figure out how to change shop prices here and make neg prob.
                card:set_edition('e_negative',true)
                card:add_to_deck()
                G.jokers:emplace(card)
            end
        end
    end
},

SMODS.Jokers{
    key = 'Luffy',
    loc_txt = {
        name = 'Monkey D. Luffy',
        text = {
            "Decreases the cost of",
            "{C:attention}all items{} in the {C:attention}shop{}",
            "by {C:money}$#2#{} and gains {C:mult}Mult{}",
            "for each {C:money}${} saved.",
            "{C:inactive}(Currently {C:mult}#0#{C:inactive} Mult)"
            -- lowers the shop prices and adds for each dollar saved
        }
    },
    rarity = 3,
    pos = {x = 1, y = 1},
    cost = 10,
    loc_vars = function(self,info_queue,card)
        -- return { vars = {}}
    end
},

SMODS.Jokers{
    key = 'big_ass_cat', -- want to make it so its a randomly spawning funny kitty
    loc_text = {         -- might need to make it so funny kitty randomly triggers each round or something.^
        name = "Big Ass Cat",
        text = {
            "dude this guy is",
            "{C:attention,s:1.5}HUGE.{}",
            "{C:xmult}X#3#{} Mult"
        }
    },
    rarity = 2,
    pos = {x = 2, y = 1},
    cost = 15,
    display_size = {w = 71, l = 190},
    pixel_size = {w = 71, l = 190},
    config = {extra = {Xmult = 3}}
},

SMODS.Vouchers{ --generates 4 soul every 2 seconds, idk how to implement
    key = 'kingsoul'
},

SMODS.Voucher{ --could prevent cards from being debuffed 
    key = 'voidheart',
    requires = {v_pokers_kingsoul}, -- idk ill fix the prereq later 
},

SMODS.Decks{ --increase lucky card chances by .25x
    key = 'luckykitty'
},

SMODS.Decks{ --start with worldbox joker
    key = 'godmode'
},

SMODS.Edition({
    key = 'gear_secando',
    loc_txt = {
        name = "Gear Second",
        label = "Gear Second",
        text = {
            "{C:Xmult}X#2#{} Mult upon scoring this card."
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'gear_secando', --need to create the shader
    config = { Xmult = 2},
    in_shop = true,
    weight = 8, -- check what this does
    extra_cost = 4,
    apply_to_float = true,
    loc_vars = function(self)
        return {}
    end
}),

SMODS.Edition({
    key = 'gear_thado',
    loc_txt = {
        name = "Gear Third",
        label = "Gear Third",
        text = {
            "{C:green}Retrigger{} this card"
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'gear_thado', --need to create the shader
    config = { repetitions = 1},
    in_shop = true,
    weight = 8, -- check what this does
    extra_cost = 4,
    apply_to_float = true,
    loc_vars = function(self)
        return {}
    end
}),

SMODS.Seals{ --be foil, holographic, AND polychrome/ be gear second and third?)
    key = 'mugiwaraseal'
},

