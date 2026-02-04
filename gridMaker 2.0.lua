local dlg = Dialog("Grid Generator")

dlg:combobox{
  id = "mode",
  label = "Mode:",
  option = "pixel",
  options = {"pixel", "split"},
  onchange = function()
    local data = dlg.data
    local isPixel = data.mode == "pixel"
    dlg:modify{id = "width", visible = isPixel}
    dlg:modify{id = "height", visible = isPixel}
    dlg:modify{id = "cols", visible = not isPixel}
    dlg:modify{id = "rows", visible = not isPixel}
  end
}

dlg:number{id = "width", label = "Width (px):", text = "32"}
dlg:number{id = "height", label = "Height (px):", text = "32"}
dlg:number{id = "cols", label = "Columns:", text = "3", visible = false}
dlg:number{id = "rows", label = "Rows:", text = "3", visible = false}

dlg:number{id = "lineWidth", label = "Line Width:", text = "1"}
dlg:color{id = "color", label = "Line Color:", color = Color{r = 0, g = 0, b = 0}}

dlg:combobox{
  id = "origin",
  label = "Origin:",
  option = "Top-Left",
  options = {
    "Top-Left", "Top-Center", "Top-Right",
    "Center-Left", "Center", "Center-Right",
    "Bottom-Left", "Bottom-Center", "Bottom-Right"
  }
}

dlg:button{id = "ok", text = "Generate"}
dlg:button{id = "cancel", text = "Cancel"}

dlg:show()

if not dlg.data.ok then return end

local spr = app.activeSprite
if not spr then
  app.alert("You must have a sprite open.")
  return
end

local cellW, cellH
if dlg.data.mode == "pixel" then
  cellW = dlg.data.width
  cellH = dlg.data.height
else
  cellW = spr.width / dlg.data.cols
  cellH = spr.height / dlg.data.rows
end

local lineW = dlg.data.lineWidth
local lineColor = dlg.data.color
local origin = dlg.data.origin

-- Offset based on origin
local offsetX, offsetY = 0, 0

if origin:find("Center") then
  offsetX = (spr.width % cellW) / 2
  offsetY = (spr.height % cellH) / 2
end
if origin:find("Right") then
  offsetX = spr.width % cellW
end
if origin:find("Bottom") then
  offsetY = spr.height % cellH
end

app.transaction(function()
  local layer = spr:newLayer()
  layer.name = "Grid"

  local img = Image(spr.width, spr.height)
  img:clear()

  -- Horizontal lines
  for y = offsetY, spr.height, cellH do
    for i = 0, lineW - 1 do
      if y + i < spr.height then
        for x = 0, spr.width - 1 do
          img:drawPixel(x, y + i, lineColor)
        end
      end
    end
  end

  -- Vertical lines
  for x = offsetX, spr.width, cellW do
    for i = 0, lineW - 1 do
      if x + i < spr.width then
        for y = 0, spr.height - 1 do
          img:drawPixel(x + i, y, lineColor)
        end
      end
    end
  end

  spr:newCel(layer, app.activeFrame.frameNumber, img, Point(0, 0))
end)

app.refresh()

