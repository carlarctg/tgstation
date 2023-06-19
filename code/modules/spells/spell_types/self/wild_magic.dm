
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
		human_cast_on.dropItemToGround(human_cast_on.w_uniform)
		human_cast_on.dropItemToGround(human_cast_on.wear_suit)
		human_cast_on.dropItemToGround(human_cast_on.head)

/datum/action/cooldown/spell/wild_magic/proc/cast_clutch(mob/living/cast_on)
	to_chat(cast_on, span_green(""))

/datum/action/cooldown/spell/wild_magic/level_spell(bypass_cap = FALSE)
	whirlwind_energy++
	reroll_spells()

/datum/action/cooldown/spell/wild_magic/proc/reroll_spells()
