--
-- msg.lua
-- Garden Lies, 													   22/11/24
--

--
-- Contient des opérations supplémentaores et des
-- constantes utilisées fréquemment.
--
local M = {}

-- Inputs
M.ACQUIRE_INPUT = hash("acquire_input_focus")
M.RELEASE_INPUT = hash("release_input_focus")

-- Activation d'une collection / préchargement
M.INIT = hash("init")
M.UNLOAD = hash("unload")
M.ENABLE = hash("enable")
M.DISABLE = hash("disable")

-- Chargement d'une collection avec proxy.
M.ASYNC_LOAD = hash("async_load")
M.PROXY_LOADED = hash("proxy_loaded")
M.PROXY_UNLOADED = hash("proxy_unloaded")

-- Collisions
M.CONTACT_RESPONSE = hash("contact_point_response")
M.TRIGGER_RESPONSE = hash("trigger_response")
M.COLLISION_RESPONSE = hash("collision_response")

--
-- Converti une url en une signature.
--
function M.url_to_hash(url)
	return hash(url.socket .. url.path .. url.fragment)
end

return M