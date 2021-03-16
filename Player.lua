Player = Object:extend()

function Player:new(x, y, conf, imgpath)
  self.name = conf.name
  self.x, self.y = x, y
  self.w, self.h = 30, 60

  self.health = 100
  self.deaths = 0
  self.weaponCounter = 1 -- Used in the menu to choose weapon
  -- Keys chosen
  self.keyUp = conf.up
  self.keyLeft = conf.left
  self.keyDown = conf.down
  self.keyRight = conf.right
  self.keyShoot = conf.shoot

  self.jumpHeight = conf.jumpHeight
  self.jumpTimes = conf.jumpTimes

  self.canJumpCount = 0
  self.canJumpTimer = 0

  self.speed = conf.speed
  self.speedMax = conf.speedMax
  self.speedLastFrameX = 1
  self.speedLastFrameY = 1

  self.hitStrength = 0.001
  -- Loading sounds per player
  self.soundIsHit = love.audio.newSource("sounds/doink.mp3", "static")

  self.image = love.graphics.newImage(imgpath)
  self.animationTimer = love.timer.getTime()
  self.animationTimerStart = love.timer.getTime()
  self.quads = {}
  self.animations = 8
  self.frame = 1
  self.direction = "idle"
  -- Load quads into a table
  if self.image:getWidth() > 100 then
    -- the number 3 below is the amount of animations
    for i=0, self.animations-1 do
      i = i * self.image:getWidth() / self.animations
      table.insert(self.quads, love.graphics.newQuad(
        i,
        0,
        self.image:getWidth() / self.animations,
        self.image:getHeight(),
        self.image
      ))
    end
  end
  -- The players collisionbox 
  self.box = world:newRectangleCollider(x, y, self.w, self.h)
  self.box:setCollisionClass("Player")
  self.box:setFixedRotation(true)
  self.box:setMass(60)
  -- Setting one-way movement for platforms
  self.box:setPreSolve(function(collider_1, collider_2, contact)
    if collider_1.collision_class == "Player"
    and collider_2.collision_class == 'Platform' then
      local px, py = collider_1:getPosition()
      local pw, ph = 20, 40
      local tx, ty = collider_2:getPosition()
      local tw, th = 100, 20
      if py + ph/2 > ty - th/2 then contact:setEnabled(false)
      elseif love.keyboard.isDown(self.keyDown) then
        contact:setEnabled(false)
      end
    end
  end)
  -- Loading relevant weapons
  local px, py = self.box:getPosition()
  self.weapon = conf.weapon
  if self.weapon == "rifle" then
    self.weapon = Rifle(px, py, self.w, self.h)
  elseif self.weapon == "bazooka" then
    self.weapon = Bazooka(px, py, self.w, self.h)
  end
end


function Player:update(dt)
  local velX, velY = self.box:getLinearVelocity()
  local px, py = self.box:getPosition()
  -- Drawing animations
  if love.timer.getTime() - self.animationTimer > 0.3 then
    self.frame = self.frame + 1
    if self.frame > self.animations then
      self.frame = 1
    end
    self.animationTimer = love.timer.getTime()
  end
  -- Jump and double jump
  if love.keyboard.isDown(self.keyUp)
  and self.canJumpCount < self.jumpTimes
  and love.timer.getTime() - self.canJumpTimer > 0.4 then
    self.canJumpCount = self.canJumpCount + 1
    if self.canJumpCount == 1 then
      self.box:setLinearVelocity(velX, 0)
      self.box:applyLinearImpulse(0, -self.jumpHeight)
    elseif self.canJumpCount > 1 then
      self.box:setLinearVelocity(velX, 0)
      self.box:applyLinearImpulse(0, -self.jumpHeight/2)
    end
    self.canJumpTimer = love.timer.getTime()
  end
  if self.box:enter("Platform") or self.box:enter("Ground") then
    self.canJumpCount = 0
  end
  -- Movement left to right
  if love.keyboard.isDown(self.keyLeft) then
    self.direction = "left"
    if velX > -self.speedMax then
      self.box:applyForce(-self.speed, 0)
    end
  end
  if love.keyboard.isDown(self.keyRight) then
    self.direction = "right"
    if velX < self.speedMax then
      self.box:applyForce(self.speed, 0)
    end
  end
  -- Player died
  if py > 1000 then
    self.box:setLinearVelocity(0, 0)
    self.box:setPosition(self.x, self.y)
    self.health = 100
    self.deaths = self.deaths + 1
    self.direction = "idle"
  end
  -- Hitstrength when player HP is low.
  if self.health < 20 then self.hitStrength = 6
  elseif self.health < 40 then self.hitStrength = 5
  elseif self.health < 60 then self.hitStrength = 4
  elseif self.health < 80 then self.hitStrength = 3
  elseif self.health < 101 then self.hitStrength = 2
  end
  -- Update the players weapon
  self.weapon:update(self.box, self.direction, self.keyShoot, dt)
