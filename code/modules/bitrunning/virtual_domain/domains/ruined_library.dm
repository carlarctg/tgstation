/datum/lazy_template/virtual_domain/ruined_library
	name = "Ruined Library (PvP)"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Several months ago, two followers of the forgotten gods took over a great library, slaughtering everyone inside. \
	Now it's time to fight back! Prepare yourself from one of several questful classes to destroy them and take back the library.\
	Be careful - these virtual creatures have glitched into true sapience and won't enjoy your attempt to destroy their home."
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	extra_loot = list(/obj/item/toy/eldritch_book = 1)
	help_text = "Arm yourself and burn the heretics."
	key = "ruined_library"
	map_name = "ruined_library"
	reward_points = BITRUNNER_REWARD_HIGH
	safehouse_path = /datum/map_template/safehouse/wood
	mission_min_candidates = 1 // They ARE the mission.
	mission_max_candidates = 2

/obj/effect/mob_spawn/ghost_role/virtual_domain

/obj/effect/mob_spawn/ghost_role/virtual_domain/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, "COMSIG_GLOB_VIRTUAL_DOMAIN_LOADED", PROC_REF(pick_ghost))

/obj/effect/mob_spawn/ghost_role/virtual_domain/proc/pick_ghost(list/mob/ghosts_to_take)
	if(length(ghosts_to_take) < 0 || isnull(ghosts_to_take))
		return
	create_from_ghost(pick_n_take(ghosts_to_take))
	if(uses > 0)
		pick_ghost(ghosts_to_take)

/obj/effect/mob_spawn/ghost_role/virtual_domain/create_from_ghost(mob/dead/user)
	var/mob/created_dude = ..()
	notify_ghosts("[user] has been selected to be a [prompt_name]!", source = created_dude, action = NOTIFY_ORBIT, header = "001010110")

/obj/effect/mob_spawn/ghost_role/virtual_domain/library_heretic
	name = "Virtual Domain Library Heretic"
	prompt_name = "Virtual Heretic"
	icon = 'icons/obj/antags/cult/rune.dmi'
	icon_state = "hierophant"
	color = "#FFFFFF"
	mob_type = /mob/living/carbon/human
	faction = list(FACTION_HERETIC)
	mob_species = /datum/species/human
	flavour_text = "Protect the Library from intruders. Scavenge supplies to help you fend them off, and make sure they don't steal anything."
	important_text = "Do not fight the other heretic! You two are allies in this mission."
	var/datum/heretic_knowledge/limited_amount/starting/path_to_research = /datum/heretic_knowledge/limited_amount/starting/base_knock

/obj/effect/mob_spawn/ghost_role/virtual_domain/library_heretic/special(mob/living/spawned_mob, mob/mob_possessor)
	. = ..()
	// Make them a Heretic.
	spawned_mob.mind.add_antag_datum(/datum/antagonist/heretic)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(spawned_mob)
	// Give them points.
	heretic_datum.knowledge_points = 8
	// Locate the base path.
	path_to_research = locate(path_to_research) in heretic_datum.get_researchable_knowledge()
	if(!path_to_research)
		CRASH("could not find path to force research into [path_to_research]")
	// Research it!
	path_to_research = new()
	path_to_research.on_research(spawned_mob, heretic_datum)

/obj/effect/mob_spawn/ghost_role/virtual_domain/library_heretic/ash
	name = "Virtual Domain Ash Heretic"
	prompt_name = "Virtual Ash Heretic"
	color = "#FF0000"
	mob_species = /datum/species/lizard
	outfit = /datum/outfit/ash_heretic
	mutcolor = "#b62020"
	eye_colors = list("#ffee00", "#a09500")
	you_are_text = "You are the Ash Heretic!"
	path_to_research = /datum/heretic_knowledge/limited_amount/starting/base_ash

/obj/effect/mob_spawn/ghost_role/virtual_domain/library_heretic/ash/special(mob/living/spawned_mob, mob/mob_possessor)
	. = ..()
	var/mob/living/carbon/human/human_spawn = spawned_mob
	var/obj/item/organ/external/wings/functional/cool_wings = pick(/obj/item/organ/external/wings/functional/skeleton, /obj/item/organ/external/wings/functional/dragon)
	cool_wings = new(human_spawn)
	if(!(cool_wings.Insert(human_spawn)))
		qdel(cool_wings)

	// Make em look as evil as possible
	human_spawn.dna.features["tail_lizard"] = "Dark Tiger"
	human_spawn.dna.features["snout"] = "Sharp"
	human_spawn.dna.features["horns"] = "Ram"
	human_spawn.dna.features["frills"] = "Short"
	human_spawn.dna.features["spines"] = "Long + Membrane"
	human_spawn.dna.features["body_markings"] = "Dark Tiger Body"
	human_spawn.dna.features["legs"] = DIGITIGRADE_LEGS
	// Come on. It would be just TOO easy to own them with glass shards
	ADD_TRAIT(human_spawn, TRAIT_PIERCEIMMUNE, SPECIES_TRAIT)

//make crucible soul interact with noteleport area falg

// Looks like an evil ashwalker cultist
/datum/outfit/ash_heretic
	name = "Library Ash Heretic"

	glasses = /obj/item/clothing/glasses/hud/health/night/cultblind/free
	mask = null
	back = null
	uniform = /obj/item/clothing/under/costume/gladiator/ash_walker/darkened
	suit = /obj/item/clothing/suit/hooded/cloak/goliath
	belt = /obj/item/storage/belt/mining/primitive/unrestricted
	backpack_contents = list()

/obj/effect/mob_spawn/ghost_role/virtual_domain/library_heretic/void
	name = "Virtual Domain Void Heretic"
	prompt_name = "Virtual Void Heretic"
	color = "#00FFFF"
	outfit = /datum/outfit/void_heretic
	haircolor = "#f7f3c5" // inbetween realistic and ethereal
	skin_tone = "albino"
	you_are_text = "You are the Void Heretic!"
	path_to_research = /datum/heretic_knowledge/limited_amount/starting/base_void

// Looks like an evil, uh, ice climber I guess??
/datum/outfit/void_heretic
	name = "Library Void Heretic"

	glasses = /obj/item/clothing/glasses/hud/health/night/cultblind/free
	gloves = /obj/item/clothing/gloves/color/black
	mask = null
	shoes = /obj/item/clothing/shoes/workboots/mining
	back = /obj/item/storage/backpack/explorer
	uniform = /obj/item/clothing/under/rank/cargo/miner/lavaland
	belt = /obj/item/shovel/serrated
	backpack_contents = list()
