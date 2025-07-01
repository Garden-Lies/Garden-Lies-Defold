--
-- analyseur_action.lua
-- Garden Lies, 													   14/07/24
--
-- Refactor et optimisations le 24/09/24
--
-- Redisign des états de pression 
-- et séparation de la pile des actions le 01/11/24
--

--
-- Générateur d'informations utiles pour chaque input.
--
local M = {}
M.__index = M

local compteur_trames = require "src.modules.information.compteur_trames"

local TRAMES_DELAIS_PRESSION_DEFAUT = 20

--
-- Détermine la longueur d'une pression et met à jour les pressions
-- selon celle-ci.
--
local function update_etat_pression(self, compteur, action_lache)

	local p = self.table_action_analyseur 
	
	if not action_lache then
		
		local est_limite_atteinte = compteur:incrementer_trames()
		p.est_pression_courte = not est_limite_atteinte
		p.est_pression_longue = est_limite_atteinte
		
	else
		p.est_pression_courte = false
		p.est_pression_longue = false
		compteur:vider_trames()
	end 

	p.est_pression = p.est_pression_courte or p.est_pression_longue
end

--
-- trames_delais_pression : nombre de trames à considéré pour qu'une pression
--							soit suffisamment longue ou courte.
--
function M.new(...)

	local self = setmetatable({}, M)
	local arguments = ... or {}

	self.table_action_analyseur = {
		est_pression = false,
		est_pression_courte = false,
		est_pression_longue = false
	}

	self.actions = {}

	self.trames_delais_pression = arguments.trames_delais_pression 
							   or TRAMES_DELAIS_PRESSION_DEFAUT
	
	return self
end

--
-- À partir d'une table "action" et de la signature "action_id"
-- de la fonction on_input, déduit de nombreuses
-- informations utiles sur la l'action effectuée.
--
-- Renvoi l'état d'une pression sous forme d'une table référencée :
-- est_pression : une pression actuellement effectuée
-- est_pression_courte : pression inférieure à un nombre de trames
-- est_pression_longue : pression supérieure à un nombre de trames
--
function M:get_analyse_input(action_id, action)
	
	-- Sauvegarde de l'action en cours avec son propre compteur de trames.
	self.actions[action_id] = self.actions[action_id] 
		or compteur_trames.new(self.trames_delais_pression, false)

	update_etat_pression(self, self.actions[action_id], action.released)
	
	return self.table_action_analyseur
end

return M