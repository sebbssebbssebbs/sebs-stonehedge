/*
Slimecrossing Potions
	Potions added by the slimecrossing system.
	Collected here for clarity.
*/

//Extract cloner - Charged Grey
/obj/item/slimepotion/extract_cloner
	name = "extract cloning potion"
	desc = ""
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpurple"

/obj/item/slimepotion/extract_cloner/afterattack(obj/item/target, mob/user , proximity)
	if(!proximity)
		return
	if(istype(target, /obj/item/reagent_containers))
		return ..(target, user, proximity)
	if(istype(target, /obj/item/slimecross))
		to_chat(user, span_warning("[target] is too complex for the potion to clone!"))
		return
	if(!istype(target, /obj/item/slime_extract))
		return
	var/obj/item/slime_extract/S = target
	if(S.recurring)
		to_chat(user, span_warning("[target] is too complex for the potion to clone!"))
		return
	var/path = S.type
	var/obj/item/slime_extract/C = new path(get_turf(target))
	C.Uses = S.Uses
	to_chat(user, span_notice("I pour the potion onto [target], and the fluid solidifies into a copy of it!"))
	qdel(src)
	return

//Peace potion - Charged Light Pink
/obj/item/slimepotion/peacepotion
	name = "pacification potion"
	desc = ""
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potlightpink"

/obj/item/slimepotion/peacepotion/attack(mob/living/M, mob/user)
	if(!isliving(M) || M.stat == DEAD)
		to_chat(user, span_warning("The pacification potion only works on the living."))
		return ..()
	if(istype(M, /mob/living/simple_animal/hostile/megafauna))
		to_chat(user, span_warning("The pacification potion does not work on beings of pure evil!"))
		return ..()
	if(M != user)
		M.visible_message(span_danger("[user] starts to feed [M] a pacification potion!"),
			span_danger("[user] starts to feed you a pacification!"))
	else
		M.visible_message(span_danger("[user] starts to drink the pacification potion!"),
			span_danger("I start to drink the pacification potion!"))

	if(!do_after(user, 100, target = M))
		return
	if(M != user)
		to_chat(user, span_notice("I feed [M] the pacification potion!"))
	else
		to_chat(user, span_warning("I drink the pacification potion!"))
	if(isanimal(M))
		ADD_TRAIT(M, TRAIT_PACIFISM, MAGIC_TRAIT)
	else if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_SURGERY)
	qdel(src)

//Love potion - Charged Pink
/obj/item/slimepotion/lovepotion
	name = "love potion"
	desc = ""
	icon = 'icons/roguetown/items/cooking.dmi'
	icon_state = "lovebottle"

/obj/item/slimepotion/lovepotion/attack(mob/living/carbon/human/M, mob/user)
	if(!isliving(M) || M.stat == DEAD)
		to_chat(user, span_warning("The love potion only works on living things, sicko!"))
		return ..()
	if(istype(M, /mob/living/simple_animal/hostile/megafauna))
		to_chat(user, span_warning("The love potion does not work on beings of pure evil!"))
		return ..()
	if(user == M)
		to_chat(user, span_warning("I can't drink the love potion. What are you, a narcissist?"))
		return ..()
	if(M.has_status_effect(STATUS_EFFECT_INLOVE))
		to_chat(user, span_warning("[M] is already lovestruck! This will undo the effects..."))
		M.remove_status_effect(STATUS_EFFECT_INLOVE)
		M.remove_curse(/datum/curse/baotha, TRUE)
		M.faction = initial(M.faction)
		to_chat(M, span_notice("I am freed of the effects of love potion."))
		qdel(src)
		return ..()

	M.visible_message(span_danger("[user] starts to feed [M] a love potion!"),
		span_danger("[user] starts to feed you a love potion!"))

	if(!do_after(user, 50, target = M))
		return
	to_chat(user, span_notice("I feed [M] the love potion!"))
	to_chat(M, span_notice("I develop feelings for [user], and anyone [user.p_they()] like."))
	M.faction |= "[REF(user)]"
	M.apply_status_effect(STATUS_EFFECT_INLOVE, user)
	M.add_curse(/datum/curse/baotha, TRUE)
	qdel(src)

/obj/item/slimepotion/endowpotion
	name = "endowment potion"
	desc = "Makes one uncomfortably endowed for about 10 minutes. It has <b>3 uses</b> left."
	icon = 'modular_stonehedge/icons/roguetown/items/cooking.dmi'
	icon_state = "endowbottle"
	var/uses = 3

