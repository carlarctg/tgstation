

/datum/outfit/echolocator
	name = "Bitrunning Echolocator"
	glasses = /obj/item/clothing/glasses/blindfold
	ears = /obj/item/radio/headset/psyker //Navigating without these is horrible.
	uniform = /obj/item/clothing/under/abductor
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/jacket/trenchcoat
	id = /obj/item/card/id/advanced


/datum/outfit/echolocator/post_equip(mob/living/carbon/human/user, visuals_only)
	. = ..()
	user.psykerize()


/datum/outfit/bitductor
	name = "Bitrunning Abductor"
	uniform = /obj/item/clothing/under/abductor
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/jackboots


/datum/outfit/beachbum_combat
	name = "Beachbum: Island Combat"
	id = /obj/item/card/id/advanced
	l_pocket = null
	r_pocket = null
	shoes = /obj/item/clothing/shoes/sandal
	uniform = /obj/item/clothing/under/pants/jeans
	/// Available ranged weapons
	var/list/ranged_weaps = list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/rifle/boltaction,
		/obj/item/gun/ballistic/automatic/mini_uzi,
		/obj/item/gun/ballistic/automatic/pistol/deagle,
		/obj/item/gun/ballistic/rocketlauncher/unrestricted,
		/obj/item/gun/ballistic/automatic/ar,

	)
	/// Corresponding ammo
	var/list/corresponding_ammo = list(
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/strilka310,
		/obj/item/ammo_box/magazine/uzim9mm,
		/obj/item/ammo_box/magazine/m50,
		/obj/item/food/pizzaslice/dank, // more silly, less destructive
		/obj/item/ammo_box/magazine/m223,
	)


/datum/outfit/beachbum_combat/post_equip(mob/living/carbon/human/bum, visuals_only)
	. = ..()

	var/choice = rand(1, length(ranged_weaps))
	var/weapon = ranged_weaps[choice]
	bum.put_in_active_hand(new weapon)

	var/ammo = corresponding_ammo[choice]
	var/obj/item/ammo1 = new ammo
	var/obj/item/ammo2 = new ammo

	if(!bum.equip_to_slot_if_possible(new ammo, ITEM_SLOT_LPOCKET))
		ammo1.forceMove(get_turf(bum))
	if(!bum.equip_to_slot_if_possible(new ammo, ITEM_SLOT_RPOCKET))
		ammo2.forceMove(get_turf(bum))

	if(prob(50))
		bum.equip_to_slot_if_possible(new /obj/item/clothing/glasses/sunglasses, ITEM_SLOT_EYES)

/datum/outfit/medieval
	name = "Bitrunning Adventurer"

	uniform = /obj/item/clothing/under/costume/gamberson/military

	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/roman

	id = /obj/item/card/id/advanced/adventuring_license/ranger

/datum/outfit/medieval/ranger
	name = "Bitrunning Ranger"
	head = /obj/item/clothing/head/flatcap
	glasses = /obj/item/clothing/glasses/night/colorless
	//neck = quiver?

	uniform = /obj/item/clothing/under/rank/civilian/chaplain/divine_archer
	l_pocket = /obj/item/hatchet/wooden
	r_pocket = /obj/item/bitrunning_host_monitor
	suit = /obj/item/clothing/suit/armor/vest/cuirass
	suit_store = /obj/item/gun/ballistic/bow/longbow

	back = /obj/item/storage/backpack/explorer
	backpack_contents = list(
		/obj/item/reagent_containers/cup/glass/bottle/healing_potion,
		/obj/item/reagent_containers/cup/glass/bottle/healing_potion,
		/obj/item/reagent_containers/cup/glass/bottle/small/stasis_potion,
		/obj/item/reagent_containers/cup/glass/bottle/small/haste_potion,
		/obj/item/reagent_containers/cup/bottle/venom,
	)

//	belt = /obj/item/shadowcloak
	belt = /obj/item/storage/bag/quiver/ranger
	gloves = /obj/item/clothing/gloves/divine_archer
	shoes = /obj/item/clothing/shoes/divine_archer

	id = /obj/item/card/id/advanced/adventuring_license/ranger

