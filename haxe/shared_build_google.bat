call shared_test.bat
cd ./projects
haxe ./hxml/shared_google.hxml
if errorlevel 1 (
    echo Can't build
	pause
	exit 1
) else (
	echo Build OK
)
lua ./shared/scripts/replace_lua_requare.lua
xcopy /Y .\shared\bin\lua\src\shared.lua ..\..\app\libs_project\shared.lua
xcopy /Y .\shared\bin\java\src\shared\shared.jar ..\..\..\junction-jaicf\libs\shared.jar
pause