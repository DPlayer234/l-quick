--[[
Returns the StateMachine middleclass
]]
return require((...):gsub("%.init$", "") .. ".state_machine")
