--
-- cfactory.lua
-- Garden Lies, 													   05/12/24
--

-- 
-- Opérations utilitaires pour les factories.
--
local M = {}

local load = collectionfactory.load

--
-- Charge une collection en asynchrone
-- via une collectionfactory, puis exécute un handler
-- avec la table de l'objet et l'url de la factory.
--
-- D'après l'API, une collectionfactory avec
-- charge non dynamique ne fera rien.
--
-- (https://defold.com/ref/collectionfactory/#collectionfactory.load)
--
function M.charger(url_cfactory, handler)
	handler = handler or function(self, url) end
	load(url_cfactory, handler)
end

return M