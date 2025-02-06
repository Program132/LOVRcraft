local x, y, z = 0, 1.5, 3   -- Position de la caméra
local yaw, pitch = 0, 0     -- Orientation de la caméra
local speed = 3             -- Vitesse de déplacement
local isRightClickDown = false -- Indique si le clic droit est enfoncé

local moveForward, moveBackward, moveLeft, moveRight, moveUp, moveDown = false, false, false, false, false, false

function lovr.load()
  -- Initialisation
end

-- Fonction appelée lorsqu'une touche du clavier est pressée
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

-- Fonction appelée lorsqu'une touche du clavier est relâchée
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

-- Fonction appelée lorsqu'un bouton de la souris est pressé
function lovr.mousepressed(xpos, ypos, button)
  if button == 2 then  -- Clic droit de la souris (2 correspond au bouton droit)
    isRightClickDown = true  -- Le clic droit est enfoncé
  end
end

-- Fonction appelée lorsqu'un bouton de la souris est relâché
function lovr.mousereleased(xpos, ypos, button)
  if button == 2 then  -- Clic droit de la souris
    isRightClickDown = false  -- Le clic droit est relâché
  end
end

-- Fonction appelée lorsqu'il y a un déplacement de souris
function lovr.mousemoved(xpos, ypos, dx, dy)
  if isRightClickDown then  -- Ne tourner la caméra que si le clic droit est enfoncé
    -- Rotation de la caméra sur l'axe horizontal (yaw) : tourner la caméra à gauche/droite
    yaw = yaw - dx * 0.002

    -- Rotation de la caméra sur l'axe vertical (pitch) : incliner la caméra haut/bas
    -- Limite de -90° à +90° pour éviter une inversion de vue
    pitch = math.max(-math.pi / 2, math.min(math.pi / 2, pitch - dy * 0.002))
  end
end

function lovr.update(dt)
  -- Calcul des directions avant (forward) et à droite (right) en fonction de l'angle yaw
  local forward = -vec3(math.sin(yaw), 0, math.cos(yaw))   -- Direction devant la caméra
  local right = vec3(math.cos(yaw), 0, -math.sin(yaw))    -- Direction à droite de la caméra

  -- Mouvement en fonction des touches appuyées
  if moveForward then
    x = x + forward.x * speed * dt  -- Avancer
    z = z + forward.z * speed * dt
  end
  if moveBackward then
    x = x - forward.x * speed * dt  -- Reculer
    z = z - forward.z * speed * dt
  end
  if moveLeft then
    x = x - right.x * speed * dt    -- Aller à gauche
    z = z - right.z * speed * dt
  end
  if moveRight then
    x = x + right.x * speed * dt    -- Aller à droite
    z = z + right.z * speed * dt
  end
  if moveUp then
    y = y - speed * dt  -- Monter (augmenter y)
  end
  if moveDown then
    y = y + speed * dt  -- Descendre (diminuer y)
  end
end


function lovr.draw(pass)
  -- Créer un quaternion pour la rotation (yaw et pitch combinés)
  local orientation = quat(yaw, 0, 1, 0) * quat(pitch, 1, 0, 0)

  -- Applique la caméra avec la position et l'orientation
  pass:setViewPose(1, vec3(x, y, z), orientation)

  -- Affiche un cube pour tester la vue
  pass:cube(3, 0, 3, 1)

  -- Affiche les coordonnées de la caméra dans le coin supérieur gauche
  local text = "Camera Position: X: " .. string.format("%.2f", x) .. " Y: " .. string.format("%.2f", y) .. " Z: " .. string.format("%.2f", z)
  pass:text(text, 0.1, 1.9, 3, 0.05, 0, 0, 1, 0)  -- Affiche le texte à une position spécifique, avec une échelle
end