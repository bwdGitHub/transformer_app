classdef(Abstract) Interface < handle
    properties
        Name (1,1) string
    end
    
    methods(Abstract)
        call(this,src,event)
    end        
end