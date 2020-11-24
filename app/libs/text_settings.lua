local COMMON = require "libs.common"
local RichText = require "richtext.richtext"
local HAXE_WRAPPER = require "libs_project.haxe_wrapper"

local base = {
	fonts = {
		Base = {
			regular = hash("roboto_bold"),
			italic = hash("roboto_bold"),
			bold = hash("roboto_bold"),
			bold_italic = hash("roboto_bold"),
		},
	},
	layers = {
		fonts = {
			[hash("roboto_bold")] = hash("text"),
		}
	},
	align = RichText.ALIGN_CENTER,
	width = 400,
	color = vmath.vector4(0, 0, 0, 1.0),
	color_outline = vmath.vector4(1, 1, 1, 1.0),
	position = vmath.vector3(0, 0, 0)
}

local showcard = {
	fonts = {
		Base = {
			regular = hash("showcard-gothic"),
			italic = hash("showcard-gothic"),
			bold = hash("showcard-gothic"),
			bold_italic = hash("showcard-gothic"),
		},
	},
	align = RichText.ALIGN_CENTER,
	width = 400,
	color = vmath.vector4(1, 1, 1, 1.0),
	color_outline = vmath.vector4(0, 0, 0, 0),
	position = vmath.vector3(0, 0, 0)
}

local tutorial_en = {
	fonts = {
		Base = {
			regular = hash("tutorial-en"),
			italic = hash("tutorial-en"),
			bold = hash("tutorial-en"),
			bold_italic = hash("tutorial-en"),
		},
	},
	align = RichText.ALIGN_CENTER,
	width = 400,
	color = vmath.vector4(1, 1, 1, 1.0),
	color_outline = vmath.vector4(0, 0, 0, 0),
	position = vmath.vector3(0, 0, 0)
}

local base_left = COMMON.LUME.clone_deep(base)
base_left.align = RichText.ALIGN_LEFT

COMMON.read_only(base)
COMMON.read_only(base_left)

local M = {}

function M.make_copy(root, vars)
	local c = COMMON.LUME.clone_deep(root)
	COMMON.LUME.merge_table(c, vars)
	return c
end

function M.get_tutorial_bubble() 
	local locale = HAXE_WRAPPER.shared_get_locale()
	if (locale == "ru") then
		return M.make_copy(M.SHOWCARD, { color = vmath.vector4(0.094, 0.388, 0, 1) })
	else
		return M.make_copy(M.TUTORIAL_EN, { color = vmath.vector4(0.094, 0.388, 0, 1) })
	end
end

M.BASE_CENTER = base
M.SHOWCARD = showcard
M.TUTORIAL_EN = tutorial_en
M.BASE_LEFT = base_left
M.BUTTON_GREEN_BIG = M.make_copy(M.BASE_CENTER, {})

function M.base_center(vars)
	return M.make_copy(M.BASE_CENTER, vars)
end

function M.get_speech_tooltip() 
	return M.make_copy(M.SHOWCARD, {color = vmath.vector4(0.62, 0.54, 0.37, 1.0)})
end

function M.base_left(vars)
	return M.make_copy(M.BASE_LEFT, vars)
end

function M.button_green_big_parent(parent)
	return M.make_copy(M.BASE_CENTER, { parent = parent, position = vmath.vector3(0, 19, 0) })
end

function M.button_green_parent(parent)
	return M.make_copy(M.BASE_CENTER, { parent = parent, position = vmath.vector3(0, 0, 0) })
end

return M