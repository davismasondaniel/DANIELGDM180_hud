fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'car hud'
version '1.0.0'
author 'DANIELGDM180'

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/sounds/buckle.ogg',
    'html/sounds/unbuckle.ogg',
    'html/fuel-icon.png'
}

client_scripts {
    'config.lua',
    'client/client.lua',
    'client/CruiseControl.lua'
}

dependencies {
    'LegacyFuel',
}
