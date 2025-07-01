--
-- printer.lua
-- Garden Lies, 													   17/08/24
--

--
-- Dans une interface graphique ou dans une interface détachée,
-- permet d'afficher les caractères un à un.
--
local M = {}
M.__index = M

local createur_texte = require "src.modules.gui.texte"
local parser = require "src.modules.gui.richtext.rtt_parser"
local gui_utils = require "src.modules.utils.gui"
local table_utils = require "src.modules.utils.table"
local vector2 = require "src.modules.utils.vector".vector2

local concat = table.concat

-- ====================== Constantes ======================

local COULEUR = vmath.vector3(1, 1, 1) -- Blanc
local ECHELLE = vector2(2.5, 2.5)
local ESPACE_X = 8 -- Marge horizontale
local ESPACE_Y = 15 -- Marge verticale
local POSITION = vector2()
local LONGUEUR_LIGNE = 41
local MAX_LETTRES = 120 -- Nombre max de noeuds
local ROTATION = 0
local TEXTE = ""
local VITESSE_PRINT = .05
local WRAP = hash("line_wrap")

local ESPACE_STR = " "
local IDENTITE = vmath.vector3()
local PROPRIETE_ROT = "euler.z"

-- ====================== Méthodes d'animations ======================

-- TODO

-- ====================== Algorithmes placement lettres ======================

local function saut_horizontal(self, noeud_lettre)
	gui.set(noeud_lettre, gui_utils.PROP_POSITION_X,
			self.params.position.x + self.params.espace_horizontal)
end

--
-- Si des sauts de ligne sont survenus, il faut se remettre à la ligne
-- et prendre en compte les décalages.
--
local function saut_horizontal_dec(self, noeud_lettre, diff_pindex)
	
	local lettre_offsetx = gui.get(noeud_lettre, gui_utils.PROP_POSITION_X)
	gui.set(noeud_lettre, gui_utils.PROP_POSITION_X,
			lettre_offsetx + self.params.espace_horizontal * diff_pindex)
end

local function saut_vertical(self, noeud_lettre)
	gui.set(noeud_lettre, gui_utils.PROP_POSITION_Y, 
			self.params.position.y - self.printer.breaks
		  * self.params.espace_vertical)
end

--
-- Algorithmes permettant de placer une lettre conforme
-- à la dimension choisie.
-- Supporte les sauts de ligne automatiques ou manuels (\n)
--

-- TODO saut de ligne basé sur la taille des pixels

-- Pas de saut de ligne automatique.
local function placer_lettre(self, noeud_lettre)

	local printer = self.printer

	local diff_pindex = (printer.pindex - printer.pindex_delta)
	saut_horizontal_dec(self, noeud_lettre, diff_pindex)

	saut_vertical(self, noeud_lettre)
end

-- Saute les lettres et non des mots.
local function placer_lettre_char_wrap(self, noeud_lettre)

	local params = self.params
	local printer = self.printer

	-- Sauvegarde l'offsetx de base après un retour à la ligne.
	local diff_pindex = printer.pindex - printer.pindex_delta

	--
	-- Si l'index est un diviseur du nombre de ligne, alors
	-- cela signifie que la limite de la boîte a été atteinte.
	--
	if diff_pindex % params.longueur_ligne  == 0 then
		saut_horizontal(self, noeud_lettre)
		printer.breaks = printer.breaks + 1
		printer.pindex_delta = printer.pindex
	else
		saut_horizontal_dec(self, noeud_lettre, diff_pindex)
	end

	saut_vertical(self, noeud_lettre)
end

-- Inclut le char_wrap !
-- TODO améliorer le char_wrap sur certains texte.
local function placer_lettre_line_wrap(self, noeud_lettre)

	local params = self.params
	local printer = self.printer

	--
	-- Cette partie traite les mots qui peuvent
	-- faire la taille de plusieurs lignes.
	--
	local prochain_espace = printer.texte_restant:find(ESPACE_STR)
	local mot_longueur = (prochain_espace or printer.texte_restant_len) - 1
	if not self.est_mot_sup then
		self.est_mot_sup = mot_longueur > params.longueur_ligne
	end
		
	if self.est_mot_sup and mot_longueur >= 0 then
		placer_lettre_char_wrap(self, noeud_lettre)
		return
	end

	self.est_mot_sup = false
	
	-- Si le mot dépasse la longueur de la ligne, aller à la ligne suivante.
	local diff_pindex = printer.pindex - printer.pindex_delta
	local ligne_restante = params.longueur_ligne - diff_pindex
	if mot_longueur > ligne_restante then
	
		saut_horizontal(self, noeud_lettre)
		printer.breaks = printer.breaks + 1
		printer.pindex_delta = printer.pindex - 1
	else
		saut_horizontal_dec(self, noeud_lettre, diff_pindex)
	end

	saut_vertical(self, noeud_lettre)
