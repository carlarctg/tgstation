/datum/action/cooldown/spell/aoe/area_cleanse
	name = "Cleanse"
	desc = "Tidies up the nearby area, extinguishes flames, and generally just makes things nicer."
	button_icon_state = "sacredflame"
	sound = 'sound/magic/repulse.ogg'

	school = SCHOOL_CONJURATION
	cooldown_time = 45 SECONDS

	invocation = "SCOURGIFY!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE // let chaplains cast!

	aoe_radius = 3
	var/static/list/elevated_structures = list(/obj/structure/table, /obj/structure/rack)

/datum/action/cooldown/spell/aoe/area_cleanse/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/atom/movable/movable_atom in view(aoe_radius, center))
		things += movable_atom

	return things

/datum/action/cooldown/spell/aoe/area_cleanse/cast_on_thing_in_aoe(atom/movable/movable_atom, mob/living/caster)

	movable_atom.wash(CLEAN_ALL)

	var/list/structures_in_view = list()
	for(var/atom/movable/atomo in view(aoe_radius, caster))
		if(is_type_in_list(movable_atom, elevated_structures))
			structures_in_view |= movable_atom

	var/cleaned
	if(isitem(movable_atom))
		handle_item(movable_atom, structures_in_view, caster)
		cleaned = TRUE

	if(isliving(movable_atom))
		handle_living(movable_atom)
		cleaned = TRUE

	if(cleaned && !locate(/obj/effect/temp_visual/bubbles) in get_turf(movable_atom))
		new /obj/effect/temp_visual/bubbles(get_turf(movable_atom))

/datum/action/cooldown/spell/aoe/area_cleanse/proc/handle_item(obj/item/cleaned_item, list/structures_in_view, atom/caster)

	if(is_type_in_list(cleaned_item, GLOB.trash_loot))
		if(cleaned_item.contents) // if there's any kind of Stuff Inside that means it Might Be Important
			return
		qdel(cleaned_item) // begone muck!

	if(!(locate(elevated_structures) in cleaned_item.loc) && isturf(cleaned_item.loc) && length(structures_in_view))
		var/atom/chosen_structure = pick(structures_in_view)
		cleaned_item.throw_at(chosen_structure, aoe_radius, 2, spin = FALSE, gentle = TRUE)

	return

/datum/action/cooldown/spell/aoe/area_cleanse/proc/handle_living(mob/living/cleaned_mob, atom/caster)
	cleaned_mob.extinguish()
	cleaned_mob.set_wet_stacks(0)
	to_chat(cleaned_mob, span_notice("You feel squeaky clean."))
	// Remove all body temp changes
	cleaned_mob.body_temp_changes = list()
	if(iscarbon(cleaned_mob))
		var/mob/living/carbon/cleaned_carbon = cleaned_mob
		cleaned_carbon.reagents.add_reagent(/datum/reagent/space_cleaner, 5)
