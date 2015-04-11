/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's an immobile card-locked storage unit."
	locked = 1
	icon_state = "secure"
	health = 200
	var/panel_open = 0
	var/pulsed = 0

/obj/structure/closet/secure_closet/update_icon()//Putting the welded stuff in updateicon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	..()
	if(!opened)
		if(!broken)
			if(locked)
				overlays += "locked"
			else
				overlays += "unlocked"
		else
			overlays += "off"

/obj/structure/closet/secure_closet/examine(mob/user)
	..()
	if(broken || opened || !ishuman(user))
		return //Monkeys don't get a message, nor does anyone ief it's open or emagged
	else
		user << "<span class='notice'>Alt-click the locker to [locked ? "unlock" : "lock"] it.</span>"

/obj/structure/closet/secure_closet/AltClick(var/mob/user)
	..()
	if(!in_range(src, user))
		return
	if(!ishuman(user))
		user << "<span class='notice'>You have no idea how this thing is supposed to work.</span>"
		return
	if(user.stat || !user.canmove || user.restrained() || broken)
		user << "<span class='notice'>You can't do that right now.</span>"
		return
	if(src.opened)
		return
	else
		togglelock(user)

/obj/structure/closet/secure_closet/can_open()
	if(src.locked || src.welded)
		return 0
	return 1

/obj/structure/closet/secure_closet/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken)
		if(prob(50/severity))
			src.locked = !src.locked
			src.update_icon()
		if(prob(20/severity) && !opened)
			if(!locked)
				open()
			else
				src.req_access = list()
				src.req_access += pick(get_all_accesses())
	..()

/obj/structure/closet/secure_closet/proc/togglelock(mob/user as mob)
	if(pulsed == 1)
		user << "<span class='danger'>The lock is malfunctioning. It will need to be fixed first.</span>"
		return
	if(src.allowed(user))
		src.locked = !src.locked
		add_fingerprint(user)
		for(var/mob/O in viewers(user, 3))
			if((O.client && !( O.eye_blind )))
				O << "<span class='notice'>[user] has [locked ? null : "un"]locked the locker.</span>"
		update_icon()
	else
		user << "<span class='notice'>Access Denied</span>"

/obj/structure/closet/secure_closet/place(var/mob/user, var/obj/item/I)
	if(!src.opened)
		togglelock(user)
		return 1
	return 0

/obj/structure/closet/secure_closet/attackby(obj/item/weapon/W as obj, mob/living/user as mob, params)

	if(!src.opened && src.broken)
		user << "<span class='notice'>The locker appears to be broken.</span>"
		return

	if(istype(W, /obj/item/weapon/screwdriver) && !src.broken && !src.opened)
		if(panel_open == 1)
			user << "<span class='notice'>You screw the access panel closed.</span>"
			panel_open = 0
			return
		else if(panel_open == 0)
			user << "<span class='notice'>You screw the access panel open</span>"
			panel_open = 1
			return

	if(istype(W, /obj/item/device/multitool) && !src.broken && !src.opened)
		if(locked == 0)
			user << "<span class='notice'>[src] is already unlocked.</span>"
			return
		else if(panel_open == 1)
			if(pulsed == 0)
				user << "<span class='notice'>You start to rapidly pulse the ID checking system... Hold the multitool steady, this may take a moment.</span>"
				add_fingerprint(user)
				spawn(60)
					if(prob(75))
						user.electrocute_act(10, src, 1.0) //5 shock dam,
//						electrocute_mob(user, get_area(src),src)
						var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
						s.set_up(5, 1, src)
						s.start()
				if(do_after(user, 120))
					user << "<span class='notice'>You overload the lock</span>"
					icon_state = icon_broken
					pulsed = 1
					return
				else
					user << "<span class='warning'>You moved the multitool away..</span>"
					return
			if(pulsed == 1)
				user << "<span class='notice'>You reset the malfunctioning lock</span>"
				pulsed = 0
				icon_state = icon_closed
				return
		else
			user << "<span class='notice'>The access panel needs to be open first</span>"
			return

	if(istype(W, /obj/item/weapon/crowbar) && !src.broken && !src.opened)
		if(welded == 1)
			user << "<span class='danger'>You can't force it open when it's welded shut!</span>"
			return
		else if(pulsed == 1)
			user.visible_message("<span class='warning'>[user] starts trying to crowbar the [src.name] open!</span>")
			if(do_after(user, 50))
				playsound(src.loc, 'sound/effects/bin_open.ogg',200,1)
				user.visible_message("<span class='danger'>[user] manages to force open the [src.name], breaking the lock in the process!</span>")
				broken = 1
				locked = 0
				opened = 1
				pulsed = 0
				desc = "It appears to be have been broken by force."
				icon_state = icon_opened
				src.dump_contents()
				src.density = 0
				return
			else
				user << "<span class='warning'>You give up on trying to force it open.</span>"
				return
		else
			user << "<span class='notice'>You try to force it open but it's locked tight.</span>"
			return



	else if(istype(W, /obj/item/weapon/melee/energy/blade) && !broken)
		broken = 1
		locked = 0
		desc = "It appears to be broken."
		icon_state = icon_off
		flick(icon_broken, src)
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
		playsound(src.loc, "sparks", 50, 1)
		visible_message("<span class='warning'>[user] has sliced the locker open with an energy blade!</span>", "You hear metal being sliced and sparks flying.")
	else
		..(W, user)

/obj/structure/closet/secure_closet/emag_act(mob/user as mob)
	if(!broken)
		broken = 1
		locked = 0
		desc += "It appears to be broken."
		update_icon()

		for(var/mob/O in viewers(user, 3))
			O.show_message("<span class='warning'>The locker has been broken by [user] with an electromagnetic card!</span>", 1, "You hear a faint electrical spark.", 2)
		overlays += "sparking"
		spawn(4) //overlays don't support flick so we have to cheat
		update_icon()

/obj/structure/closet/secure_closet/relaymove(mob/user as mob)
	if(user.stat || !isturf(src.loc))
		return

	if(!(src.locked))
		open()
	else
		user << "<span class='notice'>The locker is locked!</span>"
		if(world.time > lastbang+5)
			lastbang = world.time
			for(var/mob/M in get_hearers_in_view(src, null))
				M.show_message("<FONT size=[max(0, 5 - get_dist(src, M))]>BANG, bang!</FONT>", 2)
	return

/obj/structure/closet/secure_closet/attack_hand(mob/user as mob)
	src.add_fingerprint(user)

	if(!src.toggle())
		return src.attackby(null, user)

/obj/structure/closet/secure_closet/attack_paw(mob/user as mob)
	return src.attack_hand(user)
