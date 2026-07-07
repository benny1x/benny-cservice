fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'benny-cservice'
author 'Benny Scripts'
version '1.0.0'
description 'Configurable community service system with multi-framework support'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/debug.lua',
}

client_scripts {
    'client/modules/framework/framework.lua',
    'client/modules/notify/notify.lua',
    'client/modules/textui/textui.lua',
    'client/modules/markers/markers.lua',
    'client/modules/zone/zone.lua',
    'client/modules/tasks/tasks.lua',
    'client/modules/hud/hud.lua',
    'client/modules/commands/commands.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'shared/custom/integrations.lua',
    'server/modules/framework/framework.lua',
    'server/modules/inventory/inventory.lua',
    'server/modules/permissions/permissions.lua',
    'server/modules/database/database.lua',
    'server/modules/commands/commands.lua',
    'server/main.lua',
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js',
}

dependencies {
    'ox_lib',
    'oxmysql',
}

escrow_ignore {
    'shared/config.lua',
    'shared/custom/integrations.lua',
}
