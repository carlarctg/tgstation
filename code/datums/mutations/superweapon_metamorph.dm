///special protagonist only mutation that makes the user have to cocoon every 15 minutes, granting a slew of positive and negative mutations (the negative ones unremovable)
/datum/mutation/human/superweapon
	name = "Genetic Superweapon"
	desc = "Analysis of the genetic structure of this patient has lead to pure confusion on the absolute level of biological sabotage. Occasionally, the patient will \
	need to \"molt\" and further develop their potential."
	text_gain_indication = "You feel REALLY unstable."
	text_lose_indication = "You feel your genes settling."
	quality = NEGATIVE
	//time_coeff = 2
	locked = TRUE //protagonists only!

	///what sets of mutations to grant with each cocooning
	var/metamorph_path
	var/datum/metamorph_type/metamorph_type

	///how many times they've cocooned
	var/progress

	///timer until the owner gets a warning about the cocoon
	var/warning_timer
	///timer until the next cocoon
	var/metamorph_timer

	/// Cocoon bits to store for later usage.
	var/list/cocoon_bits
	/// Main pod the dude is store din or something. This is getting so fucking bloated
	var/obj/structure/chrysalis_pod/host_chrysalis_pod

/datum/mutation/human/superweapon/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	metamorph_path = pick(SUPERWEAPON_PSIONICS, SUPERWEAPON_CRYONICS)

	if(metamorph_path == SUPERWEAPON_PSIONICS)
		metamorph_type = new /datum/metamorph_type/psionics(src)

	if(metamorph_path == SUPERWEAPON_CRYONICS)
		metamorph_type = new /datum/metamorph_type/cryonics(src)

	//if(metamorph_path == SUPERWEAPON_SWAPLING)
	//	metamorph_type = /datum/metamorph_type/swapling // make them get abductor organs?

	var/random_variation = rand(-5, 5) MINUTES

	warning_timer = addtimer(CALLBACK(src, PROC_REF(warning)), (METAMORPH_COCOON_TIME + random_variation) - 15 SECONDS)
	metamorph_timer = addtimer(CALLBACK(src, PROC_REF(metamorph)), (METAMORPH_COCOON_TIME + random_variation))

/datum/mutation/human/superweapon/proc/get_letter()
	return metamorph_type ? metamorph_type.letter : "T"

/// Warn the SW they're about to get cocooned.
/datum/mutation/human/superweapon/proc/warning()
	to_chat(owner, span_boldwarning("Your genes begin to feel unsettled. you are going to cocoon soon, and should find some safe place for this!"))
	owner.set_jitter_if_lower(2 MINUTES)

/// Begin the metamorphosis process.
/datum/mutation/human/superweapon/proc/metamorph()

	owner.visible_message(
		span_warning("A chrysalis forms around [owner], sealing them inside."),
		span_userdanger("You begin uncontrollably vomiting a resinous cocoon that forms around you!")
	)

	owner.visible_message(
		span_warning("[owner] vomits a chunk of disgusting, pulsating organic mass under their feet that begins rapidly growing and mutating!"),
		span_userdanger("You begin uncontrollably vomiting a resinous cocoon that forms around you!")
	)
	owner.set_jitter_if_lower(1.5 MINUTES)
	owner.Stun(45 SECONDS)

	// Vomit a node into the current tile.
	var/turf/cocoon_turf = get_turf(owner)
	playsound(cocoon_turf, 'sound/effects/splat.ogg', 50, 1)
	LAZYADD(cocoon_bits, new /obj/structure/alien/weeds/node/superweapon_cocoon(cocoon_turf, metamorph_type))
	// Most alterations by the cocoon will spew a small amount of a random gas, to make things even trippier. Handled by init and destroy on the objects themselves.
	// Shouldn't cause *too* much trouble and will be funny.

	// Run this proc for each tile next to the victim, with the proc being delayed by 0.4 seconds multiplied by the amount of nearby open tiles.
	var/counter = 0
	for(var/turf/open/cocoonable_ground in orange(1, cocoon_turf))
		addtimer(CALLBACK(src, PROC_REF(bleoeurghf), cocoonable_ground), 0.4 SECONDS * counter) // timer runs fast
		counter++

	// After everything is in place, plus one second for suspense, pod 'em.
	do_after(owner, (counter * 0.4 SECONDS) + 1 SECONDS, timed_action_flags = IGNORE_HELD_ITEM|IGNORE_USER_LOC_CHANGE|IGNORE_INCAPACITATED)
	host_chrysalis_pod = new(cocoon_turf, metamorph_type)
	owner.forceMove(host_chrysalis_pod)
	owner.visible_message(
		span_warning("[owner] disappears inside [host_chrysalis_pod]!"),
		span_userdanger("Moving by an unknown impulse, you enter [host_chrysalis_pod] and go into deep hibernation.")
	)

	// Cocoon will break now.
	addtimer(CALLBACK(src, PROC_REF(finish_morpheus)), 45 SECONDS)

