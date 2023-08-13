/datum/antagonist/protagonist
	name = "Protagonist"
	roundend_category = "protagonists"
	antagpanel_category = "VIPs"
	job_rank = ROLE_PROTAGONIST
	show_to_ghosts = TRUE
	///Some protagonists have min ages
	var/min_age = 17
	///Some protagonists have max ages
	var/max_age = 99
	///Outfit to put onto the character
	var/outfit_type = /datum/outfit


/datum/antagonist/protagonist/on_gain()
	. = ..()
	equip_protagonist()
	create_objectives()

/datum/antagonist/protagonist/proc/equip_protagonist()
	if(!owner)
		CRASH("Antag datum with no owner.")
	var/mob/living/carbon/human/protagonist_human = owner.current
	if(!istype(protagonist_human))
		return

	protagonist_human.delete_equipment()

	if(protagonist_human.age > max_age)
		protagonist_human.age = max_age
	else if (protagonist_human.age < min_age)
		protagonist_human.age = min_age

	protagonist_human.equipOutfit(outfit_type)

/datum/antagonist/protagonist/proc/create_objectives()
	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = owner
	objectives += escape_objective

/datum/antagonist/protagonist/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/the_pronce = new
	var/mob/living/carbon/human/dummy/consistent/coughing_baby = new

	the_pronce.dna.features["ethcolor"] = pick(GLOB.color_list_ethereal)
	the_pronce.set_species(/datum/species/ethereal)

	coughing_baby.set_species(/datum/species/human)
	coughing_baby.hairstyle = "Shaved"
	coughing_baby.update_body_parts()

	var/icon/the_pronce_icon = render_preview_outfit(/datum/outfit/job/royal_prince, the_pronce)
	the_pronce_icon.Shift(WEST, 8)

	var/icon/coughing_baby_icon = render_preview_outfit(/datum/outfit/job/superweapon, coughing_baby)
	coughing_baby_icon.Shift(EAST, 8)

	var/icon/final_icon = the_pronce_icon
	final_icon.Blend(coughing_baby_icon, ICON_OVERLAY)

	qdel(the_pronce)
	qdel(coughing_baby)

	return finish_preview_icon(final_icon)
