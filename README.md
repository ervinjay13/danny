# Project Danny

A voice assistance application that allows the ability to request objects / services 
via Text-To-Speech using touch.

## Overview

- Data persisted to device via a sqlite database interacted with via `floor`
- Text-to-speech functionality provided by `flutter_tts`
- 'Calls' are individual items that the user interacts with to "call" for something (an image which outputs TTS)

## Getting Started

1. Run `flutter packages pub run build_runner build` to ensure database files are generated
