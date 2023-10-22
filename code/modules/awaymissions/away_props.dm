/obj/effect/oneway
	name = "one way effect"
	desc = "Only lets things in from it's dir."
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "field_dir"
	invisibility = INVISIBILITY_MAXIMUM
	anchored = TRUE

/obj/effect/oneway/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	return . && (REVERSE_DIR(border_dir) == dir || get_turf(mover) == get_turf(src))


/obj/effect/wind
	name = "wind effect"
	desc = "Creates pressure effect in it's direction. Use sparingly."
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "field_dir"
	invisibility = INVISIBILITY_MAXIMUM
	var/strength = 30

/obj/effect/wind/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj,src)

/obj/effect/wind/process()
	var/turf/open/T = get_turf(src)
	if(istype(T))
		T.consider_pressure_difference(get_step(T,dir),strength)

//Keep these rare due to cost of doing these checks
/obj/effect/path_blocker
	name = "magic barrier"
	desc = "You shall not pass."
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "blocker" //todo make this actually look fine when visible
	anchored = TRUE
	var/list/blocked_types = list()
	var/reverse = FALSE //Block if path not present

/obj/effect/path_blocker/Initialize(mapload)
	. = ..()
	if(blocked_types.len)
		blocked_types = typecacheof(blocked_types)

/obj/effect/path_blocker/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(blocked_types.len)
		var/list/mover_contents = mover.get_all_contents()
		for(var/atom/movable/thing in mover_contents)
			if(blocked_types[thing.type])
				return reverse
	return !reverse

/obj/effect/identity_barrier
	name = "identity barrier"
	desc = "Lets a person through, then only allows that person to come and go."
	icon = 'icons/effects/effects.dmi'
	icon_state = "medi_holo_no_anim"
	anchored = TRUE
	var/mob/living/allowed_entity

/obj/effect/identity_barrier/Initialize(mapload)
	. = ..()
	update_description()

/obj/effect/identity_barrier/proc/update_description()
	desc = initial(desc)
	if(allowed_entity)
		desc += "It is currently bound to [allowed_entity]."
	else
		desc += "It is not currently bound to any entity."

/obj/effect/oneway/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	// No point if this is false
	if(!.)
		return
	// Any non-mob can pass. This does include teleport beacons, quantum inverters, etc etc, so be careful!
	if(!ismob(mover))
		return TRUE
	var/mob/living/living_mover = mover
	// No marked entity? Set this one as it.
	if(isnull(allowed_entity))
		allowed_entity = living_mover
		update_description()
		visible_message("[src] pulses as [mover] passes through, marking [mover.p_them()] as the only allowed creature!")
		playsound(src, 'sound/magic/staff_chaos.ogg', 25, TRUE)
		ASYNC
			animate(src, transform = matrix()*2, alpha = 0, time = 5, flags = ANIMATION_END_NOW) //fade out
			sleep(0.5 SECONDS)
			animate(src, transform = matrix(), alpha = 255, time = 0, flags = ANIMATION_END_NOW)
		return TRUE

	// Yes marked entity and the mover is said entity? Let them through.
	if(living_mover == allowed_entity)
		return TRUE

	// No success condition passed, blare out an error and return false.
	ASYNC
		var/oldcolor = color
		color = rgb(255, 0, 0)
		animate(src, color = oldcolor, time = 5)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 0.5 SECONDS)

	return FALSE

/obj/structure/pitgrate
	name = "pit grate"
	icon = 'icons/obj/smooth_structures/lattice.dmi'
	icon_state = "lattice-255"
	plane = FLOOR_PLANE
	anchored = TRUE
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP
	var/id
	var/open = FALSE
	var/hidden = FALSE

/obj/structure/pitgrate/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs,COMSIG_GLOB_BUTTON_PRESSED, PROC_REF(OnButtonPressed))
	if(hidden)
		update_openspace()

/obj/structure/pitgrate/proc/OnButtonPressed(datum/source,obj/machinery/button/button)
	SIGNAL_HANDLER

	if(button.id == id) //No range checks because this is admin abuse mostly.
		toggle()

/obj/structure/pitgrate/proc/update_openspace()
	var/turf/open/openspace/T = get_turf(src)
	if(!istype(T))
		return
	//Simple way to keep plane conflicts away, could probably be upgraded to something less nuclear with 513
	T.invisibility = open ? 0 : INVISIBILITY_MAXIMUM

/obj/structure/pitgrate/proc/toggle()
	open = !open
	var/talpha
	if(open)
		talpha = 0
		obj_flags &= ~(BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP)
	else
		talpha = 255
		obj_flags |= BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP
	SET_PLANE_IMPLICIT(src, ABOVE_LIGHTING_PLANE) //What matters it's one above openspace, so our animation is not dependant on what's there. Up to revision with 513
	animate(src,alpha = talpha,time = 10)
	addtimer(CALLBACK(src, PROC_REF(reset_plane)),10)
	if(hidden)
		update_openspace()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in T)
		if(!AM.currently_z_moving)
			T.zFall(AM)

/obj/structure/pitgrate/proc/reset_plane()
	SET_PLANE_IMPLICIT(src, FLOOR_PLANE)

/obj/structure/pitgrate/Destroy()
	if(hidden)
		open = TRUE
		update_openspace()
	. = ..()

/obj/structure/pitgrate/hidden
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	hidden = TRUE
