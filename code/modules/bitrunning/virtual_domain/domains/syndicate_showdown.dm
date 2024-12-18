/datum/lazy_template/virtual_domain/syndicate_showdown
	name = "ERT-Syndicate Showdown (PvPnE)"
	cost = BITRUNNER_COST_MEDIUM
	help_text = "Destroy the syndicate asteroid stronghold, look for a keycard, and break into the syndicate shuttle."
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	completion_loot = list(/obj/item/toy/plush/nukeplushie = 1)
	secondary_loot = list()
	desc = "The syndicate have set up a plasma mining outpost on a nearby asteroid. \
		It is exceedingly well protected, with many lesser Syndicate, viscerators, and four true Nuclear Operatives. \
		Find the keycard to the Syndicate shuttle, breach in, take the loot, and run!"
	key = "syndicate_showdown"
	map_name = "syndicate_showdown"
	reward_points = BITRUNNER_REWARD_EXTREME
	//safehouse_path = /datum/map_template/safehouse/shuttle
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

/*

no area - FIXED
co2?
addd potions - DONE
goliath cloak in archer - FIXED
add glvoes! - DONE, ADD KNIGHT BOOTGLOVES
add bible tome subtype - FIXED, NOT ADDED
venom super deadly - replace with test tube rack with lipolicide, heparin, anacea, mute tox, tetrodox, hunter spider toxin
weird black spot below necrogate, west hell exit
wgw is used!! - FIXED
necro crates r empty - FIXED
oneways are inverted - FIXED
become ? in spawn runes - FIXED?
virtual domain desc uses short desc - FIXED
wampa is bad - FIXED
BLADSE WORK IN VR!!! - FIXED?
invisbile tables front desk - FIXED - NOT FIXED???
NORMAL BUG: drawing influence forces open cicatrix froever
remov explorer gas mask from void ehretic - DONE
move void rune from racks - DONE
void cloak stuck oon person
move void eldritch flasks htey look bad - DOEN'
skylalker corpse doesnt work
make lgihtsber toy? NAH
reduce amt of nooartrium to 10 - DONE
sacrophagus is clsoed - MEH
ash wings break bad
heretic paths arent forced - FIXED?
remove some points due to having stuff already - DONE
make narnar rune transparent n click passthru - half
remove heretic backapck, let them put stuff in belt? - done
ashn pssg might allow for escapign. fix? same with crucible soul? nvm
space phase is OP!!!!!
need 2 add extinguishers still - DONE
add some cheeeses to erp room - DONE
*/
