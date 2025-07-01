--
-- cproxy_msg.lua
-- Garden Lies, 													   04/12/24
--

-- 
-- Objet permettant de gérer les flux de message 
-- pour les proxies et supporter plus d'opérations.
--
local M = {}
M.__index = M

local msg_utils = require "src.modules.utils.msg"

--
-- Appelle un handler puis efface le message restant.
--
local function appeler_handler(self, url, handler)
	handler(url)
	self.appels[msg_utils.url_to_hash(url)] = nil
end

--
-- Crée une nouvelle instance du module
-- qui pourra gérer le flux de messages.
--
function M.new()
	
	local self = setmetatable({}, M)
	self.appels = {} -- Messages de l'utilisateur
	
	return self
end

--
-- Charge une collection en asynchrone
-- via un collectionproxy, puis exécute un handler
-- avec l'url du proxy.
--
function M:charger_async(url_pcollection, handler)

	handler = handler or function(url) end
	local url_entiere = msg.url(url_pcollection)
	
	msg.post(url_entiere, msg_utils.ASYNC_LOAD)
	self.appels[msg_utils.url_to_hash(url_entiere)] = handler
end

-- 
-- Initialise et active une collection à partir
-- d'une url d'un proxy.
--
function M:activer(url_pcollection)
	msg.post(url_pcollection, msg_utils.ENABLE)
end

-- 
-- Désactive une collection à partir
-- d'une url d'un proxy.
--
function M:desactiver(url_pcollection)
	msg.post(url_pcollection, msg_utils.DISABLE)
end

--
-- Décharge une collection
-- via un collectionproxy, puis exécute un handler
-- avec l'url du proxy.
--
function M:decharger(url_pcollection, handler)

	handler = handler or function(url) end
	local url_entiere = msg.url(url_pcollection)

	msg.post(url_entiere,msg_utils.UNLOAD)
	self.appels[msg_utils.url_to_hash(url_entiere)] = handler
end

-- 
-- Initialise une collection à partir
-- d'une url d'un proxy.
--
function M:initialiser(url_pcollection)
	msg.post(url_pcollection, msg_utils.INIT)
end

--
-- Gère les messages de collectionproxy.
--
function M:on_message(message_id, message, sender)

	local handler_sender = self.appels[msg_utils.url_to_hash(sender)]

	if handler_sender and message_id == msg_utils.PROXY_LOADED 
	or message_id == msg_utils.PROXY_UNLOADED then
		appeler_handler(self, sender, handler_sender)
	end
end

return M