--
-- global.lua
-- Garden Lies, 													   11/07/24
--

--
-- Informations globales à l'environnement.
--
-- Il est vivement déconseillé de modifier 
-- les variables manuellement !
--  
local M = {}

-- TODO initialiser les valeurs globales via bootstrap

local etat = require "src.modules.information.etat"
local pool = require "src.modules.fichier.ressources_pool"

--
-- Voir /modules/information/etat.lua
-- Stocke l'état actuel du jeu.
--
M.etat = etat:new()

-- Création des états principaux.
M.etat:set_etat("bande_son", false)
M.etat:set_etat("chargement", false)
M.etat:set_etat("en_jeu", false)
M.etat:set_etat("menu_principal", false)
M.etat:set_etat("splashscreen", false)
M.etat:set_etat("cinematique", false)
M.etat:set_etat("dialogue", false)
M.etat:set_etat("inventaire", false)
M.etat:set_etat("reve", false)
M.etat:set_etat("cauchemar", false)
M.etat:set_etat("bonheur", false)

M.pool = pool:new()

M.url_menu_chargement = hash("")

-- TODO paramètres du jeu
M.parametres = {}
M.parametres.bgm_intensite = 1.0
M.parametres.sfx_intensite = 1.0

return M