classdef BERTLM < transformer.app.eventhandlers.Interface    
    properties(Access=private)
        ModelCache = []
        TopK
    end
    
    methods
        function this = BERTLM(nvp)
            arguments
                nvp.TopK (1,1) double = 5
            end
            this.TopK = nvp.TopK;
            this.Name = "bert-LM";
        end
        
        function call(this,src,event)
            mdl = this.getModel(event);
            tokens = this.tokenizeInput(mdl.Tokenizer,event);            
            [predictions,probabilities] = this.predict(mdl,tokens);
            this.updateSource(src,event.Data.Input,mdl.Tokenizer.MaskToken,tokens,predictions,probabilities);
        end
    end
    
    methods(Access=private)
        function mdl = getModel(this,event)
            if (isempty(this.ModelCache) || ~(strcmp(this.ModelCache.Name,event.Data.Model)))
                this.ModelCache.Name = event.Data.Model;
                this.ModelCache.Model = bert("Model",event.Data.Model);
            end
            mdl = this.ModelCache.Model;
        end
        
        function toks = tokenizeInput(~,tokenizer,event)
            str = string(event.Data.Input);
            pieces = split(str,tokenizer.MaskToken);
            x = [];            
            for i = 1:numel(pieces)
                tokens = tokenizer.FullTokenizer.tokenize(pieces(i));
                x = cat(2,x,tokens);
                if i<numel(pieces)
                    x = cat(2,x,tokenizer.MaskToken);
                end
            end
            % uihtml likes cellstr, and for a single token weird things happen (1x1
            % string becomes 1xn char rather than 1x1 cell - chaos!)
            toks = cellstr(x);            
        end
        
        function [predictions,probabilities] = predict(this,model,tokens)            
            x = model.Tokenizer.encodeTokens({[model.Tokenizer.SeparatorToken,string(tokens)]});
            x = dlarray(x{1});
            maskIdx = x == model.Tokenizer.MaskCode;
            [~,probabilities] = bert.internal.predictMaskedToken(model,x,maskIdx);
            [probabilities,idx] = maxk(probabilities,this.TopK,1);
            predictions = model.Tokenizer.FullTokenizer.decode(idx);
        end
        
        function updateSource(~,src,originalStr,maskToken,tokens,predictions,probabilities)
            pieces = split(originalStr,maskToken);
            j = 0;
            outputStr = "";
            for i =1:(numel(pieces)-1)
                j = j+1;
                outputStr = strcat(outputStr,pieces(i),predictions(1,j));
            end
            outputStr = strcat(outputStr,pieces(end));
            src.Data.Output = outputStr;
            src.Data.NumMask = size(predictions,2);
            if size(predictions,2)==1
                % some dumb stuff when just 1 mask.
                predictions = num2cell(num2cell(predictions));
                probabilities = num2cell(num2cell(probabilities));
            end
            src.Data.Tokens = tokens;
            src.Data.TopKTokens = predictions;
            src.Data.TopKProbs = probabilities;
        end
    end
end