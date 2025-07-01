--
-- magnitude.lua
-- Garden Lies, 													   15/07/24
--
-- Revue majeure le 17/07/24
-- Légères optimisations le 21/07/24 - 24/07/24
-- Réecriture le 03/08/24
--

--
-- Offre des opérations sur la direction d'un vecteur et 
-- la nouvelle position qu'une entité peut avoir
-- lorsqu'elle se déplace.
--
-- Remarquez que le composant n'utilise que les coordonnées x et y,
-- Garden Lies n'a pas besoin de 3D.
--
local M = {}

local actions = require "src.modules.input.constantes_action_id"

-- Magnitude d'un vecteur dans quatre directions.

M.MAGNITUDE_X = {
	[actions.DROITE] = 1,
	[actions.GAUCHE] = -1
}

M.MAGNITUDE_Y = {
	[actions.HAUT] = 1,
	[actions.BAS] = -1,
}

-- Remplace vmath.length pour ne pas toucher au z.
local function longueur_vecteur(vecteur)

	-- Devrait être rapide sur un processeur moderne.
	return (vecteur.x * vecteur.x 
		  + vecteur.y * vecteur.y) ^ .5
end

-- Les diagonales, soient (1, 1) ; (-1, 1) ; (-1, -1) ; (1, -1)
function M.est_diagonale(vecteur)
	return vecteur.x ~= 0 and vecteur.y ~= 0
end

function M.est_vecteur_nul(vecteur)
	return vecteur.x == 0 and vecteur.y == 0
end

--
-- Remplace vmath.normalize afin de ne pas
-- créer un nouveau vecteur à chaque trame.
--
-- Renvoit v = (0, 0) si la longueur du vecteur est de 0.
--
function M.normaliser_vecteur(vecteur)
	
	local norme_vecteur = longueur_vecteur(vecteur)
	if norme_vecteur == 0 then
		return 0, 0
	end
	
	return vecteur.x / norme_vecteur, vecteur.y / norme_vecteur
end

--
-- Calcule une nouvelle position
-- en appliquant la magnitude donnée.
--
function M.get_nouvelle_position(position, magnitude, vitesse, dt)

	local v_dt = vitesse * dt
	return (position.x + magnitude.x * v_dt),
		   (position.y + magnitude.y * v_dt)
end

return M