/// Spread 'Slime' on the nearby tiles, which will blossom into a cocoon wall in a second.
/datum/mutation/human/superweapon/proc/bleoeurghf(turf/open/cocoonable_ground)
	cocoonable_ground.visible_message(span_warning("Disgusting slime creeps out of the main node on [cocoonable_ground] and begins rapidly growing upwards!"))
	var/cocoon = new /obj/structure/alien/weeds/superweapon_cocoon(cocoonable_ground, metamorph_type)
	playsound(cocoon, 'sound/effects/splat.ogg', 50, TRUE)
	LAZYADD(cocoon_bits, cocoon)
	addtimer(CALLBACK(src, PROC_REF(hurghlr), cocoonable_ground), 1 SECONDS)

/// The wall blossoming.
/datum/mutation/human/superweapon/proc/hurghlr(turf/open/cocoonable_ground)
	var/cocoon = new /obj/structure/alien/resin/wall/superweapon_cocoon(cocoonable_ground, metamorph_type)
	playsound(cocoon, 'sound/effects/attackblob.ogg', 50, TRUE)
	LAZYADD(cocoon_bits, cocoon)

/// Finish the process, breaking the walls down in random order with random timing, maximum one second. Do the effects on the victim.
/datum/mutation/human/superweapon/proc/finish_morpheus()

	playsound(owner, 'sound/effects/blobattack.ogg', 50, TRUE)
	for(var/obj/structure/alien/resin/wall/superweapon_cocoon/cocoon_wall in cocoon_bits)
		addtimer(CALLBACK(src, PROC_REF(shwip), cocoon_wall), rand(0.2 SECONDS, 1 SECONDS)) // randomly breaks to cause a cool effect

	host_chrysalis_pod.spill_out()
	// Let the metamorph datum handle the actual mutationening.
	metamorph_type.on_chrysallis()

	if(metamorph_type.current_stage < metamorph_type.total_stages)
		// The cycle continues.
		var/random_variation = rand(-5, 5) MINUTES
		warning_timer = addtimer(CALLBACK(src, PROC_REF(warning)), (METAMORPH_COCOON_TIME + random_variation) - 15 SECONDS)
		metamorph_timer = addtimer(CALLBACK(src, PROC_REF(metamorph)), (METAMORPH_COCOON_TIME + random_variation))

/// Collapse the wall, spewing gas. Keeps the 'weeds' and 'node' though.
/datum/mutation/human/superweapon/proc/shwip(obj/structure/alien/resin/wall/superweapon_cocoon/cocoon_wall)
	if(prob(11))
		return // 1/9 chance of not breaking and staying as debris
	playsound(cocoon_wall, 'sound/effects/meatslap.ogg', 50, TRUE)
	qdel(cocoon_wall)

/// Spews a randomly-heated randomly-small amount of any gas in the game. Fun!
/// Also, imagine an atmos tech setting up a cell for the superweapon to chrysallize in to harvest the gases. That'd be HILARIOUS.
/proc/spew_superweapon_gas(atom/source, datum/metamorph_type/meta_type)

	var/list/gas_list = list()

	if(meta_type)
		gas_list = meta_type.gas_spew_types
	else
		for(var/gas_path in subtypesof(/datum/gas))
			var/datum/gas/gas_type = gas_path
			LAZYADD(gas_list, initial(gas_type.id))

	var/picked_gas = pick(gas_list)

	var/turf/source_turf = get_turf(source)

	source_turf.atmos_spawn_air("[picked_gas]=[rand(1, 5)];TEMP=[((meta_type ? meta_type.gas_spew_temp : T20C) + rand(-2, 2))]")
	// bioweapons are weird, yo.

