--
-- vector.lua
-- Garden Lies, 													   23/11/24
--

-- 
-- Opérations supplémentaires sur les vecteurs.
--
local M = {}

local vector = vmath.vector
local vector3 = vmath.vector3

--
-- Crée un vecteur avec n valeurs.
--
function M.vector(...) 

	local valeurs = {...}
	return vector(valeurs)
end

--
-- Crée un vecteur de dimension 2.
-- Inplicitement, z sera mis à 0.
--
-- Si x et y ne sont pas spécifiés, alors le vecteur sera 0.
--
function M.vector2(x, y)

	if (x == nil and y == nil) then
		return vector3(0)
	end
	
	return vector3(x, y, 0)
end

return M