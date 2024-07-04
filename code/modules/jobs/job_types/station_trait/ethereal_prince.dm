
/datum/job/ethereal_prince
	title = JOB_ETHEREAL_PRINCE
	description = "Make sure your presence is treated with the pomp and dignity it requires. Partake in the delights of being an esteemed guest of the station."
	department_head = list(null)
	faction = FACTION_STATION
	total_positions = 0
	spawn_positions = 0
	supervisors = "the Captain, maybe"
	minimal_player_age = 7
	config_tag = "ETHEREAL_PRINCE"

	outfit = /datum/outfit/job/ethereal_prince
	// no plasmaman outfit...

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_CIV

	liver_traits = list(TRAIT_ROYAL_METABOLISM)

//	display_order = JOB_DISPLAY_ORDER_NANOTRASEN_SUPERWEAPON
	departments_list = list(/datum/job_department/command)

//	family_heirlooms = list(/obj/item/banner/command/mundane)

//	mail_goodies = list(
//		/obj/item/storage/fancy/cigarettes = 1,
//		/obj/item/pen/fountain = 1,
//	)
	rpg_title = "Pompous Prince"
	allow_bureaucratic_error = FALSE
	job_flags = STATION_JOB_FLAGS | STATION_TRAIT_JOB_FLAGS
	ignore_human_authority = TRUE // well. yeah
	voice_of_god_power = 5 // LITERALLY has god's divine mandate
	random_spawns_possible = TRUE

/datum/job/ethereal_prince/after_spawn(mob/living/spawned, client/player_client)
	. = ..()

	spawned.dna.features["ethcolor"] = pick(GLOB.color_list_ethereal)
	spawned.set_species(/datum/species/ethereal)

//	ADD_TRAIT(spawned, TRAIT_NO_TWOHANDING, JOB_TRAIT)

/datum/job/ethereal_prince/get_roundstart_spawn_point()
	var/list/pompous_turfs = list()
	var/list/possible_turfs = list()
	var/area/bridge = GLOB.areas_by_type[/area/station/command/bridge]
	if(isnull(bridge))
		return ..() //if no bridge, spawn on the arrivals shuttle (but also what the fuck)
	for (var/list/zlevel_turfs as anything in bridge.get_zlevel_turf_lists())
		for (var/turf/possible_turf as anything in zlevel_turfs)
			if(possible_turf.is_blocked_turf())
				continue
			if(locate(/obj/machinery/computer/communications) in range(1, possible_turf))
				pompous_turfs += possible_turf
				continue
			possible_turfs += possible_turf
	if(length(pompous_turfs))
		return pick(pompous_turfs)
	if(length(possible_turfs))
		return pick(possible_turfs) //if none, just pick a random turf in the bridge
	return ..() //if the bridge has no turfs, spawn on the arrivals shuttle

/datum/outfit/job/ethereal_prince
	name = "Ethereal Prince"
	jobtype = /datum/job/ethereal_prince

	id_trim = /datum/id_trim/job/ethereal_prince
	backpack_contents = list()

	uniform = //obj/item/clothing/under/royal_attire
	neck = //obj/item/clothing/neck/cape/royal_cape
	belt = //obj/item/clothing/belt/sabre/prince
	ears = //obj/item/radio/headset/headset_command
	glasses = null
	gloves = //obj/item/
	head = null
	shoes = /obj/item/clothing/shoes/sneakers/white
	l_pocket = /obj/item/modular_computer/pda/clear
	r_pocket = /obj/item/assembly/flash/handheld

// Royal Prince VIP
// Design: Very lootable, cannot really powergame with his own loot, but can reasonably defend himself with it. Objective to keep his own loot until roundend.
// All clothing resists any damage, though it does not make the wearer xproof.
// Crown: Can psychically sway basic and simple mobs to his side, temporarily? if hostile. Cool beam effect. Chance to deflect lasers aimed at the head (very shiny), maybe mini voice of god

/obj/item/clothing/head/costume/crown/fancy
	name = "magnificent crown"
	desc = "A crown worn by only the highest emperors of <s>the land</s> space, or more accurately, some decrepit fiefdom in Sprout. Supremely polished, and despite being made of gold it's a better mirror than anything you've ever seen! The beautiful emerald jewel in the middle shines strangely in the light.."
	icon_state = "fancycrown"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/reflect_probability = 100

/obj/item/clothing/head/costume/crown/fancy/IsReflect(def_zone)
	if(def_zone != BODY_ZONE_HEAD)
		return FALSE
	if (prob(reflect_probability)) // The crown has been polished to PERFECTION.
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
	desc = "These gauntlets were a gift to this Ethereal royal family from Nanotrasen, to cement good relations between them. They grant the user the ability to practice advanced Fencing via microchips."
	strip_delay = 15 SECONDS
	equip_delay_other = 15 SECONDS
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
	style.remove(user)

// Boots: Baton knockdown immunity, can act as magboots with a bit less slowdown, maaaaaybe dash abil

/obj/item/clothing/shoes/magboots/royal_magboots
	name = "royal mag-sabatons"
	desc = "The design for these sabatons was gifted to the Royal Family by Nanotrasen as a sign of good relations. Just as protective as normal sabatons, while also being able to be activated for zero-grav movement, alongside the ability to mantain posture if attacked by batons."
	icon_state = "crusader"
	armor_type = /datum/armor/shoes_plate
	strip_delay = 15 SECONDS
	equip_delay_other = 15 SECONDS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	// They slow you down a bit.
	slowdown = SHOES_SLOWDOWN + 0.3
	// But overall active slowdown isn't *too* bad.
	slowdown_active = SHOES_SLOWDOWN + 0.6
	// And in exchange, noslip and baton resistance.
	inactive_traits = list(TRAIT_BATON_RESISTANCE)
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
	name = "ethereal prince's attire"
	desc = "An ethereal, beautiful attire made of luminescent threads and encased with deep turquoise and blue jewels. It even contains an extra set of pockets!"
	icon_state = "captain_parade"
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	icon = 'icons/obj/clothing/under/captain.dmi'
	worn_icon = 'icons/mob/clothing/under/captain.dmi'
	armor_type = /datum/armor/royal_attire
	resistance_flags = FIRE_PROOF | ACID_PROOF

/datum/armor/royal_attire
	bio = 10
	melee = 10
	wound = 10

/obj/item/clothing/under/royal_attire/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets)

// Has slightly altered chaplain crusader armor. Minor slowdown, but hardy.

/obj/item/clothing/suit/armor/riot/knight/prince
	name = "prince's own armor"
	desc = "A very fancy if terribly outdated suit of plate armor. It has a fancy turquoise tabard. A little encumbering, but surprisingly resistant to damage."
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

/obj/item/storage/belt/sabre/prince
	name = "prince's sabre sheath"
	desc = "An ornate emerald-green sheath, which holds the prince's sabre."
	icon_state = "sheath_prince"
	inhand_icon_state = "sheath_prince"
	worn_icon_state = "sheath_prince"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/melee/sabre/prince
	name = "prince's sabre"
	desc = "A mastercrafted example of the finest of Sprout's worksmanship, this sabre is encrusted in beautiful, iridescent emeralds."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "sabre_prince"
	inhand_icon_state = "sabre_prince"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
