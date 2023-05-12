/datum/antagonist/protagonist/nanotrasen_superweapon
	name = "Nanotrasen superweapon"
	outfit_type = /datum/outfit/superweapon
	min_age = 25
	max_age = 50
	var/letter = "T"

/datum/antagonist/protagonist/nanotrasen_superweapon/on_gain()
	. = ..()
	var/mob/living/carbon/human/superweapon_human = owner.current

	superweapon_human.maxHealth = 75
	superweapon_human.health = min(superweapon_human.health, superweapon_human.maxHealth)

	var/datum/mutation/human/superweapon/mutation = superweapon_human.dna.add_mutation(/datum/mutation/human/superweapon, MUT_OTHER)
	letter = mutation.get_letter()
	ADD_TRAIT(superweapon_human, TRAIT_CHUNKYFINGERS, GENETIC_MUTATION) //same issue with thick fingers being weird but they're a frail superweapon, i want them using that

	addtimer(CALLBACK(src, PROC_REF(announce_arrival), 10 SECONDS))

/datum/antagonist/protagonist/nanotrasen_superweapon/equip_protagonist()
	. = ..()
	var/jargon = ""
	for(var/i in 1 to rand(1, 3))
		if(prob(30))
			jargon += ascii2text(rand(65, 90)) //A - Z
		else
			jargon += ascii2text(rand(48, 57)) //0 - 9
	var/new_name = "Experiment [letter + "-" + jargon] '[owner.current.first_name()]'"
	owner.current.fully_replace_character_name(owner.current.real_name, new_name)

/datum/antagonist/protagonist/nanotrasen_superweapon/greet()
	. = ..()
	to_chat(owner.current, span_greenannounce("You are a test subject from Central Command. The genetic modifications have left you weak and frail, and your slow metamorphosis into a real \
	superweapon will be difficult. Did I mention you are a lucrative target for those looking to set back Nanotrasen?"))
	owner.announce_objectives()

/datum/antagonist/protagonist/nanotrasen_superweapon/proc/announce_arrival()
	. = ..()
	minor_announce("Your research division has been sent a promising test subject from Central Command's genetic superweapon project. Please protect them from hostile forces and prepare them for further potential unlocking.", "Superweapon")
	SEND_SOUND(world, sound('sound/ambience/protag/superweapon.ogg', volume = 50))