end


function Player:draw()
  local x, y = self.box:getPosition() -- Get players position
  -- Draw the weapon behind the player
  self.weapon:draw()
  -- Shadow underneath player
  -- print(self.box:stay("Platform"), self.box:stay("Ground"))
  -- if self.box:stay("Platform") or self.box:stay("Ground") then
  --   love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
  --   love.graphics.ellipse("fill", x, y + 35, 20, 10)
  --   love.graphics.setColor(1, 1, 1, 1)
  -- end

  -- Handling animations
  local currentFrame = self.quads[self.frame]

  if self.direction == "idle" then
    if self.image:getWidth() < 100 then
      love.graphics.draw(self.image, x - 30, y - 55, 0, 0.6, 0.6)
    else
      love.graphics.draw(self.image, currentFrame, x - 30, y - 55, 0, 0.6, 0.6)
    end
  end

  if self.image:getWidth() > 100 then
    if self.direction == "left" then
      love.graphics.draw(self.image, currentFrame, x - 30, y - 55, 0, 0.6, 0.6)
    elseif self.direction == "right" then
      love.graphics.draw(self.image, currentFrame, x + 30, y - 55, 0, -0.6, 0.6)
    end
  end
end


function Player:getHealth()
  return self.health
end


function Player:takeDamage(amount)
  self.health = self.health - amount
  -- Player should not be able to get below 0 hp.
  if self.health < 0 then self.health = 0 end
end


-- Handles collision and bullets
function Player:collisionPlayers(enemy)
  local playerSpeedX, playerSpeedY = self.box:getLinearVelocity()
  local playerSpeedX = math.abs(playerSpeedX)

  if self.box:enter("Player") -- If self has the most speed
  and self.speedLastFrameX > enemy.speedLastFrameX then
    self.soundIsHit:play()

    local playerX, playerY = self.box:getPosition()
    local enemyX, enemyY = enemy.box:getPosition()

    local pushdirectionX = (enemyX - playerX)
    local pushdirectionY = (enemyY - playerY)

    enemy.box:setLinearVelocity(0, 0)
    enemy.box:applyLinearImpulse(
      pushdirectionX * enemy.hitStrength * self.speedLastFrameX,
      pushdirectionY * enemy.hitStrength * self.speedLastFrameY
    )
  end

  self.speedLastFrameX = playerSpeedX
  self.speedLastFrameY = playerSpeedX

  -- Player takes damage when hit by enemy weapon
  if self.box:enter("Bullet") then
    self:takeDamage(enemy.weapon.damage)
  end
end


-- Will change the weapon of a player to something new.
-- The input type is a string eg. "rifle", "bazooka"
function Player:setWeapon(weapontype)
  local px, py = self.box:getPosition()
  -- Get rid of the old weapon object
  self.weapon.box:destroy()
  self.weapon = nil
  if weapontype == "rifle" then
    self.weapon = Rifle(px, py, self.w, self.h)
  elseif weapontype == "bazooka" then
    self.weapon = Bazooka(px, py, self.w, self.h)
  end
end