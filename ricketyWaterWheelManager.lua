
--[[
	Made for use with create and rickety water wheels to manage durability on the water wheels.

	The back needs a bundled output, in minecraft color order matches a next section of water wheels.
	The first section is always on as no stress means no degredation.
	above is the chatbox from advanced peripherals.
	above that chatbox is a notification block to announce a problem.
	left is the stressometer
]]

local stressMeter = peripheral.wrap("left");
local chat = peripheral.wrap("top");
local waterWheelSupply = 256;
local stressCycles = 0;

local wheelSets = {
	8, 4, 4, 4
}
local bundledColors = {
	colors.white, colors.orange, colors.magenta, colors.lightBlue
}
rs.setBundledOutput("back", colors.combine(unpack(bundledColors)))

function GetStress() return stressMeter.getStress() end
function GetCapacity() return stressMeter.getStressCapacity() end

local msgColors = {
	warn  = "yellow",
	error = "dark_red",
	good  = "green",
	none  = "white",
}
function sendMessage(msg)
	chat.sendFormattedMessage(textutils.serialiseJSON(msg))
end
sendMessage{
	{text = "Water Wheel script successfuly started.", color = msgColors.good}
}

local problem = false
while true do

	stress   = GetStress()
	capacity = GetCapacity()

	local bundledOutput = colors.combine(unpack(bundledColors));
	local expectedCapacity = 8;
	local turnOffRemaining = false;
	local sectionsActive = 1;
	for i, v in ipairs(bundledColors) do
		bundledOutput = colors.subtract(bundledOutput, v);
		expectedCapacity = expectedCapacity + wheelSets[i] * waterWheelSupply;
		if expectedCapacity >= GetStress() then
			sectionsActive = i;
			rs.setBundledOutput("back", bundledOutput);
			sleep(2)
			break
		end
	end

	-- get expected stress supplied to check if one+ wheels are broken
	if GetCapacity() < expectedCapacity then
		problem = true
		sendMessage{
			{text = "Detected a problem with the Water Wheels", color = msgColors.error}
		}
		rs.setOutput("top", true);
		sleep(0.05);
		rs.setOutput("top", false);
	else
		if problem == true then
			sendMessage{
				{text = "Water wheel problem solved.", color = msgColors.good}
			}
			problem = false
		end
	end

	if stress > 0 then 
		stressCycles = stressCycles + 1
		if stressCycles > 24 and stressCycles % 15 == 0 then
			sendMessage{
				{text = "Water Wheels", color = msgColors.warn},
				{text = " detects extended activity time.", msgColors.none}
			}
			-- chat.sendMessage(message: string[, prefix: string, brackets: string, bracketColor: string, range: number]) -> true | nil, string
		end
	else
		stressCycles = 0
	end
	sleep(1);

end
