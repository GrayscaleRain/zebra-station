/*
 HUMANS
*/

/datum/species/human
	name = "Human"
	id = "human"
	roundstart = 1
	specflags = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	use_skintones = 1

/datum/species/human/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "mutationtoxin")
		H << "<span class='danger'>Your flesh rapidly mutates!</span>"
		H.dna.species = new /datum/species/slime()
		H.regenerate_icons()
		H.reagents.del_reagent(chem.type)
		H.faction |= "slime"
		return 1

/*
 LIZARDPEOPLE
*/

/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "Reptilian"
	id = "lizard"
	say_mod = "hisses"
	default_color = "00FF00"
	roundstart = 1
	specflags = list(MUTCOLORS,EYECOLOR,LIPS)
	mutant_bodyparts = list("tail", "snout")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/lizard

/datum/species/lizard/handle_speech(message)
	// jesus christ why
	if(copytext(message, 1, 2) != "*")
		message = replacetext(message, "s", "sss")

	return message

/*
 PLANTPEOPLE
*/

/datum/species/plant
	// Creatures made of leaves and plant matter.
	name = "Folia"
	id = "plant"
	default_color = "59CE00"
	specflags = list(MUTCOLORS,EYECOLOR)
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	burnmod = 1.25
	heatmod = 1.5
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/plant
	roundstart = 1 // SHINE

/datum/species/plant/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "plantbgone")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/plant/on_hit(proj_type, mob/living/carbon/human/H)
	switch(proj_type)
		if(/obj/item/projectile/energy/floramut)
			if(prob(15))
				H.irradiate(rand(30,80))
				H.Weaken(5)
				H.visible_message("<span class='warning'>[H] writhes in pain as \his vacuoles boil.</span>", "<span class='userdanger'>You writhe in pain as your vacuoles boil!</span>", "<span class='italics'>You hear the crunching of leaves.</span>")
				if(prob(80))
					randmutb(H)
					domutcheck(H,null)
				else
					randmutg(H)
					domutcheck(H,null)
			else
				H.adjustFireLoss(rand(5,15))
				H.show_message("<span class='userdanger'>The radiation beam singes you!</span>")
		if(/obj/item/projectile/energy/florayield)
			H.nutrition = min(H.nutrition+30, NUTRITION_LEVEL_FULL)
	return

/*
 PODPEOPLE
*/

/datum/species/plant/pod
	// A mutation caused by a human being ressurected in a revival pod. These regain health in light, and begin to wither in darkness.
	name = "Podperson"
	id = "pod"
	specflags = list(MUTCOLORS,EYECOLOR)
	roundstart = 0 // SHINE

/datum/species/plant/pod/spec_life(mob/living/carbon/human/H)
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		var/area/A = T.loc
		if(A)
			if(A.lighting_use_dynamic)	light_amount = min(10,T.lighting_lumcount) - 5
			else						light_amount =  5
		H.nutrition += light_amount
		if(H.nutrition > NUTRITION_LEVEL_FULL)
			H.nutrition = NUTRITION_LEVEL_FULL
		if(light_amount > 2) //if there's enough light, heal
			H.heal_overall_damage(1,1)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(2,0)

/*
 SHADOWPEOPLE
*/

/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "Shadowperson" // SHINE changed ??? to Shadow
	id = "shadow"
	darksight = 8
	sexes = 0
	ignored_by = list(/mob/living/simple_animal/hostile/faithless)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	specflags = list(NOBREATH,NOBLOOD,RADIMMUNE)
	roundstart = 1 // SHINE
	armor = -10 //shine

/datum/species/shadow/spec_life(mob/living/carbon/human/H)
	var/light_amount
	var/L
	var/C
	var/PR
	if(isturf(H.loc))
		var/turf/T = H.loc
		var/area/A = T.loc
		if(A)
			if(A.lighting_use_dynamic)
				light_amount = T.lighting_lumcount
			else
				light_amount =  10

		if(istype(H.r_hand, /obj/item/weapon/umbrella) || istype(H.l_hand, /obj/item/weapon/umbrella))
