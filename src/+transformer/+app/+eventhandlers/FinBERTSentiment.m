classdef FinBERTSentiment < transformer.app.eventhandlers.Interface    
    properties(Access=private)
        ModelCache = []        
    end
    
    methods
        function this = FinBERTSentiment()
            this.Name = "finbert-sentiment";
        end
        
        function call(this,src,event)
            mdl = this.getModel();
            seq = this.encodeInput(mdl.Tokenizer,event.Data.Input);
            sentiment = this.predict(mdl,seq);
            this.updateSource(src,sentiment);
        end
    end
    
    methods(Access=private)
        function mdl = getModel(this)
            if isempty(this.ModelCache)
                this.ModelCache = finbert();
            end
            mdl = this.ModelCache;
        end
        
        function seq = encodeInput(~,tokenizer,input)
            seqs = tokenizer.encode(string(input));
            seq = dlarray(seqs{1});
        end
        
        function sentiment = predict(~,mdl,seq)
            sentiment = finbert.sentimentModel(seq,mdl.Parameters);
        end
        
        function updateSource(~,src,sentiment)
            src.Data.Output = string(sentiment);
            src.Data.Task = "finbert-sentiment";
        end
    end
end