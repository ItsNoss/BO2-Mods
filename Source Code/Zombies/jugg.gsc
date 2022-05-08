#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;

init()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onplayerspawned();
        player thread onPlayerRevived();
    }
}

onplayerspawned()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("spawned_player");
        if (level.round_number >= 8)
        {
            if (isDefined(level.zombiemode_using_juggernaut_perk))
            self doGivePerk("specialty_armorvest");
            self iprintln("You got Juggernaut");
        }

    }
}

onPlayerRevived()
{
	self endon("disconnect");
	level endon("end_game");
	
	for(;;)
	{
		self waittill_any( "whos_who_self_revive","player_revived","fake_revive","do_revive_ended_normally", "al_t" );
		wait 1;
        if (level.round_number >= 8)
        {
            if (isDefined(level.zombiemode_using_juggernaut_perk))
            self doGivePerk("specialty_armorvest");
            self iprintln("You got Juggernaut");
        }
	}
}

doGivePerk(perk)
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");
    self endon("perk_abort_drinking");
    if (!(self hasperk(perk) || (self maps/mp/zombies/_zm_perks::has_perk_paused(perk))))
    {
        gun = self maps/mp/zombies/_zm_perks::perk_give_bottle_begin(perk);
        evt = self waittill_any_return("fake_death", "death","player_downed", "weapon_change_complete");
        if (evt == "weapon_change_complete")
            self thread maps/mp/zombies/_zm_perks::wait_give_perk(perk, 1);
        self maps/mp/zombies/_zm_perks::perk_give_bottle_end(gun, perk);
        if (self maps/mp/zombies/_zm_laststand::player_is_in_laststand() || isDefined(self.intermission))
            return;
        self notify("burp");
    }
}
