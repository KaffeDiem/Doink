echo "-- zipping files --"
zip -9 -r doink-temp.love Player.lua UI.lua conf.lua modules images main.lua sounds chars menu.lua settings.lua gamewin.lua fonts
cd love-11.3-win32
echo "-- creating windows.exe --"
cat love.exe ../doink-temp.love > doink.exe
cd .. 
echo "-- creating mac.app --"
cp doink-temp.love doink.app/Contents/Resources/doink_src.love
echo "-- cleaning up --"
rm doink-mac.zip doink-win.zip
echo "-- creating zip files --"
zip -9 -r doink-win.zip love-11.3-win32
zip -9 -r doink-mac.zip doink.app
echo "-- windows and mac os zip files have been created --"
