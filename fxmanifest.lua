fx_version 'cerulean'
games {'gta5'}
author "ameN#4789 or ameN#0001"
description 'Radar Gun Script for FiveM'

shared_scripts {
    'config.lua'
}

client_scripts {
	'cl_weaponNames.lua',
	'client.lua'
}

ui_page "html/index.html"

files{
	"**/weaponcomponents.meta",
	"**/weaponarchetypes.meta",
	"**/weaponanimations.meta",
	"**/pedpersonality.meta",
	"**/weapons.meta",
	"html/index.html",
	"html/js/jquery-3.6.0.min.js",
	"html/img/radargun.png",
	"html/img/scope.png",
	"html/js/listener.js",
	"html/style.css"
}

data_file 'WEAPONCOMPONENTSINFO_FILE' '**/weaponcomponents.meta'
data_file 'WEAPON_METADATA_FILE' '**/weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/weaponanimations.meta'
data_file 'PED_PERSONALITY_FILE' '**/pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/weapons.meta'