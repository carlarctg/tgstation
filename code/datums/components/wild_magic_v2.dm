

/**
 * # wild_magic component!
 *
 * Component that makes casted spells cost blood from the user and dramatically lowers their cooldown.
 */
/datum/component/wild_magic
	var/list/current_wild_spells = list()
	// Roughly how many spells/objects are given per cycle.
	var/whirlwind_energy = 1
	// Any of the spells in this list may be picked for rerolling. Local list, not global, which allows for admin abuse.
	var/list/possible_wild_spells = list()
	// Any of the objects in this list may be picked randomly. Local list, not global, which allows for admin abuse.
	var/list/possible_wild_objects = list()
	// Spells that won't work for some reason or another, despite having a reasonable school.
	var/static/list/barred_spell_types = list(
			/datum/action/cooldown/spell/summon_mob,
	)
	var/forbidden_schools = list(SCHOOL_HOLY, SCHOOL_MIME, SCHOOL_FORBIDDEN)
	// List of temporary objects created by odd happenings within rerolls.
	var/list/temporary_objects = list()
	// This 'spell' is used to xxxx'
	var/datum/action/cooldown/spell/wild_magic/wild_magic_action
	// traits added and removed by the component.
	var/static/list/wild_traits = list(TRAIT_NO_SPECIES_CHANGE)

/datum/component/wild_magic/Initialize(list/override_wild_spells, list/override_wild_spells)
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	if(override_wild_spells)
		possible_wild_spells = override_wild_spells
	else if(!length(possible_wild_spells))
		for(var/datum/action/cooldown/spell/spell as anything in subtypesof(/datum/action/cooldown/spell))
			// Spells that probably aren't magical whatsoever, remove outright
			if(initial(spell.school) == SCHOOL_UNSET)
				continue
			// Spells from a Wrong magical school
			if(initial(spell.school) in forbidden_schools)
				continue
			// code-only parent types, not actually usable - remove
			if(initial(spell.name) == "Spell")
				continue
			// Spells that aren't properly mantained
			if(initial(spell.type) in typesof(barred_spells))
				continue
			possible_wild_spells |= spell

	START_PROCESSING(SSwild_magic, src)
	parent.add_traits(wild_traits, REF(src))

/datum/component/wild_magic/Destroy()
	parent.remove_traits(wild_traits, REF(src))
	STOP_PROCESSING(SSwild_magic, src)
	QDEL_LIST(current_wild_spells)
	QDEL_LIST(temporary_objects)
	return ..()

/datum/component/wild_magic/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_SPECIES_LOSS, PROC_REF(on_species_change))
	RegisterSignal(parent, COMSIG_MOB_SPELL_PROJECTILE, PROC_REF(on_spell_projectile))
	RegisterSignal(parent, COMSIG_MOB_PURCHASE_SPELL, PROC_REF(on_spell_purchase))

/datum/component/wild_magic/proc/on_spell_purchase(mob/user, datum/spellbook_entry/wild_magic/entry_type)
	SIGNAL_HANDLER
	if(!istype(entry_type))
		return

	whirlwind_energy++
	reroll_spells()
	playsound(user, 'sound/magic/staff_healing.ogg', 25, TRUE)
	to_chat(user, span_green("Your internal whirlwind gains even more speed! You will roll at least [whirlwind_energy] new spells every minute."))

/datum/component/wild_magic/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_SPECIES_LOSS, COMSIG_MOB_SPELL_PROJECTILE))

/datum/component/wild_magic/process(seconds_per_tick)
	reroll_spells()

