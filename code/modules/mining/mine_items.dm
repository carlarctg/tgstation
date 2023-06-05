/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades. we also use the base effect for certain lighting effects while mapping.
/obj/effect/light_emitter
	name = "light emitter"
	icon_state = "lighting_marker"
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	var/set_luminosity = 8
	var/set_cap = 0

/obj/effect/light_emitter/Initialize(mapload)
	. = ..()
	set_light(set_luminosity, set_cap)

/obj/effect/light_emitter/singularity_pull()
	return

/obj/effect/light_emitter/singularity_act()
	return

/**********************Miner Lockers**************************/

/obj/structure/closet/wardrobe/miner
	name = "mining wardrobe"
	icon_door = "mixed"

/obj/structure/closet/wardrobe/miner/PopulateContents()
	new /obj/item/storage/backpack/duffelbag/explorer(src)
	new /obj/item/storage/backpack/explorer(src)
	new /obj/item/storage/backpack/satchel/explorer(src)
	new /obj/item/clothing/under/rank/cargo/miner/lavaland(src)
	new /obj/item/clothing/under/rank/cargo/miner/lavaland(src)
	new /obj/item/clothing/under/rank/cargo/miner/lavaland(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/suit/hooded/wintercoat/miner(src)
	new /obj/item/clothing/suit/hooded/wintercoat/miner(src)
	new /obj/item/clothing/suit/hooded/wintercoat/miner(src)

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment locker"
	icon_state = "mining"
	req_access = list(ACCESS_MINING)

/obj/structure/closet/secure_closet/miner/unlocked
	locked = FALSE

/obj/structure/closet/secure_closet/miner/PopulateContents()
	..()
	new /obj/item/stack/sheet/mineral/sandbags(src, 5)
	new /obj/item/storage/box/emptysandbags(src)
	new /obj/item/shovel(src)
	new /obj/item/pickaxe/mini(src)
	new /obj/item/radio/headset/headset_cargo/mining(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/storage/bag/plants(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/gun/energy/recharge/kinetic_accelerator(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/survivalcapsule(src)
	new /obj/item/assault_pod/mining(src)


/**********************Shuttle Computer**************************/

/obj/machinery/computer/shuttle/mining
	name = "mining shuttle console"
	desc = "Used to call and send the mining shuttle."
	circuit = /obj/item/circuitboard/computer/mining_shuttle
	shuttleId = "mining"
	possible_destinations = "mining_home;mining_away;landing_zone_dock;mining_public"
	no_destination_swap = TRUE

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/machinery/computer/shuttle/mining/attack_hand(mob/user, list/modifiers)
	if(is_station_level(user.z) && user.mind && IS_HEAD_REVOLUTIONARY(user) && !(user.mind in dumb_rev_heads))
		to_chat(user, span_userdanger("You get a feeling that leaving the station might be a REALLY dumb idea..."))
		dumb_rev_heads += user.mind
		return

	if (HAS_TRAIT(user, TRAIT_FORBID_MINING_SHUTTLE_CONSOLE_OUTSIDE_STATION) && !is_station_level(user.z))
		to_chat(user, span_warning("You get the feeling you shouldn't mess with this."))
		return
	return ..()

/obj/machinery/computer/shuttle/mining/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/shuttle_controls))
	// Add another circuit for possible valid destinations

/obj/item/circuit_component/shuttle_controls
	display_name = "Mining Shuttle Controls"

	/// The destination to go
	var/datum/port/input/new_destination

	/// The trigger to send the shuttle
	var/datum/port/input/trigger_move

	/// The current location
	var/datum/port/output/location

	/// Whether or not the shuttle is moving
	var/datum/port/output/travelling_output

	/// All valid destinations
	var/datum/port/output/valid_destinations

	/// The shuttle controls computer (/obj/machinery/computer/shuttle_controls)
	var/obj/machinery/computer/shuttle/computer

	/// The saved destination to update 'location' value.
	var/saved_destination

/obj/item/circuit_component/shuttle_controls/populate_ports()
	new_destination = add_input_port("Destination", PORT_TYPE_STRING, trigger = null)
	trigger_move = add_input_port("Send Shuttle", PORT_TYPE_SIGNAL)

	location = add_output_port("Location", PORT_TYPE_STRING)
	travelling_output = add_output_port("Travelling", PORT_TYPE_NUMBER)
	valid_destinations = add_output_port("Valid Destinations", PORT_TYPE_LIST(PORT_TYPE_STRING))

#define COMSIG_SHUTTLE_PRE_LAUNCH "gogus"
#define COMSIG_SHUTTLE_LAUNCH "grongus"
#define COMSIG_SHUTTLE_ARRIVE "gingus"

/obj/item/circuit_component/shuttle_controls/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/shuttle))
		computer = shell
		valid_destinations.set_output(splittext(computer.possible_destinations,";"))
		RegisterSignal(computer, COMSIG_SHUTTLE_PRE_LAUNCH, PROC_REF(save_location))
		RegisterSignal(computer, COMSIG_SHUTTLE_LAUNCH, PROC_REF(update_location), "Transit")
		RegisterSignal(computer, COMSIG_SHUTTLE_ARRIVE, PROC_REF(update_location), saved_destination)

