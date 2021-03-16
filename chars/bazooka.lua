Bazooka = Object:extend()


function Bazooka:new(px, py, pw, ph)
  self.px, self.py = px, py
  self.pw, self.ph = pw, ph
  self.w, self.h = 64, 64
  self.damage = 50
  self.name = "Bazooka"

  self.image = love.graphics.newImage("images/weapons/bazooka.png")
  self.box = world:newRectangleCollider(self.px, self.py, self.w, self.h)
  self.box:setCollisionClass("Weapon")
  self.box:setFixedRotation(true)

  self.direction = "idle"
  -- A table containing bullets that a player has shot
  self.bullets = {}
  self.bulletSpeed = 800
  self.bulletSpeedVertical = 500
  self.bulletTime = 2 -- Time between bullets in seconds
  self.timeLastBullet = love.timer.getTime()
  self.bulletImage = love.graphics.newImage("images/weapons/bullet.png")

  flameParticle = love.graphics.newImage("images/weapons/flame.png")
  self.psystem = love.graphics.newParticleSystem(flameParticle, 32)
	self.psystem:setParticleLifetime(2, 3) -- Particles live at least 2s and at most 5s.
	self.psystem:setEmissionRate(10)
	self.psystem:setSizeVariation(1)
	self.psystem:setLinearAcceleration(-10, -10, 10, 10) -- Random movement in all directions.
	self.psystem:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency.

  self.bulletExplosionTime = 0
  self.bulletExplosionX = 0
  self.bulletExplosionY = 0
end

-- Updates the weapon and takes a player hitbox as input
function Bazooka:update(pbox, pdirection, keyShoot, dt)
  self.psystem:update(dt)
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
    local bx, by = self.bullets[i-bulletDeleted]:getPosition()
    self.bulletExplosionTime = love.timer.getTime()
    self.bulletExplosionX = bx
    self.bulletExplosionY = by

    if self.bullets[i-bulletDeleted]:enter("Player") then
      self.bullets[i-bulletDeleted]:destroy()
      table.remove(self.bullets, i-bulletDeleted)
      bulletDeleted = bulletDeleted + 1

    elseif self.bullets[i-bulletDeleted]:enter("Ground")
    or self.bullets[i-bulletDeleted]:enter("Ground") then
      self.bullets[i-bulletDeleted]:destroy()
      table.remove(self.bullets, i-bulletDeleted)
    end
  end
end

function Bazooka:drawExplosion()
  love.graphics.draw(self.psystem, self.bulletExplosionX, self.bulletExplosionY)
end

function Bazooka:draw()
  local x, y = self.box:getPosition()
  if self.direction == "left" then
    love.graphics.draw(self.image, x + (self.w/2) + 20, y - (self.h/2) - 20, 0, -1, 1)
  elseif self.direction == "right" then
    love.graphics.draw(self.image, x - (self.w/2) - 20, y - (self.h/2) - 20, 0, 1, 1)
  else
    love.graphics.draw(self.image, x, y - (self.h/2), 45)
  end

  for i = 1, #self.bullets do
    local bx, by = self.bullets[i]:getPosition()
    love.graphics.draw(self.bulletImage, bx, by)
  end

  -- love.graphics.draw(self.psystem, self.box:getX(), self.box:getY())
  if self.bulletExplosionTime - love.timer.getTime() < 2 
  and #self.bullets > 0 then
    self:drawExplosion()
  end
end


function Bazooka:shoot(key)
  local timeNow = love.timer.getTime()

  if love.keyboard.isDown(key) and
  timeNow - self.timeLastBullet > self.bulletTime then
    local x, y = self.box:getPosition()
    local bullet = world:newCircleCollider(x, y, 5)
    bullet:setCollisionClass("Bullet")
    bullet:setType("dynamic")
    bullet:setMass(1)
    -- Shoot in the right direction
    if self.direction == "left" then
      bullet:setPosition(x - 5, y - 20)
      bullet:applyLinearImpulse(-self.bulletSpeed, -self.bulletSpeedVertical)
    elseif self.direction == "right" then
      bullet:setPosition(x + 5, y - 20)
      bullet:applyLinearImpulse(self.bulletSpeed, -self.bulletSpeedVertical)
    end

    table.insert(self.bullets, bullet)
    self.timeLastBullet = timeNow
  end
end


-- Returns the reload time from 0..1
function Bazooka:getReload()
  local timeSinceShot = love.timer.getTime() - self.timeLastBullet
  if timeSinceShot > self.bulletTime then
    return 1
  else
    return timeSinceShot/self.bulletTime
  end
end