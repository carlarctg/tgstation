
#define HOLDING_MODE "Clutch Spell"
#define RITUAL_MODE "Cast Ritual"

/datum/action/cooldown/spell/wild_magic
	name = "Wild Sorcery"
	desc = "A sorcerous ritual invented by now-extinct (due to wizards) dryads, much, much earlier than the first time anyone was called a 'wizard', this sorcery \
			effectively turns the essences of magic inside you into a constant, revolving tornado, bringing forth great power \
			but also making it extremely difficult to hold onto specific spells for more than one minute. \
			You may 'hold onto' a spell to try to keep it for a little while longer, but this strains the soul over time, and \
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
	var/upgrade_uses_left = 1
	var/current_mode = RITUAL_MODE

	/// Any of the spells in this list may be picked for rerolling. Local list, not global, which allows for admin abuse.
	var/list/possible_wild_spells = list()
	/// Funny rare spells, because why not. These are omitted from the initial selection of random spells.
	var/list/possible_rare_wild_spells = list(
			/datum/action/cooldown/spell/splattercasting,
			/datum/action/cooldown/spell/lichdom,
	)
	/// Rarely, something can go wrong and the wizard can get a spell that they really, really shouldn't get. (Not because of balance or anything)
	var/list/forbidden_wild_spells = list()
	/// Spells that won't work for some reason or another, despite having a reasonable school.
	var/list/barred_spells = list(
			/datum/action/cooldown/spell/conjure/soulstone/cult,
	)
	var/blacklisted_schools = list(SCHOOL_UNSET, SCHOOL_HOLY, SCHOOL_MIME, SCHOOL_FORBIDDEN)

/datum/action/cooldown/spell/wild_magic/New(Target, original)
	. = ..()
	var/static/list/base_spell_options
	var/static/list/rare_spell_options
	var/static/list/forb_spell_options
	if(!base_spell_options)
		base_spell_options = subtypesof(/datum/action/cooldown/spell)
		for(var/datum/action/cooldown/spell/spell as anything in base_spell_options)
			// Spells that probably aren't magical whatsoever, remove outright
			if(initial(spell.school) == SCHOOL_UNSET)
				base_spell_options -= spell
				continue
			// Spells from a Wrong magical school, removed from the main pool but kept in a rare one for hijinks.
			if(initial(spell.school) in blacklisted_schools)
				base_spell_options -= spell
				forb_spell_options += spell
				continue
			// Similar to above
			if(initial(spell.type) in possible_rare_wild_spells)
				base_spell_options -= spell
				rare_spell_options += spell
				continue
			// code-only parent types, not actually usable - remove
			if(initial(spell.name) == "Spell")
				base_spell_options -= spell
				continue
			// Spells that despite fitting the rest of the criteria still won't be good for one reason or another
			if(initial(spell.type) in barred_spells)
				base_spell_options -= spell
				continue

	// Done like this to allow for admin abuse.
	possible_wild_spells = base_spell_options
	possible_rare_wild_spells = rare_spell_options

/datum/action/cooldown/spell/wild_magic/proc/handle_modes()
	if(upgrade_uses_left || spell_level == 1)
		set_ritual()
	else
		set_holding()

/datum/action/cooldown/spell/wild_magic/proc/set_ritual()
	current_mode = RITUAL_MODE
	name = initial(name)
	desc = initial(desc)
	button_icon_state = initial(button_icon_state)
	cooldown_time = initial(cooldown_time)
	invocation = initial(invocation)

/datum/action/cooldown/spell/wild_magic/proc/set_holding()
	current_mode = HOLDING_MODE
	name = "Clutch Spell"
	desc = "Mentally 'hold on' to a spell, allowing you to keep it for one more cycle. This is exhausting, and drains 30% of your stamina."
	button_icon_state = initial(button_icon_state)
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

	if(ishuman(cast_on))
		var/mob/living/carbon/human/human_cast_on = cast_on
		// Mostly 'hurdur dryad' flavor, can be changed out at will. Won't happen if they've already changed their race to something else
		if(human_cast_on.dna.species.id == SPECIES_HUMAN)
			human_cast_on.set_species(/datum/species/pod)
			// Green like druids should be!
			human_cast_on.dna.features["mcolor"] = "#8ec94a"
			human_cast_on.dna.update_uf_block(DNA_MUTANT_COLOR_BLOCK)
			// No sense punishing them for keeping the aesthetic up. Outdated
			human_cast_on.dna.species.brutemod = 1
			human_cast_on.dna.species.burnmod = 1
			to_chat(cast_on, span_green("Your human anatomy is affected by the ritual, and morphs to that of one reminiscent of the druids of old. \
										You lack the brittleness of modern plant-people, but this form is not obligatory and may be altered if one wishes so."))

/datum/action/cooldown/spell/wild_magic/proc/cast_clutch(mob/living/cast_on)
	to_chat(cast_on, span_green("You hold on to something"))

/datum/action/cooldown/spell/wild_magic/level_spell(bypass_cap = FALSE)
	whirlwind_energy++
	reroll_spells()

/datum/action/cooldown/spell/wild_magic/proc/reroll_spells()

	playsound(owner, 'sound/magic/staff_healing.ogg', 25, TRUE)

	if(clutched_spell)
		to_chat(owner, span_green("You hold onto [clutched_spell] as the whirlwind of magic inside you spins out of control."))
		//owner.adjustStaminaLoss(40)
	else
		to_chat(owner, span_green("The revolving whirlwind of magic inside your soul spins ever faster, altering your spell[length(current_wild_spells) > 1 ? "s" : ""]!"))

	var/list/spells_to_delete = current_wild_spells - clutched_spell

	QDEL_LIST(spells_to_delete)

	var/local_energy = whirlwind_energy

	for(var/i in 1 to local_energy)

		var/random_energy_flux = rand(1, 100)

		var/datum/action/cooldown/spell/chosen_spell = pick(possible_wild_spells)

		var/level = 1
		switch(random_energy_flux)
			if(1)
				if(is_station_level(owner.z))
					to_chat(owner, span_hypnophrase("Your soul is overflowing with magic!"))
					chosen_spell = pick(possible_rare_wild_spells)
				else
					to_chat(owner, span_hypnophrase("A feeling of loss comes over you."))
			if(1 to 4)
				to_chat(owner, span_narsiesmall("You like feel something has gone deeply wrong."))
				chosen_spell = pick(forbidden_wild_spells)
				ADD_TRAIT(owner, TRAIT_ALLOW_HERETIC_CASTING, INNATE_TRAIT)
			if(4 to 7)
				var/choice = pick(subtypesof(/obj/item/gun/magic/staff))
				var/obj/item/gun/magic/staff/magic_staff = new choice(owner)
				ADD_TRAIT(magic_staff, TRAIT_NODROP, INNATE_TRAIT)
				owner.equip_to_slot_or_del(magic_staff, ITEM_SLOT_HANDS)
				if(magic_staff)
					to_chat(owner, span_userdanger("A staff appears in your hand! It feels brittle.."))
					chosen_spell = null
					playsound(owner.loc, 'sound/magic/summon_magic.ogg', 25, TRUE)
					QDEL_IN(magic_staff, 1 MINUTES)
				else
					to_chat(owner, span_notice("You have a sad feeling for a moment, then it passes."))
			if(7 to 15)
				local_energy++
				to_chat(owner, span_notice("You feel especially energetic!"))
			if(15 to 20)

		if(chosen_spell)
			var/datum/action/new_action = new chosen_spell(owner.mind || owner)
			new_action.Grant(owner)
			current_wild_spells += new_action
