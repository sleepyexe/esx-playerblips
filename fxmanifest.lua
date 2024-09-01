fx_version 'cerulean'
lua54 'yes'
game 'gta5'

name "playerblips"
description "Player Blips"
author "Sleepy Rae"
version "1.0.0"

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
	'shared/*.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