/obj/item/storage/bag/quiver/ranger/PopulateContents()
	. = ..()
	for(var/i in 1 to 12)
		new arrow_path(src)
	for(var/i in 1 to 2)
		new /obj/item/ammo_casing/arrow/sticky(src)
	for(var/i in 1 to 2)
		new /obj/item/ammo_casing/arrow/poison(src)
	for(var/i in 1 to 2)
		new /obj/item/ammo_casing/arrow/holy/blazing(src)

/datum/outfit/medieval/knight
	name = "Bitrunning Knight"
	head = /obj/item/clothing/head/helmet/chaplain

	l_pocket = /obj/item/flashlight/flare/torch
	r_pocket = /obj/item/bitrunning_host_monitor
	suit = /obj/item/clothing/suit/chaplainsuit/armor/templar
	suit_store = /obj/item/claymore/weak
	force_suit_store = TRUE

	back = /obj/item/shield/kite
	belt = /obj/item/storage/belt/mining/alt/unrestricted
	belt_contents = list(
		/obj/item/reagent_containers/cup/glass/bottle/healing_potion,
		/obj/item/reagent_containers/cup/glass/bottle/healing_potion,
		/obj/item/reagent_containers/cup/glass/bottle/healing_potion,
		/obj/item/reagent_containers/cup/glass/bottle/small/endurance_potion,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/food/grown/apple,
		/obj/item/food/grown/apple,
		/obj/item/food/grown/apple,
	)
	l_hand = /obj/item/sbeacondrop/horse/bit
	gloves = /obj/item/clothing/gloves/tackler//plate
	shoes = /obj/item/clothing/shoes/bhop/plate

	id = /obj/item/card/id/advanced/adventuring_license/knight

/datum/outfit/medieval/cleric
	name = "Bitrunning Cleric"
	head = /obj/item/clothing/head/helmet/chaplain/witchunter_hat
	glasses = /obj/item/clothing/glasses/godeye/noturfs
	neck = /obj/item/clothing/neck/heretic_focus/crimson_medallion

	uniform = /obj/item/clothing/under/costume/dutch
	l_pocket = /obj/item/flashlight/lantern/jade/on
	r_pocket = /obj/item/bitrunning_host_monitor
	suit = /obj/item/clothing/suit/chaplainsuit/armor/witchhunter
	suit_store = /obj/item/book/bible/blessing_bible

	back = /obj/item/storage/backpack/cultpack
	backpack_contents = list(
		/obj/item/reagent_containers/cup/glass/bottle/healing_potion,
		/obj/item/reagent_containers/cup/glass/bottle/healing_potion,
		/obj/item/reagent_containers/cup/tube/mending_phial,
		/obj/item/reagent_containers/cup/tube/mending_phial,
		/obj/item/reagent_containers/cup/tube/mending_phial,
		/obj/item/knife/bloodletter,
	)
	belt = /obj/item/gun/ballistic/revolver/chaplain/burdenless
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/sneakers/marisa

	id = /obj/item/card/id/advanced/adventuring_license/priest

	spells_to_add = list(/datum/action/cooldown/spell/aoe/area_cleanse)

/datum/outfit/medieval/jester
	name = "Bitrunning Jester"
	head = /obj/item/clothing/head/costume/jester/clown_colors
	mask = /obj/item/clothing/mask/gas/clown_hat

	uniform = /obj/item/clothing/under/rank/civilian/clown
	l_pocket = /obj/item/grown/bananapeel
	r_pocket = /obj/item/bitrunning_host_monitor
	suit = /obj/item/clothing/suit/armor/balloon_vest
	force_suit_store = TRUE
	suit_store = /obj/item/balloon_mallet/squasher

	back = /obj/item/storage/backpack/clown
	backpack_contents = list(
		/obj/item/reagent_containers/cup/glass/bottle/healing_potion,
		/obj/item/reagent_containers/cup/glass/bottle/dreadful_potion,
		/obj/item/reagent_containers/cup/glass/bottle/hilarious_potion,
		/obj/item/sticker/clown,
		/obj/item/sticker/clown,
		/obj/item/stamp/clown,
		/obj/item/pillow/clown,
		/obj/item/stack/sheet/mineral/bananium/five,
		/obj/item/bikehorn,
	)
	belt = /obj/item/modular_computer/pda/clown
	gloves = /obj/item/clothing/gloves/color/rainbow
	shoes = /obj/item/clothing/shoes/clown_shoes/banana_shoes

	id = /obj/item/card/id/advanced/adventuring_license/jester
	implants = list(/obj/item/implant/sad_trombone)
