//Engineering Mesons

/obj/item/clothing/glasses/perceptomatrix
	name = "perceptomatrix visor"
	desc = "A highly sophisticated visor that utilizes perceptual anomalous power to allow complete sight through walls. Resonating anomalous frequencies allow anyone and anything seen by you, to see you right back. Needs a hallucination core to function."
	icon_state = "perceptomatrix"
	inhand_icon_state = "perceptomatrix"
	actions_types = list(/datum/action/item_action/toggle_mode)
	glass_colour_type = /datum/client_colour/glass_colour/lightpurple

	color_cutoffs = list(30, 5, 15)
	glass_colour_type = /datum/client_colour/glass_colour/lightpurple
	forced_glass_color = TRUE
	flash_protect = FLASH_PROTECTION_HYPER_SENSITIVE

	//---- Anomaly core variables:
	///The core item the organ runs off.
	var/obj/item/assembly/signaler/anomaly/core
	///Accepted types of anomaly cores.
	var/required_anomaly = /obj/item/assembly/signaler/anomaly/hallucination
	///If this one starts with a core in.
	var/prebuilt = FALSE
	///If the core is removable once socketed.
	var/core_removable = TRUE
	var/component

/obj/item/clothing/glasses/perceptomatrix/Initialize(mapload)
	. = ..()
	if(prebuilt)
		core = new /obj/item/assembly/signaler/anomaly/hallucination(src)
		update_icon_state()

	// Holds the component to un/apply when un/equipped
		// to be celar
		// Issue is thus
		// We need to listen for the signal on mob/item
		// If we listen on goggles for being equipped 1st arg is goggles, which i cant easily shove into ec_holder
		// And we cant listen to a mob that doesnt yet exist.
		// so im ditching ec holder

	// downsides: flash vuln, cosntant hallucinations
	// also narnar rips ur eyes out

/obj/item/clothing/glasses/perceptomatrix/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_EYES)
		return
	component = user.AddComponent(/datum/component/inverse_sonar, sonar_icon_state = "perception", listening_signal = COMSIG_MOVABLE_MOVED, sonar_alert_type = /atom/movable/screen/alert/perception_recipient)
	ADD_TRAIT(user, TRAIT_XRAY_VISION, "[CLOTHING_TRAIT]_[REF(src)]")
	user.throw_alert("perceptomatrix", /atom/movable/screen/alert/perception_owner)
	user.update_sight()

/obj/item/clothing/glasses/perceptomatrix/dropped(mob/user)
	REMOVE_TRAIT(user, TRAIT_XRAY_VISION, "[CLOTHING_TRAIT]_[REF(src)]")
	user.clear_alert("perceptomatrix", clear_override = TRUE) // idk i cant get it to work
	qdel(component)
	user.update_sight()
	. = ..()


/obj/item/clothing/glasses/perceptomatrix/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, required_anomaly))
		return NONE
	if(core)
		balloon_alert(user, "core already in!")
		return ITEM_INTERACT_BLOCKING
	var/mob/living/carbon/human/human_user = ishuman(user)
	if(human_user && (src == human_user.glasses))
		balloon_alert(user, "can't install core while worn!")
		return
	if(!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING
	core = tool
	balloon_alert(user, "core installed")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	update_icon_state()
	return ITEM_INTERACT_SUCCESS

/obj/item/clothing/glasses/perceptomatrix/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!core)
		balloon_alert(user, "no core!")
		return
	if(!core_removable)
		balloon_alert(user, "can't remove core!")
		return
	var/mob/living/carbon/human/human_user = ishuman(user)
	if(human_user && (src == human_user.glasses))
		balloon_alert(user, "can't remove core while worn!")
		return
	balloon_alert(user, "removing core...")
	if(!do_after(user, 3 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return
	balloon_alert(user, "core removed")
	core.forceMove(drop_location())
	if(Adjacent(user) && !issilicon(user))
		user.put_in_hands(core)
	core = null
	update_icon_state()

/atom/movable/screen/alert/perception_owner
	name = "Perceptual Resonance"
	icon_state = "perception_invert"
	desc = "You're emitting a wave of perceptual resonance. Anyone who you can see, can see you right back."

/atom/movable/screen/alert/perception_recipient
	name = "Perceptual Resonance"
	icon_state = "perception"
	desc = "Anomalous resonances make you aware of someone's location..."

/atom/movable/screen/alert/perception_recipient/Initialize(mapload, datum/hud/hud_owner, mob/gazer)
	. = ..()
	desc = "Anomalous resonances make you aware of [gazer ? gazer : "someone"]'s location..."
