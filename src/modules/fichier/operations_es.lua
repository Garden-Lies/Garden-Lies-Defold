--
-- operations_es.lua
-- Garden Lies, 													   07/11/24
--

-- 
-- Autorise la vérification et la modification de fichiers
-- ainsi que de dossiers.
--
local M = {}

-- TODO écriture d'un fichier en asynchrone.

--
-- Ecrit des données dans un fichier texte.
-- N'est pas adapté pour les très grands fichiers.
--
-- Retourne vrai si l'opération s'est bien passée,
-- sinon false.
--
function M.ecrire_fichier_texte(chemin_fichier, donnees_ecriture)
	
	local fichier, _, _ = io.open(chemin_fichier, "w")
	if not fichier then
		return false
	end

	fichier:write(donnees_ecriture)
	
	fichier:close()
	return true
end 

--
-- Ecrit des données json sous forme d'une table lua,
-- ou d'un string dans un fichier.
--
-- Retourne vrai si l'opération s'est bien passée,
-- sinon false.
--
function M.ecrire_fichier_json(chemin_fichier, donnees_ecriture)
	
	if type(donnees_ecriture) == "table" then
		return M.ecrire_fichier_texte(chemin_fichier,
									  json.encode(donnees_ecriture))
	end

	return M.ecrire_fichier_texte(chemin_fichier, donnees_ecriture)
end

--
-- Indique si un fichier ou un dossier existe.
--
function M.is_fichier_existant(chemin_fichier)
	return sys.exists(chemin_fichier)
end

return M