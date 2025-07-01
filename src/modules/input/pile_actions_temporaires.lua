--
-- pile_actions_temporaires.lua
-- Garden Lies, 													   01/11/24
--

--
-- Garde une pile des actions sauvegardées
-- pendant une certaine période. 
--
local M = {}
M.__index = M

local compteur_trames = require "src.modules.information.compteur_trames"

local clear = require "src.modules.utils.table".clear

local PILE_TRAMES_VIDAGE_DEFAUT = 50

--
-- trames_existance_pile : le nombre de trames maximum
--						   avant que la pile se vide.
--
function M.new(...)

	local self = setmetatable({}, M)
	local arguments = ... or {}
	
	self.pile_actions_effectuees = {}

	-- Temps d'existance en trames avant que la pile se vide.
	self.trames_existance_pile
	= compteur_trames.new(arguments.trames_existance_pile
					   or PILE_TRAMES_VIDAGE_DEFAUT)

	return self
end

--
-- Récupère action_id de la fonction on_input et
-- demande une insertion de cette action dans
-- update_pile()
--
function M:set_action(action_id)
	self.action_id = action_id
	self.maj = true
end

-- 
-- Doit être mise à jour constamment dans un update() !
--
-- Met à jour une pile des actions effectuées et
-- renvoie une référence de cette table.
--
-- Elle est vidée selon un nombre de trames atteintes.
--
function M:update_pile()
	
	if self.trames_existance_pile:incrementer_compteur() then
		clear(self.pile_actions_effectuees)
	end

	-- Mise à jour seulement si une touche a été rentrée.
	if self.maj then
		self.pile_actions_effectuees[#self.pile_actions_effectuees + 1] 
		= self.action_id
		self.maj = false
	end

	return self.pile_actions_effectuees
end

return M