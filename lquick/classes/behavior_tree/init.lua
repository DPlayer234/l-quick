--[[
Returns the BehaviorTree class
]]
return require((...):gsub("%.init$", "") .. ".behavior_tree")
