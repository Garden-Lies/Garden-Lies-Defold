--
-- constantes_action_id.lua
-- Garden Lies, 													   03/07/24
--

--
-- Contient la liste de toutes les actions hashées.
-- Voir config/clavier.input_binding
--
local M = {}

M.HAUT = hash("haut")
M.DROITE = hash("droite")
M.BAS = hash("bas")
M.GAUCHE = hash("gauche")

M.CARTE = hash("carte")
M.CONFIRMER = hash("confirmer")
M.INVENTAIRE = hash("inventaire")
M.OPTIONS = hash("options")
M.RETOUR = hash("retour")
M.ROUE = hash("roue")
M.SPRINT = hash("sprint")

M.MOUVEMENTS = {
	[M.HAUT] = true,
	[M.DROITE] = true,
	[M.BAS] = true,
	[M.GAUCHE] = true
} 

return M