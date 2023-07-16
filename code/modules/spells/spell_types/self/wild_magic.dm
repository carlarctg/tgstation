
#define HOLDING_MODE "Clutch Spell"
#define RITUAL_MODE "Cast Ritual"

/datum/action/cooldown/spell/wild_magic
	name = "Wild Sorcery"
	desc = "A sorcerous ritual invented by now-extinct dryads, much, much earlier than the first time anyone was called a 'wizard', this sorcery \
			effectively turns the essences of magic inside you into a constant, revolving tornado, bringing forth great power \
			but also making it extremely difficult to wield specific spells for more than one minute. \
			You may intentionally 'hold onto' a spell to try to keep it for a little while longer, but this strains the soul over time, and \
			is not recommended."
	button_icon_state = "splattercasting"

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 1 SECONDS

	invocation = "DRUUIDE' WHIRL!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_MIND
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY
	spell_max_level = 5
	var/list/current_wild_spells = list()
	var/datum/action/cooldown/spell/clutched_spell
	// How many spells will be rolled, with a chance for one or two at best more.
	var/whirlwind_energy = 0
	var/current_mode = RITUAL_MODE

	/// Any of the spells in this list may be picked for rerolling. Local list, not global, which allows for admin abuse.
	var/list/possible_wild_spells = list()
	/// Funny rare spells, because why not. These are omitted from the initial selection of random spells.
	// While they may be alarming, the chance of getting one of these is 1 in 100, and you need to be on the station.. so in short, not going to happen.
	var/list/possible_rare_wild_spells = list(
			/datum/action/cooldown/spell/splattercasting,
			/datum/action/cooldown/spell/lichdom,
	)
	/// Rarely, something can go wrong and the wizard can get a spell that they really, really shouldn't get. (Not because of balance or anything)
	var/list/forbidden_wild_spells = list()
	/// Spells that won't work for some reason or another, despite having a reasonable school.
	var/list/barred_spells = list(
			/datum/action/cooldown/spell/conjure/soulstone/cult,
			/datum/action/cooldown/spell/summon_mob,
			/datum/action/cooldown/spell/pointed/manse_link,
	)
	var/forbidden_schools = list(SCHOOL_HOLY, SCHOOL_MIME, SCHOOL_FORBIDDEN)
	// List of temporary objects created by odd happenings within rerolls.
	var/list/temporary_objects = list()

/datum/action/cooldown/spell/wild_magic/New(Target, original)
	. = ..()
	var/static/list/base_spell_options = list()
	var/static/list/rare_spell_options = list()
	var/static/list/forb_spell_options = list()
	if(!length(possible_wild_spells))
		base_spell_options = subtypesof(/datum/action/cooldown/spell)
		for(var/datum/action/cooldown/spell/spell as anything in base_spell_options)
			// Spells that probably aren't magical whatsoever, remove outright
			if(initial(spell.school) == SCHOOL_UNSET)
				base_spell_options -= spell
				continue
			// Spells from a Wrong magical school, removed from the main pool but kept in a rare one for hijinks.
			if(initial(spell.school) in forbidden_schools)
				base_spell_options -= spell
				forb_spell_options += spell
				continue
			// Similar to above
			if(spell in possible_rare_wild_spells)
				base_spell_options -= spell
				rare_spell_options += spell
				continue
			// code-only parent types, not actually usable - remove
			if(initial(spell.name) == "Spell")
				base_spell_options -= spell
				continue
			// Spells that despite fitting the rest of the criteria still won't be good for one reason or another
			if(spell in barred_spells)
				base_spell_options -= spell
				continue

	// Done like this to allow for admin abuse.
	possible_wild_spells = base_spell_options
	possible_rare_wild_spells = rare_spell_options
	forbidden_wild_spells = forb_spell_options

/datum/action/cooldown/spell/wild_magic/Destroy()
	STOP_PROCESSING(SSwild_magic, src)
	return ..()

/datum/action/cooldown/spell/wild_magic/process(seconds_per_tick)
	reroll_spells()

/datum/action/cooldown/spell/wild_magic/proc/handle_modes()
	if(!whirlwind_energy)
		set_ritual()
	else
		set_holding()
	owner.update_action_buttons()

