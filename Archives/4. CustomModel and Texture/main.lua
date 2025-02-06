local x, y, z = 0, 1.5, 3
local yaw, pitch = 0, 0
local speed = 3
local isRightClickDown = false

local moveForward, moveBackward, moveLeft, moveRight, moveUp, moveDown = false, false, false, false, false, false

local model
local material1
local material2
local currentMaterial

function lovr.load()
  -- Charger le modèle et les textures
  model = lovr.graphics.newModel("./src/Character/Character.obj", {materials = false})  -- .obj ou .gltf

  material1 = lovr.graphics.newMaterial({
          texture = 'src/Character/Character Texture1.png',
          uvScale = { 1, -1 }
        })

        material2 = lovr.graphics.newMaterial({
                texture = 'src/Character/Character Texture2.png',
                uvScale = { 1, -1 }
              })

        currentMaterial = material1
      end

      -- Fonction pour changer la texture
      function changeTexture()
        if currentMaterial == material1 then
          currentMaterial = material2  -- Changer pour material2
        else
          currentMaterial = material1  -- Sinon, revenir à material1
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
        elseif key == 't' then  -- Changer la texture lorsqu'on appuie sur 't'
          changeTexture()
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
        local orientation = quat(yaw, 0, 1, 0) * quat(pitch, 1, 0, 0)
        pass:setViewPose(1, vec3(x, y, z), orientation)

        -- Dessiner le modèle avec la texture appliquée
        pass:setMaterial(currentMaterial)
        pass:draw(model)
      end