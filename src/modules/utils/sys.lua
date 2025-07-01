--
-- sys.lua
-- Garden Lies, 													   23/11/24
--

--
-- Constantes et méthodes supplémentaires pour le module sys
--
local M = {}

local format = string.format

local FORMAT_MESSAGE_EXIT = "L'application s'est fermé proprement "
						 .. "avec le code '%s'"

-- Codes erreur

M.CODE_ERREUR_INCONNUE = 0
M.CODE_SUCCES = 1
M.CODE_SORTIE_FORCEE = 2
M.CODE_FICHIER_NON_TROUVE = 3

--
-- Affiche un message sur la console avant de quitter le jeu
-- avec un code de sortie.
--
function M.exit_with_msg(code)
	print(format(FORMAT_MESSAGE_EXIT, code))
	sys.exit(code)
end

return M