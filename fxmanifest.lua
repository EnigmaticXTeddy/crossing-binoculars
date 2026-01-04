fx_version 'cerulean'
game 'rdr3'

description 'Crossing Scripts - RSG Binoculars Script'
version '1.0.0'
author 'Crossing-Scripts'

client_scripts {
    'client/binoculars.lua'
}

server_scripts {
    'server/binoculars.lua'
}

dependencies {
    'rsg-core'
}

lua54 'yes'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'