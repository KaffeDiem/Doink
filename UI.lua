function drawHP(hp1, hp2)

  love.graphics.print(P1.name .. ": ".. hp1 .. "  " .. "Deaths: " .. P1.deaths, 20, 670)
  love.graphics.print(P2.name .. ": ".. hp2 .. "  " .. "Deaths: " .. P2.deaths, 1060, 670)

  -- P1 hp and reload
  love.graphics.rectangle("line", 20, 700, 200, 10)
  love.graphics.rectangle("line", 20, 690, 200, 10)
  -- P2 hp and reload
  love.graphics.rectangle("line", 1060, 700, 200, 10)
  love.graphics.rectangle("line", 1060, 690, 200, 10)


  -- Weapon reload bars
  love.graphics.setColor(0, 1, 1, 0.6)
  love.graphics.rectangle("fill", 20, 690, 200 * P1.weapon:getReload(), 10)
  love.graphics.rectangle("fill", 1060, 690, 200 * P2.weapon:getReload(), 10)

  -- Health bars
  love.graphics.setColor(1, 0, 0, 0.6)
  love.graphics.rectangle("fill", 20, 700, 2 * P1.health, 10)
  love.graphics.rectangle("fill", 1060, 700, 2 * P2.health, 10)

  -- Bars over the players
  local px1, py1 = P1.box:getPosition()
  love.graphics.setColor(1, 1, 1, 0.3)
  love.graphics.rectangle("fill", px1 - 25, py1 - 50, 50, 5)
  love.graphics.setColor(1, 0, 0, 0.6)
  love.graphics.rectangle("fill", px1 - 25, py1 - 50, 0.5 * P1.health, 5)

  local px2, py2 = P2.box:getPosition()
  love.graphics.setColor(1, 1, 1, 0.3)
  love.graphics.rectangle("fill", px2 - 25, py2 - 50, 50, 5)
  love.graphics.setColor(1, 0, 0, 0.6)
  love.graphics.rectangle("fill", px2 - 25, py2 - 50, 0.5 * P2.health, 5)

  -- Reset colors
  love.graphics.setColor(1, 1, 1, 1)

  -- Weapon is ready to get shot
  if P1.weapon:getReload() == 1 then
    love.graphics.setColor(1, 0, 1, 0.2)
    love.graphics.rectangle("fill", 15, 685, 210, 30)
  end
  if P2.weapon:getReload() == 1 then
    love.graphics.setColor(1, 0, 1, 0.2)
    love.graphics.rectangle("fill", 1055, 685, 210, 31)
  end

  -- Reset colors
  love.graphics.setColor(1, 1, 1, 1)
end