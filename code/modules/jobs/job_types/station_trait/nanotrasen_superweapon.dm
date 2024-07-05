
/datum/job/nanotrasen_superweapon
	title = JOB_NANOTRASEN_SUPERWEAPON
	description = "Continue your metamorphosis, try not to die."
	department_head = list(JOB_RESEARCH_DIRECTOR, JOB_CHIEF_MEDICAL_OFFICER)
	faction = FACTION_STATION
	total_positions = 0
	spawn_positions = 0
	supervisors = "the Chief Medical Officer and the Research Director" // Under both departments, but primarily science
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_SCIENCE
	exp_granted_type = EXP_TYPE_SCIENCE
	config_tag = "NANOTRASEN_SUPERWEAPON"

	outfit = /datum/outfit/job/nanotrasen_superweapon
	// no plasmaman outfit...

	paycheck = PAYCHECK_ZERO // test subjects get paid in exposure (to radiation)
	paycheck_department = ACCOUNT_SCI

	liver_traits = list(TRAIT_MEDICAL_METABOLISM) // science liver would make them spout scientist remarks when drunk

	display_order = JOB_DISPLAY_ORDER_NANOTRASEN_SUPERWEAPON
	departments_list = list(/datum/job_department/science, /datum/job_department/medical)

//	family_heirlooms = list(/obj/item/banner/command/mundane)

//	mail_goodies = list(
//		/obj/item/storage/fancy/cigarettes = 1,
//		/obj/item/pen/fountain = 1,
//	)
	rpg_title = "Werewolf"
	allow_bureaucratic_error = FALSE
	job_flags = STATION_JOB_FLAGS | STATION_TRAIT_JOB_FLAGS
	ignore_human_authority = TRUE
	voice_of_god_power = 0.5
	random_spawns_possible = FALSE
	var/drop_area

/datum/job/nanotrasen_superweapon/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	// Special droppod entry
	if(!drop_area)
		return
	send_supply_pod_to_area(spawned, drop_area, /obj/structure/closet/supplypod/centcompod)

//	ADD_TRAIT(spawned, TRAIT_NO_TWOHANDING, JOB_TRAIT)
	spawned.add_traits(list(
		TRAIT_WOUND_LICKER,
		TRAIT_SURGICALLY_ANALYZED, // they get bonuses to weird surgical stuff
		TRAIT_SPECIAL_TRAUMA_BOOST,
		TRAIT_HATED_BY_DOGS,
		TRAIT_HIGH_VALUE_RANSOM,
	), JOB_TRAIT)

	var/datum/antagonist/protagonist/nanotrasen_superweapon/free_antag = new()
	spawned.client.assign_antag_datum(free_antag)

/datum/job/nanotrasen_superweapon/get_roundstart_spawn_point()
	var/area/deployment_zone = prob(50) ? (GLOB.areas_by_type[/area/station/science/genetics]) : (GLOB.areas_by_type[/area/station/medical/treatment_center])
	if(isnull(deployment_zone))
		return ..() //if not, spawn on the arrivals shuttle (but also what the fuck)
	drop_area = deployment_zone
	// Try to drop pod them in, otherwise arrivals shuttle by default
	return ..()

/datum/outfit/job/nanotrasen_superweapon
	name = "Nanotrasen Superweapon"
	jobtype = /datum/job/nanotrasen_superweapon

	id_trim = /datum/id_trim/job/nanotrasen_superweapon
	backpack_contents = list()

	uniform = /obj/item/clothing/under/misc/hospital_gown
	neck = /obj/item/clothing/mask/whistle/safety
	belt = null
	ears = /obj/item/radio/headset/headset_medsci
	glasses = null
	gloves = null
	head = null
	shoes = /obj/item/clothing/shoes/sneakers/white
	l_pocket = /obj/item/modular_computer/pda/clear
	r_pocket = /obj/item/assembly/flash/handheld
