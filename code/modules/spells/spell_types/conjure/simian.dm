/datum/action/cooldown/spell/conjure/simian
	name = "Summon Simians"
	desc = "This spell reaches deep into the elemental plane of bananas (the monkey one, not the clown one), and \
		summons monkeys and gorillas that will promptly flip out and attack everything in sight. Fun! \
		Their lesser, easily manipulable minds will be convinced you are one of their allies, but only for a minute."
	button_icon_state = "bee"
	sound = 'sound/ambience/antag/monkey.ogg'

	school = SCHOOL_CONJURATION
	cooldown_time = 2 MINUTES
	cooldown_reduction_per_rank = 15 SECONDS

	invocation = "OOGA OOGA OOGA!!!!"
	invocation_type = INVOCATION_SHOUT

	summon_radius = 2
	summon_type = list(/mob/living/carbon/human/species/monkey/angry, /mob/living/simple_animal/hostile/gorilla)
	summon_amount = 4

/datum/action/cooldown/spell/conjure/simian/cast(atom/cast_on)
	. = ..()
	if(FACTION_MONKEY in owner.faction)
		return
	owner.faction.Add(FACTION_MONKEY)
	addtimer(CALLBACK(src, PROC_REF(remove_monky_faction), owner), 1 MINUTES)

/datum/action/cooldown/spell/conjure/simian/proc/remove_monky_faction(mob/owner)
	owner.faction.Remove(FACTION_MONKEY)

/datum/action/cooldown/spell/conjure/simian/post_summon(atom/summoned_object, atom/cast_on)
	if(istype(summoned_object, /mob/living/carbon/human/species/monkey))
		create_monky(summoned_object)
		return
	//else if(istype(summoned_object, /mob/living/simple_animal/hostile/gorilla))
	//	create_gorilla(summoned_object)

/datum/action/cooldown/spell/conjure/simian/proc/create_monky(atom/summoned_object)
	var/mob/living/carbon/human/species/monkey/summoned_monkey = summoned_object

	var/obj/item/organ/internal/brain/primate/monky_brain = locate(summoned_monkey)
	monky_brain?.tripping = FALSE // You fucked with Elemental Monkeys DOESNT WORK
	// MONKEY ATTACK GORILLAS. INVERSE NOT TRUE

	// Monkeys get a random gear tier, but it's more likely to be good the more leveled the spell is!
	var/monkey_gear_tier = rand(0, 5) + (spell_level - 1)
	monkey_gear_tier = min(monkey_gear_tier, 5)

	// Gear is separated by tier.
	var/list/static/monky_weapon = list(
		/obj/item/food/grown/banana = 1,
		/obj/item/grown/bananapeel = 1,
		/obj/item/tailclub = 2,
		/obj/item/knife/combat/bone = 2,
		/obj/item/shovel/serrated = 3,
		/obj/item/spear/bamboospear = 3,
		/obj/item/spear/bonespear = 4,
		/obj/item/fireaxe/boneaxe = 4,
		/obj/item/gun/syringe/blowgun = 5,
		/obj/item/gun/ballistic/revolver = 5, // gatfruit = jungle weapon. i dont make the rules
	)

	var/list/options = list()
	for(var/i in monky_weapon)
		if(monky_weapon[i] == monkey_gear_tier)
			options.Add(i)

	var/obj/item/weapon
	if(monkey_gear_tier != 0)
		weapon = pick(options)
		weapon = new(summoned_monkey)
		summoned_monkey.equip_to_slot_or_del(weapon, ITEM_SLOT_HANDS)

	// Load the ammo
	if(istype(weapon, /obj/item/gun/syringe/blowgun))
		var/obj/item/reagent_containers/syringe/crude/tribal/syring = new(summoned_monkey)
		weapon.attackby(syring, summoned_monkey)

	// Wield the weapon!
	if(is_type_in_list(weapon, list(/obj/item/spear, /obj/item/fireaxe)))
		weapon.attack_self(summoned_monkey)

	var/list/static/monky_hats = list(
		/obj/item/clothing/head/costume/garland = 1,
		/obj/item/clothing/head/helmet/durathread = 2,
		/obj/item/clothing/head/helmet/skull = 3,
	)

	// Not enough options here for each tier, let's cap at 3
	monkey_gear_tier = min(monkey_gear_tier, 3)

	options = list()
	for(var/i in monky_hats)
		if(monky_hats[i] == monkey_gear_tier)
			options.Add(i)

	var/obj/item/clothing
	if(monkey_gear_tier != 0)
		clothing = pick(options)
		clothing = new(summoned_monkey)
		summoned_monkey.equip_to_slot_or_del(clothing, ITEM_SLOT_HEAD)

	summoned_monkey.fully_replace_character_name(summoned_monkey.real_name, "primal " + summoned_monkey.name)
