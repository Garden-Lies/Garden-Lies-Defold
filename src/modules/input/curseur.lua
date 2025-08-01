--
-- curseur.lua
-- Garden Lies, 													   31/08/24
--

--
-- Peut gérer le principal de la logique du curseur, dont :
-- * L'offset du curseur
-- * L'indexing des éléments selon l'offset.
--
-- Lors du déplacement de l'offset,
-- il est garanti que l'élément à cette position ne sera jamais nil.
--
-- Respecte la CU no° 33 (Déplacer la sélection )
--
local M = {}
M.__index = M

local actions_id = require "src.modules.input.constantes_action_id"
local compteur_trames = require "src.modules.information.compteur_trames"
local analyseur_action = require "src.modules.input.analyseur_action"
local magnitude = require "src.modules.physique.magnitude"

local REPRESENTATION_CURSEUR = "cur_%s : %d, %d"

local DEFAUT_OFFSET = 0
local DEFAUT_TRAMES_LIMITE = 25
local NOM_CURSEUR_DEFAUT = "CURSEUR_DEFAUT"

--
-- La pression n'a pas besoin d'être mise en pause si
-- elle est assez courte, ou si elle est longue.
--
-- Dans le cas d'une pression longue, le nombre d'input est limité
-- pour éviter le spam.
--
local function est_pression_valide(etat_pression, limite_trames, est_presse)
	return etat_pression.est_pression_longue and limite_trames or est_presse
end

local function get_offset_index(self, x, y)
	return x * self.colonnes + y
end

--
-- Remet une coordonnée au point de départ 
-- si elle est inférieure ou supérieure à la longueur d'une grille.
--
local function inv_pos(pos, grille_len)

	if pos > grille_len then
		return 1
	elseif pos < 1 then
		return grille_len
	end

	return pos
end

--
-- Met une coordonnée à l'emplacement donnée
-- sans qu'elle ne dépasse pas non plus les limites de la grille.
--
local function nor_pos(pos, grille_len)
	
	if pos > grille_len then
		return grille_len
	elseif pos < 1 then
		return 1
	end

	return pos
end

local function set_offset(self, x, y)
	self.offsetx, self.offsety = x, y
end

-- À appeler à chaque fois que la position du curseur change.
local function update_offset_pos(self)
	
	if self.inversion_active then
		set_offset(self, inv_pos(self.offsetx, self.colonnes),
						 inv_pos(self.offsety, self.lignes))
	else
		set_offset(self, nor_pos(self.offsetx, self.colonnes),
						 nor_pos(self.offsety, self.lignes))
	end
end

-- TODO méthode pour supprimer des éléments.

function M.new(...)

	local self = setmetatable({}, M)
	local args = ... or {}

	self.nom_curseur = args.nom or NOM_CURSEUR_DEFAUT

	-- Active l'inversion de l'offset dans l'atteinte d'une limite.
	self.inversion_active = args.inversion and true
	
	--
	-- Pseudo matrice contenant des éléments.
	-- La table n'est pas faites pour être itérée.
	--
	self.grille_noeuds = {}

	-- m * n MAX
	self.colonnes = args.grille_x or 1
	self.lignes = args.grille_y or 1

	-- Crée l'offset du curseur
	set_offset(self, args.offsetx or DEFAUT_OFFSET,
					 args.offsety or DEFAUT_OFFSET)
	update_offset_pos(self)

	self.controleur_curseur = analyseur_action.new()
	self.compteur_trames = compteur_trames.new(DEFAUT_TRAMES_LIMITE)

	return self
end

function M:get_element_at_position(x, y)
	return self.grille_noeuds[get_offset_index(self, x, y)]
end

function M:get_element_at_offset()
	return self.grille_noeuds
		[get_offset_index(self, self.offsetx, self.offsety)]
end

function M:get_offset()
	return self.offsetx, self.offsety
end

function M:inc_offset(a, b)
	set_offset(self, self.offsetx + a, self.offsety + b)
	update_offset_pos(self)
end

function M:reset_offset()
	set_offset(self, DEFAUT_OFFSET, DEFAUT_OFFSET)
end

function M:set_element(x, y, e)
	self.grille_noeuds[get_offset_index(self, x, y)] = e
end

--
-- Place le curseur à l'offset indiqué.
-- Il sera toujours normalisé par rapport aux paramètres du curseur
-- et aux limites de la grille.
--
function M:set_offset(x, y)
	set_offset(self, x, y)
	update_offset_pos(self)
end

--
-- Génère une représentation du curseur selon le nom de celui-ci et
-- l'offset actuel.
--
function M:tostring()
	return string.format(REPRESENTATION_CURSEUR, 
						 self.nom_curseur, self.offsetx, self.offsety)
end

--
-- Pour éviter d'implémenter le même algorithme,
-- plutôt utiliser cette méthode.
--
-- Change arbitrairement l'offset.
--
-- Retourne true si le curseur à changé de position, sinon false.
--
function M:update_curseur_input(action_id, action)

	local table_etat_pression 
	= self.controleur_curseur:get_analyse_input(action_id, action)
	
	if actions_id.MOUVEMENTS[action_id] then

		if action.released then
			self.compteur_trames:vider_trames()
		end
		
		local limite_trames = self.compteur_trames:incrementer_trames()
		if est_pression_valide(table_etat_pression, limite_trames,
							   action.pressed) then

			local x, y = self:get_offset()

			self:inc_offset(magnitude.MAGNITUDE_X[action_id] or 0,
							magnitude.MAGNITUDE_Y[action_id] or 0)

			self.compteur_trames:vider_trames()
			
			-- On vérifie la position actuelle et ancienne du curseur.
			return x ~= self.offsetx or y ~= self.offsety
		end
	end

	return false
end

return M