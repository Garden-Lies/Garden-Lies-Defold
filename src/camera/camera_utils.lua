--
-- camera_utils.lua
-- Garden Lies, 													   22/07/24
--

-- Offre des composants supplémentaires pour gérer la caméra.
local M = {}

local lerp = vmath.lerp

-- Format de l'écran
local RATIO_RES = vmath.normalize(vmath.vector2(16, 9))

-- smoothstep
function M.AUI(x)
	return x^3 --* (2 - x)
end

function M.CIRCULAIRE(x)
	return 1 - (1 - x^2) ^ .5
end

--
-- Calcule la nouvelle position de la caméra 
-- selon une distance et une direction donnée.
--
function M.calculer_distance_magnitude(position, magnitude, distance)
	return position.x + magnitude.x * distance * RATIO_RES.x,
		   position.y + magnitude.y * distance * RATIO_RES.y
end

--
-- Effectue du lerping entre deux points.
-- Une fonction f(x) peut-être spécifiée.
--
function M.lerping_points(position, position_cible, intensite, dt, fn)

	fn = fn or function(x) return x end 

	return lerp(fn(1 - (intensite * RATIO_RES.x) ^ dt),
				position.x, position_cible.x),

		   lerp(fn(1 - (intensite * RATIO_RES.y) ^ dt),
				position.y, position_cible.y)
end

function M.delta_position(ancienne_position, nouvelle_position)
	return nouvelle_position.x - ancienne_position.x, 
		   nouvelle_position.y - ancienne_position.y
end	

return M