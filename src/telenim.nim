when defined(debug):
  import logging

  var console_logger = newConsoleLogger(fmtStr="[$time]::$levelname - ")
  addHandler(console_logger)

  when not defined(android):
    var file_logger = newFileLogger("logs.log", fmtStr="[$date at $time]::$levelname - ")
    addHandler(file_logger)

  info("Compiled in debug mode.")

import
  telenim/core

export
  core
