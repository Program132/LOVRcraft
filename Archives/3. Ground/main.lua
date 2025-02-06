local x, y, z = 0, 1.5, 3
local yaw, pitch = 0, 0
local speed = 3
local isRightClickDown = false

local moveForward, moveBackward, moveLeft, moveRight, moveUp, moveDown = false, false, false, false, false, false

local floorCubes = {}  -- Table pour stocker les cubes du sol

function lovr.load()
  -- Créer un sol de cubes colorés une seule fois
  local cubeSize = 1
  local gridSize = 10  -- Taille de la grille
  for i = 1, gridSize do
    for j = 1, gridSize do
      -- Position de chaque cube
      local xPos = i - gridSize / 2
      local zPos = j - gridSize / 2
      local yPos = 0  -- Position verticale du sol, ajustée pour que le centre des cubes soit aligné

      -- Choisir une couleur aléatoire pour chaque cube
      local r = math.random()
      local g = math.random()
      local b = math.random()

      -- Ajouter les informations du cube dans la table floorCubes
      table.insert(floorCubes, {
        x = xPos,
        y = yPos,
        z = zPos,
        r = r,
        g = g,
        b = b
      })
    end
  end
end



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
  end
end

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

function lovr.mousemoved(xpos, ypos, dx, dy)
  if isRightClickDown then
    yaw = yaw - dx * 0.002
    pitch = math.max(-math.pi / 2, math.min(math.pi / 2, pitch - dy * 0.002))
  end
end

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
end


function lovr.draw(pass)
  -- Créer un quaternion pour la rotation (yaw et pitch combinés)
  local orientation = quat(yaw, 0, 1, 0) * quat(pitch, 1, 0, 0)

  -- Applique la caméra avec la position et l'orientation
  pass:setViewPose(1, vec3(x, y, z), orientation)

  -- Afficher les cubes du sol à partir de la table pré-générée
  for _, cube in ipairs(floorCubes) do
    -- Appliquer la couleur du cube
    pass:setColor(cube.r, cube.g, cube.b)
    -- Afficher le cube
    pass:cube(cube.x, cube.y, cube.z, 1)  -- Taille des cubes de 1
  end
end
