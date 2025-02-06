local x, y, z = 0, 1.5, 3
local yaw, pitch = 0, 0
local speed = 5
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

local gridSize = 128
local cubeSize = 1
local terrain = {}

-- Fonction pour générer du bruit lissé
local function smoothNoise(x, y)
  return math.max(1, (math.sin(x * 0.08) * math.cos(y * 0.08) +
                      math.sin(x * 0.03) * math.cos(y * 0.05)) * 3 + 3) -- Assurer des valeurs positives
end

-- Fonction pour générer le terrain
function generateTerrain()
  for i = 1, gridSize do
    terrain[i] = {}
    for j = 1, gridSize do
      local height = math.floor(smoothNoise(i, j))
      terrain[i][j] = height
    end
  end
end

-- Initialisation du jeu
function lovr.load()
  -- Charger le modèle du personnage
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

  terrainModel = lovr.graphics.newModel("./src/Dirt/Dirt.obj", {materials = false})

  currentMaterialCharacter = material1

  print(model:getAnimationCount())
  if model:getAnimationCount() > 0 then
    currentAnimation = 1
  else
    print("Aucune animation trouvée dans le modèle.")
  end

  generateTerrain()
end

function changeTexture()
  if currentMaterialCharacter == material1 then
    currentMaterialCharacter = material2
  else
    currentMaterialCharacter = material1
  end
end

-- Fonction pour gérer les touches appuyées
function lovr.keypressed(key, scancode, repeating)
  if key == 'w' then
    moveForward = true
  elseif key == 's' then
    moveBackward = true
  elseif key == 'a' then
    moveLeft = true
  elseif key == 'd' then
    moveRight = true
  elseif key == 'q' then
    moveUp = true
  elseif key == 'e' then
    moveDown = true
  elseif key == 't' then  -- Changer la texture lorsqu'on appuie sur 't'
    changeTexture()
  elseif key == 'r' then
    if model:getAnimationCount() > 0 then
      currentAnimation = (currentAnimation % model:getAnimationCount()) + 1
      animationTime = 0  -- Reset l'animation au début
      print("Changement d'animation: " .. currentAnimation)
    end
  end
end

-- Fonction pour gérer les touches relâchées
function lovr.keyreleased(key)
  if key == 'w' then
    moveForward = false
  elseif key == 's' then
    moveBackward = false
  elseif key == 'a' then
    moveLeft = false
  elseif key == 'd' then
    moveRight = false
  elseif key == 'q' then
    moveUp = false
  elseif key == 'e' then
    moveDown = false
  end
end

-- Fonction pour gérer le clic droit de la souris
function lovr.mousepressed(xpos, ypos, button)
  if button == 2 then
    isRightClickDown = true
  end
end

function lovr.mousereleased(xpos, ypos, button)
  if button == 2 then
    isRightClickDown = false
  end
end

-- Fonction pour gérer le mouvement de la souris
function lovr.mousemoved(xpos, ypos, dx, dy)
  if isRightClickDown then
    yaw = yaw - dx * 0.002
    pitch = math.max(-math.pi / 2, math.min(math.pi / 2, pitch - dy * 0.002))
  end
end

-- Mise à jour du jeu
function lovr.update(dt)
  local forward = -vec3(math.sin(yaw), 0, math.cos(yaw))
  local right = vec3(math.cos(yaw), 0, -math.sin(yaw))

  if moveForward then
    x = x + forward.x * speed * dt
    z = z + forward.z * speed * dt
  end
  if moveBackward then
    x = x - forward.x * speed * dt
    z = z - forward.z * speed * dt
  end
  if moveLeft then
    x = x - right.x * speed * dt
    z = z - right.z * speed * dt
  end
  if moveRight then
    x = x + right.x * speed * dt
    z = z + right.z * speed * dt
  end
  if moveUp then
    y = y - speed * dt
  end
  if moveDown then
    y = y + speed * dt
  end

  if currentAnimation then
    animationTime = animationTime + dt * animationSpeed
    model:animate(currentAnimation, animationTime)  -- Joue l'animation
  end
end

function lovr.draw(pass)
  local orientation = quat(yaw, 0, 1, 0) * quat(pitch, 1, 0, 0)
  pass:setViewPose(1, vec3(x, y, z), orientation)
  pass:setMaterial(currentMaterialCharacter)
  pass:draw(model, 0,2,0, 0.5)

  -- Dessiner la grille de modèles de terrain
  for i = 1, gridSize do
    for j = 1, gridSize do
      local height = terrain[i][j]
      -- Dessiner les cubes un par un, vérifiant la hauteur
      for k = 0, height - 1 do
        local xpos = (i - gridSize / 2)  * cubeSize
        local ypos = k * cubeSize
        local zpos = (j - gridSize / 2) * cubeSize
        -- Appliquer la texture de la terre pour chaque cube
        pass:setMaterial(materialDirt)
        pass:draw(terrainModel, xpos, ypos, zpos, 0.5)
      end
    end
  end
end