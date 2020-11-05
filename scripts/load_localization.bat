
if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd ./upload_to_gsheets
node index_download_localization.js

xcopy /Y .\localization\localization_ru.json ..\..\haxe\projects\shared\data\ru\localization.json
xcopy /Y .\localization\localization_en.json ..\..\haxe\projects\shared\data\eng\localization.json

xcopy /Y .\localization\speech_commands_ru.json ..\..\haxe\projects\shared\data\ru\speech_commands.json
xcopy /Y .\localization\speech_commands_en.json ..\..\haxe\projects\shared\data\eng\speech_commands.json

xcopy /Y .\localization\match_words_ru.json ..\..\haxe\projects\shared\data\ru\match_words_ru.json
xcopy /Y .\localization\match_words_en.json ..\..\haxe\projects\shared\data\eng\match_words_en.json
pause