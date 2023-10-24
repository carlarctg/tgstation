/obj/item/book/granter/action/spell/area_cleanse
	granted_action = /datum/action/cooldown/spell/aoe/area_cleanse
	action_name = "area cleanse"
	icon_state = "bookaraecleanse"
	desc = "Essential reading for all stay-at-home wizards and witches."
	remarks = list(
		"This incantation sounds familiar...",
		"This is useless... wait, what if I get set on fire?",
		"Is this why wizards don't go to the bathroom?",
		"I'm never going to need a shower again!",
	)

/obj/item/book/granter/action/spell/area_cleanse/Initialize(mapload)
	. = ..()
	add_overlay("+bookareacleanse_overlay")
