--
-- compteur_trames.lua
-- Garden Lies, 													   01/11/24
--

--
-- Simple compteur pouvant être vidé
-- automatiquement ou manuellement.
--
local M = {}
M.__index = M

--
-- Initialise un compteur
--
-- trames_limite_vidage défini la trame 
-- dans laquelle le compteur devra être mis à zéro.
-- Si la limite est -1, alors il ne sera jamais vidé.
--
-- est_vidage_cyclique défini si lors du vidage,
-- le nombre de trames doit retomber à zéro (true par défaut.)
-- Sinon le nombre de trames reste bloqué à la limite.
--
function M.new(trames_limite_vidage, est_vidage_cyclique)

	local self = setmetatable({}, M)
	
	self.trames_limite_vidage = trames_limite_vidage
	self.trames = 0

	self.algorithme_vidage = self.vider_trames
	if est_vidage_cyclique ~= nil and not est_vidage_cyclique then
		self.algorithme_vidage = function() end -- ne se vide jamais
	end
	
	return self
end

function M:get_trames()
	return self.trames
end

--
-- Incrémente le compteur
--
-- Est vidé automatiquement 
-- si la limite de trames_limite_vidage est atteinte.
--
-- True est retourné si le compteur a été vidé, sinon false.
--
function M:incrementer_trames()

	if self.trames == self.trames_limite_vidage then
		self:algorithme_vidage()
		return true
	end

	self.trames = self.trames + 1
	return false
end

function M:vider_trames()
	self.trames = 0
end

return M