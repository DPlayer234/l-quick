--[[
Returns the BehaviorTree middleclass
]]
return require((...):gsub("%.init$", "") .. ".behavior_tree")
