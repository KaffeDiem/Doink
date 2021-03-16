debug = false
-- love.graphics.setDefaultFilter('nearest', 'nearest')

wf = require "modules/windfield"
Object = require "modules/classic"
suit = require "modules/suit"

require "Player"
require "UI"
require "menu"
require "settings"
require "chars/rifle"
require "chars/bazooka"
require "gamewin"

function love.load()
  print("\t***Loading game***")

  gamestate = "menu"
  weapons = {"rifle", "bazooka"}

  -- Default amount of rounds played
  deaths = 5 -- playing till 5 deaths as default
  if debug == "true" then deaths = 1 end -- die quicker if debug is true

  volume = 0 -- Global volume is muted at beginning of game
  love.audio.setVolume(volume)

  pixelfont = love.graphics.newFont("fonts/pixel.ttf", 12) -- Load the pixelated font
  pixelfontbig = love.graphics.newFont("fonts/pixel.ttf", 32)
  love.graphics.setFont(pixelfont)

  -- Setting up the world and all necessary classes
  world = wf.newWorld(0, 1512, true)
  world:addCollisionClass('Platform')
  world:addCollisionClass('Ground')
  world:addCollisionClass('Player')
  world:addCollisionClass('Weapon', {ignores = {'Player'}})
  world:addCollisionClass(
    'Bullet',
    {ignores = {'Player', 'Weapon', 'Platform'}}
  )

  -- Create some platforms to jump around on
  -- TODO: Create a level class and make this dynamic
  ground = world:newRectangleCollider(120, 635, 1000, 30)
  ground:setType('kinematic')
  ground:setCollisionClass('Ground')
  groundimage = love.graphics.newImage("images/ground.png")

  -- The cloud image to be used for the first two platforms
  platformimagesmall = love.graphics.newImage("images/platform.png")
  platform = world:newRectangleCollider(200, 400, 200, 40)
  platform:setType('static')
  platform:setCollisionClass('Platform')

  platform = world:newRectangleCollider(750, 450, 200, 40)
  platform:setType('static')
  platform:setCollisionClass('Platform')

  platformimagebig = love.graphics.newImage("images/platformbig.png")
  platform = world:newRectangleCollider(450, 200, 400, 40)
  platform:setType('static')
  platform:setCollisionClass('Platform')

  -- Background image 
  bgImageRandomNumber = math.random(2)
  bgImage = {
    love.graphics.newImage("images/bg.png"),
    love.graphics.newImage("images/bg_night.png")
  }
  -- Some music plays for 45 seconds ATM
  game_loop = love.audio.newSource('sounds/loop.wav', 'static')
  game_loop:play()
  -- Creating the player objects with config from conf.lua
  P1 = Player(200, 500, p1_conf, "images/fishsheet_8.png")
  P2 = Player(900, 500, p2_conf, "images/cactus.png")

  print("\t***Game loaded***")
end


function love.update(dt)
  -- Makes the ground move like a wave
  local wavemovement = math.sin(
    (2 * math.pi * love.timer.getTime()) * 0.5
  ) * 0.3
  ground:setPosition(ground:getX(), ground:getY() + (wavemovement))

  if P1.deaths >= deaths or P2.deaths >= deaths then
    gamestate = "gamewin"
  end

  if gamestate == "running" then
    world:update(dt)
    P1:update(dt)
    P2:update(dt)
    P1:collisionPlayers(P2)
    P2:collisionPlayers(P1)
  end

  if gamestate == "menu" then
    menuActive()
  end
end


function love.draw()

  if gamestate == "running" or gamestate == "gamewin" then
    love.graphics.draw(bgImage[2], 0, 0)

    local gx, gy = ground:getPosition()
    love.graphics.draw(groundimage, gx - 500, gy - 40, 0, 0.25, 0.25)
    love.graphics.draw(platformimagesmall, 200, 400 - 10)
    love.graphics.draw(platformimagesmall, 750, 450 - 10)
    love.graphics.draw(platformimagebig, 450, 200 - 10)

    if debug == true then world:draw() end -- draw hitboxes if debug is true

    P1:draw()
    P2:draw()
    drawHP(P1:getHealth(), P2:getHealth())
    -- Draw a menu button ingame
    if suit.Button("Menu", 10, 10, 50, 30).hit then
      gamestate = "menu"
    end
    suit:draw()
  end

  if gamestate == "menu" then
    suit:draw()
  end

  if gamestate == "gamewin" then
    drawGameWin()
  end
end

function love.keypressed(key)
  if gamestate == "menu" then
    if key == "space" then
      gamestate = "running"
    end
  end
  if key == "escape" or key == "p" then
    gamestate = "menu"
  end
  if gamestate == "gamewin" then
    if key then
      love.load()
    end
  end
end
