#pragma once

#include <string>

extern "C" void HtmlInteractiveCanvasRegisterCallbacks();
extern "C" void HtmlInteractiveCanvasSendTextQuery(const char*);
extern "C" void HtmlInteractiveCanvasExitContinuousMatchMode();

void InteractiveCanvasInitialize();
void InteractiveCanvasExitContinuousMatchMode();
void InteractiveCanvaseSendTextQuery(const char* text);