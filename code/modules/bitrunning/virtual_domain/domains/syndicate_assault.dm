/datum/lazy_template/virtual_domain/syndicate_showdown
	name = "ERT-Syndicate Showdown (PvPnE)"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Destroy the syndicate asteroid stronghold, look for a keycard, and break into the syndicate shuttle."
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	extra_loot = list(/obj/item/toy/plush/nukeplushie = 1)
	help_text = "The syndicate have set up a plasma mining outpost on a nearby asteroid. \
		It is exceedingly well protected, with many lesser Syndicate, viscerators, and four true Nuclear Operatives. \
		Find the keycard to the Syndicate shuttle, breach in, take the loot, and run!"
	key = "syndicate_showdown"
	map_name = "syndicate_showdown"
	reward_points = BITRUNNER_REWARD_EXTREME
	safehouse_path = /datum/map_template/safehouse/shuttle
	mission_flags = "pvp"
	mission_min_candidates = 0 // Not required.
	mission_max_candidates = 4

/obj/effect/mob_spawn/ghost_role/human/virtual_domain/syndicate_showdown
	name = "Virtual Syndicate Showdown Operative"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	prompt_name = "virtual syndicate operative"
	mob_type = /mob/living/carbon/human
	faction = list(ROLE_SYNDICATE)
	mob_species = /datum/species/human
	you_are_text = "You are a syndicate operative tasked with protecting an important plasma mining operation from any assailants."
	flavour_text = "Get your gear from the ship, lounge with your colleagues in the lobby, and take up defensive positions out in space."
	important_text = "Defend the outpost southeast of you. Ensure it and its keycards do not fall into enemy hands!"
	outfit = /datum/outfit/syndicatespace/syndicrew
	spawner_job_path = /datum/job/syndicate_cybersun
