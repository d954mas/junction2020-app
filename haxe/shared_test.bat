cd ./projects
haxe ./hxml/shared_test.hxml
if errorlevel 1 (
    echo Error In Test
	pause
	exit 1
) else (
	echo Test OK
	cd ../
)