/datum/component/wild_magic/proc/reroll_spells()

	var/mob/living/owner = parent

	playsound(owner, 'sound/magic/staff_healing.ogg', 25, TRUE)
	to_chat(owner, span_green("The revolving whirlwind of magic inside your soul spins ever faster, reshaping your spell[length(current_wild_spells) > 1 ? "s" : ""]!"))

	// Remove all temp. objects
	QDEL_LIST(temporary_objects)
	// Remove all previous spells
	QDEL_LIST(current_wild_spells)

	var/local_energy = whirlwind_energy
	// Classic for loop as we have a chance to increase local_energy in the loop.
	for(var/i = 1, i <= local_energy, i++)
		if(prob(whirlwind_energy)) // 1-5% chance of an extra spell (but it triggers each loop)
			local_energy++
			to_chat(owner, span_green("You feel a little bit more magical."))

		// 1-5% chance for a temporary magical object.
		if(prob(whirlwind_energy))
			var/list/static/possible_magic_items = subtypesof(/obj/item/gun/magic/staff) + list(
				/obj/item/singularityhammer,
				/obj/item/mjollnir,
				/obj/item/highfrequencyblade/wizard,
				/obj/item/necromantic_stone,
			)

			var/choice = pick(possible_magic_items)
			var/obj/item/magic_item = new choice(owner)
			if(owner.equip_to_slot_or_del(magic_item, ITEM_SLOT_HANDS))
				to_chat(owner, span_userdanger("\A [magic_item] appears in your hand!"))
				chosen_spell = null
				playsound(owner.loc, 'sound/magic/summon_magic.ogg', 25, TRUE)
				temporary_objects.Add(magic_item)
			else
				to_chat(owner, span_notice("You have a sad feeling for a moment, then it passes."))
				qdel(magic_item)

		var/datum/action/cooldown/spell/chosen_spell = pick(possible_wild_spells)

		// If spell is a dupe, 90-75% chance of rerolling it once.
		if(is_type_in_list(chosen_spell, current_wild_spells) && prob(90 - whirlwind_energy * 3))
			chosen_spell = pick(possible_wild_spells)

		if(chosen_spell)
			var/datum/action/cooldown/spell/new_action = new chosen_spell(owner.mind || owner)
			new_action.Grant(owner)
			// Make it obvious it's a 'wild magic' spell, to avoid confusion.
			new_action.background_icon_state = "bg_nature"
			new_action.overlay_icon_state = "bg_nature_border"
			// The HUD gets weird if the buttons aren't updated.
			owner.update_action_buttons()
			RegisterSignal(new_action, COMSIG_QDELETING, PROC_REF(remove_from_list))
			current_wild_spells += new_action

		// 3-15% chance to upgrade a random spell (could be one that already was!)
		if(prob(spell_level * 3))
			var/datum/action/cooldown/spell/upgrader = pick(current_wild_spells)
			upgrader.level_spell()
			to_chat(owner, span_notice("You feel slightly more competent at casting [upgrader]!"))

/datum/component/wild_magic/proc/remove_from_list(datum/action/new_action)
	current_wild_spells -= new_action

/datum/action/cooldown/spell/wild_magic
	name = "Wild Sorcery"
	desc = "A sorcerous ritual invented by now-extinct dryads, this sorcery \
			effectively turns the essences of magic inside you into a constant, revolving tornado, bringing forth great power, \
			but also making it impossible to wield specific spells for more than one minute."
	button_icon_state = "splattercasting"

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 1 SECONDS

	invocation = "DRUUIDE' WHIRL!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_MIND
	spell_max_level = 5

/datum/action/cooldown/spell/wild_magic/cast(mob/living/cast_on)
	. = ..()

	if(DOING_INTERACTION(cast_on, src))
		return

	to_chat(cast_on, span_green("You close your eyes and feel the magical essence inside you. You start to twist it, causing it to revolve in place..."))
	//make clsoe eyes
	cast_on.set_temp_blindness(3 SECONDS)

	if(!do_after(cast_on, 3 SECONDS, src))
		to_chat(cast_on, span_warning("Your focus is broken, and the essence inside slowly stills."))
		cast_on.set_temp_blindness(0 SECONDS)
		return

	cast_on.set_temp_blindness(0 SECONDS)
	playsound(cast_on, 'sound/effects/pope_entry.ogg', 100)
	to_chat(cast_on, span_danger("Your essence spins in place quicker and quicker, until you can't stand feeling it no longer! You open your eyes and feel a tornado of violent, yet powerful magic inside you."))

	cast_on.set_species(/datum/species/pod/dryad)
	cast_on.AddComponent(/datum/component/wild_magic)
	qdel(src)


// should never happen
/datum/component/wild_magic/proc/on_species_change(mob/living/carbon/source, datum/species/lost_species)
	SIGNAL_HANDLER
	qdel(src)

///signal sent when the parent casts a spell that has a projectile
/datum/component/wild_magic/proc/on_spell_projectile(mob/living/carbon/source, datum/action/cooldown/spell/spell, atom/cast_on, obj/projectile/to_fire)
	SIGNAL_HANDLER

	if(spell.school == SCHOOL_SANGUINE) // lime blood trolls were slaughtered eons ago
		return

	playsound(source, 'sound/effects/wounds/splatter.ogg', 60, TRUE, -1)
	to_fire.color = COLOR_SERVICE_LIME
	to_fire.name = "wild [to_fire.name]"
	to_fire.set_light(2, 2, LIGHT_COLOR_VIVID_GREEN, TRUE)
