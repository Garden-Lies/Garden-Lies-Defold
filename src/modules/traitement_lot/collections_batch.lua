--
-- collections_batch.lua
-- Garden Lies, 													   04/12/24
--

--
-- S'occupe du chargement en lot des collections.
--
local M = {}

local batch = require "src.modules.traitement_lot.batch"
local cfactory_utils = require "src.modules.collections.cfactory_utils"

local clock = os.clock
local format = string.format

local INFO_BATCH_COLLECTION = "Chargement de %s collection(s) : "

--
-- Charge une liste de collection en asynchrone via des factories.
-- Une fois chargé, il suffit de d'appeler collectionfactory.create(url)
-- pour les instancier.
--
-- liste_cfactories :
-- Les collections factories à charger avec la structure suivante :
-- -> url_cfactory (le lien de la collection factory)
-- -> action_cfactory (action exécutée lorsque la factory est prête 
--					   avec en argument l'url de la collection factory.)
--
-- on_chargement : handler global exécuté à chaque fois
-- 				   qu'un fichier est complètement chargé.
--				   L'url de la collection factory est en argument.
--
-- on_completion : handler exécuté à la fin du batch.
--
function M.charger_collections_factory(liste_cfactories, on_chargement,
									   on_completion)

	print()
	local nombre_taches = #liste_cfactories
	print(format(INFO_BATCH_COLLECTION, nombre_taches))

	local temps_depart = clock()

	local compteur_taches = batch.nouveau_compteur(nombre_taches)

	on_chargement = on_chargement or function() end
	on_completion 
	= batch.construire_on_completion(on_completion, liste_cfactories,
									 temps_depart)

	for i, v in pairs(liste_cfactories) do

		batch.afficher_infos_chargement(v.url_cfactory, v, i)
		cfactory_utils.charger(v.url_cfactory,
		function(_, url) 

			on_chargement(url)

			if v.action_cfactory then
				v.action_cfactory(url)
			end
			
			batch.incrementer_par_tache_exec(compteur_taches, on_completion)
		end)
	end
end

return M