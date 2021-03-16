-- Handles rendering the menu and button presses and so on
function menuActive()

  if suit.Button("Start Game", 1280/2 - 250,750/2-50, 500,50).hit then
    gamestate = "running"
  end
  if suit.Button("Quit", 1280/2 - 250,750/2+60, 500,50).hit then
    love.event.quit()
  end

  -- Ability to choose weapons for P1 and P2
  if suit.Button(P1.name .. ": " .. P1.weapon.name, 1280/2 - 250, 750/2 + 5, 247.5, 50).hit then
    P1:setWeapon(weapons[P1.weaponCounter])
    if P1.weaponCounter < #weapons then
      P1.weaponCounter = P1.weaponCounter + 1
    else
      P1.weaponCounter = 1
    end
  end

  if suit.Button(P2.name .. ": " .. P2.weapon.name, 1280/2 + 2.5, 750/2+5, 247.25, 50).hit then
    P2:setWeapon(weapons[P2.weaponCounter])
    if P2.weaponCounter < #weapons then
      P2.weaponCounter = P2.weaponCounter + 1
    else
      P2.weaponCounter = 1
    end
  end

  -- The mute / unmute button
  if suit.Button("Audio: " .. getVolume(), 1160, 650, 100, 50).hit then
    if volume == 100 then
      volume = 0
      love.audio.setVolume(0)
    else
      volume = 100
      love.audio.setVolume(1)
    end
  end
  -- Playing till how many deaths button
  if suit.Button("Deaths: " .. deaths, 65, 650, 100, 50).hit then
    deaths = 5
  end
  if suit.Button("-", 20, 650, 40, 50).hit then
    if deaths > 1 then
      deaths = deaths - 1
    end
  end
  if suit.Button("+", 170, 650, 40, 50).hit then
    if deaths < 10 then
      deaths = deaths + 1
    end
  end
end


-- Helper function to get global audio volume
function getVolume()
  if volume == 0 then return "OFF"
    else return "ON"
  end
end