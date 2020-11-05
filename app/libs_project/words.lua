local COMMON = require "libs.common"
local JSON = require "libs_project.json"
local utf8 = require "richtext.utf8"
local SHARED_HAXE = require "libs_project.shared"

local Words = COMMON.class("Words")

function Words:initialize(locale)
   --local file_name = locale == "ru" and "words_ru.json" or "words_eng.json"
    local file_name = "words_eng.json"
    local file = io.open(file_name, "rb") -- r read mode and b binary mode
    if file then
        local content = file:read("*a") -- *a or *all reads the whole file
        file:close()
        self.words = assert(JSON.decode(content).base_words)
    else
        COMMON.w("can't load debug words")
        self.words = { "text", "text2", "text3" }
    end
    assert(self.words, "words can't be nil")

    file_name = "words_db.json"
    file = io.open(file_name, "rb") -- r read mode and b binary mode
    if file then
        local content = file:read("*a") -- *a or *all reads the whole file
        file:close()
        self.words_db = assert(JSON.decode(content))
    else
        COMMON.w("can't load words_db")
        self.words_db = { "text", "text2", "text3" }
    end
    assert(self.words_db, "words_db can't be nil")
end

function Words:word_exist(word)
	if(self.words_db[word]) then return true else return false end
end

function Words:get_data(base_word)
    assert(base_word)
    base_word = utf8.lower(base_word)
    local base_word_key = SHARED_HAXE.shared.project.utils.WordUtils.wordToCharsKey(base_word)
    local base_word_from_db = self.words[base_word_key]
    assert(base_word_from_db, "no data for word:" .. base_word .. " key:" .. base_word_key)
    return base_word_from_db
end

function Words:exist(base_word, new_word)
    assert(base_word)
    assert(new_word)
    base_word = utf8.lower(base_word)
    new_word = utf8.lower(new_word)
    local base_word_key = SHARED_HAXE.shared.project.utils.WordUtils.wordToCharsKey(base_word)
    local base_word_from_db = self.words[base_word_key]
    assert(base_word_from_db, "no data for word:" .. base_word .. " key:" .. base_word_key)
    return base_word_from_db.words[new_word] and true or false
end

return Words