/datum/action/cooldown/spell/wild_magic/proc/set_ritual()
	current_mode = RITUAL_MODE
	name = initial(name)
	desc = initial(desc)
	button_icon_state = initial(button_icon_state)
	cooldown_time = initial(cooldown_time)
	invocation = initial(invocation)

/datum/action/cooldown/spell/wild_magic/proc/set_holding()
	current_mode = HOLDING_MODE
	name = "Clutch Spell or Reroll"
	desc = "Mentally 'hold on' to a spell, allowing you to keep it for one more cycle. This is exhausting, and drains 40% of your stamina. You can also use RMB and force a reroll, which is extremely draining and can be done only once every five minutes, blocking Clutching as well."
	button_icon_state = "chuuni"
	cooldown_time = 1.5 MINUTES
	invocation = null

/datum/action/cooldown/spell/wild_magic/cast(mob/living/cast_on)
	. = ..()

	handle_modes()

	if(current_mode == RITUAL_MODE)
		cast_ritual(cast_on)
	else
		cast_clutch(cast_on)

/datum/action/cooldown/spell/wild_magic/proc/cast_ritual(mob/living/cast_on)
	to_chat(cast_on, span_green("You close your eyes and feel the magical essence inside you. You start to twist it, causing it to revolve in place..."))
	//make clsoe eyes
	cast_on.set_temp_blindness(3 SECONDS)

	if(!do_after(cast_on, 3 SECONDS))
		to_chat(cast_on, span_warning("Your focus is broken, and the essence inside slowly stills."))
		cast_on.set_temp_blindness(0 SECONDS)
		return

	cast_on.set_temp_blindness(0 SECONDS)
	playsound(cast_on, 'sound/effects/pope_entry.ogg', 100)
	to_chat(cast_on, span_danger("Your essence spins in place quicker and quicker, until you can't stand feeling it no longer! You open your eyes and feel a tornado of violent, yet powerful magic inside you."))

	whirlwind_energy++
	START_PROCESSING(SSwild_magic, src)

	if(ishuman(cast_on))
		var/mob/living/carbon/human/human_cast_on = cast_on
		// Mostly 'hurdur dryad' flavor, can be changed out at will. Won't happen if they've already changed their race to something else
		if(human_cast_on.dna.species.id == SPECIES_HUMAN)
			// Green like druids should be!
			human_cast_on.dna.features["mcolor"] = "#8ec94a"
			human_cast_on.dna.update_uf_block(DNA_MUTANT_COLOR_BLOCK)
			human_cast_on.set_species(/datum/species/pod)
			// No sense punishing them for keeping the aesthetic up. Outdated
			human_cast_on.dna.species.brutemod = 1
			human_cast_on.dna.species.burnmod = 1
			to_chat(cast_on, span_green("Your human anatomy is affected by the ritual, and morphs to that of one reminiscent of the druids of old. \
										You lack the brittleness of modern plant-people, but this form is not obligatory and may be altered if one wishes so."))

/datum/action/cooldown/spell/wild_magic/proc/cast_clutch(mob/living/cast_on)
	var/list/clutchable_spells = list()
	for(var/datum/action/cooldown/spell/clutched_spell as anything in current_wild_spells)
		var/image/item_image = image(icon = clutched_spell.button_icon, icon_state = clutched_spell.button_icon_state)
		clutchable_spells[clutched_spell.name] = item_image

	var/choice = show_radial_menu(cast_on, anchor = cast_on, choices = clutchable_spells)

	if(choice)
		to_chat(cast_on, span_green("You prepare yourself to hold on to [choice], which will drain your stamina moderately but allow you to mantain it for one more minute."))
		clutched_spell = choice
		cooldown

// doesnt work
/datum/action/cooldown/spell/wild_magic/InterceptClickOn(mob/living/caller, params, atom/click_target) // 'cast_roll()'
	if(!(LAZYACCESS(params2list(params), RIGHT_CLICK) && (current_mode == HOLDING_MODE)))
		return FALSE
	if(!IsAvailable(feedback = TRUE))
		return FALSE
	if(!do_after(caller, 2 SECONDS, timed_action_flags = IGNORE_USER_LOC_CHANGE|IGNORE_INCAPACITATED))
		return FALSE
	to_chat(caller, span_green("You focus your entire being and energy on forcing the magical whirlwind to change directions! You feel very exhausted."))
	caller.adjustStaminaLoss(90)
	reroll_spells()
	StartCooldown(/*5*/ 0.5 MINUTES)

