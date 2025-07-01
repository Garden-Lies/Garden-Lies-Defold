--
-- math.lua
-- Garden Lies, 													   22/11/24
--

-- 
-- Opérations supplémentaires par rapport à celles de math.
--
local M = {}

local floor = math.floor

--
-- Arrondit à l'entier le plus proche.
--
function M.round(x)
	return floor(x + .5)
end

return M