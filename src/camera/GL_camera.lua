--
-- GL_camera.lua
-- Garden Lies, 													   21/07/24
--
-- Réecriture le 09/08/24 - 11/08/24
--

--
-- Caméra de Garden Lies, reprise de
-- https://github.com/britzl/defold-orthographic
-- https://github.com/whiteboxdev/library-defold-rendy
--
-- Faite pour être rapide et légère.
-- Elle ne fait rien de plus qu'effectuer un rendu en projection
-- zoomée avec un aspect_ratio régulier. La caméra s'occupe également
-- de l'interface graphique et est donc tout le temps active.
--
-- Un système de windowbox offert par Rendy permet de
-- garder un aspect ratio régulier.
--
-- Elle est plus stricte que certaines caméras,
-- surtout dans le fait qu'elle régule l'écran selon,
-- le ratio 16 / 9,
-- mais aussi qu'une seule instance est autorisée.
--
-- Note pour le GUI : toujours le régler en STRETCH !!!
--
local M = {}

local max = math.max

M.PP_ZOOM = hash("zoom")

-- Résolution de base du jeu.
local BASE_RESOLUTION_WIDTH, BASE_RESOLUTION_HEIGHT = 480, 270

-- Résolution upscalée.
local RESOLUTION_WIDTH, RESOLUTION_HEIGHT 
= sys.get_config_int("display.width"), sys.get_config_int("display.height")

-- Centre la caméra
local OFFSET = vmath.vector3(RESOLUTION_WIDTH * .5, RESOLUTION_HEIGHT * .5, 0)

local VECTOR3_MINUS1_Z = vmath.vector3(0, 0, -1.0)
local VECTOR3_UP = vmath.vector3(0, 1.0, 0)

local RATIO = {16, 9}
local RATIO_RWH = RATIO[1] / RATIO[2]
local RATIO_RHW = RATIO[2] / RATIO[1]

-- Sert aux calculs de la vue.
local camera_world_pos = vmath.vector3()
local pos, look_at, up = vmath.vector3(), vmath.vector3(), vmath.vector3()
local rot = vmath.quat()

-- Taille de la fenêtre du jeu.
M.WINDOW_WIDTH, M.WINDOW_HEIGHT = RESOLUTION_WIDTH, RESOLUTION_HEIGHT

local CAMERA_CONF_DEFAUT = {

	view = vmath.matrix4(),
	projection = vmath.matrix4(),
	projection_gui = vmath.matrix4_orthographic(0, M.WINDOW_WIDTH, 0,
												M.WINDOW_HEIGHT, -1, 1),

	--
	-- x, y : set the pixel width and pixel height of the viewport relative
	-- to the initial window size specified in the game.project file.
	--
	viewport = vmath.vector3(M.WINDOW_WIDTH, M.WINDOW_HEIGHT, 0),

	-- Viewport final de la caméra
	viewport_pixel = vmath.vector4(0, 0, 0, 0)
}

-- La SEULE instance de caméra.
M.camera = CAMERA_CONF_DEFAUT

-- Windowbox venant de Rendy
local function appliquer_windowbox()
								
	local rw = RESOLUTION_WIDTH
	local rh = RESOLUTION_HEIGHT
	local ww = M.WINDOW_WIDTH
	local wh = M.WINDOW_HEIGHT

	local ww_ratio = ww / wh
	local wh_ratio = wh / ww
	local rw_ratio = RATIO_RWH
	local rh_ratio = RATIO_RHW

	local viewport_fraction_width = M.camera.viewport.x / rw
	local viewport_fraction_height = M.camera.viewport.y / rh

	--
	-- These bars are only necessary 
	-- if the window width exceeds its target resolution.
	--
	local ww_diff_ratio = ww_ratio - rw_ratio
	local margin_width = ww_diff_ratio > 0 and (ww_diff_ratio)
					   * wh * viewport_fraction_width or 0

	local wh_diff_ratio = wh_ratio - rh_ratio
	local margin_height = wh_diff_ratio > 0 and (wh_diff_ratio) 
						* ww * viewport_fraction_height or 0

	M.camera.viewport_pixel.x = margin_width * 0.5
	M.camera.viewport_pixel.y = margin_height * 0.5
	M.camera.viewport_pixel.z = ww * viewport_fraction_width - margin_width
	M.camera.viewport_pixel.w = wh * viewport_fraction_height - margin_height
end

--
-- Algorithme de projection venant de Orthographic Camera.
--
-- Calcule la projection de la vue.
-- À mettre à jour constamment.
--
local function update_projection()

	--
	-- Attention, du scintillement peut subvenir selon le facteur de zoom donné,
	-- mais aussi la taille de l'écran.
	-- Les valeurs multiples de 1 (.25, .50, .75, 1, 2...) sont conseillées.
	--
	-- Etendre les textures réglerait le problème, mais donnerait un aspect
	-- beaucoup moins propre.
	--
	-- TODO enquêter sur la résolution des écrans.
	--
	local zoom = M.camera.zoom
	local projected_width = BASE_RESOLUTION_WIDTH / zoom
	local projected_height = BASE_RESOLUTION_HEIGHT / zoom
	local x = (-projected_width + RESOLUTION_WIDTH) * .5
	local y = (-projected_height + RESOLUTION_HEIGHT) * .5
	local xoffset = x + projected_width
	local yoffset = y + projected_height
	
	setv.matrix_orthographic(M.camera.projection, x,
							  xoffset, y, yoffset, -1, 1)

end

-- Algorithme de vue venant de Orthographic Camera.
local function update_view()
	
	local id_camera = M.camera.id
	
	setv.get_world_rotation(rot, id_camera)
	setv.rotate(pos, rot, OFFSET)

	setv.get_position(camera_world_pos, id_camera)
	setv.sub(pos, camera_world_pos, pos)

	setv.rotate(look_at, rot, VECTOR3_MINUS1_Z)
	setv.add(look_at, look_at, pos)

	setv.rotate(up, rot, VECTOR3_UP)

	setv.matrix_look_at(M.camera.view, pos, look_at, up)
end

function M.init(camera_id, camera_script_url)
	
	M.camera.id = camera_id
	M.camera.url = camera_script_url
	M.camera.zoom = go.get(camera_script_url, M.PP_ZOOM)

	-- Informe d'un changement de zoom.
	update_projection()
end

function M.final()
	M.camera = CAMERA_CONF_DEFAUT
end

function M.update()

	-- TODO vérifier si la caméra est initialisée.
	local zoom_pred = M.camera.zoom
	M.camera.zoom = go.get(M.camera.url, M.PP_ZOOM)

	--
	-- La projection dépend du zoom 
	-- et n'a donc pas besoin d'être tout le temps mis à jour.
	--
	if zoom_pred ~= M.camera.zoom then
		update_projection()
	end
	
	update_view()
	
end

--
-- Met à jour la taille de la fenêtre ainsi que l'interface graphique.
-- À mettre à jour seulement quand cela est requis.
--
function M.update_window()

	M.WINDOW_WIDTH, M.WINDOW_HEIGHT = window.get_size()
	
	-- 0 pourrait faire NaN.
	M.WINDOW_WIDTH = max(M.WINDOW_WIDTH, 1)
	M.WINDOW_HEIGHT = max(M.WINDOW_HEIGHT, 1)

	-- Opération gourmande
	appliquer_windowbox()

	setv.matrix_orthographic(M.camera.projection_gui, 0, M.WINDOW_WIDTH,
							 0, M.WINDOW_HEIGHT, -1, 1)

end

return M