--
-- gui.lua
-- Garden Lies, 													   22/11/24
--

--
-- Contient des constantes et des méthodes supplémentaires
-- pour le gui.
--
local M = {}

local go_utils = require "src.modules.utils.go"

M.PROP_ALPHA = "color.w"

M.PROP_POSITION_X = go_utils.PROP_POSITION_X
M.PROP_POSITION_Y = go_utils.PROP_POSITION_Y

--
-- Crée un noeud conteneur étiré proprement.
--
function M.new_box_node_stretch(pos, size)

	local noeud = gui.new_box_node(pos, size)
	gui.set_adjust_mode(noeud, gui.ADJUST_STRETCH)
	return noeud
end

--
-- Crée un noeud texte étiré proprement.
--
function M.new_text_node_stretch(pos, size)

	local noeud = gui.new_text_node(pos, size)
	gui.set_adjust_mode(noeud, gui.ADJUST_STRETCH)
	return noeud
end

--
-- Récupère les coordonnées du noeud.
--
function M.get_position(node, position)
	return gui.get(node, M.POS_X, position.x),
		   gui.get(node, M.POS_Y, position.y)
end

--
-- Met à jour la position comme le fairait setv.get_position
-- pour les objets.
--
function M.set_position(node, position)
	gui.set(node, M.POS_X, position.x)
	gui.set(node, M.POS_Y, position.y)
end

return M