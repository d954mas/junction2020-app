#include "interactive_canvas.h"

#include <iostream>
#include <string>
#include <stdio.h>

void InteractiveCanvasInitialize(){
    HtmlInteractiveCanvasRegisterCallbacks();
}
void InteractiveCanvasExitContinuousMatchMode(){
   HtmlInteractiveCanvasExitContinuousMatchMode();
}

void InteractiveCanvaseSendTextQuery(const char* text){
    std::string s = text;
    HtmlInteractiveCanvasSendTextQuery(text);
}