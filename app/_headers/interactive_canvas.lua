interactive_canvas = {}

--Register native callbacks for interactive_canvas
--use JSToDef to get it in lua
function interactive_canvas.init() end

---@param text string
function interactive_canvas.send_text_query(text) end

function interactive_canvas.exit_continuous_match_mode() end