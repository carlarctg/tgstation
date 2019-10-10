//my tabs have turned into spaces so you will have to live with this now



obj/item/kitchen/fork/spatula
    name = "Spatula"
    desc = "Also known as a 'grill fork' in some circles. Essential for proper grilling."

/obj/item/storage/backpack/satchel/flat/boomer
    name = "griller's satchel"
    desc += "Contains every item an aspiring griller needs, hidden below a floortile so the zoomer interns at Centcom don't confiscate it."

/obj/item/storage/backpack/satchel/flat/boomer/PopulateContents()
    new /obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy(src)
    new /obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy(src)
    new /obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy(src)
    new /obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy(src)
    new /obj/item/kitchen/fork/spatula(src)
    new /obj/item/stack/sheet/mineral/coal/ten(src)
    new /obj/item/clothing/head/chefhat(src)
    ..()