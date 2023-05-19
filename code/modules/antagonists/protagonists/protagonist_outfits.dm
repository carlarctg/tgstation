/datum/outfit/royal_prince
	name = "Royal Prince"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/plate/red
	suit = /obj/item/clothing/suit/armor/riot/knight/red
	gloves = /obj/item/clothing/gloves/plate/red
	head = /obj/item/clothing/head/costume/crown/fancy
	r_hand = /obj/item/claymore/weak/prince
	back = /obj/item/shield/buckler

// Royal Prince VIP
// Design: Very lootable, cannot really powergame with his own loot, but can reasonably defend himself with it. Objective to keep his own loot until roundend.
// All clothing resists any damage, though it does not make the wearer xproof.
// Crown: Can psychically sway basic and simple mobs to his side, temporarily? if hostile. Cool beam effect. Chance to deflect lasers aimed at the head (very shiny), maybe mini voice of god

/obj/item/clothing/head/costume/crown/fancy
	name = "magnificent crown"
	desc = "A crown worn by only the highest emperors of the <s>land</s> space."
	icon_state = "fancycrown"

// Gloves: Very fancy gloves that are insulated?, Grant Fencing martial arts to the user if wielding an appropriate blade.
// Fencing: Buffs block chances, adds krav maga like 'Stance' buttons, defensive to absorb and parry hits, offensive reduces attack cooldown, thrusting slows down but lets you attack from two tiles.

/obj/item/clothing/gloves/plate
	name = "Plate Gauntlets"
	icon_state = "crusader"
	desc = "They're like gloves, but made of metal."
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT

// Boots: Baton knockdown immunity, can act as magboots with a bit less slowdown, maaaaaybe dash abil

/obj/item/clothing/shoes/plate
	name = "Plate Boots"
	desc = "Metal boots, they look heavy."
	icon_state = "crusader"
	armor_type = /datum/armor/shoes_plate
	clothing_traits = list(TRAIT_NO_SLIP_WATER)
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/datum/armor/shoes_plate
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 60
	fire = 60
	acid = 60

// Uniform has CM webbing pockets.

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	greyscale_colors = "#eb0c07"

// Has slightly altered chaplain crusader armor. Minor slowdown, but hardy.

/obj/item/clothing/suit/armor/riot/knight
	name = "plate armour"
	desc = "A classic suit of plate armour, highly effective at stopping melee attacks."
	icon_state = "knight_green"
	inhand_icon_state = null
	allowed = list(
		/obj/item/banner,
		/obj/item/claymore,
		/obj/item/nullrod,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		)

// Reskinned captain sabre, real sabre is altered so its implied it was given to him by a visiting noble. (Or stolen)
// Ability to knight others, which adds Knight to their name and gives them minor combat buffs and airdropped gear (buckler, claymore, plate armor) at the cost of a massive mood penalty if away from their liege.
// Can if willing summon a servant as a ghostrole, servants are very weak... Somehow but, well, serve the royal

/datum/outfit/superweapon
	name = "Nanotrasen Superweapon"

	uniform = /obj/item/clothing/under/color/white
	shoes = /obj/item/clothing/shoes/sneakers/white

