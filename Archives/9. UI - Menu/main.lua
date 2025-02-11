-- Charger une texture
local texture = lovr.graphics.newTexture('./src/red_text.png')

-- Charger une police personnalisée
local font = lovr.graphics.newFont('./src/FfMoon-Regular.ttf')

-- Définir la taille de la police
font:setPixelDensity(1.5) -- Ajustez cette valeur selon vos besoins

-- Configuration d'une projection orthographique 2D
local width, height = lovr.system.getWindowDimensions()
local projection = lovr.math.newMat4():orthographic(0, width, 0, height, -10, 10)

-- Fonction pour dessiner le menu
function lovr.draw(pass)
  pass:setViewPose(1, lovr.math.newMat4():identity())
  pass:setProjection(1, projection)
  pass:setDepthTest()

  -- Définition des boutons
  local buttons = {
    { text = "Jouer", x = width / 2, y = height / 2 - 40, w = 180, h = 60 },
    { text = "Quitter", x = width / 2, y = height / 2 + 80, w = 180, h = 60 }
  }

  -- Récupération de la position de la souris
  local mx, my = lovr.system.getMousePosition()
  local pressed = lovr.system.isMouseDown(1)

  -- Dessin des boutons
  for _, button in ipairs(buttons) do
    local hovered = mx > button.x - button.w / 2 and mx < button.x + button.w / 2 and
                    my > button.y - button.h / 2 and my < button.y + button.h / 2

    if hovered and pressed then
      pass:setColor(.25, .25, .27)
      if button.text == "Quitter" then
        lovr.event.quit()
      elseif button.text == "Jouer" then
        print("Jouer cliqué")
      end
    elseif hovered then
      pass:setColor(.20, .20, .22)
    else
      pass:setColor(.15, .15, .17)
    end

    -- Dessiner le plan texturé
    pass:setMaterial(texture)
    pass:plane(button.x, button.y, 0, button.w, button.h)

    -- Dessiner le texte par-dessus
    pass:setColor(1, 1, 1) -- Couleur du texte
    pass:setFont(font)
    pass:text(button.text, button.x, button.y, 0)
  end
end
