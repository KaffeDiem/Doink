function drawGameWin()
  love.graphics.setFont(pixelfontbig)
  love.graphics.setColor(0.5, 1, 0.5, 1)
  if P1.deaths > P2.deaths then
    love.graphics.print(P2.name .. " " .. "wins!", 
    love.graphics.getWidth()/2 - 150, love.graphics.getHeight()/2 - 200)
  else
    love.graphics.print(P1.name .. " " .. "wins!", 
    love.graphics.getWidth()/2 - 150, love.graphics.getHeight()/2 - 200)
  end
  love.graphics.setFont(pixelfont)
  love.graphics.setColor(1, 1, 1, 1)
end