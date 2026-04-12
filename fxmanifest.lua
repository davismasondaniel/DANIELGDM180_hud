fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'DANIELGDM180'
description 'car hud'
version '1.0.0'


ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/sounds/buckle.ogg',
    'html/sounds/unbuckle.ogg',
    'html/fuel-icon.png',
    'html/engine-icon.png'
}

client_scripts {
    'config.lua',
    'client/client.lua'
}

shared_scripts {
	'@ox_lib/init.lua'
}

dependencies {
    'LegacyFuel',
    'ox_lib',
}
