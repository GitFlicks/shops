
fx_version 'cerulean'
game 'gta5'

author 'Authentic'
description 'Shops System'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
    'config.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/images/**.**'
}