/datum/action/cooldown/spell/wild_magic/level_spell(bypass_cap = FALSE)
	..()
	whirlwind_energy++
	reroll_spells()
	playsound(owner, 'sound/magic/staff_healing.ogg', 25, TRUE)
	to_chat(owner, span_green("Your internal whirlwind gains even more speed! You will roll at least [whirlwind_energy] new spells every minute."))

/datum/action/cooldown/spell/wild_magic/proc/reroll_spells()

	playsound(owner, 'sound/magic/staff_healing.ogg', 25, TRUE)

	var/local_energy = whirlwind_energy

	if(clutched_spell)
		to_chat(owner, span_green("You hold onto [clutched_spell] as the whirlwind of magic inside you spins out of control, leaving you exhausted."))
		var/mob/living/lowner = owner
		lowner.adjustStaminaLoss(40)
		local_energy--
	else
		to_chat(owner, span_green("The revolving whirlwind of magic inside your soul spins ever faster, altering your spell[length(current_wild_spells) > 1 ? "s" : ""]!"))

	var/list/spells_to_delete = current_wild_spells - clutched_spell

	QDEL_NULL(clutched_spell)

	// Remove mime spell gesturing bypass
	UnregisterSignal(owner, COMSIG_MOB_TRY_INVOKE_SPELL)
	// Remove all temp. objects
	QDEL_LIST(temporary_objects)
	// Remove all previous spells
	QDEL_LIST(spells_to_delete)

	// There's only one attempt to summon a magic item per wild magic roll.
	var/attempted_to_summon_item = FALSE
	for(var/i in 1 to local_energy)

		var/random_energy_flux = rand(1, 100)
		// Increased luck the more leveled it is. The way it works is by reducing the number by how leveled your spell is.
		// Which effectively means that each level is an increase of roughly 2% in luck.
		// Doesn't sound like a lot, but consider it rolls for each spell in the list, and at level 5 that's 10% more luck for five rolls.
		if(random_energy_flux > spell_level)
			random_energy_flux = clamp(random_energy_flux, 1, random_energy_flux - ((spell_level - 1) * 2))

		var/datum/action/cooldown/spell/chosen_spell = pick(possible_wild_spells)

		// Reroll a spell if it's a dupe, unless it doesn't feel like it. Or lands on the same thing.
		if(is_type_in_list(chosen_spell, current_wild_spells) && prob(66))
			chosen_spell = pick(possible_wild_spells)

		// If the spell's going to level up, applied at the end of the chain.
		var/level_spell = FALSE

		// The magic item that's summoned if you get lucky enough, and don't have anything in your hands. Can't be dropped, disappears in one minute.
		var/obj/item/magic_item
		switch(random_energy_flux)
			// 1% chance to get Lich or Splattercasting. As stated in the rare spells variable, this is unlikely, and fun.
			if(1)
				if(is_station_level(owner.z))
					to_chat(owner, span_hypnophrase("Your soul is overflowing with magic!"))
					chosen_spell = pick(possible_rare_wild_spells)
				else
					to_chat(owner, span_hypnophrase("A feeling of loss comes over you."))
			// 2% chance to get spell you're not meant to get. (Within reason)
			// If it's a heretic spell, you temporarily gain the ability to cast without a focus.
			// If it's a mime spell, you temporarily go mute (and get a snowflake allowance for general spellcasting)
			if(1 to 3)
				to_chat(owner, span_hypnophrase("You're pretty sure you're not supposed to have this..."))
				chosen_spell = pick(forbidden_wild_spells)
				if(initial(chosen_spell.school) == SCHOOL_FORBIDDEN)
					ADD_TRAIT(owner, TRAIT_ALLOW_HERETIC_CASTING, INNATE_TRAIT)
					to_chat(owner, span_hierophant("You feel like you've gained some knowledge of the forbidden arts. Probably not a good thing."))
					// Not necessary, but fun flavor.
					magic_item = new /obj/item/clothing/neck/heretic_focus(owner)
					if(owner.equip_to_slot_or_del(magic_item, ITEM_SLOT_NECK))
						to_chat(owner, span_warning("A forbidden necklace appears on your neck! It twitches uncomfortable in your presence, but stills."))
						ADD_TRAIT(magic_item, TRAIT_NODROP, INNATE_TRAIT)
						temporary_objects.Add(magic_item)
				else if(initial(chosen_spell.school) == SCHOOL_MIME)
					ADD_TRAIT(owner, TRAIT_MIMING, INNATE_TRAIT)
					RegisterSignal(owner, COMSIG_MOB_TRY_INVOKE_SPELL, PROC_REF(gesture_casting_override))
					to_chat(owner, span_grey("You feel like keeping your mouth shut for now."))
					// Not necessary, but fun flavor.
					magic_item = new /obj/item/clothing/mask/gas/mime(owner)
					if(owner.equip_to_slot_or_del(magic_item, ITEM_SLOT_MASK))
						to_chat(owner, span_warning("A mime's mask appears on your face! You scream in terror! Wait, no you don't."))
						ADD_TRAIT(magic_item, TRAIT_NODROP, INNATE_TRAIT)
						temporary_objects.Add(magic_item)
			// 2% chance to get a magic item, if your hands are empty.
			if(3 to 5)
				if(attempted_to_summon_item)
					to_chat(owner, span_notice("You have a feeling of loss for a moment, then it passes."))
					continue
				attempted_to_summon_item = TRUE

				var/list/static/possible_magic_items = list(
					/obj/item/singularityhammer,
					/obj/item/mjollnir,
					/obj/item/highfrequencyblade/wizard,
					/obj/item/necromantic_stone,
				) + subtypesof(/obj/item/gun/magic/staff)

				// Useless and unfun
				possible_magic_items.Remove(list(/obj/item/gun/magic/staff/healing))

				var/choice = pick(possible_magic_items)
				magic_item = new choice(owner)
				ADD_TRAIT(magic_item, TRAIT_NODROP, INNATE_TRAIT)
				if(owner.equip_to_slot_or_del(magic_item, ITEM_SLOT_HANDS))
					to_chat(owner, span_userdanger("\A [magic_item] appears in your hand! It glues itself to your hand, but it feels ephemeral in your grasp."))
					chosen_spell = null
					playsound(owner.loc, 'sound/magic/summon_magic.ogg', 25, TRUE)
					temporary_objects.Add(magic_item)
				else
					to_chat(owner, span_notice("You have a sad feeling for a moment, then it passes."))
					qdel(magic_item)
			// 3% chance for an extra roll! Yay!
			if(5 to 9)
				local_energy++
				to_chat(owner, span_notice("You feel especially energetic!"))
			// 4$ chance for that spell to get leveled up at the end.
			if(9 to 13)
				level_spell = TRUE
				to_chat(owner, span_notice("You feel slightly more competent at casting [initial(chosen_spell.name)]!"))

		if(chosen_spell)
			var/datum/action/cooldown/spell/new_action = new chosen_spell(owner.mind || owner)
			new_action.Grant(owner)
			if(level_spell)
				new_action.level_spell()
			// Make it obvious it's a 'wild magic' spell, to avoid confusion.
			new_action.background_icon_state = "bg_nature"
			//new_action.overlay_icon_state = "bg_nature_border" Keep the border though, to help clarify!
			// The HUD gets weird if the buttons aren't updated.
			owner.update_action_buttons()
			RegisterSignal(new_action, COMSIG_QDELETING, PROC_REF(remove_from_list))
			current_wild_spells += new_action

/datum/action/cooldown/spell/wild_magic/proc/remove_from_list(datum/action/new_action)
	current_wild_spells -= new_action

/datum/action/cooldown/spell/wild_magic/proc/gesture_casting_override()
	return SPELL_INVOCATION_ALWAYS_SUCCEED

/datum/action/cooldown/spell/wild_magic/get_spell_title()
	switch(spell_level)
		if(2)
			return "Revolving "
		if(3)
			return "Whirlwind of "
		if(4)
			return "Hurricane of "
		if(5)
			return "Dryad's Own "
		if(6)
			return "Perfect "

	return ""
