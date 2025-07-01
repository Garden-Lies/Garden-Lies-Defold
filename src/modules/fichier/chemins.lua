--
-- chemins.lua
-- Garden Lies, 													   06/11/24
--

-- 
-- Interface entre les chemins et fichiers du module constantes_bundle
-- et celui qui demande un chemin complet d'un fichier.
--
-- La vérification de la présence des fichiers n'est pas faite.
--
local M = {}

local fichiers = require "src.modules.fichier.constantes_bundle"

local format = string.format

-- Les listes sont au format json.

local DOSSIER_FICHIERS_DEFAUT = fichiers.dossier_fichiers_defaut 
local DOSSIER_MUSIQUES = fichiers.dossier_bgm
local LISTE_MUSIQUES = fichiers.fichier_liste_bgm

local DOSSIER_ASSETS = fichiers.dossier_localisation_assets
local DOSSIER_TEXTES = fichiers.dossier_localisation_texte
local LISTE_LANGUES = fichiers.fichier_pack_langages

--
-- Format d'un fichier avec localisation.
-- [chemin][code_langue]_[nom_fichier]
--
local FORMAT_FICHIER_LANGUE = "%s%s_%s"

-- ============== Custom resources ==============

function M.get_fichier_defaut(nom_fichier)
	return DOSSIER_FICHIERS_DEFAUT .. nom_fichier
end

function M.get_musique(nom_fichier)
	return DOSSIER_MUSIQUES .. nom_fichier
end

function M.get_liste_musiques()
	return LISTE_MUSIQUES
end

-- ============== Bundles ==============

function M.get_assets(code_langue, nom_fichier)
	return format(FORMAT_FICHIER_LANGUE, DOSSIER_ASSETS,
				  code_langue, nom_fichier)
end

function M.get_texte(code_langue, nom_fichier)
	return format(FORMAT_FICHIER_LANGUE, DOSSIER_TEXTES,
				  code_langue, nom_fichier)
end

function M.get_fichier_config()
	return fichiers.fichier_parametres
end

function M.get_pack_langues()
	return LISTE_LANGUES
end

return M