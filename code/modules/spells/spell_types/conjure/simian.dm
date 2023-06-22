/datum/action/cooldown/spell/conjure/simian
	name = "Summon Simians"
	desc = "This spell reaches deep into the elemental plane of bananas (the monkey one, not the clown one), and \
		summons monkeys and gorillas that will promptly flip out and attack everything in sight. Fun! \
		Their lesser, easily manipulable minds will be convinced you are one of their allies, but only for a minute."
	button_icon_state = "bee"
	sound = 'sound/creatures/monkey/monkey_screech_1.ogg'

	school = SCHOOL_CONJURATION
	cooldown_time = 2 MINUTES
	cooldown_reduction_per_rank = 15 SECONDS

	invocation = "OOGA OOGA OOGA!!!!"
	invocation_type = INVOCATION_SHOUT

	summon_radius = 3
	summon_type = list(/mob/living/carbon/human/species/monkey/angry, /mob/living/simple_animal/hostile/gorilla)
	summon_amount = 6

/datum/action/cooldown/spell/conjure/simian/New(Target, original)
	. = ..()
	sound = "sound/creatures/monkey/monkey_screech_[rand(1, 7)].ogg"

/datum/action/cooldown/spell/conjure/simian/cast(atom/cast_on)
	. = ..()
	sound = "sound/creatures/monkey/monkey_screech_[rand(1, 7)].ogg"
	if(FACTION_MONKEY in owner.faction)
		return
	owner.faction.Add(FACTION_MONKEY)
	addtimer(CALLBACK(src, PROC_REF(remove_monky_faction), owner), 1 MINUTES)

/datum/action/cooldown/spell/conjure/simian/proc/remove_monky_faction(mob/owner)
	owner.faction.Remove(FACTION_MONKEY)

/datum/action/cooldown/spell/conjure/simian/post_summon(atom/summoned_object, atom/cast_on)
	if(!istype(summoned_object, /mob/living/carbon/human/species/monkey))
		return

	var/mob/living/carbon/human/species/monkey/summoned_monkey = summoned_object

	var/obj/item/organ/internal/brain/primate/monky_brain = locate(summoned_monkey)
	monky_brain?.tripping = FALSE // You fucked with Elemental Monkeys

	var/list/static/monky_weapon = list(
		/obj/item/food/grown/banana,
		/obj/item/grown/bananapeel,
		/obj/item/tailclub,
		/obj/item/knife/combat/bone,
		/obj/item/shovel/serrated,
		/obj/item/spear/bamboospear,
		/obj/item/spear/bonespear,
		/obj/item/fireaxe/boneaxe,
		/obj/item/gun/syringe/blowgun,
		/obj/item/gun/ballistic/revolver, // gatfruit!
	)

	var/obj/item/weapon
	if(prob(80))
		weapon = new monky_weapon(summoned_monkey)
		summoned_monkey.equip_to_slot_or_del(weapon, ITEM_SLOT_HANDS)

	// Load the ammo
	if(istype(weapon, /obj/item/gun/syringe/blowgun))
		var/obj/item/reagent_containers/syringe/crude/tribal/syring = new(summoned_monkey)
		weapon.attackby(syring, summoned_monkey)

	// Wield the weapon!
	if(is_type_in_list(weapon, list(/obj/item/spear, /obj/item/fireaxe)))
		weapon.attack_self(summoned_monkey)

	var/list/static/monky_hats = list(
		/obj/item/clothing/head/helmet/skull,
		/obj/item/clothing/head/helmet/durathread,
		/obj/item/clothing/head/costume/garland,
	)

	if(prob(50))
		var/choice = pick(monky_hats)
		var/obj/item/clothing/head/monky_hat = new choice(src)
		summoned_monkey.equip_to_slot_or_del(monky_hat, ITEM_SLOT_HEAD)

	summoned_monkey.fully_replace_character_name(summoned_monkey.real_name, "primal " + summoned_monkey.name)
