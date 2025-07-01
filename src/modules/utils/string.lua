--
-- string.lua
-- Garden Lies, 													   22/11/24
--

-- 
-- Opérations supplémentaires par rapport à celles de math.
--
local M = {}

local concat = table.concat
local gmatch = string.gmatch
local format = string.format
local substring = string.sub

local REGEX_SEPARATION = "([^%s]+)"

--
-- Remplace une partie de la chaîne de caractère 
-- par une autre à partir de l'indice i.
--
function M.replace(chaine_a_modifier, chaine_remplacement, i)
	return concat{chaine_remplacement,
				substring(chaine_a_modifier, i + #chaine_remplacement,
				#chaine_a_modifier)}
end

--
-- Sépare les caractères selon le séparateur et
-- les place dans un tableau.
--
function M.split(chaine, caractere_separation)
	
	local t = {}
	for i in gmatch(caractere_separation,
					format(REGEX_SEPARATION, caractere_separation)) do
		t[#t + 1] = i
	end
	return t
end

return M