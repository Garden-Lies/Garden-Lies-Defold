--
-- table.lua
-- Garden Lies, 													   22/11/24
--

-- 
-- Opérations supplémentaires par rapport à celles de table.
--
local M = {}

--
-- Vide une table complètement.
--
function M.clear(t)
	for i, _ in pairs(t) do
		t[i] = nil
	end
end

--
-- Copie une table avec des valeurs primitives.
--
function M.shallow_copy(t)
	
	local t_copy = {}
	for i, v in pairs(t) do
		t_copy[i] = v
	end

	return t_copy
end

return M