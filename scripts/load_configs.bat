
if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd ./upload_to_gsheets
node index_download_configs.js

xcopy /Y .\configs\configs_ru.json ..\..\haxe\projects\shared\data\configs_ru.json
xcopy /Y .\configs\configs_en.json ..\..\haxe\projects\shared\data\configs_en.json
pause