/obj/item/slimepotion/endowpotion/attack(mob/living/M, mob/user)
	if(!isliving(M) || M.stat == DEAD)
		to_chat(user, span_warning("The endowment potion only works on living things, sicko!"))
		return ..()

	if(M.has_status_effect(STATUS_EFFECT_ENDOWED))
		to_chat(user, span_warning("[M] is already endowed! This will reset the duration..."))
	M.visible_message(span_danger("[user] starts to feed [M] an endowment potion!"),
		span_danger("[user] starts to feed you an endowment potion!"))
	if(!do_after(user, 25, target = M))
		return
	uses--
	desc = "Makes one uncomfortably endowed for about 10 minutes.  It has <b>[uses] uses</b> left."
	if(uses <= 0)
		to_chat(M, span_notice("The potion is useless now."))
		qdel(src)
	to_chat(user, span_notice("I feed [M] the endowment potion!"))
	if(M.has_status_effect(STATUS_EFFECT_ENDOWED))
		M.remove_status_effect(STATUS_EFFECT_ENDOWED)
	M.apply_status_effect(STATUS_EFFECT_ENDOWED)

//Pressure potion - Charged Dark Blue
/obj/item/slimepotion/spaceproof
	name = "slime pressurization potion"
	desc = ""
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potblue"
	var/uses = 2

/obj/item/slimepotion/spaceproof/afterattack(obj/item/clothing/C, mob/user, proximity)
	. = ..()
	if(!uses)
		qdel(src)
		return
	if(!proximity)
		return
	if(!istype(C))
		to_chat(user, span_warning("The potion can only be used on clothing!"))
		return
	if(C.min_cold_protection_temperature == SPACE_SUIT_MIN_TEMP_PROTECT && C.clothing_flags & STOPSPRESSUREDAMAGE)
		to_chat(user, span_warning("The [C] is already pressure-resistant!"))
		return ..()
	to_chat(user, span_notice("I slather the blue gunk over the [C], making it airtight."))
	C.name = "pressure-resistant [C.name]"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#000080", FIXED_COLOUR_PRIORITY)
	C.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	C.cold_protection = C.body_parts_covered
	C.clothing_flags |= STOPSPRESSUREDAMAGE
	uses--
	if(!uses)
		qdel(src)

//Enhancer potion - Charged Cerulean
/obj/item/slimepotion/enhancer/max
	name = "extract maximizer"
	desc = ""
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpurple"

//Lavaproofing potion - Charged Red
/obj/item/slimepotion/lavaproof
	name = "slime lavaproofing potion"
	desc = ""
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potred"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	var/uses = 2

/obj/item/slimepotion/lavaproof/afterattack(obj/item/C, mob/user, proximity)
	. = ..()
	if(!uses)
		qdel(src)
		return ..()
	if(!proximity)
		return ..()
	if(!istype(C))
		to_chat(user, span_warning("I can't coat this with lavaproofing fluid!"))
		return ..()
	to_chat(user, span_notice("I slather the red gunk over the [C], making it lavaproof."))
	C.name = "lavaproof [C.name]"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#800000", FIXED_COLOUR_PRIORITY)
	C.resistance_flags |= LAVA_PROOF
	if (istype(C, /obj/item/clothing))
		var/obj/item/clothing/CL = C
		CL.clothing_flags |= LAVAPROTECT
	uses--
	if(!uses)
		qdel(src)

//Revival potion - Charged Grey
/obj/item/slimepotion/slime_reviver
	name = "slime revival potion"
	desc = ""
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potsilver"

/obj/item/slimepotion/slime_reviver/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, span_warning("The potion only works on slimes!"))
		return ..()
	if(M.stat != DEAD)
		to_chat(user, span_warning("The slime is still alive!"))
		return
	if(M.maxHealth <= 0)
		to_chat(user, span_warning("The slime is too unstable to return!"))
	M.revive(full_heal = TRUE, admin_revive = FALSE)
	M.stat = CONSCIOUS
	M.visible_message(span_notice("[M] is filled with renewed vigor and blinks awake!"))
	M.maxHealth -= 10 //Revival isn't healthy.
	M.health -= 10
	M.regenerate_icons()
	qdel(src)

//Stabilizer potion - Charged Blue
/obj/item/slimepotion/slime/chargedstabilizer
	name = "slime omnistabilizer"
	desc = ""
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potcyan"

/obj/item/slimepotion/slime/chargedstabilizer/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, span_warning("The stabilizer only works on slimes!"))
		return ..()
	if(M.stat)
		to_chat(user, span_warning("The slime is dead!"))
		return
	if(M.mutation_chance == 0)
		to_chat(user, span_warning("The slime already has no chance of mutating!"))
		return

	to_chat(user, span_notice("I feed the slime the omnistabilizer. It will not mutate this cycle!"))
	M.mutation_chance = 0
	qdel(src)
