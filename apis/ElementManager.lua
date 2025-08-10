local ElementManager = {}
local ElementManagerMeta = {
	-- __index metamethod allows you to define a fallback for accessing keys not present in the table
	__index = ElementManager
}
ElementManager._VERSION = "0.4.0"

function ElementManager:newElement()
	local self = setmetatable({}, {
		__index = self -- Children inherit properties and methods from the element manager
	})
	self.children = {}
	return self
end

-- Adds child elements to an element
function ElementManager:addChild(parent, ...)
	for _, v in ipairs({...}) do
		table.insert(parent.children, v)
	end
end

-- Function to draw all elements recursively
function ElementManager:drawAll(element)
	if element.skipDraw then return end
	if element.draw then
		element:draw() -- Draw the element
	end
	for _, child in ipairs(element.children) do
		self:drawAll(child) -- Draw all children recursively
	end
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
