--
-- constantes_bundle.lua
-- Garden Lies, 													   03/11/24
--

--
-- Compile une liste de chemins de fichiers ou de dossiers
-- dans des bundles ou des custom ressources d'après la configuration
-- se trouvant dans game.project.
--
-- ELLE N'EST PAS AUTOMATIQUE
-- Si un fichier change d'endroit, il faudra modifier
-- également le chemin ici.
--
-- Le module ne garanti pas non plus la présence des fichiers.
--
local M = {}

local disque = require "src.modules.fichier.operations_es"

M.CHEMIN_RACINE_APPLICATION = sys.get_application_path() .. "/"

M.CHEMIN_BUNDLE = M.CHEMIN_RACINE_APPLICATION

--
-- Si le dossier n'existe pas,
-- il y a une chance qu'il soit lancé depuis l'éditeur.
--
-- game.arcd doit forcément exister quelque part !
--
if not disque.is_fichier_existant(M.CHEMIN_BUNDLE .. "game.arcd") then

	-- D'après la structure de fichiers et game.project
	M.CHEMIN_BUNDLE = "assets/common/"
end

-- ============= Fichiers internes =============

M.dossier_bgm = "/assets/audio/bgm/"
M.dossier_fichiers_defaut = "/assets/ressources_defaut/"

M.fichier_liste_bgm = M.dossier_bgm .. "liste_musiques.json"

-- ============= Fichiers externes =============

M.dossier_localisation_assets = M.CHEMIN_BUNDLE .. "localisation/assets/"
M.dossier_localisation_texte = M.CHEMIN_BUNDLE .. "localisation/texte/"

M.fichier_parametres = M.CHEMIN_BUNDLE .. "config.json"
M.fichier_pack_langages = M.CHEMIN_BUNDLE .. "localisation/langages.json"

-- ================= Méthodes ==================

function M.est_build_editeur()
	return M.CHEMIN_BUNDLE ~= M.CHEMIN_RACINE_APPLICATION
end

return M