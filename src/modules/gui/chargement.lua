--
-- chargement.lua
-- Garden Lies, 													   30/11/24
--

--
-- Donne des informations supplémentaires
-- afin de faire un menu de chargement.
--
-- Actuellement, le module gère
-- le nombre d'opérations en attente.
--
local M = {}
M.__index = M

local compteur = require "src.modules.information.compteur_trames"

local round = require "src.modules.utils.math".round

--
-- Crée une instance de chargement 
-- avec le nombre total d'opérations à effectuer.
--
function M.new(nombre_operations)
	
	local self = setmetatable({}, M)
	
	self.nombre_operations_total = nombre_operations
	if nombre_operations == nil or nombre_operations < 0 then
		self.nombre_operations_total = 0
	end

	self.compteur_operations = compteur.new(self.nombre_operations_total,
											false)
	
	return self
end

--
-- Retourne le nombre d'opérations
-- au total que doit effectuer le système.
--
function M:get_operations_total()
	return self.nombre_operations_total
end

--
-- Retourne le nombre d'opérations effectué
-- par le système.
--
function M:get_operations_effectuees()
	return self.compteur_operations:get_trames()
end

--
-- Effectue et retourne en entier le ratio 
-- entre le nombre d'opérations effectué
-- et le nombre d'opérations total
--
function M:get_rapport_operations()

	local operations_total = self:get_operations_total()
	if operations_total == 0 then
		return 100
	end
	
	return round(self:get_operations_effectuees()
			   / self:get_operations_total() * 100)
end

--
-- Incrémente de 1 le nombre d'opération effectué.
--
function M:incrementer_operations_effectuees()
	self.compteur_operations:incrementer_trames()
end

return M