/datum/mutation/human/superweapon/on_losing(mob/living/carbon/human/owner)
	deltimer(warning_timer)
	deltimer(metamorph_timer)
	. = ..()

#define ADDED_MUTATIONS "added_muts"
#define ADDED_QUIRKS "added_quirks"
#define ADDED_TRAUMAS "added_traumas"

/// Handler datum for specific metamorph types.
/datum/metamorph_type
	var/total_stages = 3
	var/current_stage = 0
	var/letter = "T"
	var/list/gas_spew_types = list()
	var/gas_spew_temp = T20C
	var/chrysalis_color = "#f7f335"
	var/list/starting_mutations = list(/datum/mutation/human/cough, /datum/mutation/human/biotechcompat)
	var/list/starting_quirks = list(/datum/quirk/badback)
	var/list/starting_traumas = list()
	var/mob/living/carbon/human/victim
	var/datum/mutation/human/superweapon/victim_mutation

/datum/metamorph_type/New(datum/mutation/human/superweapon/new_mutation)
	. = ..()
	victim_mutation = new_mutation
	if(isnull(victim_mutation))
		stack_trace("metamorph_type datum created without mutation ref")
		qdel(src)
	victim = victim_mutation.owner

	for(var/datum/mutation/human/mut as anything in starting_mutations)
		victim.dna.add_mutation(mut, MUT_OTHER) // starting mutations are unenhanced
	for(var/datum/quirk/quark as anything in starting_quirks)
		victim.add_quirk(quark, MUT_OTHER)
	for(var/datum/brain_trauma/trauma as anything in starting_traumas)
		victim.gain_trauma(trauma, TRAUMA_RESILIENCE_ABSOLUTE)

/// Base proc called after the SW finishes cocooning
/datum/metamorph_type/proc/on_chrysallis()
	current_stage++
	var/list/add_list = handle_chrysallis()

	var/list/mutations_to_add = add_list[ADDED_MUTATIONS]
	var/list/quirks_to_add = add_list[ADDED_QUIRKS]
	var/list/traumas_to_add = add_list[ADDED_TRAUMAS]

	for(var/datum/mutation/human/mut as anything in mutations_to_add)
		add_enhanced_mutation(mut)
	for(var/datum/quirk/quark as anything in quirks_to_add)
		victim.add_quirk(quark, MUT_OTHER)
	for(var/datum/brain_trauma/trauma as anything in traumas_to_add)
		victim.gain_trauma(trauma, TRAUMA_RESILIENCE_ABSOLUTE)
	return

// superweapons cant use almost anything but their mutations and they even have bad back
// so making their mutations slightly better will hopefully help them actually use their powerset rather than resort
// to average tider self-defence things like shove cuff.
/datum/metamorph_type/proc/add_enhanced_mutation(datum/mutation/human/mutation)
	mutation = victim.dna.add_mutation(mutation, MUT_OTHER)
	mutation.stabilizer_coeff = 0 // no instability
	mutation.power_coeff = 1.5 // guaranteed power
	mutation.synchronizer_coeff = 0.5 // less self-effects
	mutation.energy_coeff = 0.5 // faster use

// The proc that's changed by subtypes that returns a list of mutations, traits, and traumas to be added by the above proc.
/datum/metamorph_type/proc/handle_chrysallis()
	return

// Psionics! Using 100% of your brain.
/datum/metamorph_type/psionics
	letter = "P"
	gas_spew_types = list("nob", "nitrium", "antinoblium", "bz", "pluox", "miasma") // Spews exotic and mind-affecting gases. And miasma.
	gas_spew_temp = T20C
	chrysalis_color = COLOR_PRIDE_PURPLE
	starting_quirks = list(/datum/quirk/badback, /datum/quirk/frail, /datum/quirk/selfaware, /datum/quirk/item_quirk/signer)
	starting_traumas = list(/datum/brain_trauma/special/quantum_alignment)

