<div align="center">
  <h1>Telenim</h1>
  The telegram framework written in Nim.

[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)
[![Nim language-plastic](https://github.com/Ethosa/yukiko/blob/master/nim-lang.svg)](https://github.com/Ethosa/yukiko/blob/master/nim-lang.svg)
[![License](https://img.shields.io/github/license/Ethosa/telenim)](https://github.com/Ethosa/telenim/blob/master/LICENSE)
[![time tracker](https://wakatime.com/badge/github/Ethosa/telenim.svg)](https://wakatime.com/badge/github/Ethosa/telenim)

</div>

## Install
- `nimble install https://github.com/Ethosa/telenim`

## Features
- only stdlib was used;
- telegram types support;
- handlers;

## Simple usage
```nim
import telenim

var api = TelegramApi("878812:lashfbajsb")

api@update(event):  # handles any telegram update
  # `event` is an Update object.
  echo update.update_id

api.listen()
```

## F.A.Q.
*Q*: Where I can see examples?  
*A*: You can see it [here](https://github.com/Ethosa/telenim/blob/master/tests)

*Q*: Where can I read the docs?  
*A*: You can read docs [here](https://ethosa.github.io/telenim/telenim.html)

<div align="center">
  Copyright 2020 Ethosa
</div>
