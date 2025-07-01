--
-- batch.lua
-- Garden Lies, 													   04/12/24
--

-- 
-- Opérations générales pour préparer des traitement en lot.
--
local M = {}

local compteur = require "src.modules.information.compteur_trames"

local clock = os.clock
local format = string.format

local INFO_BATCH_CHARGEMENT = " -> %s (%s, %s) \\"
local INFO_TEMPS_TOTAL = "Temps de chargement du batch (%s) : %s seconde(s)"

-- 
-- Affiche une ligne d'une ressource en chargement.
--
function M.afficher_infos_chargement(chemin_ressource, table_ligne, num)
	print(format(INFO_BATCH_CHARGEMENT, chemin_ressource, table_ligne, num))
end

--
-- Complète la méthode on_completion d'un batch 
-- en ajoutant son temps d'exécution à la fin.
--
function M.construire_on_completion(on_completion, table_taches,
									temps_depart)

	local on_completion_base = on_completion or function() end
	return function() 
		on_completion_base()
		print(format(INFO_TEMPS_TOTAL, table_taches,
					 clock() - temps_depart)) 
	end
end

--
-- Exécute un handler lorsque la trame max est atteinte.
--
function M.incrementer_par_tache_exec(compteur_taches, handler)

	if compteur_taches:incrementer_trames() then
		handler()
	end
end

--
-- Compteur de tâches n + 1 pour les chargements asynchrones.
--
function M.nouveau_compteur(nombre_taches)

	local compteur_taches = compteur.new(nombre_taches, false)
	compteur_taches:incrementer_trames()

	return compteur_taches
end

return M