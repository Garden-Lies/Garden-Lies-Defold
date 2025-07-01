--
-- gestionnaire_ressources.lua
-- Garden Lies, 													   26/11/24
--

--
-- Interface entre le module resource de Defold
-- et l'application.
--
local M = {}

local chemins = require "src.modules.fichier.chemins"
local sound_utils = require "src.modules.utils.sound"

local format = string.format

local ERREUR_OBJET_AUDIO_INTROUVABLE 
= "L'instance de l'objet audio avec le chemin %s est introuvable"

local NOM_AUDIO_DEFAUT = "no_sound.wav"

local FICHIER_AUDIO_DEFAUT 
= sys.load_buffer(chemins.get_fichier_defaut(NOM_AUDIO_DEFAUT))

local function executer_handler(handler)
	
	if handler then
		handler()
	end

	return handler ~= nil
end

local function set_ressource_avec_url(url, buffer, handler, fichier_defaut)

	if buffer then
		resource.set(url, buffer)

	-- Sinon, le fichier n'a pas été trouvé.
	elseif not executer_handler(handler) then  
		resource.set(url, fichier_defaut)
	end
end

-- TODO charger une tilesource / atlas et le régler.

-- 
-- Affecte la propriété Sound d'un objet avec le buffer,
-- supposément le chemin d'un fichier json.
--
-- Si le buffer est nil ou invalide,
-- alors le handler par défaut va s'exécuter
-- et affecter un son par défaut.
--
function M.set_ressource_audio(chemin_objet_audio, buffer_audio, handler)
		
	if go.exists(chemin_objet_audio) then
		
		local objet_url = go.get(chemin_objet_audio, sound_utils.PROP_SOUND)
		set_ressource_avec_url(objet_url, buffer_audio,
							   handler, FICHIER_AUDIO_DEFAUT)
	else
		print(format(ERREUR_OBJET_AUDIO_INTROUVABLE, chemin_objet_audio))
	end
end

return M