
/datum/surgery/cure_rot
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/burn_rot,
		/datum/surgery_step/cauterize
	)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery_step/burn_rot
	name = "burn rot"
	implements = list(
		TOOL_CAUTERY = 85,
		/obj/item/clothing/neck/roguetown/psicross = 85,
		TOOL_WELDER = 70,
		TOOL_HOT = 35,
	)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	time = 8 SECONDS
	surgery_flags = SURGERY_INCISED
	skill_min = SKILL_LEVEL_APPRENTICE
	preop_sound = 'sound/surgery/cautery1.ogg'
	success_sound = 'sound/surgery/cautery2.ogg'

/datum/surgery_step/burn_rot/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/intent/intent)
	display_results(user, target, span_notice("I begin to burn the rot within [target]..."),
		span_notice("[user] begins to burn the rot from [target]'s heart."),
		span_notice("[user] begins to burn the rot from [target]'s heart."))
	return TRUE

// most of this is copied from the Cure Rot spell
/datum/surgery_step/burn_rot/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/intent/intent)
	var/burndam = 20
	if(user.mind)
		burndam -= (user.mind.get_skill_level(/datum/skill/misc/medicine) * 3)
	var/unzombification_pq = PQ_GAIN_UNZOMBIFY 
	var/datum/antagonist/zombie/was_zombie = target.mind?.has_antag_datum(/datum/antagonist/zombie) 
	var/has_rot = was_zombie
	if(!has_rot && iscarbon(target))
		var/mob/living/carbon/stinky = target
		for(var/obj/item/bodypart/bodypart as anything in stinky.bodyparts)
			if(bodypart.rotted || bodypart.skeletonized)
				has_rot = TRUE
				break
	if(was_zombie)
		was_zombie.become_rotman = FALSE
		target.mind.remove_antag_datum(/datum/antagonist/zombie)
		target.Unconscious(20 SECONDS)
		target.emote("breathgasp")
		target.Jitter(100)
		if(unzombification_pq && !HAS_TRAIT(target, TRAIT_IWASUNZOMBIFIED) && user?.ckey)
			adjust_playerquality(unzombification_pq, user.ckey)
			ADD_TRAIT(target, TRAIT_IWASUNZOMBIFIED, "[type]")
	var/datum/component/rot/rot = target.GetComponent(/datum/component/rot)
	if(rot)
		rot.amount = 0
	if(iscarbon(target))
		var/mob/living/carbon/stinky = target
		for(var/obj/item/bodypart/rotty in stinky.bodyparts)
			rotty.rotted = FALSE
			rotty.skeletonized = FALSE
			rotty.update_limb()
			rotty.update_disabled()
	target.update_body()
	display_results(user, target, span_notice("You burn away the rot inside of [target]."),
		"[user] burns the rot within [target].",
		"[user] takes a [tool] to [target]'s innards.")
	target.take_bodypart_damage(null, burndam)
	return TRUE