/obj/item/seeds/coconut
	name = "pack of coconut seeds"
	desc = "These seeds grow into coconut trees."
	icon_state = "seed-coconut"
	species = "coconut"
	plantname = "Coconut Trees"
	product = /obj/item/reagent_containers/food/snacks/grown/coconut
	lifespan = 50
	endurance = 40
	potency = 50 //can naturally produce 100u beakers.
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_dead = "coconut-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/coconut/cocanut)
	reagents_add = list(/datum/reagent/water/coconut = 0.4, /datum/reagent/consumable/coconut_oil = 0.4, /datum/reagent/consumable/coconut_milk = 0.4)

/obj/item/seeds/coconut/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is swallowing [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.gib()
	new product(drop_location())
	qdel(src)
	return MANUAL_SUICIDE

/obj/item/reagent_containers/food/snacks/grown/coconut
	seed = /obj/item/seeds/coconut
	name = "coconut"
	desc = "It's full of coconut water/milk/oil/husk/strands."
	icon_state = "coconut"
	slice_path = /obj/item/reagent_containers/glass/coconut //?
	slices_num = 1
	dried_type = null
	w_class = WEIGHT_CLASS_SMALL
	filling_color = "#CEC3B9"
	bitesize_mod = 3
	foodtype = FRUIT
	juice_results = list(/datum/reagent/consumable/watermelonjuice = 0)

/obj/item/reagent_containers/food/snacks/grown/coconut/Initialize()
	. = ..()
	if(potency < 75) //above that its normal sized
		w_class = WEIGHT_CLASS_NORMAL

/obj/item/reagent_containers/food/snacks/grown/coconut/slice(accuracy, obj/item/W, mob/user)
	to_chat(user, "You carve out the coconut's insides and seal the hole up. You can now use it as a beaker!")
	var/obj/item/reagent_containers/glass/coconut/CB = new slice_path (loc)
	CB.seedpot = seed.potency
	qdel(src)

/obj/item/reagent_containers/glass/beaker/coconut
	name = "hollowed-out coconut"
	desc = "A large coconut, hollowed out by a sharp implement. Its storage capacity depends on the potency the original plant had."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "coconut"
	fill_icon_thresholds = list(0,60,100) //i'd love to make it less shitty by doing volume-only thresholds but the filling code doesn't account for varying thresholds
	custom_materials = null
	volume = 720
	w_class = WEIGHT_CLASS_NORMAL
	amount_per_transfer_from_this = 10
	spillable = FALSE
	possible_transfer_amounts = list(1,2,5,10,15,20,25,30,40,50)
	var/possible_transfer_amounts_big = list(1,2,5,10,15,20,25,30,40,50,100)
	var/beaker_capacity = 100 //changed by being cut up from the base coconut
	var/seedpot = 50 //it's what the potency on the plant was, used for transforming the sprite

/obj/item/reagent_containers/glass/beaker/coconut/Initialize()
	. = ..()
	volume = seedpot * 2 //standard 100, max 200
	if(volume < 99)
		possible_transfer_amounts = possible_transfer_amounts_big
		fill_icon_thresholds = list(0,150,180)
		transform *= TRANSFORM_USING_VARIABLE(seedpot.potency, 100) + 0.5
	if(seedpot > 35) //less than 71u makes it small
		w_class = WEIGHT_CLASS_SMALL
	if(seedpot > 20) //40u pocket sand (acid)
		w_class = WEIGHT_CLASS_TINY

// cocanut
/obj/item/seeds/coconut/cocanut
	name = "pack of cocanut seeds"
	desc = "These seeds grow into non-copyrighted cocanuts."
	icon_state = "seed-cocanut"
	species = "cocanut"
	plantname = "Cocanut Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/cocanut
	mutatelist = list()
	reagents_add = list()
	rarity = 20

/obj/item/seeds/coconut/cocanut/Initialize(map_load) //randomly filled with all the types of space cola
	. = ..()
	var/potential_dronks = list(
	200; /datum/reagent/consumable/space_cola, //cola cola, doubled weight
	/datum/reagent/consumable/lemonade, 
	/datum/reagent/consumable/nuka_cola, 
	/datum/reagent/consumable/grey_bull, 
	/datum/reagent/consumable/dr_gibb, 
	/datum/reagent/consumable/lemon_lime, 
	/datum/reagent/consumable/pwr_game, 
	/datum/reagent/consumable/shamblers, 
	/datum/reagent/consumable/soda_water, 
	/datum/reagent/consumable/monkey_energy)
	reagents_add += list(potential_dronks)
	  //special thanks to cobby for making this cool

/obj/item/reagent_containers/food/snacks/grown/cocanut
	seed = /obj/item/seeds/coconut/cocanut
	name = "cocanut"
	desc = "This coconut has been 'blessed' by a neutrally-alinged soda deity that's particularly fond of bad puns. Contains some sort of normally-canned drink."
	icon_state = "cocanut"
	filling_color = "#EC3841"

/obj/item/reagent_containers/food/snacks/grown/cocanut/slice(accuracy, obj/item/W, mob/user)
	..()
