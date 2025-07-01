--
-- ressources_pool.lua
-- Garden Lies, 													   04/11/24
--

--
-- Singleton pouvant charger, décharger et stocker en mémoire
-- des données (buffers) de custom resources et de bundles.
--
-- Le module est initialisé avec global.lua
--
local M = {}

local conv_buffer = require "src.modules.fichier.convertisseur_buffer"
local table_utils = require "src.modules.utils.table"

local format = string.format

local async_load = sys.load_buffer_async
local load = sys.load_buffer

local AVERTISSEMENT_FICHIER_NON_CHARGE
= "Le fichier au chemin '%s' n'a pas pu être chargé ! (err: %s)"

local AVERTISSEMENT_FICHIER_NON_CHARGE_ASYNC
= "Le fichier au chemin '%s' n'a pas pu être chargé en parallèle ! (err: %s)"

M.RESSOURCE_CHARGE_CORRECTEMENT = sys.REQUEST_STATUS_FINISHED
M.RESSOURCE_ERREUR_ES = sys.REQUEST_STATUS_ERROR_IO_ERROR
M.RESSOURCE_NON_TROUVEE = sys.REQUEST_STATUS_ERROR_NOT_FOUND

M.BUFFER_TYPE_JSON = "json"
M.BUFFER_TYPE_STRING = "string"

-- ======================== Méthodes privées ========================

--
-- Charge un fichier au chemin sélectionné.
--
local function charger_ressource(chemin_fichier)
	return load(chemin_fichier)
end

--
-- Convertit un buffer en string ou en table json.
-- Si le nom du type n'est pas trouvé, alors il restera un buffer.
--
local function convertir_buffer(buffer, nouveau_type)

	if nouveau_type == M.BUFFER_TYPE_JSON then
		return conv_buffer.buffer_to_json(buffer)
	elseif nouveau_type == M.BUFFER_TYPE_STRING then
		return conv_buffer.buffer_to_string(buffer)
	end

	return buffer
end

-- ======================= Méthodes publiques =======================

function M:new()

	self.pool = {} -- Pool principal

	-- Pool reservé aux ressources chargées en asynchrone.
	self.res_async = {}
	
	return self
end 

-- Chargement des ressources *********************

--
-- Charge en asynchrone une ressource et donne pendant ce temps
-- une référence vers une table contenant :
-- 	* status, le status actuel de la ressource
--  * buffer, la ressource chargée ou en cours de chargement
--
-- Comme charger_ressource(), le buffer peut être converti en 
-- chaîne de caractères ou en table JSON selon type_conversion,
-- sinon il restera en buffer.
--
-- - Le status est égal à -1 s'il est en cours de chargement,
--   sinon il est égal à un des REQUEST de sys.
-- - Le buffer est égal à nil s'il n'est pas encore chargé,
--   sinon il est égal à nil / "" / {} si un problème a eu lieu
--   (après un changement de statut).
--
-- Le buffer de la table renvoyé est une référence du buffer
-- du pool principal. Il peut donc être libéré sans problème
-- avec liberer_pool() ou liberer_ressource()
--
-- Une fois que la ressource est chargée,
-- le handler est actionné (s'il existe) 
-- et passe en argument le buffer final.
--
function M:charger_ressource_async(chemin_fichier, type_conversion,
								   handler)

	-- La ressource a été déjà chargée.
	handler = handler or function() end
	if self.pool[chemin_fichier] then
		handler(self.pool[chemin_fichier])
		return self.pool[chemin_fichier]
	end

	-- Weak table, le buffer deviendra nil quand la ressource se libérera.
	self.res_async[chemin_fichier] = setmetatable({status = -1},
												  {__mode = "v"})
	
	async_load(chemin_fichier,

		function(op, request_id, result)

			-- Erreur lors du chargement de la ressource.
			if result.status ~= sys.REQUEST_STATUS_FINISHED then
				print(format(AVERTISSEMENT_FICHIER_NON_CHARGE_ASYNC, 
							 chemin_fichier, result.status))
			end

			local buffer_final = convertir_buffer(result.buffer,
												  type_conversion)
			
			-- On place le buffer dans le pool principal.
			self.pool[chemin_fichier] = buffer_final

			--
			-- Dans le cas d'un string,
			-- ce n'est pas que la référence qui est copié !
			--
			self.res_async[chemin_fichier].buffer 
			= self.pool[chemin_fichier]
			
			self.res_async[chemin_fichier].status = result.status

			handler(buffer_final)
		end)

		-- Référence vers le pool principal en attendant le chargement.
		return self.res_async[chemin_fichier]
end

--
-- Charge une ressource en synchrone et renvoi 
-- une référence de son buffer, une chaîne de caractères binaire,
-- ou une table JSON selon type_conversion
--
-- Le buffer sera de plus disponible dans le pool.
--
-- Renvoi nil si la ressource ne peut être lu, "" pour un string,
-- ou une table vide pour le json.
--
-- Une fois que la ressource est chargée,
-- le handler est actionné (s'il existe) 
-- et passe en argument le buffer.
--
function M:charger_ressource(chemin_fichier, type_conversion, handler)

	-- La ressource a été déjà chargée.
	handler = handler or function() end
	if self.pool[chemin_fichier] then
		handler(self.pool[chemin_fichier])
		return self.pool[chemin_fichier]
	end

	-- Peut provoquer une exception si le fichier n'a pas été trouvé.
	local est_fichier_lu, buffer
	= pcall(charger_ressource, chemin_fichier)

	if not est_fichier_lu then
		print(format(AVERTISSEMENT_FICHIER_NON_CHARGE,
					 chemin_fichier, buffer))
		buffer = nil
	end

	buffer = convertir_buffer(buffer, type_conversion)
	self.pool[chemin_fichier] = buffer

	handler(buffer)
	return buffer
end

-- Utilitaires *****************************

--
-- Compte le nombre de ressources dans le pool.
--
function M:get_nombre_ressources()

	-- On n'utilisera pas "#" en raison des limites de Lua.
	
	local i = 0
	for _, _ in pairs(self.pool) do
		i = i + 1
	end

	return i
end

--
-- Retourne une référence d'un buffer déjà chargé 
-- ou nil s'il ne l'est pas.
--
function M:get_ressource(chemin_fichier)
	return self.pool[chemin_fichier]
end

-- Nettoyage des ressources ***********************

--
-- Libère la ressource sélectionnée dans le pool.
--
function M:liberer_ressource(chemin_fichier)
	self.pool[chemin_fichier] = nil
end

--
-- Libère toutes les ressources
--
function M:liberer_pool()
	table_utils.clear(self.pool)
end

--
-- Vide la table des ressources asynchrones en éliminant la référence
-- les ressources qui ont été déjà libérés.
--
-- Il est bien d'appeler cette méthode 
-- si de nombreux chargements ont été fait
-- avec derrière de la mémoire libérée.
--
function M:nettoyer_ressources_async()

	collectgarbage() -- Force les tables faibles à se libérer.
	for i, v in pairs(self.res_async) do

		-- TODO surveiller les leaks
		if not v.buffer or v.buffer == "" or #v.buffer == 0 then
			table_utils.clear(self.res_async[i])
		end
	end
end
	
return M