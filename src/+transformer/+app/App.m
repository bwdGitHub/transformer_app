classdef App
    properties(Access=private)
        EventHandlers
    end
    
    methods
        function this = App(nvp)
            arguments
                nvp.SourceFile = fullfile(fileparts(mfilename("fullpath")),"..","..","html","index.html")
                nvp.EventHandlers = iDefaultEventHandlers()
            end
            screenSz = get(0,'ScreenSize');
            width = 800;
            height = 400;
            app = uifigure('Position',createCenterPosition(screenSz(3),screenSz(4),width,height),'Visible',false,'Name','Transformers App');            
            app.Visible = true;
            this.EventHandlers = nvp.EventHandlers;
            uihtml(app,'HTMLSource',nvp.SourceFile,'DataChangedFcn',@(src,event) this.callModel(src,event),'Position',[0,0,width,height]);
        end
    end
    
    methods(Access=private)
        function callModel(this,src,event)
            eventHandler = this.EventHandlers(event.Data.Task);
            eventHandler.call(src,event);
            src.Data.Task = eventHandler.Name;
        end
    end
end

function eventhandlerMap = iDefaultEventHandlers()
eventhandlers = {
    transformer.app.eventhandlers.BERTLM()
    transformer.app.eventhandlers.FinBERTSentiment()};

eventhandlerMap = containers.Map();
for i = 1:numel(eventhandlers)
    eventhandler = eventhandlers{i};
    eventhandlerMap(eventhandler.Name) = eventhandler;
end
end

function sz = getCenter(parentSize,mySize)
sz = (parentSize - mySize)/2;
end

function pos = createCenterPosition(parentW,parentH,myW,myH)
pos = round([getCenter(parentW,myW),getCenter(parentH,myH),myW,myH]);
end