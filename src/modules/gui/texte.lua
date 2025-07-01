--
-- texte.lua
-- Garden Lies, 													   20/09/24
--

--
-- Opérations utilitaires sur des noeuds de texte.
--
local M = {}

local gui_utils = require "src.modules.utils.gui"

local vector3 = vmath.vector3

--
-- Crée un nouveau noeud texte.
--
function M.creer_noeud_texte(position, texte)
	
	local noeud_texte 
	= gui_utils.new_text_node_stretch(position or vector3(),
									  texte or "")

	gui.set_adjust_mode(noeud_texte, gui.ADJUST_STRETCH)
	gui.set_pivot(noeud_texte, gui.PIVOT_SW)

	--
	-- Tout les GUIs doivent inclure le matériel modifié "font" pour que
	-- le module fonctionne correctement !
	-- 
	gui.set_material(noeud_texte, "font")

	return noeud_texte
end

--
-- Retourne la longueur et la largeur
-- en nombre de pixels d'un texte.
--
function M.get_taille_pixels(noeud_texte)
	
	local police = gui.get_font_resource(gui.get_font(noeud_texte))
	local texte = gui.get_text(noeud_texte)
	local meta = resource.get_text_metrics(police, texte)

	return meta.width, meta.height
end

return M