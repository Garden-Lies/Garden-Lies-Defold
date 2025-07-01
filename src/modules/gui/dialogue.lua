--
-- dialogue.lua
-- Garden Lies, 													   10/11/24
--

--
-- Gère la disposition d'une boîte de dialogue.
-- Les sprites, ni les contrôleurs ne sont fournis.
--
local M = {}
M.__index = M

local gui_utils = require "src.modules.utils.gui"
local vector2 = require "src.modules.utils.vector".vector2

-- ===================== Constantes =====================

-- Taille fixe du jeu
local RES_X, RES_Y = sys.get_config_int("display.width"),
					 sys.get_config_int("display.height")

-- Marges extérieures
local MAX_SIZE_X, MAX_SIZE_Y = RES_X - 40, RES_Y - 10

-- Placements possibles des dialogues.
local PLACEMENTS_BOITE = {
	
	["CENTRE"] = {
		position = vector2(RES_X / 2, RES_Y / 4.5),
		taille = vector2(MAX_SIZE_X / 3.5 , MAX_SIZE_Y / 7)
	},

	["CENTRE_REDUIT"] = {
		position = vector2(RES_X / 2, RES_Y / 4.5),
		taille = vector2(MAX_SIZE_X / 6 , MAX_SIZE_Y / 7)
	},

	["GAUCHE"] = {
		position = vector2(RES_X / 4, RES_Y / 3.5),
		taille = vector2(MAX_SIZE_X / 6, MAX_SIZE_Y / 6)
	},

	["DROITE"] = {
		position = vector2(RES_X / 1.4, RES_Y / 3.5),
		taille = vector2(MAX_SIZE_X / 6, MAX_SIZE_Y / 6)
	},

	["NULL"] = {
		position = vector2(RES_X / 2, RES_Y / 4.5),
		taille = vector2()
	}
}

-- ====================== Méthodes ======================

local function setup_boite(self, echelle_boite, noeud_cadre)
	
	local placement_defaut = PLACEMENTS_BOITE["NULL"]
	self.boite = {

		racine = gui_utils.new_box_node_stretch(placement_defaut.position,
												placement_defaut.taille)

		-- TODO prise en charge du nom
	}

	local p = self.boite 

	p.cadre = noeud_cadre 
		   or gui_utils.new_box_node_stretch(vector2(), vector2())

	gui.set_parent(p.cadre, p.racine)
	
	gui.set_enabled(p.racine, false)
	gui.set_visible(p.racine, false)
	gui.set_scale(p.racine, vector2(echelle_boite, echelle_boite))
end

-- 
-- Créee une nouvelle boîte de dialogue
-- avec un placement par défaut.
-- Elle est invisible après création.
--
-- Le cadre peut être défini à l'avance.
--
function M.new(echelle_boite, noeud_cadre)
	
	local self = setmetatable({}, M)

	setup_boite(self, echelle_boite or 1, noeud_cadre)
	self.taille_cadre = gui.get_size(self.boite.cadre) -- Taille du cadre
	
	return self
end

--
-- Retourne le cadre de la boîte de dialogue.
--
function M:get_cadre()
	return self.boite.cadre
end

--
-- Détermine les quatre points au bord du cadre,
-- respectivement les coordonnées
-- haut, droite, bas et gauche.
--
-- Une marge peut éventuellement être appliquée
-- pour ne pas être collé au cadre.
--
--
-- Si vous voulez ajouter des éléments par rapport à cette méthode,
-- il faut ajouter le noeud en tant que l'enfant du cadre, puis
-- modifier son pivot :
-- * Centrer les noeuds fonctionnent pour tout points.
-- * Sinon, il faut un pivot différent pour chaque position du point,
--   soit les 9 cardinaux existants.
--
function M:get_limites_cadre(marge_x, marge_y)

	-- Moitié de la texture du cadre.
	local taille_demi_cadre = self.taille_cadre * .5

	-- On détermine les coordonnées du point bas et gauche.
	local point_bas = -taille_demi_cadre.y + (marge_y or 0)
	local point_gauche = -taille_demi_cadre.x + (marge_x or 0)

	-- Les autres sont déterminés par symétrie.
	return vmath.vector4(-point_bas, -point_gauche,
						  point_bas, point_gauche)
end

--
-- Retourne la boîte de dialogue entièrement.
--
function M:get_racine()
	return self.boite.racine
end

--
-- Paramètre une texture découpée pour le cadre.
-- Sans slice, on aurait un mauvais rendu.
--
function M:set_cadre_texture(atlas, texture, slice9)
	
	gui.set_texture(self.boite.cadre, atlas)
	gui.play_flipbook(self.boite.cadre, texture)
	
	gui.set_slice9(self.boite.cadre, slice9)
end

--
-- Place la boîte de dialogue dans la nouvelle position
-- et change la taille de celle-ci au préalable.
--
function M:set_placement(placement, delais_pos, delais_taille,
						 complete_function)

	-- Détermine l'animation qui devra exécuter la fonction finale.
	local fct_a = (complete_function and delais_pos >= delais_taille)
			   and complete_function or nil
	
	local fct_b = (complete_function and not fct_a) and complete_function or nil

	local transformation = PLACEMENTS_BOITE[placement]
	gui.animate(self.boite.racine, gui.PROP_POSITION, transformation.position,
				gui.EASING_OUTEXPO, delais_pos or 0, 0, fct_a)

	gui.animate(self.boite.cadre, gui.PROP_SIZE, transformation.taille,
	gui.EASING_OUTEXPO, delais_taille or 0, 0, fct_b)

	-- La taille est mise à jour après coup.
	self.taille_cadre = transformation.taille
end

return M