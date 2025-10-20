name "flex_moneywashv2"
author "Flexiboi"
version "0.0.1"
description "Moneywash"
fx_version "cerulean"
game "gta5"
lua54 'yes'

shared_scripts {
	'@ox_lib/init.lua',
	'@PolyZone/client.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/BoxZone.lua',
    'config.lua',
	'locales/*.lua',
	'client/bridge/*.lua',
	'server/bridge/*.lua',
}

client_scripts {
	'@PolyZone/client.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/BoxZone.lua',
	'client/bridge/*.lua',
	'client/*.lua',
}

server_scripts {
	'server/**.lua',
}

-- ['blackmoney']          = {
-- 	label = 'Dirty Money',
-- 	client = {
-- 		image = 'blackmoney.png',
-- 	},
-- 	buttons = {
-- 		{
-- 			label = "Rollen",
-- 			action = function(slot)
-- 				TriggerEvent('sublime_moneywash:Client:RollMoney')
-- 			end 
-- 		}
-- 	}
-- },
-- ['brick_phone']          = {
-- 	label = 'Telefoon',
-- 	client = {
-- 		image = 'phone.png',
-- 	},
-- 	buttons = {
-- 		{
-- 			label = "Bellen",
-- 			action = function(slot)
-- 				TriggerEvent('sublime_moneywash:Client:Startrun')
-- 			end 
-- 		}
-- 	}
-- },