/datum/round_event_control/spontaneous_appendicitis
	name = "Spontaneous Appendicitis"
	typepath = /datum/round_event/spontaneous_appendicitis
	weight = 15 // SHINE reduce to 15 from 20
	max_occurrences = 4
	earliest_start = 6000

/datum/round_event/spontaneous_appendicitis/start()
	for(var/mob/living/carbon/human/H in shuffle(living_mob_list))
		var/foundAlready = 0	//don't infect someone that already has the virus
		for(var/datum/disease/D in H.viruses)
			foundAlready = 1
		if(H.stat == 2 || foundAlready)
			continue

		var/datum/disease/D = new /datum/disease/appendicitis
		H.AddDisease(D)
		break