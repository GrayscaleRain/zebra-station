/datum/round_event_control/vent_gunk
	name = "Vent Gunk"
	typepath = /datum/round_event/vent_gunk
	weight = 300 //300
	max_occurrences = 1000
	earliest_start = 0

/datum/round_event/vent_gunk
	startWhen		= 1
	endWhen			= 2
	announceWhen	= 3
	var/list/vents = list()
	var/obj/machinery/atmospherics/unary/vent_pump/chosenvent

/datum/round_event/vent_gunk/announce()
	message_admins("Vent gunk happened at [chosenvent.x], [chosenvent.y]")
	return

/datum/round_event/vent_gunk/setup()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in machines)
		if(temp_vent.loc.z == 1 && temp_vent.network)
			if(temp_vent.network.normal_members.len > 20)
				if(temp_vent.clogged == 0)
					vents += temp_vent
	if(!vents.len)
		return kill()
	chosenvent = pick(vents)

/datum/round_event/vent_gunk/start()
	chosenvent.gunkup()

/datum/round_event/vent_gunk/tick()
	return


/*
/datum/round_event_control/vent_clog
	name = "Scrubber surge"
	typepath = /datum/round_event/vent_clog
	weight = 35

/datum/round_event/vent_clog
	announceWhen	= 1
	startWhen		= 5
	endWhen			= 35
	var/interval 	= 2
	var/list/vents  = list()

/datum/round_event/vent_clog/announce()
	priority_announce("The scrubbers network is experiencing a backpressure surge.  Some ejection of contents may occur.", "Atmospherics alert")


/datum/round_event/vent_clog/setup()
	endWhen = rand(25, 100)
	for(var/obj/machinery/atmospherics/unary/vent_scrubber/temp_vent in machines)
		if(temp_vent.loc.z == 1 && temp_vent.network)
			if(temp_vent.network.normal_members.len > 20)
				vents += temp_vent
	if(!vents.len)
		return kill()

/datum/round_event/vent_clog/tick()
	if(activeFor % interval == 0)
		var/obj/vent = pick_n_take(vents)
		if(vent && vent.loc)
			var/list/gunk = list("water","carbon","flour","radium","toxin","cleaner","nutriment","condensedcapsaicin","mushroomhallucinogen","lube",
								 "plantbgone","banana","anti_toxin","space_drugs","hyperzine","holywater","ethanol","hot_coco") // SHINE remove pacid since it melts everything
			var/datum/reagents/R = new/datum/reagents(50)
			R.my_atom = vent
			R.add_reagent(pick(gunk), 50)

			var/datum/effect/effect/system/chem_smoke_spread/smoke = new
			smoke.set_up(R, rand(1, 2), 0, vent, 0, silent = 1)
			playsound(vent.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
			smoke.start()
			R.delete()	//GC the reagents
			*/