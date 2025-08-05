
local helper = {}

function helper.find(arr,y) 
    for i=1,#arr do 
        if arr[i]==y then return true end 
    end

    return false
end

return helper
