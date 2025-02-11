local x, y, z = 0, 1.5, 3
local yaw, pitch = 0, 0
local speed = 8
local isRightClickDown = false

local moveForward, moveBackward, moveLeft, moveRight, moveUp, moveDown = false, false, false, false, false, false

local model
local terrainModel
local material1
local material2
local materialDirt
local currentMaterialCharacter

local currentAnimation = nil
local animationTime = 0
local animationSpeed = 1

local GRID_SIZE = 128
local cubeSize = 1
local terrain = {}

local transformBuffer
local transformBufferSize
local shader
local dirt

local swordModel
local swordTexture


local function smoothNoise(x, y)
  return math.max(1, (math.sin(x * 0.08) * math.cos(y * 0.08) +
                      math.sin(x * 0.03) * math.cos(y * 0.05)) * 3 + 3)
end


function generateTerrain()
  for i = 1, GRID_SIZE do
    terrain[i] = {}
    for j = 1, GRID_SIZE do
      terrain[i][j] = math.floor(smoothNoise(i, j))
    end
  end
end


function lovr.load()
  model = lovr.graphics.newModel("./src/Character/Character.glb", {materials = false})

  material1 = lovr.graphics.newMaterial({
    texture = 'src/Character/Character Texture1.png',
    uvScale = { 1, 1 }
  })

  material2 = lovr.graphics.newMaterial({
    texture = 'src/Character/Character Texture2.png',
    uvScale = { 1, 1 }
  })

  materialDirt = lovr.graphics.newMaterial({
    texture = 'src/Dirt/Texture.png',
    uvScale = { 1, -1 }
  })

  swordModel = lovr.graphics.newModel('./src/Sword/Sword.glb', {materials=false})
  swordTexture = lovr.graphics.newMaterial({
    texture = 'src/Sword/Texture.png',
    uvScale = { 1, 1 }
  })

  terrainModel = lovr.graphics.newModel("./src/Dirt/Dirt.obj", {materials = false})

  currentMaterialCharacter = material1

  if model:getAnimationCount() > 0 then
    currentAnimation = 1
  end

  -- Génération du terrain et stockage des transformations dans le buffer
  generateTerrain()

  local transforms = {}
  local count = 0
  for i = 1, GRID_SIZE do
    for j = 1, GRID_SIZE do
      local height = terrain[i][j]
      for k = 0, height - 1 do
        local xpos = (i - GRID_SIZE / 2) * cubeSize
        local ypos = k * cubeSize
        local zpos = (j - GRID_SIZE / 2) * cubeSize

        local position = vec3(xpos, ypos, zpos)
        local orientation = quat(0, 0, 0, 1) -- Pas de rotation
        local scale = vec3(0.5)

        transforms[count + 1] = mat4(position, scale, orientation)
        count = count + 1
      end
    end
  end
  transformBuffer = lovr.graphics.newBuffer('mat4', transforms)
  transformBufferSize = transformBuffer:getLength()



  -- Création du shader pour l'instancing
  shader = lovr.graphics.newShader([[
  layout(set = 2, binding = 0) buffer Transforms {
    mat4 transforms[];
  };

    vec4 lovrmain() {
      return Projection * View * transforms[InstanceIndex] * VertexPosition;
    }
  ]], 'unlit')

  dirt = lovr.graphics.newModel('src/Dirt/Dirt.obj')

  print("Terrain généré avec " .. count .. " cubes !")
end

function changeTexture()
  currentMaterialCharacter = (currentMaterialCharacter == material1) and material2 or material1
end

-- Gestion des entrées clavier
function lovr.keypressed(key)
  if key == 'w' then moveForward = true
  elseif key == 's' then moveBackward = true
  elseif key == 'a' then moveLeft = true
  elseif key == 'd' then moveRight = true
  elseif key == 'q' then moveUp = true
  elseif key == 'e' then moveDown = true
  elseif key == 't' then changeTexture()
  elseif key == 'r' then
    if model:getAnimationCount() > 0 then
      currentAnimation = (currentAnimation % model:getAnimationCount()) + 1
      animationTime = 0
      print("Changement d'animation: " .. currentAnimation)
    end
  end
end

function lovr.keyreleased(key)
  if key == 'w' then moveForward = false
  elseif key == 's' then moveBackward = false
  elseif key == 'a' then moveLeft = false
  elseif key == 'd' then moveRight = false
  elseif key == 'q' then moveUp = false
  elseif key == 'e' then moveDown = false
  end
end

-- Gestion des mouvements de la souris
function lovr.mousepressed(_, _, button)
  if button == 2 then isRightClickDown = true end
end

function lovr.mousereleased(_, _, button)
  if button == 2 then isRightClickDown = false end
end

function lovr.mousemoved(_, _, dx, dy)
  if isRightClickDown then
    yaw = yaw - dx * 0.002
    pitch = math.max(-math.pi / 2, math.min(math.pi / 2, pitch - dy * 0.002))
  end
end

-- Mise à jour du jeu
function lovr.update(dt)
  local forward = -vec3(math.sin(yaw), 0, math.cos(yaw))
  local right = vec3(math.cos(yaw), 0, -math.sin(yaw))

  if moveForward then x = x + forward.x * speed * dt; z = z + forward.z * speed * dt end
  if moveBackward then x = x - forward.x * speed * dt; z = z - forward.z * speed * dt end
  if moveLeft then x = x - right.x * speed * dt; z = z - right.z * speed * dt end
  if moveRight then x = x + right.x * speed * dt; z = z + right.z * speed * dt end
  if moveUp then y = y - speed * dt end
  if moveDown then y = y + speed * dt end

  if currentAnimation then
    animationTime = animationTime + dt * animationSpeed
    model:animate(currentAnimation, animationTime)
  end
end

function lovr.draw(pass)
  -- Camera:
  local orientation = quat(yaw, 0, 1, 0) * quat(pitch, 1, 0, 0)
  pass:setViewPose(1, vec3(x, y, z), orientation)


  -- Character:
  pass:push() -- A
  pass:setMaterial(currentMaterialCharacter)
  pass:scale(0.5, 0.5, 0.5) -- B
  pass:translate(0, 2, 0) -- C
  pass:draw(model)


  -- Sword:
  pass:push()
  pass:setMaterial(swordTexture)
  pass:transform(model:getNodeTransform("WeaponBone"))
  pass:draw(swordModel, 0,-0.4,0)
  pass:pop()
  pass:pop()


  -- Ground:
  pass:setShader(shader)
  pass:send('Transforms', transformBuffer)
  pass:setMaterial(materialDirt)
  pass:draw(dirt, mat4(), transformBufferSize)
end
