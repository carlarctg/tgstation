/datum/mutation/human/biotechcompat
	name = "Biotech Compatibility"
	desc = "Subject is more compatibile with biotechnology such as skillchips."
	quality = POSITIVE
	instability = 5

/datum/mutation/human/biotechcompat/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	owner.adjust_skillchip_complexity_modifier(1)

/datum/mutation/human/biotechcompat/on_losing(mob/living/carbon/human/owner)
	owner.adjust_skillchip_complexity_modifier(-1)
	return ..()

/datum/mutation/human/clever
	name = "Clever"
	desc = "Causes the subject to feel just a little bit smarter. Most effective in specimens with low levels of intelligence."
	quality = POSITIVE
	instability = 20
	text_gain_indication = "<span class='danger'>You feel a little bit smarter.</span>"
	text_lose_indication = "<span class='danger'>Your mind feels a little bit foggy.</span>"

/datum/mutation/human/clever/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.add_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE), GENETIC_MUTATION)

/datum/mutation/human/clever/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.remove_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE), GENETIC_MUTATION)

/datum/mutation/human/good_looking
	name = "Good Looking"
	desc = "A long lineage of strong genes has made this person look somewhat good compared to most, although it does make them a bit vain most likely."
	quality = POSITIVE
	locked = TRUE
	text_gain_indication = "<span class='notice'>You feel like you're looking good!</span>"
	text_lose_indication = "<span class='notice'>You no longer feel like like a prince charming.</span>"

/datum/mutation/human/good_looking/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.AddElement(/datum/element/beauty, GOOD_LOOKING_BEAUTY_LEVEL) //what a sigh to behold!
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/mutation/human/good_looking/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_PARENT_EXAMINE)


/datum/mutation/human/good_looking/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice("They are very good looking.")