//			world << "Yup it's covered"
			PR = 1
		if(!istype(H.r_hand, /obj/item/weapon/umbrella) && !istype(H.l_hand, /obj/item/weapon/umbrella))
//			world << "Nope, not covered"
			PR = 0

		if(light_amount > 3) //if there's enough light, start dying
			L = light_amount / 2
			if(PR == 1)
				L = 0
			H.take_overall_damage(0,L)
//			world << "Take [L] damage"
		else if(light_amount < 3 && light_amount > 2)
//			world << "No light stuff"
		else if (light_amount < 2) //heal in the dark
			L = light_amount
			C = 2 - L
			H.heal_overall_damage(0,C)
//			world << "Heal [C]"

/*
 SLIMEPEOPLE
*/

/datum/species/slime
	// Humans mutated by slime mutagen, produced from green slimes. They are not targetted by slimes.
	name = "Slime"
	id = "slime"
	default_color = "00FFFF"
	darksight = 3
	invis_sight = SEE_INVISIBLE_LEVEL_ONE
	specflags = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR,NOBLOOD)
	hair_color = "mutcolor"
	hair_alpha = 150
	ignored_by = list(/mob/living/simple_animal/slime)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimejelly
	var/recently_changed = 1

	roundstart = 1 // SHINE ADD
	coldmod = 2

/datum/species/slime/spec_life(mob/living/carbon/human/H)
	if(!H.reagents.get_reagent_amount("slimejelly"))
		if(recently_changed)
			H.reagents.add_reagent("slimejelly", 80)
			recently_changed = 0
		else
			H.reagents.add_reagent("slimejelly", 5)
			H.adjustBruteLoss(5)
			H << "<span class='danger'>You feel empty!</span>"

	for(var/datum/reagent/toxin/slimejelly/S in H.reagents.reagent_list)
		if(S.volume < 100)
			if(H.nutrition >= NUTRITION_LEVEL_STARVING)
				H.reagents.add_reagent("slimejelly", 0.5)
				H.nutrition -= 5
		if(S.volume < 50)
			if(prob(5))
				H << "<span class='danger'>You feel drained!</span>"
		if(S.volume < 10)
			H.losebreath++

/datum/species/slime/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "slimejelly")
		return 1
/*
 JELLYPEOPLE
*/

/datum/species/jelly
	// Entirely alien beings that seem to be made entirely out of gel. They have three eyes and a skeleton visible within them.
	name = "Xenobiological Jelly Entity"
	id = "jelly"
	default_color = "00FF90"
	say_mod = "chirps"
	eyes = "jelleyes"
	specflags = list(MUTCOLORS,EYECOLOR,NOBLOOD)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimejelly
	var/recently_changed = 1

/datum/species/jelly/spec_life(mob/living/carbon/human/H)
	if(!H.reagents.get_reagent_amount("slimejelly"))
		if(recently_changed)
			H.reagents.add_reagent("slimejelly", 80)
			recently_changed = 0
		else
			H.reagents.add_reagent("slimejelly", 5)
			H.adjustBruteLoss(5)
			H << "<span class='danger'>You feel empty!</span>"

	for(var/datum/reagent/toxin/slimejelly/S in H.reagents.reagent_list)
		if(S.volume < 100)
			if(H.nutrition >= NUTRITION_LEVEL_STARVING)
				H.reagents.add_reagent("slimejelly", 0.5)
				H.nutrition -= 5
			else if(prob(5))
				H << "<span class='danger'>You feel drained!</span>"
		if(S.volume < 10)
			H.losebreath++

/datum/species/jelly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "slimejelly")
		return 1
/*
 GOLEMS
*/

/datum/species/golem
	// Animated beings of stone. They have increased defenses, and do not need to breathe. They're also slow as fuuuck.
	name = "Golem"
	id = "golem"
	specflags = list(HEATRES,COLDRES,NOGUNS,NOBLOOD,RADIMMUNE,NOBREATH) // SHINE removed NOBREATH
	speedmod = 3
	armor = 35 // SHINE nerfed 55 to 35
	punchmod = 5
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_head, slot_w_uniform) // slot_wear_mask SHINE letting them have masks on
	nojumpsuit = 1 // SHINE not letting them have magic skin pockets anymore
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/golem
	roundstart = 1 // SHINE
