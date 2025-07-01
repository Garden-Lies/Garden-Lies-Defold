--
-- message.lua
-- Garden Lies, 													   06/09/24
--

--
-- Simplifie l'utilisation des messages en masse.
--
local M = {}
M.__index = M

local clear = require "src.modules.utils.table".clear

local post = msg.post

--
-- TODO le module peut-être optimisé grandement
-- en écrivant une partie en C.
--

function M.new()

	local self = setmetatable({}, M)
	
	self.messages_destinataire = {}
	self.messages_id = {}
	self.messages_valeur = {}
	
	return self
end

--
-- Ajoute un message pouvant être envoyé.
-- Attention, les messages ne peuvent pas être retirés.
--
function M:ajouter_message(message_id, message, sender)

	-- Les trois tables ont la même longueur.
	local len_msg_alloc = #self.messages_id + 1
	self.messages_id[len_msg_alloc] = message_id
	self.messages_valeur[len_msg_alloc] = message
	self.messages_destinataire[len_msg_alloc] = sender
	
end

-- Insuffisant pour le garbage collector.
function M:delete()
	clear(self.messages_destinataire)
	clear(self.messages_id)
	clear(self.messages_valeur)
	clear(self)
end

function M:envoi_brodcast()
	for i = 1, #self.messages_id do
		post(self.messages_destinataire[i], self.messages_id,
			 self.messages_valeur)
	end
end

return M