/datum/metamorph_type/psionics/handle_chrysallis()
	var/list/return_list = list()
	switch(current_stage)
		if(1)
			// Stage 1. Glow purple and get an antenna! But you're mute. Thankfully you can sign.
			return_list[ADDED_MUTATIONS] = list(/datum/mutation/human/glow/purple, /datum/mutation/human/antenna, /datum/mutation/human/mute)
		if(2)
			// Stage 2. Get telepathy, telekinesis, and you can see bluespace holes in space.
			return_list[ADDED_TRAUMAS] = list(/datum/brain_trauma/special/bluespace_prophet)
			return_list[ADDED_MUTATIONS] = list(/datum/mutation/human/telepathy, /datum/mutation/human/telekinesis)
		if(3)
			// Stage 3. LASER EYES! Whoops, you get the two void shuffle mutations and the trauma to boot. Also the laser eyes are weak. Everything at a price.
			return_list[ADDED_TRAUMAS] = list(/datum/brain_trauma/special/existential_crisis)
			return_list[ADDED_MUTATIONS] = list(/datum/mutation/human/laser_eyes/weak, /datum/mutation/human/badblink, /datum/mutation/human/void)

	return return_list

// Cryonics! Freeze your foes and drive everyone around you, including yourself, insane with your awful accent(s)
/datum/metamorph_type/cryonics
	letter = "C"
	gas_spew_types = list("freon", "n2", "water_vapor", "nob", "halon", "miasma") // Spews cold and inert-ish gases, and also yucky miasma.
	gas_spew_temp = T0C
	chrysalis_color = COLOR_BLUE_LIGHT
	starting_quirks = list(/datum/quirk/badback, /datum/quirk/glass_jaw, /datum/quirk/depression)
	starting_mutations = list(/datum/mutation/human/cough, /datum/mutation/human/biotechcompat, /datum/mutation/human/geladikinesis, /datum/mutation/human/canadian)

/datum/metamorph_type/cryonics/handle_chrysallis()
	var/list/return_list = list()
	switch(current_stage)
		if(1)
			// Stage 1, glow blue, can resist the COLD! Not much use by itself though.
			return_list[ADDED_MUTATIONS] = list(/datum/mutation/human/glow/blue_light, /datum/mutation/human/temperature_adaptation/cryogenic_adaptation)
		if(2)
			// Stage 2, can fire freezing rays at the downside of becoming nearly unintelligible.
			return_list[ADDED_MUTATIONS] = list(/datum/mutation/human/cryokinesis, /datum/mutation/human/frost)
		if(3)
			// Stage 3, get over your SAD and become festively jolly, get thermal vision!
			victim.remove_quirk(/datum/quirk/depression)
			return_list[ADDED_QUIRKS] = list(/datum/quirk/jolly)
			return_list[ADDED_MUTATIONS] = list(/datum/mutation/human/thermal)

	return return_list

/obj/structure/alien/weeds/superweapon_cocoon
	name = "cocoon floor"
	desc = "The goopy, soupy innard filled bottom of the cocoon. It has a sickly yellow color to it."
	color = "#f7f335"
	dies_without_node = FALSE
	/// Bound metatype, used for color and gas spewing.
	var/datum/metamorph_type/meta_type

/obj/structure/alien/weeds/superweapon_cocoon/Initialize(mapload, datum/metamorph_type/meta_type)
	. = ..()
	src.meta_type = meta_type
	spew_superweapon_gas(src, meta_type)
	if(meta_type)
		color = meta_type.chrysalis_color

/obj/structure/alien/weeds/superweapon_cocoon/Destroy()
	spew_superweapon_gas(src, meta_type)
	. = ..()

/obj/structure/alien/weeds/node/superweapon_cocoon
	name = "cocoon center"
	desc = "The goopy, soupy innard filled center of the cocoon. It has a sickly yellow color to it, with some diseased glowing bits at the center..."
	color = "#f7f335"
	dies_without_node = FALSE
	node_range = 0 // no weed growing shenanigans
	/// Bound metatype, used for color and gas spewing.
	var/datum/metamorph_type/meta_type