end

local PLACEMENT_ALGO_LETTRE = {
	[hash("no_wrap")] = placer_lettre,
	[hash("char_wrap")] = placer_lettre_char_wrap,
	[hash("line_wrap")] = placer_lettre_line_wrap
}

-- ====================== Méthodes d'affichage ======================

local function appliquer_rtt_gui(self, noeud_lettre, nom_rtt, val_rtt)
	
	if val_rtt then
		gui.set(noeud_lettre, nom_rtt, val_rtt[4])

	--
	-- Sinon, plus de style dans la pile. 
	-- On passe donc au style d'origine.
	--
	else

		local propriete_origine = gui.get(self.printer.noeud_immuable, nom_rtt)
		gui.set(noeud_lettre, nom_rtt, propriete_origine)
	end
end

local function appliquer_rtt_printer(self, noeud_lettre, nom_rtt, val_rtt)

	-- Temporaire
	
	if nom_rtt == "time" then
		timer.cancel(self.printer.ptimer)

		self.printer.ptimer = timer.delay(val_rtt, false,
					function()
						self.printer.ptimer 
						= timer.delay(self.params.vitesse_print, true,
									  self.printer.ptimer_callback_info)	
						
					end)
	elseif nom_rtt == "br" then
		self.printer.breaks = self.printer.breaks + 1
		self.printer.pindex_delta = self.printer.pindex - 1
	end
end

-- TODO gui_text
local TYPE_PROPRIETE_COMPORTEMENT = {
	[hash("gui")] = appliquer_rtt_gui,
	[hash("printer")] = appliquer_rtt_printer
}

