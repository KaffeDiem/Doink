Rifle = Object:extend()


function Rifle:new(px, py, pw, ph)
  self.px, self.py = px, py
  self.pw, self.ph = pw, ph
  self.w, self.h = 64, 64
  self.reload = 100
  self.damage = 15
  self.name = "Rifle"

  self.image = love.graphics.newImage("images/weapons/rifle.png")
  self.box = world:newRectangleCollider(self.px, self.py, self.w, self.h)
  self.box:setCollisionClass("Weapon")
  self.box:setFixedRotation(true)

  self.direction = "idle"
  -- A table containing bullets that a player has shot
  self.bullets = {}
  self.bulletSpeed = 1000
  self.bulletTime = 0.8 -- Time between bullets in seconds
  self.timeLastBullet = love.timer.getTime()
  self.bulletImage = love.graphics.newImage("images/weapons/bullet.png")
end

-- Updates the weapon and takes a player hitbox as input
function Rifle:update(pbox, pdirection, keyShoot, dt)
  self.direction = pdirection
  -- Set the position of the weapon relative to the player
  self.px, self.py = pbox:getPosition()
  if self.direction == "left" then
    self.box:setPosition(self.px - self.pw, self.py)
  elseif self.direction == "right" then
    self.box:setPosition(self.px + self.pw, self.py)
  else
    self.box:setPosition(self.px, self.py)
  end

  self:shoot(keyShoot)
  -- Remove bullets if they hit a player
  local bulletDeleted = 0
  for i = 1, #self.bullets do
    if self.bullets[i-bulletDeleted]:enter("Player") then

      local bx, by = self.bullets[i-bulletDeleted]:getPosition()

      self.bullets[i-bulletDeleted]:destroy()
      table.remove(self.bullets, i-bulletDeleted)
      bulletDeleted = bulletDeleted + 1

    elseif self.bullets[i-bulletDeleted]:enter("Platform") then

      print("Platform hit") -- TODO: Make this work
      self.bullets[i-bulletDeleted]:destroy()
      table.remove(self.bullets, i-bulletDeleted)
    end
  end
end


function Rifle:draw()
  local x, y = self.box:getPosition()
  if self.direction == "left" then
    love.graphics.draw(self.image, x + (self.w/2), y - (self.h/2), 0, -1, 1)
  elseif self.direction == "right" then
    love.graphics.draw(self.image, x - (self.w/2), y - (self.h/2), 0, 1, 1)
  else
    love.graphics.draw(self.image, x, y - (self.h/2), 45)
  end

  for i = 1, #self.bullets do
    local bx, by = self.bullets[i]:getPosition()
    love.graphics.draw(self.bulletImage, bx, by)
  end
end


function Rifle:shoot(key)
  local timeNow = love.timer.getTime()

  if love.keyboard.isDown(key) and
  timeNow - self.timeLastBullet > self.bulletTime then
    local x, y = self.box:getPosition()
    local bullet = world:newCircleCollider(x, y, 5)
    bullet:setCollisionClass("Bullet")
    bullet:setType("kinematic")
    bullet:setMass(0.1)
    -- Shoot in the right direction
    if self.direction == "left" then
      bullet:setPosition(x - 5, y -5)
      bullet:setLinearVelocity(-self.bulletSpeed, 0)
    elseif self.direction == "right" then
      bullet:setPosition(x + 5, y - 5)
      bullet:setLinearVelocity(self.bulletSpeed, 0)
    end

    table.insert(self.bullets, bullet)
    self.timeLastBullet = timeNow
  end
end

-- Returns the reload time from 0..1
function Rifle:getReload()
  local timeSinceShot = love.timer.getTime() - self.timeLastBullet

  if timeSinceShot > self.bulletTime then
    return 1
  else
    return timeSinceShot/self.bulletTime
  end

end