/obj/structure/alien/weeds/node/superweapon_cocoon/Initialize(mapload, datum/metamorph_type/meta_type)
	. = ..()
	src.meta_type = meta_type
	spew_superweapon_gas(src, meta_type)
	if(meta_type)
		color = meta_type.chrysalis_color

/obj/structure/alien/weeds/node/superweapon_cocoon/Destroy()
	spew_superweapon_gas(src, meta_type)
	. = ..()

/obj/structure/alien/resin/wall/superweapon_cocoon //For chrysalis
	name = "chrysalis cocoon"
	desc = "Some sort of yellow cocoon in an egglike shape. It pulses and throbs from within."
	color = "#f7f335"
	/// Bound metatype, used for color and gas spewing.
	var/datum/metamorph_type/meta_type

/obj/structure/alien/resin/wall/superweapon_cocoon/Initialize(mapload, datum/metamorph_type/meta_type)
	. = ..()
	src.meta_type = meta_type
	spew_superweapon_gas(src, meta_type)
	if(meta_type)
		color = meta_type.chrysalis_color

/obj/structure/alien/resin/wall/superweapon_cocoon/Destroy()
	spew_superweapon_gas(src, meta_type)
	. = ..()

/obj/structure/chrysalis_pod
	icon = 'icons/mob/simple/meteor_heart.dmi'
	anchored = TRUE
	name = "flesh pod"
	desc = "A quivering pod of yellow resin. Something is pulsing inside!"
	icon_state = "flesh_pod"
	max_integrity = 250
	density = TRUE
	color = "#f7f335"
	var/cut_open = FALSE
	/// Bound metatype, used for color and gas spewing.
	var/datum/metamorph_type/meta_type

/obj/structure/chrysalis_pod/Initialize(mapload, datum/metamorph_type/meta_type)
	. = ..()
	src.meta_type = meta_type
	spew_superweapon_gas(src, meta_type)
	if(meta_type)
		color = meta_type.chrysalis_color

/obj/structure/chrysalis_pod/Destroy()
	spew_superweapon_gas(src, meta_type)
	. = ..()

/obj/structure/chrysalis_pod/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', vol = 50, vary = TRUE, pressure_affected = FALSE)
			else
				playsound(loc, 'sound/effects/meatslap.ogg', vol = 50, vary = TRUE, pressure_affected = FALSE)
		if(BURN)
			playsound(loc, 'sound/effects/wounds/sizzle1.ogg', vol = 100, vary = TRUE, pressure_affected = FALSE)

/obj/structure/chrysalis_pod/attackby(obj/item/attacking_item, mob/user, params)
	var/mob/living/luser = user
	if (attacking_item.sharpness & SHARP_EDGED && istype(luser) && !luser.combat_mode)
		cut_open(user)
		return
	return ..()

/// Cut the pod open and destroy it
/obj/structure/chrysalis_pod/proc/cut_open(mob/user)
	balloon_alert(user, "slicing...")
	if (!do_after(user, 3 SECONDS, target = src))
		return
	take_damage(200)

/obj/structure/chrysalis_pod/take_damage(damage_flag)
	..()
	if((get_integrity() < max_integrity * 0.5) && !cut_open)
		spill_out()

/obj/structure/chrysalis_pod/proc/spill_out()
	cut_open = TRUE
	playsound(loc, 'sound/effects/wounds/blood3.ogg', vol = 50, vary = TRUE, pressure_affected = FALSE)
	visible_message(span_notice("[src] is cut open, causing an odd gas to seep into the room..."))
	spew_superweapon_gas(src, meta_type)
	for(var/atom/movable/atom in contents)
		atom.forceMove(get_turf(src))
		if(isliving(atom))
			var/mob/living/latom = atom
			latom.SetAllImmobility(2 SECONDS) // remove the long 45 second stun, set to 2
	desc = "A pod of living meat, this one has been hollowed out."
	icon_state = "flesh_pod_open"

/obj/structure/chrysalis_pod/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 300

/obj/structure/chrysalis_pod/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(5, BURN, 0, 0)

#undef ADDED_MUTATIONS
#undef ADDED_QUIRKS
#undef ADDED_TRAUMAS
