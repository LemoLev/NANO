--- STEAMODDED HEADER
--- MOD_NAME: Nano Jokers
--- MOD_ID: NANO_J
--- MOD_AUTHOR: [ShadowLev]
--- MOD_DESCRIPTION: Adds nerdy nano Jokers.
--- PREFIX: nanoj
----------------------------------------------
------------MOD CODE -------------------------
function get_self_index(find, from)
	local ind = nil
	for i = 1, #from do
		if from[i] == find then
			ind = i
		end
	end
	if not ind then
		print('Card not found')
	end
	return ind
end
function get_highlighted(areas, ignore, min, max, blacklist, seed)
	ignore.checked = true
	blacklist = blacklist or function()
		return true
	end
	local cards = {}
	for i, area in pairs(areas) do
		if area.cards then
			for i2, card in pairs(area.cards) do
				if
					card ~= ignore
					and blacklist(card)
					and card.highlighted
					and not card.checked
				then
					cards[#cards + 1] = card
					card.checked = true
				end
			end
		end
	end
	for i, v in ipairs(cards) do
		v.checked = nil
	end
	if #cards >= min and #cards <= max then
		ignore.checked = nil
		return cards
	else
		for i, v in pairs(cards) do
			v.f_use_order = i
		end
		pseudoshuffle(cards, pseudoseed("forcehighlight" or seed))
		local actual = {}
		for i = 1, max do
			if cards[i] and not cards[i].checked and actual ~= ignore then
				actual[#actual + 1] = cards[i]
			end
		end
		table.sort(actual, function(a, b)
			return a.f_use_order < b.f_use_order
		end)
		for i, v in pairs(cards) do
			v.f_use_order = nil
		end
		ignore.checked = nil
		return actual
	end
	return {}
end

function choose_random(source_arr, seed)
	return source_arr[math.ceil(pseudorandom(seed)*#source_arr)]
end

function done_with_NANO(ctd)
	SMODS.destroy_cards(ctd)
	local aval_jokers = {
		"j_nanoj_arnano",
		"j_nanoj_persfm",
		"j_nanoj_fire_dpt"
	}
	local nano_jok = create_card("Joker", G.jokers, nil, nil, nil, nil, choose_random(aval_jokers, 'nowspellNANO'))
	nano_jok:add_to_deck()
	G.jokers:emplace(nano_jok)
end
-- Jokers atlas
SMODS.Atlas{
	key = 'Jokers',
	path = 'Jokers.png',
	px = 71,
	py = 95
}
-- Tarots atlas
SMODS.Atlas{
	key = 'Tarots',
	path = 'Tarots.png',
	px = 71,
	py = 95
}
-- Letters atlas
SMODS.Atlas{
	key = 'Letters',
	path = 'Letters.png',
	px = 9,
	py = 14
}
-- Smoking (shader)
SMODS.Shader{
	key = 'smoking',
	path = 'smoking.fs'
}
-- Burnt (shader)
SMODS.Shader{
	key = 'burnt',
	path = 'burnt.fs'
}
-- Explosion
SMODS.Sound{
	key = 'explosion',
	path = 'explosion.ogg',
	volume = 1.5
}
-- N (Sound)
SMODS.Sound{
	key = 'snd_n',
	path = 'snd_n.ogg'
}
-- N2 (Sound)
SMODS.Sound{
	key = 'snd_n2',
	path = 'snd_n.ogg'
}
-- A (Sound)
SMODS.Sound{
	key = 'snd_a',
	path = 'snd_a.ogg'
}
-- O (Sound)
SMODS.Sound{
	key = 'snd_o',
	path = 'snd_o.ogg'
}
-- Extinguisher Sound Effect
SMODS.Sound{
	key = 'exting',
	path = 'ext_sfx.ogg',
	volume = 0.8
}
-- Short circuit
SMODS.Sound{
	key = 'short_circuit',
	path = 'short_circuit.ogg',
	pitch = 1.3
}
-- Fire whoosh
SMODS.Sound{
	key = 'fire',
	path = 'fire.ogg'
}
-- Match
SMODS.Consumable{
	key = 'match',
	atlas = 'Tarots',
	pos = {x = 1, y = 0},
	set = 'Spectral',
	loc_txt = {
		name = 'Match',
		text = {
			'When used, make the selected {C:attention}Joker{} {C:red}burnt{}'
		}
	},
	config = {
		cardLimit = 0
	},
	use = function(self, card, area, copier)
		local highlighted = get_highlighted({ G.jokers }, card, 1, 1, function(card)
			return card.ability.set == "Joker"
		end)
		for i = 1, #highlighted do
			highlighted[i]:set_edition('e_nanoj_burnt', true, false)
		end
	end,
	can_use = function(self, card)
		local highlighted = get_highlighted({ G.jokers }, card, 1, 1, function(card)
			return card.ability.set == "Joker"
		end)
		return #highlighted > self.config.cardLimit
	end
}
-- Extinguisher
SMODS.Consumable{
	key = 'exting',
	atlas = 'Tarots',
	pos = {x = 0, y = 0},
	set = 'Spectral',
	loc_txt = {
		name = 'Extinguisher',
		text = {
			'When used, extinguish a {C:red}Burnt{} card',
			'without any sacrifice',
			'{C:inactive,s:0.6}(well, except for this card){}'
		}
	},
	use = function(self, card, area, copier)
		local highlighted = get_highlighted({ G.jokers }, card, 1, 1, function(card)
			return card.ability.set == "Joker"
		end)
		for i = 1, #highlighted do
			if not (highlighted[i] == self) then
				if highlighted[i].edition and highlighted[i].edition.key == 'e_nanoj_burnt' then
					highlighted[i]:set_edition(nil, true, false)
				end
			end
		end
	end,
	can_use = function(self, card)
		local highlighted = get_highlighted({ G.jokers }, card, 1, 1, function(card)
			return card.ability.set == "Joker"
		end)
		return #highlighted == 1
	end
}
-- Burnt (Edition)
SMODS.Edition{
	key = 'burnt',
	shader = 'burnt',
	loc_txt = {
		name = 'Burnt',
		label = 'Burnt',
		text = {
			'{C:mult}+#1#{} mult, after',
			'{C:attention}#2#{} hand(s) played,', 
			'destroy a random joker',
			'and extinguish itself'
		}
	},
	loc_vars = function(self, info_queue, center)
		return {vars = {
			center.edition.mult,
			center.edition.handsLeft
		} }
	end,
	config = {
		mult = 15,
		handsLeft = 5
	},
	badge_colour = G.C.RED,
	sound = { sound = "nanoj_fire", per = 1.0 + math.random(1, 10)*0.05-0.25, vol = 0.6 },
	calculate = function(self, card, context)
		if context.before then
			card.edition.handsLeft = card.edition.handsLeft - 1
			if card.edition.handsLeft <= 0 then
				local burnt_ext_list = {}
				for c = 1, #G.jokers.cards do
					if not (G.jokers.cards[i] == card) then
						burnt_ext_list[c] = G.jokers.cards[c]
					end
				end
				SMODS.destroy_cards(choose_random(burnt_ext_list, 'burnt_ext'))
				card:set_edition(nil, true, false)
			end
			return { message = "-1", colour = G.C.BLUE } -- updated value
		end

		if context.pre_joker then
			return { mult = card.edition.mult }
		end
	end
}
-- Smoking (Edition)
SMODS.Edition{
	key = 'smoking',
	atlas = 'Jokers',
	pos = {x = 0, y = 0},
	shader = 'smoking',
	loc_txt = {
		name = 'Smoking',
		label = 'Smoking',
		text = {
			'{X:mult,C:white}X#1#{} Mult every 9 frames.',
			'Appliable only to {B:1,C:white}Arduino NANO{}'
		}
	},
	loc_vars = function(self, info_queue, center)
		return {vars = {
			self.config.x_mult, 
			colours = {G.C.BLUE}
		} }
	end,
	config = {
		x_mult = -0.01
	},
	disable_base_shader = true,
	badge_colour = G.C.GREY,
	sound = { sound = 'nanoj_short_circuit' }
}
-- Script variables
frameCounter = 0
blindCounter = 0
-- Arduino NANO
SMODS.Joker{
	key = 'arnano',
	loc_txt = {
		name = 'Arduino NANO',
		text = {
			'{X:mult,C:white}X#1#{} Mult.',
			'After each hand played,',
			'{C:green}#2# in #3#{} chance', 
			'to start {C:attention}Smoking{}'
		}
	},
	unlocked = true, --where it is unlocked or not: if true, 
    discovered = true, --whether or not it starts discovered,
	atlas = 'Jokers',
	pos = {x = 0, y = 0},
	rarity = 1,
	cost = -2,
	blueprint_compat = true,
	config = {
		extra = {
			Xmult = 9,
			odds = 9,
			smoking = false
		}
	},
	loc_vars = function(self,info_queue,center)
		local num, den = SMODS.get_probability_vars(card, G.GAME.probabilities.normal, center.ability.extra.odds, 'arnano_smoke')
		return {
			vars = {
				center.ability.extra.Xmult,
				num,
				den,
				center.ability.extra.smoking,
				colours = {
					{0.8, 0.8, 0.8, 1},
					G.C.BLUE
				}
			}
		}
	end,
	calculate = function(self, card, context)
		if context.before then
			if card.ability.cry_rigged or pseudorandom('arduino_smoke') < G.GAME.probabilities.normal/card.ability.extra.odds then
				card:set_edition('e_nanoj_smoking', true, false)
				card.ability.extra.smoking = true
				return {
					message_card = card,
					message = "MY NANO!"
				}
			else
				return {
					message_card = card,
					message = "Safe!"
				}
			end
		end

		if context.joker_main then
			return {
				card = card,
				xmult = card.ability.extra.Xmult
			}
		end

		if context.setting_blind and card.edition and card.edition.key == 'e_nanoj_smoking' then
			blindCounter = blindCounter + 1
			if blindCounter >= 2 then
				local other_joker = nil
				local other_joker2 = nil
				for i = 1, #G.jokers.cards do
					if G.jokers.cards[i] == card then 
						other_joker = G.jokers.cards[i+1] 
						other_joker2 = G.jokers.cards[i-1]
					end
				end
				if other_joker then
					other_joker:set_edition('e_nanoj_burnt', true, false);
				end
				if other_joker2 then
					other_joker2:set_edition('e_nanoj_burnt', true, false);
				end
				SMODS.destroy_cards(card)
				return {
					message = 'BOOM!!',
					message_card = card,
					sound = 'nanoj_explosion'
				}
			end
		end
	end,
	update = function(self, card, dt)
		if card.edition and card.edition.key == "e_nanoj_smoking" then
			frameCounter = frameCounter + 1
			if frameCounter >= 9 then
				card.ability.extra.Xmult = card.ability.extra.Xmult + card.edition.x_mult
				frameCounter = 0
			end
		end
	end
}

-- Personal Fireman
SMODS.Joker{
	key = 'persfm',
	atlas = 'Jokers',
	loc_txt = {
		name = 'Personal Fireman',
		text = {
			'After each hand played,',
			'this {C:attention}Joker{} saves', 
			'the {C:attention}Joker{} to the left',
			'{C:inactive}(and itself){}',
			'from burning or smoking',
			'and gives {C:mult}+#1#{} mult when done'
		}
	},
	config = {
		extraMult = 2
	},
	loc_vars = function(self, info_queue, center)
		return { 
			vars = {
				center.ability.extraMult 
			}
		}
	end,
	pos = { x = 1, y = 0 },
	rarity = 1,
	calculate = function(self, card, context)
		if context.final_scoring_step then
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i] == card then
					if not G.jokers.cards[i-1] then return { mult = card.ability.extraMult } end
					if G.jokers.cards[i-1].edition and (G.jokers.cards[i-1].edition.key == 'e_nanoj_burnt' or G.jokers.cards[i-1].edition.key == 'e_nanoj_smoking') then
						G.jokers.cards[i-1]:set_edition(nil, true, false)
						return {
							message = "Extinguished!",
							message_card = G.jokers.cards[i],
							mult = card.ability.extraMult,
							sound = "nanoj_exting"
						}
					end
					if G.jokers.cards[i].edition and (G.jokers.cards[i].edition.key == 'e_nanoj_burnt' or G.jokers.cards[i].edition.key == 'e_nanoj_smoking') then
						G.jokers.cards[i]:set_edition(nil, true, false)
						return {
							message = "Extinguished!",
							mult = card.ability.extraMult,
							sound = "nanoj_exting"
						}
					end
				end
			end
		end
	end
}

-- Fire Department
SMODS.Joker{
	key = 'fire_dpt',
	atlas = 'Jokers',
	pos = {x = 2, y = 0},
	rarity = 2,
	config = {
		extraMult = 4
	},
	loc_vars = function(self, info_queue, center)
		return {
			vars = {
				center.ability.extraMult
			}
		}
	end,
	loc_txt = {
		name = 'Fire Department',
		text = {
			'After each hand played,',
			'Saves all {C:attention}Jokers{} held in hand',
			'from burning or smoking,',
			'and gives +#1# mult when done.',
			'Becomes {C:dark_edition}Eternal{} after',
			'the first extinguish'
		}
	},
	calculate = function(self, card, context)
		if context.final_scoring_step then
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i].edition and (G.jokers.cards[i].edition.key == 'e_nanoj_burnt' or G.jokers.cards[i].edition.key == 'e_nanoj_smoking') then
					G.jokers.cards[i]:set_edition(nil, true, false)
					if not card.ability.eternal then
						card:set_eternal(true)
					end
					return {
						message = "Extinguished!",
						message_card = G.jokers.cards[i],
						mult = card.ability.extraMult,
						sound = "nanoj_exting"
					}
				end
			end
		end
	end
}
-- N (Joker)
SMODS.Joker{
	key = 'lett_n',
	atlas = 'Letters',
	pos = { x = 0, y = 0},
	config = {
		mult = 4,
		i_am = 'N'
	},
	loc_vars = function(self, info_queue, center)
		return {
			vars = {
				center.ability.mult
			}
		}
	end,
	loc_txt = {
		name = 'N',
		text = {
			'{C:mult}+#1#{} mult.',
			'One of the letters to spell {C:attention}"NANO"{}',
			'Spell it correctly,',
			'and get a random {C:blue}NANO Joker{}!',
			'{C:inactive}(Checks happen after each',
			'{C:inactive}hand played){}'
		}
	},
	rarity = 2,
	calculate = function(self, card, context)
		if context.before then
			local prev_card = G.jokers.cards[get_self_index(card, G.jokers.cards)-1]
			if prev_card and prev_card.ability.i_am == 'A' and prev_card.ability.has_before then
				card.ability.has_before = true
				return {
					message = 'N!',
					message_card = card,
					sound = 'nanoj_snd_n',
					mult = card.ability.mult,
				}
			else
				if G.jokers.cards[get_self_index(card, G.jokers.cards)+1].ability.i_am == 'A' then
					return {
						message = 'N!',
						message_card = card,
						sound = 'nanoj_snd_n',
						mult = card.ability.mult,
					}
				else
					return {
						message = 'Not yet!',
						message_card = card,
						sound = 'glass3',
						mult = card.ability.mult,
					}
				end
			end
		end
	end
}

-- A (Joker)
SMODS.Joker{
	key = 'lett_a',
	atlas = 'Letters',
	pos = { x = 0, y = 1},
	config = {
		mult = 4,
		i_am = 'A'
	},
	loc_vars = function(self, info_queue, center)
		return {
			vars = {
				center.ability.mult
			}
		}
	end,
	loc_txt = {
		name = 'A',
		text = {
			'{C:mult}+#1#{} mult.',
			'One of the letters to spell {C:attention}"NANO"{}',
			'Spell it correctly,',
			'and get a random {C:blue}NANO Joker{}!',
			'{C:inactive}(Checks happen after each',
			'{C:inactive}hand played){}'
		}
	},
	rarity = 2,
	calculate = function(self, card, context)
		if context.before then
			local prev_card = G.jokers.cards[get_self_index(card, G.jokers.cards)-1]

			if prev_card.ability.i_am == 'N' and (not prev_card.ability.has_before) then
				card.ability.has_before = true
				return {
					message = 'A!',
					message_card = card,
					sound = 'nanoj_snd_a',
					mult = card.ability.mult,
				}
			else 
				print(prev_card.ability.i_am)
				print(not prev_card.ability.has_before)
				return {
					message = 'Not yet!',
					message_card = card,
					sound = 'glass3',
					mult = card.ability.mult,
				}
			end
		end
	end
}
-- O (Joker)
SMODS.Joker{
	key = 'lett_o',
	atlas = 'Letters',
	pos = { x = 0, y = 3},
	config = {
		mult = 4
	},
	loc_vars = function(self, info_queue, center)
		return {
			vars = {
				center.ability.mult
			}
		}
	end,
	loc_txt = {
		name = 'O',
		text = {
			'{C:mult}+#1#{} mult.',
			'One of the letters to spell {C:attention}"NANO"{}',
			'Spell it correctly,',
			'and get a random {C:blue}NANO Joker{}!',
			'{C:inactive}(Checks happen after each',
			'{C:inactive}hand played){}'
		}
	},
	rarity = 2,
	calculate = function(self, card, context)
		if context.before then
			local prev_card = G.jokers.cards[get_self_index(card, G.jokers.cards)-1]

			if prev_card.ability.i_am == 'N' and prev_card.ability.has_before then
				card.ability.has_before = true
				done_with_NANO({
					G.jokers.cards[get_self_index(card, G.jokers.cards)-3],
					G.jokers.cards[get_self_index(card, G.jokers.cards)-2],
					G.jokers.cards[get_self_index(card, G.jokers.cards)-1],
					G.jokers.cards[get_self_index(card, G.jokers.cards)]
				})
				return {
					message = 'O!',
					message_card = card,
					sound = 'nanoj_snd_o',
					mult = card.ability.mult,
				}
			else 
				return {
					message = 'Not yet!',
					message_card = card,
					sound = 'glass3',
					mult = card.ability.mult,
				}
			end
		end
	end
}

----------------------------------------------
------------MOD CODE END----------------------