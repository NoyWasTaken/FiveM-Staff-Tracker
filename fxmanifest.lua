fx_version 'cerulean'
games { 'gta5' }

author 'Noy Bueno (noyb051@gmail.com)'
description 'Simple resource made in order to track staff members activity time'
version '1.0b'

server_scripts {
    'config.lua',
    '@mysql-async/lib/MySQL.lua',
    'server/server.lua'
}
