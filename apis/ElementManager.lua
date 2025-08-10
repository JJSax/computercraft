local ElementManager = {}
local ElementManagerMeta = {
	-- __index metamethod allows you to define a fallback for accessing keys not present in the table
	__index = ElementManager
}
ElementManager._VERSION = "0.4.4"

function ElementManager:newElement(init)
	local element = setmetatable(init or {}, { __index = ElementManager })
	element.children = {}
	return element
end

-- Adds child elements to an element
function ElementManager:addChild(parent, ...)
	for _, v in ipairs({ ... }) do
		v.parent = parent
		table.insert(parent.children, v)
	end
end

function ElementManager:removeChild(parent, child)
	error("Not Implemented Yet")
end

--todo consider having method to hide/show; may need to redraw parent

-- Function to draw all elements recursively
function ElementManager:drawAll(element)
	if element.hide then return end
	if element.draw then
		element:draw() -- Draw the element
	end
	for _, child in ipairs(element.children) do
		self:drawAll(child) -- Draw all children recursively
	end
end

function ElementManager:setPosition(x, y)
	self.x = x
	self.y = y
end

function ElementManager:getAbsolutePosition()
	local x, y = self.x or 1, self.y or 1
	local parent = self.parent
	while parent do
		x = x + (parent.x or 0)
		y = y + (parent.y or 0)
		parent = parent.parent
	end
	return x, y
end

function ElementManager:setCursorPos(relX, relY)
	local absX, absY = self:getAbsolutePosition()
	term.setCursorPos(absX + (relX - 1), absY + (relY - 1))
end

function ElementManager:inBounds(obj, x, y)
	if obj.hide then return false end
	for _, v in ipairs(obj.children) do
		local inside = self:inBounds(v, x, y)
		if inside then
			return inside
		end
	end

	if not obj.x or not obj.y or not obj.width or not obj.height then return false end

	local absX, absY = obj:getAbsolutePosition()
	if x >= absX and x < absX + obj.width and y >= absY and y < absY + obj.height then
		return obj
	end

	return false
end

function ElementManager:triggerAt(obj, x, y, button)
	local target = self:inBounds(obj, x, y)
	if target and target.activate then
		target:activate(button, x, y)
		return true
	end
	return false
end

if false then -- make true if you want to run the demo
	-- Create a new element manager instance
	local manager = setmetatable({}, ElementManagerMeta)

	-- Create elements
	local root = manager:newElement()
	local child1 = manager:newElement()
	local child2 = manager:newElement()

	-- Add children to the root element
	manager:addChild(root, child1)
	manager:addChild(root, child2)

	-- Define draw function for the root element
	function root:draw()
		print("Drawing root element")
	end

	-- Define draw function for child elements
	function child1:draw()
		print("Drawing child element 1")
	end

	function child2:draw()
		print("Drawing child element 2")
	end

	-- Add sub-elements to child2
	local subchild1 = manager:newElement()
	local subchild2 = manager:newElement()

	manager:addChild(child2, subchild1)
	manager:addChild(child2, subchild2)

	-- Define draw function for sub-child elements
	function subchild1:draw()
		print("Drawing sub 1 of child 2")
	end

	function subchild2:draw()
		print("Drawing sub 2 of child 2")
	end

	-- Draw all elements
	manager:drawAll(root)
end

return setmetatable({}, ElementManagerMeta)
