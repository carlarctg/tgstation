/*
Inverse Sonar component.

When added onto an atom, it will create a visible image for every nearby cliented mob when they're not in LOS.

*/
/datum/component/inverse_sonar
	var/list/obj/effect/temp_visual/dir_setting/inverse_sonar/sonars_to_mobs
	var/list/resonating_mobs
	var/sonar_icon
	var/sonar_icon_state
	var/sonar_alert_text
	var/sonar_alert_icon

/datum/component/inverse_sonar/Initialize(sonar_icon, sonar_icon_state, listening_signal, sonar_alert_text, sonar_alert_icon)

	src.sonar_icon = sonar_icon
	src.sonar_icon_state = sonar_icon_state
	src.sonar_alert_text = sonar_alert_text
	src.sonar_alert_icon = sonar_alert_icon

	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, listening_signal, PROC_REF(sonar_ping))
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(update_sonars))
	RegisterSignal(parent, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, PROC_REF(update_glide))

/datum/component/inverse_sonar/Destroy(force)
	for(var/mob/living/entity in resonating_mobs)
		remove_resonant(entity)

	sonars_to_mobs = null
	resonating_mobs = null

	. = ..()

/datum/component/inverse_sonar/proc/update_glide(atom/movable/parent_atom, new_glide_size)
	AAdebug_animtime = new_glide_size

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
	var/obj/effect/temp_visual/dir_setting/inverse_sonar/new_sonar = new(parent_atom)
	LAZYADDASSOC(sonars_to_mobs, resonating_mob, new_sonar)
	new_sonar.setDir(parent_atom.dir)
	new_sonar.sonar_image = sonar_image

	return sonar_image

/obj/effect/temp_visual/dir_setting/inverse_sonar/Destroy()
	stack_trace("deleted")
	. = ..()

/datum/component/inverse_sonar/var/AAdebug_animtime = 2.5

/datum/component/inverse_sonar/proc/adjust_sonar_offset(mob/mob)
	var/atom/movable/parent_atom = parent
	var/obj/effect/temp_visual/dir_setting/inverse_sonar/sonar_effect = sonars_to_mobs[mob]
	sonar_effect.sonar_image.loc = get_turf(mob)
	//sonar_effect.sonar_image.pixel_x = ((parent_atom.x - mob.x) * 32)
	//sonar_effect.sonar_image.pixel_y = ((parent_atom.y - mob.y) * 32)
	sonar_effect.sonar_image.setDir(parent_atom.dir)
	animate(sonar_effect.sonar_image, pixel_x = ((parent_atom.x - mob.x) * 32), pixel_y = ((parent_atom.y - mob.y) * 32), time = parent_atom.glide_size, easing = (EASE_IN|EASE_OUT))

/datum/component/inverse_sonar/proc/update_sonars()
	SIGNAL_HANDLER
	for(var/mob/entity in resonating_mobs)
		adjust_sonar_offset(entity)

/datum/component/inverse_sonar/proc/sonar_ping(atom/source)
	SIGNAL_HANDLER

	// List of creatures currently viewing the user.
	var/list/current_viewers

	for(var/mob/living/entity in get_hearers_in_range(7, source))
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
	if(sonar_alert_text || sonar_alert_icon)
		var/atom/movable/screen/alert/inverse_sonar/alert = user.throw_alert(REF(src), /atom/movable/screen/alert/inverse_sonar, new_master = sonar_icon_state ? null : parent_atom)
		alert.desc = sonar_alert_text ? sonar_alert_text : alert.desc
		alert.icon_state = sonar_alert_icon ? sonar_alert_icon : alert.icon_state

/datum/component/inverse_sonar/proc/remove_resonant(mob/user)
	LAZYREMOVE(resonating_mobs, user)
	LAZYREMOVE(user.client.images, sonars_to_mobs[user])
	var/alert = locate(/atom/movable/screen/alert/inverse_sonar) in user.alerts
	if(alert)
		qdel(alert)
	//sonars_to_mobs[user] = null
	sonars_to_mobs.Remove(sonars_to_mobs[user])

	//LAZYREMOVEASSOC(sonars_to_mobs, user)

/atom/movable/screen/alert/inverse_sonar
	name = "Sonar Call"
	icon_state = "template"
