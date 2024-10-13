/*
Inverse Sonar component.

When added onto an atom, it will create a visible image for every nearby cliented mob when they're not in LOS.

*/
/datum/component/inverse_sonar
	var/list/obj/effect/temp_visual/dir_setting/inverse_sonar/sonars_to_mobs
	var/list/resonating_mobs
	var/sonar_icon
	var/sonar_icon_state
	var/sonar_alert_type

/datum/component/inverse_sonar/Initialize(sonar_icon = 'icons/effects/effects.dmi', sonar_icon_state, listening_signal, sonar_alert_type = /atom/movable/screen/alert/inverse_sonar)

	src.sonar_icon = sonar_icon
	src.sonar_icon_state = sonar_icon_state
	src.sonar_alert_type = sonar_alert_type

	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, listening_signal, PROC_REF(sonar_ping))

/datum/component/inverse_sonar/Destroy(force)
	for(var/mob/living/entity in resonating_mobs)
		remove_resonant(entity)

	sonars_to_mobs = null
	resonating_mobs = null

	. = ..()

/datum/component/inverse_sonar/proc/generate_sonar_image_to_mob(resonating_mob)
	var/atom/movable/parent_atom = parent
	// Create the sonar image and adjust its variables.
	var/image/sonar_image = image(icon = sonar_icon, loc = parent, icon_state = sonar_icon_state, layer = ABOVE_ALL_MOB_LAYER)
	sonar_image.plane = ABOVE_LIGHTING_PLANE
	SET_PLANE_EXPLICIT(sonar_image, ABOVE_LIGHTING_PLANE, parent_atom)

	// make it copy the target if no icon is set
	if(isnull(sonar_icon || sonar_icon_state))
		sonar_image.copy_overlays(parent_atom, TRUE)
		sonar_image.alpha = 150

	sonar_image.dir = parent_atom.dir

	// Create the effect that will hold the inverse sonar and attach it.
	// needs to be located on the resonating mob. if its on the component holder it won't load, because out of sight
	var/obj/effect/temp_visual/dir_setting/inverse_sonar/new_sonar = new(resonating_mob)
	LAZYADDASSOC(sonars_to_mobs, resonating_mob, new_sonar)
	new_sonar.setDir(parent_atom.dir)
	new_sonar.sonar_image = sonar_image

	return sonar_image

/obj/effect/temp_visual/dir_setting/inverse_sonar/Destroy()
	stack_trace("deleted")
	. = ..()

/datum/component/inverse_sonar/proc/adjust_sonar_offset(mob/mob)
	var/atom/movable/parent_atom = parent
	var/obj/effect/temp_visual/dir_setting/inverse_sonar/sonar_effect = sonars_to_mobs[mob]
	sonar_effect.sonar_image.loc = get_turf(mob)
	//sonar_effect.sonar_image.pixel_x = ((parent_atom.x - mob.x) * 32)
	//sonar_effect.sonar_image.pixel_y = ((parent_atom.y - mob.y) * 32)
	sonar_effect.sonar_image.setDir(parent_atom.dir)
	animate(sonar_effect.sonar_image, pixel_x = ((parent_atom.x - mob.x) * 32), pixel_y = ((parent_atom.y - mob.y) * 32))

/datum/component/inverse_sonar/proc/sonar_ping(atom/source)
	SIGNAL_HANDLER

	// List of creatures currently viewing the user.
	var/list/current_viewers

	for(var/mob/living/entity in get_hearers_in_range(10, source))
		if(!entity.client || entity == source)
			continue
		//if(entity in get_viewers(7, parent))
		//	remove_resonant(entity)
		//	continue
		LAZYADD(current_viewers, entity)
		if(entity in resonating_mobs)
			adjust_sonar_offset(entity)
			continue
		add_resonant(entity)

	// Removes creatures that aren't nearby anymore
	for(var/mob/living/entity in resonating_mobs)
		if(entity in current_viewers || !entity.client)
			continue
		remove_resonant(entity)

/datum/component/inverse_sonar/proc/add_resonant(mob/user)
	var/atom/movable/parent_atom = parent
	var/image/resonant_image = generate_sonar_image_to_mob(user)
	LAZYADD(resonating_mobs, user)
	LAZYADD(user.client.images, resonant_image)
	adjust_sonar_offset(user)
	// always update on the resonant's movement so the image stays in place
//	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(adjust_sonar_offset))
	if(sonar_alert_type)
		var/atom/movable/screen/alert/alert = user.throw_alert("sonar", sonar_alert_type)

/datum/component/inverse_sonar/proc/remove_resonant(mob/user)
	LAZYREMOVE(resonating_mobs, user)
	if(user.client)
		LAZYREMOVE(user.client.images, sonars_to_mobs[user])
	user.clear_alert("sonar", clear_override = TRUE) // idk i cant get it to work
	//sonars_to_mobs[user] = null
	sonars_to_mobs.Remove(sonars_to_mobs[user])

	//LAZYREMOVEASSOC(sonars_to_mobs, user)

/atom/movable/screen/alert/inverse_sonar
	name = "Sonar Call"
	icon_state = "perception" // palceholder
