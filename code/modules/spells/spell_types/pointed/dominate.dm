/datum/action/cooldown/spell/pointed/dominate
	name = "Dominate"
	desc = "This spell dominates the mind of a lesser creature to your side!"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "dominate"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'

	school = SCHOOL_EVOCATION
	cooldown_time = 1 MINUTES
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

	cast_range = 7
	active_msg = "You prepare to dominate the mind of a target..."
	var/faction_to_set
	var/dominate_caston_msg = "Your feel someone attempting to subject your mind to terrible machinations!"

/datum/action/cooldown/spell/pointed/dominate/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE

	var/mob/living/animal = cast_on
	if(animal.mind)
		return FALSE
	if(animal.stat == DEAD)
		return FALSE
	if(!animal.compare_sentience_type(SENTIENCE_ORGANIC)) // Will also return false if not a basic or simple mob, which are the only two we want anyway
		return FALSE
	if(faction_to_set in animal.faction)
		return FALSE

	return animal

/datum/action/cooldown/spell/pointed/dominate/cast(mob/living/simple_animal/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_warning(dominate_caston_msg))
		to_chat(owner, span_warning("[cast_on] resists your domination!"))
		return FALSE

	cast_on.faction |= faction_to_set
	handle_conversion(cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/dominate/crown
	name = "Sway Peon"
	desc = "This spell dominates the mind of a lesser creature, joining you in your court as a loyal servant."
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "dominate"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'

	school = SCHOOL_EVOCATION
	cooldown_time = 1 MINUTES
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

	cast_range = 7
	active_msg = "You prepare to sway the mind of a creature..."
	dominate_caston_msg = "Your feel a royal presence in your mind attempting to sway you!"
	faction_to_set = null

/datum/action/cooldown/spell/pointed/dominate/crown/Grant(mob/grant_to)
	. = ..()
	faction_to_set |= grant_to.faction

/datum/action/cooldown/spell/pointed/dominate/cult
	name = "Dominate"
	desc = "This spell dominates the mind of a lesser creature to the will of Nar'Sie, \
		allying it only to her direct followers."
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "dominate"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'

	school = SCHOOL_EVOCATION
	cooldown_time = 1 MINUTES
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	// An UNHOLY, MAGIC SPELL that INFLUECNES THE MIND - all things work here, logically
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY|MAGIC_RESISTANCE_MIND

	cast_range = 7
	active_msg = "You prepare to dominate the mind of a target..."
	faction_to_set = FACTION_CULT

/datum/action/cooldown/spell/pointed/dominate/cult/is_valid_target(atom/cast_on)
	var/mob/living/animal = ..()

	if(!animal || HAS_TRAIT(animal, TRAIT_HOLY))
		return FALSE

	return animal

/datum/action/cooldown/spell/pointed/dominate/cult/handle_conversion(mob/living/simple_animal/cast_on)
	var/turf/cast_turf = get_turf(cast_on)
	cast_on.add_atom_colour("#990000", FIXED_COLOUR_PRIORITY)
	playsound(cast_turf, 'sound/effects/ghost.ogg', 100, TRUE)
	new /obj/effect/temp_visual/cult/sac(cast_turf)
