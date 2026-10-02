fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'nb-dispatch'
author 'NullBound - Veyx (AJ)'
description 'Modern Multi-Framework FiveM Dispatch - Created by NullBound - Veyx (AJ)'
version '1.0.0'

ui_page 'web/build/index.html'

shared_scripts {
    'config.lua',
    'shared/constants.lua',
    'shared/utils.lua',
}

client_scripts {
    'client/main.lua',
    'client/nui.lua',
    'client/blips.lua',
    'client/dispatch.lua',
    'client/detection.lua',
}

server_scripts {
    'bridge/init.lua',
    'bridge/esx.lua',
    'bridge/qbcore.lua',
    'bridge/qbox.lua',
    'bridge/standalone.lua',
    'server/permissions.lua',
    'server/database.lua',
    'server/units.lua',
    'server/calls.lua',
    'server/main.lua',
}

files {
    'web/build/index.html',
    'web/build/assets/**/*',
}
