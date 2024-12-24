/datum/lazy_template/virtual_domain/ruined_library
	name = "Ruined Library (PvP)"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Several months ago, two followers of the forgotten gods took over a great library, slaughtering everyone inside. \
	Now it's time to fight back! Prepare yourself from one of several questful classes to destroy them and take back the library.\
	Be careful - these virtual creatures have glitched into true sapience and won't enjoy your attempt to destroy their home."
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	completion_loot = list(/obj/item/toy/eldritch_book = 1)
	secondary_loot = list()
	help_text = "Arm yourself and burn the heretics."
	key = "ruined_library"
	map_name = "ruined_library"
	reward_points = BITRUNNER_REWARD_HIGH
	//safehouse_path = /datum/map_template/safehouse/wood
	//mission_min_candidates = 1 // They ARE the mission.
	//mission_max_candidates = 2


/datum/lazy_template/virtual_domain/ruined_library/setup_domain(list/created_atoms)
	. = ..()
	for(var/mob/living/dude in ghost_mobs)
		RegisterSignal(dude, COMSIG_LIVING_DEATH, PROC_REF(do_add_points))

/datum/lazy_template/virtual_domain/ruined_library/proc/do_add_points()
	SIGNAL_HANDLER
	// 10 points make a crate. 15 points make a crate and a half. Thus a dead heretic = 1 crate, two dead heretics = 3 crates.
	add_points(15)

/obj/effect/mob_spawn/ghost_role/virtual_domain
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

/obj/effect/mob_spawn/ghost_role/virtual_domain/library_heretic/ash
	name = "Virtual Domain Ash Heretic"
	prompt_name = "Virtual Ash Heretic"
	color = "#FF0000"
	mob_species = /datum/species/lizard
	outfit = /datum/outfit/heresy/ash_heretic
	mutcolor = "#b62020"
	eye_colors = list("#ffee00", "#a09500")
	you_are_text = "You are the Ash Heretic!"

/obj/effect/mob_spawn/ghost_role/virtual_domain/library_heretic/ash/special(mob/living/spawned_mob, mob/mob_possessor)
	. = ..()
	var/mob/living/carbon/human/human_spawn = spawned_mob
	var/obj/item/organ/wings/functional/cool_wings = pick(/obj/item/organ/wings/functional/skeleton, /obj/item/organ/wings/functional/dragon)
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
/datum/outfit/heresy
	/// Mob gets these knowledges on spawn.
	var/list/knowledge_to_grant

/datum/outfit/heresy/pre_equip(mob/living/carbon/human/user, visuals_only)
	. = ..()
	ADD_TRAIT(user, TRAIT_ACT_AS_HERETIC, REF(src))
	// Creates the knowledge as an isolated datum inside the target, allowing passive knowledges to work still.
	for(var/datum/heretic_knowledge/knowhow as anything in knowledge_to_grant)
		knowhow = new knowhow(user)
		knowhow.on_gain(user, null)

// Looks like an evil ashwalker cultist
/datum/outfit/heresy/ash_heretic
	name = "Library Ash Heretic"

	glasses = /obj/item/clothing/glasses/hud/health/night/cultblind/free
	mask = /obj/item/clothing/mask/madness_mask
	neck = /obj/item/clothing/neck/eldritch_amulet

	uniform = /obj/item/clothing/under/costume/gladiator/ash_walker/darkened
	suit = /obj/item/clothing/suit/hooded/cloak/goliath // forces hood on. annoying
	l_pocket = /obj/item/eldritch_potion/wounded
	r_pocket = /obj/item/eldritch_potion/crucible_soul
	back = null
	backpack_contents = list()
	belt = /obj/item/storage/belt/mining/primitive/unrestricted
	belt_contents = list(
		/obj/item/slimecross/stabilized/darkblue/waterstone,
		/obj/item/reagent_containers/cup/beaker/eldritch,
		/obj/item/reagent_containers/cup/beaker/eldritch,
		/obj/item/reagent_containers/cup/glass/bottle/wyvern,
		/obj/item/melee/sickly_blade/ash,
		/obj/item/melee/sickly_blade/ash,
	)
	knowledge_to_grant = list(
		/datum/heretic_knowledge/spell/basic,
		/datum/heretic_knowledge/ashen_grasp,
		/datum/heretic_knowledge/spell/ash_passage,
		/datum/heretic_knowledge/mark/ash_mark,
		/datum/heretic_knowledge/spell/fire_blast,
		/datum/heretic_knowledge/spell/flame_birth,
		/datum/heretic_knowledge/blade_upgrade/ash,
		// spawns with mad mask
	)
	spells_to_add = list(/datum/action/cooldown/spell/pointed/ash_beams) // Not a knowledge

/obj/item/slimecross/stabilized/darkblue/waterstone
	name = "water stone"
	desc = "This legendary artifact will continually douse your fires when pocketed."

/obj/effect/mob_spawn/ghost_role/virtual_domain/library_heretic/void
	name = "Virtual Domain Void Heretic"
	prompt_name = "Virtual Void Heretic"
	color = "#00FFFF"
	outfit = /datum/outfit/heresy/void_heretic
	haircolor = "#f7f3c5" // inbetween realistic and ethereal
	skin_tone = "albino"
	you_are_text = "You are the Void Heretic!"

// Looks like an evil, uh, ice climber I guess??
/datum/outfit/heresy/void_heretic
	name = "Library Void Heretic"

	glasses = /obj/item/clothing/glasses/hud/health/night/cultblind/free
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/gas/explorer/folded
	head = /obj/item/clothing/head/hooded/winterhood
	neck = /obj/item/clothing/neck/heretic_focus/moon_amulet

	shoes = /obj/item/clothing/shoes/workboots/mining
	uniform = /obj/item/clothing/under/rank/cargo/miner/lavaland
	suit = /obj/item/clothing/suit/hooded/wintercoat

	l_pocket = /obj/item/eldritch_potion/wounded
	r_pocket = /obj/item/eldritch_potion/duskndawn
	belt = /obj/item/shovel/serrated
	back = /obj/item/storage/backpack/explorer
	backpack_contents = list(
		/obj/item/reagent_containers/cup/beaker/eldritch,
		/obj/item/reagent_containers/cup/beaker/eldritch,
		/obj/item/reagent_containers/cup/glass/bottle/wyvern,
		/obj/item/eldritch_potion/wounded,
		/obj/item/melee/sickly_blade/void,
		/obj/item/melee/sickly_blade/void,
	)
	knowledge_to_grant = list(
		/datum/heretic_knowledge/spell/basic,
		/datum/heretic_knowledge/void_grasp,
		/datum/heretic_knowledge/cold_snap,
		/datum/heretic_knowledge/mark/void_mark,
		/datum/heretic_knowledge/spell/void_conduit,
		/datum/heretic_knowledge/spell/void_phase,
		/datum/heretic_knowledge/blade_upgrade/void,
		/datum/heretic_knowledge/spell/void_pull,
	)
