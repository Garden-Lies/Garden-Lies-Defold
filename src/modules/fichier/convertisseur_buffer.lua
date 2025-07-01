--
-- convertisseur_buffer.lua
-- Garden Lies, 													   06/11/24
--

--
-- Convertit des buffers en d'autres types de fichiers.
--
local M = {}

local concat = table.concat
local tochar = string.char

local CHAINE_JSON_VIDE = "{}"

--
-- Transforme un buffer en une table lua
-- avec les propriétés JSON.
--
function M.buffer_to_json(buffer_entree)

	local chaine_buffer = M.buffer_to_string(buffer_entree)
	if chaine_buffer == "" then
		return json.decode(CHAINE_JSON_VIDE)
	end
	
	return json.decode(M.buffer_to_string(buffer_entree))
end

--
-- Retourne un string à partir d'un buffer,
-- ou une chaîne de caractères vide si le buffer est nil.
--
function M.buffer_to_string(buffer_entree)

	if not buffer_entree then
		return ""
	end
	
	local flux_buffer = buffer.get_stream(buffer_entree, "data")
	
	local chaine_corde = {}
	for i = 1, #flux_buffer do
		chaine_corde[i] = tochar(flux_buffer[i])
	end

	return concat(chaine_corde)
end

return M