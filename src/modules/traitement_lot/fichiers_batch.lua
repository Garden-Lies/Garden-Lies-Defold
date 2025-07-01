--
-- fichiers_batch.lua
-- Garden Lies, 													   30/11/24
--

--
-- S'occupe du chargement en lot des fichiers.
--
local M = {}

local batch = require "src.modules.traitement_lot.batch"
local pool = require "src.modules.fichier.ressources_pool"

local clock = os.clock
local format = string.format

local INFO_BATCH_FICHIER = "Chargement de %s fichier(s) : "
local INFO_BATCH_FICHIER_ASYNC = "Chargement de %s fichier(s) en parallèle : "

--
-- Charge les fichiers.
--
-- liste_fichiers : 
-- les fichiers à charger avec la structure suivante :
-- -> chemin_fichier (chemin du fichier)
-- -> type_fichier (type de fichier lors de la lecture, string ou json)
-- -> action_buffer (fonction à exécuter une fois que le buffer est prêt,
--					 le buffer est donné en paramètre par le pool.)
-- 
-- on_completion : handler exécuté à la fin du batch.
--
function M.charger_fichiers(liste_fichiers, on_completion)
	
	print()
	print(format(INFO_BATCH_FICHIER, #liste_fichiers))

	local temps_depart = clock()
	
	on_completion = batch.construire_on_completion(on_completion, liste_fichiers,
												   temps_depart)
	for i, v in pairs(liste_fichiers) do
												
		batch.afficher_infos_chargement(v.chemin_fichier, v, i)
		pool:charger_ressource(v.chemin_fichier, v.type_fichier,
							   v.action_buffer)
	end

	on_completion()
	print()	
end

--
-- Charge les fichiers en parallèle.
--
-- liste_fichiers : même chose que charger_fichiers.
-- 
-- on_chargement : handler global exécuté à chaque fois
-- 				   qu'un fichier est complètement chargé.
--				   Le buffer est donné en argument.
--
-- on_completion : handler exécuté à la fin du batch.
--
function M.charger_fichiers_async(liste_fichiers, on_chargement,
												  on_completion)

	print()
	local nombre_taches = #liste_fichiers
	print(format(INFO_BATCH_FICHIER_ASYNC, nombre_taches))

	local temps_depart = clock()

	local compteur_taches = batch.nouveau_compteur(nombre_taches)
	
	on_chargement = on_chargement or function() end
	on_completion = batch.construire_on_completion(on_completion, liste_fichiers,
												   temps_depart)
	local action_buffer_fichier
	for i, v in pairs(liste_fichiers) do

		batch.afficher_infos_chargement(v.chemin_fichier, v, i)
		
		action_buffer_fichier = v.action_buffer or function(buffer) end
		pool:charger_ressource_async(v.chemin_fichier, v.type_fichier,
		function(buffer) 

			on_chargement(buffer) 
			action_buffer_fichier(buffer) 
			
			batch.incrementer_par_tache_exec(compteur_taches, on_completion)
		end)
	end
end

return M