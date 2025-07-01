--
-- collisions.lua
-- Garden Lies, 													   05/08/24
--

--
-- Utilitaire sur la correction des collisions
-- et d'autres opérations sur celles-ci.
--
local M = {}

local vect_nul = require "src.modules.physique.magnitude".est_vecteur_nul
local round = require "src.modules.utils.math".round

local abs = math.abs

--
-- Pousse l'entité à l'extérieur d'un bloc.
--
-- TODO (non priorité)
--
-- Trouver un moyen de calculer la distance de pénétration
-- et la norme de cette distance sans utiliser les attributs
-- de Defold.
--
-- Permet de remplacer la méthode gourmande du moteur et de
-- gagner en performance (du moment que les collisions sont en Trigger.)
--
function M.resoudre_collisions(position, distance_penetration, norme_contact)
	return (position.x + distance_penetration * norme_contact.x),
		   (position.y + distance_penetration * norme_contact.y)
end

--
-- Si une entité en rencontre une autre,
-- cela informe si sa direction est l'opposée de la sienne.
--
function M.est_direction_opposee(magnitude, norme_contact)
	return magnitude.x == -round(norme_contact.x) 
	   and magnitude.y == -round(norme_contact.y)
end

--
-- Même chose que la fonction précédente,
-- mais est moins stricte en utilisant une plage de valeur entre 0 et x.
--
-- Il est conseillé d'utiliser des valeurs entre 1 et ~2,
-- sinon tout sera bloqué.
--
-- Note : renvoit false si la magnitude est nulle.
--
function M.est_direction_opposee_approximation(magnitude, norme_contact,
											   plage)

	-- Signifie que l'entité ne bouge pas.
	if vect_nul(magnitude) then
		return false
	end
	
	local norme_difference_x = -magnitude.x - norme_contact.x
	local norme_difference_y = -magnitude.y - norme_contact.y
	return (abs(norme_difference_x) + abs(norme_difference_y)) < plage
end

return M