//	magicIDslot = 1 // SHINE everyone must have ID

/*
 ADAMANTINE GOLEMS
*/

/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = "adamantine"
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/golem/adamantine
	roundstart = 0
	specflags = list(NOBREATH,HEATRES,COLDRES,NOGUNS,NOBLOOD,RADIMMUNE)
	armor = 55
	nojumpsuit = 1
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_head, slot_w_uniform)
/*
 FLIES
*/

/datum/species/fly
	// Humans turned into fly-like abominations in teleporter accidents.
	name = "Flyperson" // SHINE changed Human? to Flyperson
	id = "fly"
	say_mod = "buzzes"
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/fly
	roundstart = 1 // SHINE

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "pestkiller")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/fly/handle_speech(message)
	return replacetext(message, "z", stutter("zz"))

/*
 SKELETONS
*/

/datum/species/skeleton
	// 2spooky
	name = "Spooky Scary Skeleton"
	id = "skeleton"
	say_mod = "rattles"
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	specflags = list(NOBREATH,HEATRES,COLDRES,NOBLOOD,RADIMMUNE)
/*
 ZOMBIES
*/

/datum/species/zombie
	// 1spooky
	name = "Recycled Human"
	id = "zombie"
	say_mod = "moans"
	sexes = 0
	speedmod = 2
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	specflags = list(NOBREATH,NOBLOOD,RADIMMUNE,NOGUNS,HAIR,FACEHAIR,EYECOLOR)
	burnmod = 1.25
	roundstart = 1
	armor = -10

/datum/species/zombie/handle_speech(message)
	var/list/message_list = text2list(message, " ")
	var/maxchanges = max(round(message_list.len / 1.5), 2)

	for(var/i = rand(maxchanges / 2, maxchanges), i > 0, i--)
		var/insertpos = rand(1, message_list.len - 1)
		var/inserttext = message_list[insertpos]

		if(!(copytext(inserttext, length(inserttext) - 2) == "..."))
			message_list[insertpos] = inserttext + "..."

		if(prob(20) && message_list.len > 3)
			message_list.Insert(insertpos, "[pick("BRAINS", "Brains", "Braaaiinnnsss", "BRAAAIIINNSSS")]...")

	return list2text(message_list, " ")

/datum/species/cosmetic_zombie
	name = "Human"
	id = "czombie"
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie


/datum/species/abductor
	name = "Abductor"
	id = "abductor"
	darksight = 3
	say_mod = "gibbers"
	sexes = 0
	invis_sight = SEE_INVISIBLE_LEVEL_ONE
	specflags = list(NOBLOOD,NOBREATH)
	var/scientist = 0 // vars to not pollute spieces list with castes
	var/agent = 0
	var/team = 1

/datum/species/abductor/handle_speech(message)
	//Hacks
	var/mob/living/carbon/human/user = usr
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.dna.species.id != "abductor")
			continue
		else
			var/datum/species/abductor/target_spec = H.dna.species
			if(target_spec.team == team)
				H << "<i><font color=#800080><b>[user.name]:</b> [message]</font></i>"
				//return - technically you can add more aliens to a team
	for(var/mob/M in dead_mob_list)
		M << "<i><font color=#800080><b>[user.name]:</b> [message]</font></i>"
	return ""


///////////////////////////////////////////////////////////////////////////////
///SHINE SPECIES///
///////////////////////////////////////////////////////////////////////////////

/datum/species/gamoid
	name = "Gamoid/Android"
	id = "gamoid"
	say_mod = "states"
	sexes = 1
	specflags = list(COLDRES,NOBLOOD,NOBREATH,EYECOLOR,HAIR,FACEHAIR,LIPS,RADIMMUNE)
	exotic_blood = /datum/reagent/oil
	use_skintones = 1
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/synthmeat
	roundstart = 1

