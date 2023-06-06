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
	desc = "A crown worn by only the highest emperors of <s>the land</s> space. Supremely polished, despite being made of gold it's a better mirror than anything you've ever seen! The jewel in the middle shines strangely in the light.."
	icon_state = "fancycrown"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/reflect_probability = 50
	var/datum/action/cooldown/spell/pointed/dominate/crown/sway_power = new(src)

/obj/item/clothing/head/costume/crown/fancy/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HEAD)
		sway_power.Grant(user)

/obj/item/clothing/head/costume/crown/fancy/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_HEAD) == src)
		sway_power.Remove(user)

/obj/item/clothing/head/costume/crown/fancy/IsReflect(def_zone)
	if(def_zone != BODY_ZONE_HEAD) // The crown has been polished to PERFECTION.
		return FALSE
	if (prob(hit_reflect_chance))
		return TRUE

/datum/armor/royal_crown
	melee = 10
	bullet = 15
	laser = 80
	energy = 80
	bomb = 100
	fire = 100
	acid = 100

// Gloves: Very fancy gloves that are insulated?, Grant Fencing martial arts to the user if wielding an appropriate blade.
// Fencing: Buffs block chances, adds krav maga like 'Stance' buttons, defensive to absorb and parry hits, offensive reduces attack cooldown, thrusting slows down but lets you attack from two tiles.

/obj/item/clothing/gloves/plate/royal_gauntlets
	name = "royal bejeweled gauntlets"
	icon_state = "crusader"
	desc = "Royal gauntlets with embedded microchips that grant the user the knowledge to do Fencing. Can't spend time learning fencing when you're busy with your princely duties!"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/datum/martial_art/fencing/style = new

/obj/item/clothing/gloves/plate/royal_gauntlets/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_GLOVES)
		style.teach(user, TRUE)

/obj/item/clothing/gloves/plate/royal_gauntlets/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		style.remove(user)

// Boots: Baton knockdown immunity, can act as magboots with a bit less slowdown, maaaaaybe dash abil

/obj/item/clothing/shoes/magboots/royal_magboots
	name = "royal mag-sabatons"
	desc = "The design for these sabatons was gifted to the Royal Family by Nanotrasen as a sign of good relations. Just as protective as normal sabatons, while also being able to be activated for zero-grav movement, alongside the ability to mantain posture if attacked by batons."
	icon_state = "crusader"
	armor_type = /datum/armor/shoes_plate
	strip_delay = 10 SECONDS
	equip_delay_other = 10 SECONDS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	// They slow you down...
	slowdown = SHOES_SLOWDOWN + 0.25
	// But overall active slowdown isn't *too* bad.
	slowdown_active = 0.25
	// And in exchange, noslip and baton resistance.
	active_traits = list(TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE, TRAIT_NEGATES_GRAVITY, TRAIT_BATON_RESISTANCE)
	// Overall useful as something to keep you alive, not to murderbone.

/datum/armor/shoes_plate
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 60
	fire = 60
	acid = 60

// Uniform has CM webbing pockets.

/obj/item/clothing/under/royal_attire
	name = "royal prince's attire"
	desc = "A mastercrafted set of clothing with impeccable, majestuous jewels embedded and golden silk-threads spanning its whole thread. It even contains an extra set of pockets!"
	icon_state = "captain_parade"
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	icon = 'icons/obj/clothing/under/captain.dmi'
	worn_icon = 'icons/mob/clothing/under/captain.dmi'
	armor_type = /datum/armor/royal_attire
	resistance_flags = FIRE_PROOF | ACID_PROOF

/datum/armor/royal_attire
	bio = 10
	wound = 10

/obj/item/clothing/under/royal_attire/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets)

// Has slightly altered chaplain crusader armor. Minor slowdown, but hardy.

/obj/item/clothing/suit/armor/riot/knight/prince
	name = "prince's own armor"
	desc = "A very fancy suit of plate armor. A little encumbering, but surprisingly resistant to damage."
	icon_state = "knight_green"
	inhand_icon_state = null
	allowed = list(
		/obj/item/banner,
		/obj/item/tank/internals/emergency_oxygen,
		)
	slowdown = 0.25
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor_type = /datum/armor/prince_armor

/datum/armor/prince_armor
	melee = 50
	bullet = 40
	laser = 50
	energy = 50
	fire = 100
	acid = 100
	wound = 20

// Reskinned captain sabre, real sabre is altered so its implied it was given to him by a visiting noble. (Or stolen)
// Ability to knight others, which adds Knight to their name and gives them minor combat buffs and airdropped gear (buckler, claymore, plate armor) at the cost of a massive mood penalty if away from their liege.
// Can if willing summon a servant as a ghostrole, servants are very weak... Somehow but, well, serve the royal

/datum/outfit/superweapon
	name = "Nanotrasen Superweapon"

	uniform = /obj/item/clothing/under/color/white
	shoes = /obj/item/clothing/shoes/sneakers/white