-- Applique le style établit par la pile rtt.
local function appliquer_pile_rtt(self, noeud_lettre)
	
	for i, v in pairs(self.printer.pile_rtt) do

		local dernier_rtt = v[#v]

		-- FIXME trouver une méthode plus propre ?
		-- Contournement à l'index de valeur nil.
		local type_propriete = self.parser_rtt.RTT_LOOKUP[i][2]
		TYPE_PROPRIETE_COMPORTEMENT[type_propriete](self, noeud_lettre,
													i, dernier_rtt)
	end
end

local function calculer_texte_restant(self)

	local p = self.printer
	
	local index_debut_rtt_norme = p.index_debut_rtt - 1
	if p.pindex <= index_debut_rtt_norme then
		p.texte_restant = concat{p.texte:sub(p.pindex, index_debut_rtt_norme),
								 ESPACE_STR, p.texte:sub(p.index_fin_rtt)}
	else
		p.texte_restant = p.texte:sub(p.pindex)
	end

	p.texte_restant_len = #p.texte_restant
end

-- 
-- Lit une table Rich Text en se basant sur pindex,
-- et complète une pile des attributs à appliquer à la lettre.
-- Pour l'instant, seulement les attributs définis par gui.PROP.
--
-- Le format de la table est la suivante :
-- t[x] = {{nom_attribut, type_valeur, type_balise, valeur}, ...}
--
-- La dernière valeur insérée est le style appliqué en priorité.
-- Pour l'annuler, il suffit de faire :
-- t[x + j] = {..., nil}
-- (Pas besoin de le faire si elle est de nature orpheline.)
--
-- Cela annulera SEULEMENT la dernière valeur dans la pile.
--
-- Exemple concret :
-- x = {
-- 	[1] = {{gui.PROP_COLOR, "gui", false, true, vmath.vector3(0, 1, 0)}},
-- 	[4] = {{gui.PROP_COLOR, "gui", false, true, vmath.vector3(1, 1, 0)}},
-- 	[12] = {{gui.PROP_COLOR, "gui", false, true, nil}}
-- }
--
local function lire_rtt(self)
	
	local p = self.printer
	
	local rtt, index_debut = self.parser_rtt:chercher_prochaine_balise()
	if rtt then

		self.printer.index_debut_rtt = index_debut
		self.printer.index_fin_rtt = self.parser_rtt:get_curseur()
		
		-- Mise à jour de l'ensemble des rtt
		local r = p.rtt_progressif

		-- Balises se lançant AVANT la prochaine lettre.
		if rtt[4] and index_debut ~= 1 then
			index_debut = index_debut - 1
		end
		
		r[index_debut] = r[index_debut] or {}
		r[index_debut][#r[index_debut] + 1] = rtt
	end
end

-- 
-- Construit peu à peu le style, surtout si les styles (les balises)
-- se chevauchent. Ex: </color></color>Garden Lies</color>
-- Les balises sont ensuite tronquées pour ne pas gêner pindex.
-- 
-- Il est attendu que p.pindex rencontre la prochaine balise.
--
local function lecture_chaine_rtt(self, comparer_pindex)

	local p = self.printer
	while not self.parser_rtt:est_fin_de_fichier() 
		and p.index_debut_rtt == p.pindex do
		lire_rtt(self)
		p.texte = concat{p.texte:sub(1, p.index_debut_rtt - 1),
						 p.texte:sub(p.index_fin_rtt, #p.texte)}
		self.parser_rtt:set_texte(p.texte)
	end
end

local function est_affichage_termine(self)
	return self.printer.texte_restant_len == 0
end

-- 
-- Structure de la pile :
-- [nom_du_style] = {{type_style, type_balise, valeur}, {...}, ...}
--
-- Le premier attribut du rtt est donc enlevée et est mis 
-- en tant que nouvelle clé de la pile.
--
local function update_pile_rtt(self, noeud_lettre)

	local p = self.printer
	
	local rtt_styles = p.rtt_progressif[p.pindex]
	if not rtt_styles then  
		return -- Pas de style prévu à l'index pindex
	end
		
	for _, v in pairs(rtt_styles) do

		-- Les balises orphelines doivent être exécutées tout de suite.
		if v[3] then 
			TYPE_PROPRIETE_COMPORTEMENT[v[2]](self, noeud_lettre,
											  v[1], v[5])
		else

			-- Clé = nom attribut
			p.pile_rtt[v[1]] = p.pile_rtt[v[1]] or {}
			
			local style_loc = p.pile_rtt[v[1]]
			local style_loc_len = #style_loc
			if v[5] then
				style_loc[style_loc_len + 1] = {unpack(v, 2)}
			else

				-- Annulation du style le plus récent.
				style_loc[style_loc_len] = nil
			end
		end
	end
end

--
-- Permet d'afficher une lettre sur l'écran.
--
-- Afin d'afficher toutes les lettres, il faut
-- itérer dans cette fonction à l'aide d'une boucle
-- ou à l'aide d'un timer.
--
local function afficher_lettre(self)

	local p = self.printer	
	local noeud_lettre = self.noeuds[p.pindex]

	lecture_chaine_rtt(self, true)
	calculer_texte_restant(self)
	
	-- Application du style aux lettres.
	update_pile_rtt(self, noeud_lettre)
	appliquer_pile_rtt(self, noeud_lettre)
	
	-- Placement de la lettre
	p.lettre_analyse = p.texte:sub(p.pindex, p.pindex)
	gui.set_text(noeud_lettre, p.lettre_analyse)
	self.params.algorithme_char(self, noeud_lettre)

	-- La lettre devient visible à l'écran.
	-- TODO à changer
	gui.set_enabled(noeud_lettre, true)
	gui.set_alpha(noeud_lettre, 1)

	p.pindex = p.pindex + 1
	if est_affichage_termine(self) then
		self.flush_requis = true
		timer.cancel(p.ptimer)
	end
end

-- ====================== Méthodes setup ======================

local function init_noeuds(self)

	local p = self.params
	
	-- Setup du noeud racine
	self.noeud_racine = gui_utils.new_box_node_stretch(p.position, IDENTITE)
	
	local n_racine = self.noeud_racine
	gui.set_scale(n_racine, p.echelle)
	gui.set(n_racine, PROPRIETE_ROT, p.rotation)
	gui.set_alpha(n_racine, 0)
	gui.set_visible(n_racine, false)

	-- Setup de l'ensemble des noeuds
	for i = 1, self.params.max_lettres do

		self.noeuds[i] = createur_texte.creer_noeud_texte(p.position, "")

		local n = self.noeuds[i]
		gui.set_color(n, p.couleur)
		gui.set_enabled(n, false)
		gui.set_parent(n, self.noeud_racine)
	end

	self.printer.noeud_immuable = gui.clone(self.noeuds[1])
end

-- Ajuste les paramètres du printer.
local function setup_params(self, args)

	local p = self.params
	p.espace_horizontal = args.espace_horizontal 
					   or p.espace_horizontal or ESPACE_X
	p.espace_vertical = args.espace_vertical 
					 or args.espace_vertical or ESPACE_Y
	p.longueur_ligne = args.longueur_LIGNE 
					or p.longueur_ligne or LONGUEUR_LIGNE
	p.vitesse_print = args.vitesse_print 
				   or p.vitesse_print or VITESSE_PRINT
	p.algorithme_char = PLACEMENT_ALGO_LETTRE[args.algorithme_char] 
					 or p.algorithme_char or PLACEMENT_ALGO_LETTRE[WRAP]

	-- Optimisation lors de la relecture d'un texte.
	if p.texte ~= args.texte then
		self.printer.rtt_progressif = {}
		self.printer.texte = nil
	end
	p.texte = args.texte or p.texte or TEXTE

	-- TODO animation apparition, disparition, idle...
end

-- ====================== Méthodes publiques ======================

-- Créer MAX_LETTRES + 2 noeuds à la construction.
function M.new(...)

	local self = setmetatable({}, M)
	
	self.noeuds = {}  -- Text_nodes
	self.parser_rtt = parser.new() -- Parser pour le rtt

	self.printer = { -- Paramètres des noeuds et du printer.
		ptimer_callback_info = function() afficher_lettre(self) end	
	} 

	local args = ... or {}
	self.params = { -- Informations du printer en cours.

		-- Propriétés non modifiables
		max_lettres = args.max_lettres or MAX_LETTRES,
		couleur = args.couleur or COULEUR,

		-- 
		-- Pour modifier ces propriétés,
		-- il faut récupérer le noeud racine.
		--
		echelle = args.echelle or ECHELLE,
		position = args.position  or POSITION,
		rotation = args.rotation or ROTATION
	}

	setup_params(self, args)
	init_noeuds(self)

	self.flush_requis = false

	return self
end

--
-- FIXME fps spike sur Vulkan
-- Arrête le printer s'il est en cours de fonctionnement.
-- Le reste du texte peut-être affiché, ou pas.
--
function M:arreter_printer(terminer_texte)

	local p = self.printer
	timer.cancel(p.ptimer)
	if not terminer_texte then
		return
	end
	
	-- Affiche le texte dans son entiereté si possible.
	repeat
		afficher_lettre(self)
	until est_affichage_termine(self)
end

--
-- Affiche les lettres une à une sur l'écrans
-- d'après les paramètres.
--
function M:commencer_printer()

	local p = self.printer

	if M.est_en_marche(self) or self.flush_requis then
		M.flush(self)
	end

	-- Copie du texte avec le rtt.
	p.texte = p.texte or ESPACE_STR .. self.params.texte

	p.breaks = 0 -- Nbr de lignes sautées
	p.pindex = 1 -- Index du curseur
	p.pindex_delta = 1 -- Position depuis la dernière ligne sautée.
	
	p.index_debut_rtt = 1 -- Debut de la prochaine balise
	p.index_fin_rtt = 1 -- Fin de la prochaine balise
	p.pile_rtt = {} -- Pile analytique pour le style

	-- Ensemble des rtt du texte à remplir.
	p.rtt_progressif = p.rtt_progressif or {}

	self.parser_rtt:set_texte(p.texte)

	p.ptimer = timer.delay(self.params.vitesse_print, true,
						   p.ptimer_callback_info)

end

-- Efface le printer et les noeuds associés.
function M:delete()
	
	M:arreter_printer()
	
	-- Effacement des noeuds
	gui.delete_node(self.noeud_racine)
	table_utils.clear(self.noeuds)

	-- Effacement du printer
	local p = self.printer
	if p.rtt_progressif then
		for _, v in pairs(p.rtt_progressif) do
			table_utilsclear(v)
		end
	end
	if p.pile_rtt then table_utils.clear(p.pile_rtt) end
	gui.delete_node(p.noeud_immuable)
	table_utils.clear(p)
	
	table_utils.clear(self.params)
	self.parser_rtt:delete()
	table_utils.clear(self)
end

function M:est_en_marche()
	if not self.printer.ptimer then return false end
	return timer.get_info(self.printer.ptimer) ~= nil
end

function M:get_noeud_racine()
	return self.noeud_racine
end

function M:get_params()
	return table_utils.shallow_copy(self.params)
end

--
-- Fait disparaître les lettres affichées sur l'écran.
-- Est automatiquement appelé si l'utilisateur
-- ordonne d'afficher un texte.
function M:flush()

	timer.cancel(self.printer.ptimer)
	
	local i = 1
	while i < self.params.max_lettres and gui.is_enabled(self.noeuds[i]) do
		gui.delete_node(self.noeuds[i])
		self.noeuds[i] = gui.clone(self.printer.noeud_immuable)
		i = i + 1
	end

	self.flush_requis = false
end

function M:set_params(...)
	setup_params(self, ... or self.params)
end

return M