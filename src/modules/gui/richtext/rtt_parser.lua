--
-- rtt_parser.lua
-- Garden Lies, 													   19/08/24
--

--
-- Lit les balises d'un texte pour le printer afin d'en récupérer
-- le style Rich Text Table.
--
local M = {}
M.__index = M

local clear = require "src.modules.utils.table".clear

local find = string.find

--
-- Le slash ainsi que les valeurs sont optionnelles pour
-- laisser place à la balise de closure (</b>)
--
-- Exemple de balises valides : 
-- 	<clr;1.0,1.0,1.0>Garden Lies</clr>
--  <clr ; 1.0, 1.0, 1.0>Garden Lies
-- 	< clr ; 1.0, 1.0, 1.0 >Garden Lies< / clr >
--
-- Paterne sans espaces : "<*(/?)([%w_]+)*;"
-- 					   .. "?*([%d%.]*),?*([%d%.]*),s*([%d%.]*)*>"
--
-- TODO réduire le regex
--
local PATERNE_BALISE = "<%s*(/?)([%w_]+)%s*;"
					.. "?%s*([%d%.]*),?%s*([%d%.]*),?%s*([%d%.]*)%s*>"

local STRING_VIDE = ""

local TYPES_PROPRIETES = {
	GUI = hash("gui"),
	PRINTER = hash("printer")
}

-- Fonctions afin de rediriger les valeurs requises.

local function red_valeur_sint(val)
	return tonumber(val)
end

local function red_valeur_vect(...)
	local args = {...}
	return vmath.vector3(tonumber(args[1]), tonumber(args[2]),
						 tonumber(args[3]))
end

--
-- Table donnant la signification de la propriété d'une balise :
-- * La clé n'est pas le nom de la vraie propriété, [1] l'est.
-- * [2] informe du type de propriété.
-- * [3] dit si la balise est orpheline ou non.
-- * [4] informe si le style doit se déclencher AVANT la prochaine lettre.
-- * [5] représente la valeur de la propriété. Si elle est nulle (nil),
-- 		 alors il s'agit d'une balise de fermeture.
--
M.RTT_LOOKUP = {
	
	["color"] = {gui.PROP_COLOR, TYPES_PROPRIETES.GUI,
				false, false, red_valeur_vect},

	-- Balises orphelines
	["br"] = {"br", TYPES_PROPRIETES.PRINTER,
			  true, false, red_valeur_sint},
	["time"] = {"time", TYPES_PROPRIETES.PRINTER,
				true, true, red_valeur_sint}
	
}

local function est_eof(self, index_fin)
	return self.curseur_texte > #self.texte_analyse 
		or not index_fin
end

local function valeurs_prochaine_balise(self)	
	return find(self.texte_analyse, PATERNE_BALISE, self.curseur_texte)
end

function M.new(texte, curseur)
	
	local self = setmetatable({}, M)
	
	self:set_texte(texte or STRING_VIDE, curseur or 1) 
	return self
end

-- 
-- Cherche et retourne la valeur de la prochaine balise si présente,
-- puis met à jour le curseur.
--
-- S'il n'y a plus de balise,
-- ou que la fin du string a été rencontré (EOF),
-- alors rien n'est retourné.
--
-- Attention, il n'y a pas de vérification d'erreur !
--
function M:chercher_prochaine_balise()
	
	local index_deb, index_fin, slash, nom, val1, val2, val3
	if not self.valeurs_pcheck then
		index_deb, index_fin, slash, nom, val1, val2, val3 
		= unpack(self.valeurs_panalyse)
		self.valeurs_pcheck = true
	else
		index_deb, index_fin, slash, nom, val1, val2, val3 
		= valeurs_prochaine_balise(self)
	end 

	if est_eof(self, index_fin) then
		self.eof = true
		return
	end
	
	-- Construction des valeurs à retourner.
	local rtt = M.RTT_LOOKUP[nom]
	local rtt_tampon = {unpack(rtt)}

	-- La balise est-elle fermée ou non ?
	local index_valeur = #rtt_tampon
	if slash ~= STRING_VIDE then
		rtt_tampon[index_valeur] = nil
	else
		rtt_tampon[index_valeur] = rtt[index_valeur](val1, val2, val3)
	end
	
	self.curseur_texte = index_fin + 1
	return rtt_tampon, index_deb, index_fin
end

function M:est_fin_de_fichier()
	return self.eof
end

function M:delete()
	clear(self.valeurs_panalyse)
	clear(self)
end

function M:get_curseur()
	return self.curseur_texte
end

function M:set_curseur(i)
	
	self.curseur_texte = i

	-- Analyse la potentielle première balise après le curseur, ou eof.
	self.valeurs_panalyse = {valeurs_prochaine_balise(self)}
	self.valeurs_pcheck = false
	self.eof = est_eof(self, self.valeurs_panalyse[2])
end

function M:set_texte(texte, curseur)
	self.texte_analyse = texte
	M.set_curseur(self, curseur or 1)
end

return M