// Can't eat or drink
/datum/species/gamoid/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
//	if(chem.id == "")
	H.adjustFireLoss(3)
	H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
	if(prob(33))
		H << "<span class='danger'>WARNING: Foreign contaminant detected internally. Systems damaged.</span>"
	return 1


///Repairs and recharging///
/mob/living/carbon/human/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(src.dna.species.id == "gamoid")

		if (istype(W, /obj/item/weapon/weldingtool) && user.a_intent == "help")
			user.changeNext_move(CLICK_CD_MELEE)
			var/obj/item/weapon/weldingtool/WT = W
			if (src == user)
				user << "<span class='warning'>You lack the reach to be able to repair yourself.</span>"
				return 1
			if (src.health >= src.maxHealth)
				user << "<span class='warning'>[src] does not need repairs.</span>"
				return 1
			if (WT.remove_fuel(0, user))
				adjustBruteLoss(-10)
				adjustFireLoss(-10)
				adjustToxLoss(-10)
				updatehealth()
				visible_message("<span class='notice'>[user] has made some repairs to [src].</span>")
				return 0
			else
				user << "<span class='warning'>The welder must be on for this task.</span>"
				return 1

		if (istype(W, /obj/item/weapon/stock_parts/cell) && user.a_intent == "help")
			user.changeNext_move(CLICK_CD_MELEE)
			var/obj/item/weapon/stock_parts/cell/C = W
			if (src == user)
				user << "<span class='warning'>You cannot reach your own powercell interface port.</span>"
				return 1

			if (src.nutrition >= NUTRITION_LEVEL_FULL || src.nutrition >= (NUTRITION_LEVEL_FULL - 10))
				user << "<span class='warning'>Gamoid unit already at maximum charge capacity.</span>"
				return 1
			if (C.charge > 0)
				user << "<span class='notice'>You insert the powercell into [src.name].</span>"
				var/powergap = 0
				powergap = (NUTRITION_LEVEL_FULL - src.nutrition)
//				world << "DEBUG [powergap]"

				src.nutrition += C.charge
				C.charge -= powergap
				if (C.charge < 0)
					C.charge = 0
				if (src.nutrition >= NUTRITION_LEVEL_FULL)
					src.nutrition = NUTRITION_LEVEL_FULL
				src << "<span class='notice'>SYSTEM NOTICE: Internal power storage has finished charging.</span>"
				return 0
			if (C.charge < 3)
				user << "<span class='warning'>The powercell is empty!</span>"
				return 1
/*
		if (istype(w, /obj/item/weapon/card/id) && user.a_intent == "help")
			user.changeNext_move(CLICK_CD_MELEE)
			var/obj/item/weapon/card/id/ID = W
			if (src == user)
				user << "<span class='warning'>Your programming disallows this action.</span>"
				return 1
			if(src.nutrition < NUTRITION_LEVEL_STARVING)
				user << "<span class='warning'>[src.name] is currently in Emergency Sleep Mode and cannot be powered on.</span>"
				return 1
			if (29 in ID.access)
				if (!src.sleeping)
				src.sleeping =

*/
		return ..()
	return ..()

/datum/species/gamoid/spec_life(mob/living/carbon/human/H)
	if(H.viruses.len > 0) // SHINE robots dont get sick
		for(var/datum/disease/D in H.viruses)
			D.cure()
//			world << "DEBUG: viruses removed from gamoid, cured [D.name]"

//	var/powerwarned
//	if((H.nutrition+50) > NUTRITION_LEVEL_STARVING)
//		powerwarned = 0
//	if((H.nutrition+50) < NUTRITION_LEVEL_STARVING && powerwarned == 0) // SHINE robots run out of power and shutdown
//		H << "<span class='warning'>WARNING: Power levels low. System will enter Sleep Mode if power is not recharged soon.</span>"
//		powerwarned = 1
	if(H.nutrition < NUTRITION_LEVEL_STARVING)
		if(!H.sleeping)
			H << "<span class='warning'>WARNING: Entering Emergency Sleep Mode...</span>"
		H.sleeping = 10
