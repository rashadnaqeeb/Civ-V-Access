/**
 *  Product:        Tolk
 *  File:           ScreenReaderDriverZDSR.h
 *  Description:    Driver for the ZDSR screen reader.
 *  Copyright:      (c) 2022, qt06<qt06.com@gmail.com>
 *  License:        LGPLv3
 */

#ifndef _SCREEN_READER_DRIVER_ZDSR_H_
#define _SCREEN_READER_DRIVER_ZDSR_H_

#include <windows.h>
#include "ScreenReaderDriver.h"

class ScreenReaderDriverZDSR : public ScreenReaderDriver {
public:
  ScreenReaderDriverZDSR();
  ~ScreenReaderDriverZDSR();

public:
  bool Speak(const wchar_t *str, bool interrupt);
  bool Braille(const wchar_t *str);
  bool IsSpeaking();
  bool Silence();
  bool IsActive();
  bool Output(const wchar_t *str, bool interrupt);

private:
  typedef int (WINAPI *ZDSRInitTTS)(int channelType, const wchar_t* channelName, BOOL bKeyDownInterrupt);
  typedef int (WINAPI *ZDSRGetSpeakState)();
  typedef int (WINAPI *ZDSRSpeak)(const wchar_t* text, BOOL bInterrupt);
  typedef void (WINAPI *ZDSRStopSpeak)();


private:
  HINSTANCE controller;
  ZDSRInitTTS zdsrInitTTS;
  ZDSRGetSpeakState zdsrGetSpeakState;
  ZDSRSpeak zdsrSpeak;
  ZDSRStopSpeak zdsrStopSpeak;
};

#endif // _SCREEN_READER_DRIVER_ZDSR_H_
