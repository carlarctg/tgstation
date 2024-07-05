/obj/item/clothing/head/costume/crown
	name = "crown"
	desc = "A crown fit for a king, a petty king maybe."
	icon_state = "crown"
	armor_type = /datum/armor/costume_crown
	resistance_flags = FIRE_PROOF
	var/reflect_probability = 10

/obj/item/clothing/head/costume/crown/IsReflect(def_zone)
	if(def_zone != BODY_ZONE_HEAD)
		return FALSE
	if (prob(reflect_probability)) // The crown has been polished to PERFECTION.
		return TRUE

/datum/armor/costume_crown
	melee = 15
	energy = 10
	fire = 100
	acid = 50
	wound = 5

/obj/item/clothing/head/costume/crown/fancy
	name = "magnificent crown"
	desc = "A crown worn by only the highest emperors of the <s>land</s> space."
	icon_state = "fancycrown"
	reflect_probability = 45