/obj/item/circuit_component/shuttle_controls/proc/save_location()
	location.set_output("Transit")
	saved_destination = new_destination
	travelling_output.set_output(1)

/obj/item/circuit_component/shuttle_controls/proc/update_location(computer, dest_value)
	location.set_output(dest_value)
	if(location.value != "Transit")
		travelling_output.set_output(0)

/obj/item/circuit_component/shuttle_controls/unregister_usb_parent(atom/movable/shell)
	computer = null
	return ..()

/obj/item/circuit_component/shuttle_controls/input_received(datum/port/input/port)
	if (!COMPONENT_TRIGGERED_BY(trigger_move, port))
		return

	if (isnull(computer))
		return

	if (!computer.powered())
		return

	// Doubling this bit over from send_shuttle so it doesn't think we're doing a href exploit if the circuit user fucks up the input
	var/list/dest_list = computer.get_valid_destinations()
	var/validdest = FALSE
	for(var/list/dest_data in dest_list)
		if(dest_data["id"] == new_destination.value)
			validdest = new_destination.value //Found our destination, we can skip ahead now
			break

	if(validdest)
		INVOKE_ASYNC(computer, TYPE_PROC_REF(/obj/machinery/computer/shuttle, send_shuttle), validdest)

/obj/machinery/computer/shuttle/mining/common
	name = "lavaland shuttle console"
	desc = "Used to call and send the lavaland shuttle."
	circuit = /obj/item/circuitboard/computer/mining_shuttle/common
	shuttleId = "mining_common"
	possible_destinations = "commonmining_home;lavaland_common_away;landing_zone_dock;mining_public"

/obj/docking_port/stationary/mining_home
	name = "SS13: Mining Dock"
	shuttle_id = "mining_home"
	roundstart_template = /datum/map_template/shuttle/mining/delta
	width = 7
	dwidth = 3
	height = 5

/obj/docking_port/stationary/mining_home/kilo
	roundstart_template = /datum/map_template/shuttle/mining/kilo
	height = 10

/obj/docking_port/stationary/mining_home/northstar
	roundstart_template = /datum/map_template/shuttle/mining/northstar
	height = 6

/obj/docking_port/stationary/mining_home/common
	name = "SS13: Common Mining Dock"
	shuttle_id = "commonmining_home"
	roundstart_template = /datum/map_template/shuttle/mining_common/meta

/obj/docking_port/stationary/mining_home/common/kilo
	roundstart_template = /datum/map_template/shuttle/mining_common/kilo

/obj/docking_port/stationary/mining_home/common/northstar
	roundstart_template = /datum/map_template/shuttle/mining_common/northstar

/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "Mining car (not for rails)"
	icon_state = "miningcar"
	base_icon_state = "miningcar"
