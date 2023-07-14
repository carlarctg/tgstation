/datum/job/royal_prince
	title = JOB_VIP_PRINCE
	description = "Secure unethical trade deals with Nanotrasen. Display your ludicrous amount of wealth to the crew. \
				Attempt to keep said wealth on you until the round ends."
	department_head = list()
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = ""
	exp_granted_type = EXP_TYPE_SPECIAL
	config_tag = "PRINCE"

	outfit = /datum/outfit/job/royal_prince
	plasmaman_outfit = /datum/outfit/job/royal_prince

	paycheck = PAYCHECK_ZERO
	paycheck_department = ""

	liver_traits = list(TRAIT_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_ROYAL_PRINCE
	bounty_types = CIV_JOB_BASIC
	departments_list = list(
		/datum/job_department/very_important_personnel,
		)

	family_heirlooms = list()

	mail_goodies = list(
		/obj/item/reagent_containers/hypospray/medipen = 20,
	)
	rpg_title = "Most Royal Majesty"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_ASSIGN_QUIRKS

/datum/outfit/job/royal_prince
	name = "Royal Prince"
	jobtype = /datum/job/royal_prince

	id = /obj/item/card/id/advanced/vip
	id_trim = /datum/id_trim/job/vip_royal_prince
	uniform = /obj/item/clothing/under/royal_attire
	suit = /obj/item/clothing/suit/armor/riot/knight/prince
	suit_store = /obj/item/banner
	backpack_contents = list(
		/obj/item/shield/buckler = 1,
		)
	//belt = //obj/item/storage/belt/medical/paramedic
	ears = /obj/item/radio/headset/headset_com
	head = /obj/item/clothing/head/costume/crown/fancy
	gloves = /obj/item/clothing/gloves/plate/royal_gauntlets
	shoes = /obj/item/clothing/shoes/magboots/royal_magboots
	l_pocket = /obj/item/modular_computer/pda/clear

	backpack = /obj/item/storage/backpack/saddlepack
	satchel = /obj/item/storage/backpack/saddlepack
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	box = /obj/item/storage/box/survival/centcom
	//chameleon_extras = //obj/item/gun/syringe
	pda_slot = ITEM_SLOT_LPOCKET

/datum/outfit/job/royal_prince/pre_equip(mob/living/carbon/human/human, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	human.dna.features["ethcolor"] = pick(GLOB.color_list_ethereal)
	human.set_species(/datum/species/ethereal)
	var/chosen_name = human.dna.species.random_name(human.gender, unique = TRUE)
	human.fully_replace_character_name(human.real_name,chosen_name)

/datum/job/superweapon
	title = "Nanotrasen Superweapon"
	description = "Inspire people with your incredible powers. Require constant help from security, medical, and engineering. \
		Be an extremely alluring target for bad people."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_CMO
	exp_granted_type = EXP_TYPE_SPECIAL
	config_tag = "SUPERWEAPON"

	outfit = /datum/outfit/job/superweapon
	plasmaman_outfit = /datum/outfit/job/superweapon

	paycheck = PAYCHECK_LOWER
	paycheck_department = ACCOUNT_SCI

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_SUPERWEAPON
	bounty_types = CIV_JOB_MED
	departments_list = list(
		/datum/job_department/very_important_personnel,
		/datum/job_department/medical,
		/datum/job_department/science,
		)

	family_heirlooms = list(/obj/item/storage/medkit/ancient/heirloom)

	mail_goodies = list(
		/obj/item/reagent_containers/hypospray/medipen = 20,
		/obj/item/reagent_containers/hypospray/medipen/oxandrolone = 10,
		/obj/item/reagent_containers/hypospray/medipen/salacid = 10,
		/obj/item/reagent_containers/hypospray/medipen/salbutamol = 10,
		/obj/item/reagent_containers/hypospray/medipen/penacid = 10,
		/obj/item/reagent_containers/hypospray/medipen/survival/luxury = 5
	)
	rpg_title = "Forsaken One"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_ASSIGN_QUIRKS

/datum/job/superweapon/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	spawned.mind.add_antag_datum(/datum/antagonist/protagonist/nanotrasen_superweapon)

/datum/outfit/job/superweapon
	name = "Nanotrasen Superweapon"
	jobtype = /datum/job/superweapon

	id = /obj/item/card/id/advanced/vip
	id_trim = /datum/id_trim/job/vip_superweapon
	uniform = /obj/item/clothing/under/rank/medical/scrubs//hospital_gown
	suit = null
	backpack_contents = list(
		/obj/item/shield/buckler = 1,
		)
	//belt = //obj/item/storage/belt/medical/paramedic
	ears = /obj/item/radio/headset/headset_medsci
	head = null
	gloves = null
	shoes = /obj/item/clothing/shoes/sandal
	l_pocket = /obj/item/modular_computer/pda/clear

	//backpack = //obj/item/storage/backpack/saddlepack
	//satchel = //obj/item/storage/backpack/saddlepack
	//duffelbag = //obj/item/storage/backpack/duffelbag/med

	box = /obj/item/storage/box/survival/centcom
	//chameleon_extras = //obj/item/gun/syringe
	pda_slot = null
