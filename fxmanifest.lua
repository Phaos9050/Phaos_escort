fx_version 'adamant'

game {'gta5'}

author 'Phaos ¦ soahP#9050'

description 'Minigame Escort'

version '1.0.0'

server_scripts {
    '@es_extended/locale.lua',
	'config.lua',
	'server/main.lua',
	'locales/*.lua',
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'client/main.lua',
	'locales/*.lua',
	--'font.lua'
}