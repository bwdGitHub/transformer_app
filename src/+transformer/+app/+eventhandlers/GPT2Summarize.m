classdef GPT2Summarize < transformer.app.eventhandlers.Interface
    properties(Access=private)
        ModelCache        
    end
    
    methods
        function this = GPT2Summarize()
            this.Name = "gpt2-summarize";
        end
        
        function call(this,src,event)
            inputStr = string(event.Data.Input);
            mdl = this.getModel();
            src.Data.Output = generateSummary(mdl,inputStr);
        end        
    end
    
    methods(Access=private)
        function mdl = getModel(this)
            if (isempty(this.ModelCache))
                this.ModelCache = gpt2();
            end
            mdl = this.ModelCache;
        end
    end
end