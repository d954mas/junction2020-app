var LibInteractiveCanvas = {


    HtmlInteractiveCanvasRegisterCallbacks: function () {
        var TAG = "[InteractiveCanvasJS]";
        console.log(TAG + "InteractiveCanvas:init");
        var callbacks = {
            onUpdate: function (data) {
                //console.log(TAG +"onUpdate:",data);
                JsToDef.send("InteractiveCanvasOnUpdate", data);
            },
            onTtsMark: function (markName) {
                //	console.log(TAG +"onTtsMark:" , markName);
                JsToDef.send("InteractiveCanvasOnTtsMark", {"markName": markName});
            },
            onListeningModeChanged: function (mode) {
                // console.log(TAG +"onListeningModeChanged:" , mode);
                JsToDef.send("InteractiveCanvasOnListeningModeChanged", {"mode": mode});
            },
            onPhraseMatched: function (phraseMatchResult) {
                console.log(TAG + "onPhraseMatched:", phraseMatchResult);
                JsToDef.send("InteractiveCanvasOnPhraseMatched", {"phraseMatchResult": phraseMatchResult});
            },
        };

        //Send events that was handled while web app was loading
        for (var index = 0; index < window.interactiveCanvasUpdateEvents.length; index++) {
            var data = window.interactiveCanvasUpdateEvents[index];
            callbacks.onUpdate(data);
        }

        window.interactiveCanvasUpdateEvents = [];

        // called by the Interactive Canvas web app once web app has loaded to
        // register callbacks
        window.interactiveCanvas.ready(callbacks);
    },
    HtmlInteractiveCanvasSendTextQuery: function (textQuery) {
        var TAG = "[InteractiveCanvasJS]";
        textQuery = UTF8ToString(textQuery);
        //=console.log(TAG + "textQuery:" , textQuery);
        window.interactiveCanvas.sendTextQuery(textQuery);
    },
    HtmlInteractiveCanvasExitContinuousMatchMode: function () {
        var TAG = "[InteractiveCanvasJS]";
        console.log(TAG + "exitContinuousMatchMode");
        window.interactiveCanvas.exitContinuousMatchMode();
    }

}

mergeInto(LibraryManager.library, LibInteractiveCanvas);