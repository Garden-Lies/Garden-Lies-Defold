--
-- etat.lua
-- Garden Lies, 													   11/07/24
--

--
-- Représente l'état du jeu au moment présent.
-- Plusieurs états simultanés sont possibles.
--
local M = {}
M.__index = M

function M.new()

	local self = setmetatable({}, M)
	
	self.args = {}
	self.callback = function() end
	
	self.liste = {}
	
	return self
end

function M:get_etat(valeur)
	return self.liste[valeur]
end

--
-- Méthode appelée après le changement d'état 
-- d'une valeur.
-- Voir set_etat() avant.
--
function M:set_callback(fn, ...)
	self.args = ...
	self.callback = fn
end

--
-- Crée ou modifie un état selon la valeur donnée.
-- (Devrait seulement être false ou true)
--
function M:set_etat(valeur, nouvelle_valeur)

	-- TODO appeler callback seulement si la valeur a été modifiée.
	
	local v = valeur
	-- if self.liste[v] ~= nouvelle_valeur then
		self.liste[v] = nouvelle_valeur

		--
		-- Appel du callback après un REEL changement d'état,
		-- en rajoutant également deux arguments.
		--
		self.callback(valeur, nouvelle_valeur, self.args)
	-- end
end

return M