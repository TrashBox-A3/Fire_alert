#define EXPLORATION_RANGE 200
#define MARKER_RESPAWN_TIME 10
#define MARKER_END_TIME 10

if (!isServer) exitwith {};

rock_script = false;
check_count = 0;
script_caller = "";
check_time = time;

suppressor_items = [
"muzzle_snds_H",
"muzzle_snds_L",
"muzzle_snds_M",
"muzzle_snds_B",
"muzzle_snds_H_MG",
"muzzle_snds_H_SW",
"muzzle_snds_acp",
"muzzle_snds_338_black",
"muzzle_snds_338_green",
"muzzle_snds_338_sand",
"muzzle_snds_93mmg",
"muzzle_snds_93mmg_tan",
"muzzle_snds_H_khk_F",
"muzzle_snds_H_snd_F",
"muzzle_snds_58_blk_F",
"muzzle_snds_m_khk_F",
"muzzle_snds_m_snd_F",
"muzzle_snds_B_khk_F",
"muzzle_snds_B_snd_F",
"muzzle_snds_58_wdm_F",
"muzzle_snds_65_TI_blk_F",
"muzzle_snds_65_TI_hex_F",
"muzzle_snds_65_TI_ghex_F",
"muzzle_snds_H_MG_blk_F",
"muzzle_snds_H_MG_khk_F"
];

weapon_suppressor = [
"srifle_dmr_04_f",
"srifle_DMR_04_Tan_F"
];

check_shooter = {
	[_this select 0] spawn {
		_unit = _this select 0;
		_timer = time;
		if ((script_caller == str _unit) and (check_time >= _timer)) then
		{
			rock_script = true;
			script_caller = str _unit;
		}
		else
		{
			rock_script = false;
			script_caller = str _unit;
			check_time = time + MARKER_RESPAWN_TIME;
		};
	};
};

respawn_count = {
	check_count = check_count + 1;
	if (check_count > 100) then
	{
		check_count = 0;
	};
};

create_map_marker = {
	[_this select 0, _this select 1] spawn {
		_unit = _this select 0;
		_weapon = _this select 1;
		_items = _unit weaponAccessories _weapon;
		_uname = str check_count + str _unit;
		_tname = "t" + str _uname;
		_size = EXPLORATION_RANGE;
		_ranpos = [(getpos _unit select 0) + (random [-_size, 0, _size]), (getpos _unit select 1) + (random [-_size, 0, _size])];
		_alpha = 1;
		_hour = floor daytime;
		_minute = floor ((daytime - _hour) * 60);

		if (_hour < 10) then
		{
			_hour = "0" + str _hour;
		};
		if (_minute < 10) then
		{
			_minute = "0" + str _minute;
		};

		if (((_items select 0) in suppressor_items) or (_weapon in weapon_suppressor)) exitWith{check_time = time - MARKER_RESPAWN_TIME;};

		/* Ellipse marker */
		_marker = createMarker[_uname,_ranpos];
		_marker setMarkerShape "ELLIPSE";
		_marker setMarkerColor "ColorRed";
		_marker setMarkerSize [_size, _size];
		_marker setMarkerAlpha _alpha;
		_marker setMarkerBrush "Solid";

		/* Dot and marker txit */
		_tmarker = createMarker[_tname,_ranpos];
		_tmarker setMarkerText format ["%1:%2 / %3 fired / weapon : %4",_hour,_minute,name _unit,_weapon];
		_tmarker setMarkerType "hd_dot";
		_tmarker setMarkerColor "Coloryellow";
		_tmarker setMarkerSize [1, 1];
		_tmarker setMarkerAlpha _alpha;

		sleep MARKER_END_TIME;

		for [{_alpha = 1},{_alpha >= -1},{_alpha = _alpha  - 0.01}] do
		{
			_uname setMarkerAlpha _alpha;
			_tname setMarkerAlpha _alpha;
			sleep 0.2;
		};

		sleep 0.1;

		{
			deleteMarker _x;
		} forEach [_uname,_tname];
	};
};

/* player only*/
player addEventHandler  ["Fired", {
	[_this select 0] call check_shooter;
	if (not rock_script) then {
		[] call respawn_count;
		[_this select 0,_this select 1] call create_map_marker;
	};
}];

/* playre and AI
{
_x addEventHandler  ["Fired", {
	[_this select 0] call check_shooter;
	if (not rock_script) then {
		[] call respawn_count;
		[_this select 0,_this select 1] call create_map_marker;
	};
}];
} forEach allUnits;
*/