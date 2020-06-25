import
  json,
  uri

proc encode*(json: JsonNode): string =
  for key, value in json.pairs():
    if value.kind != JString:
      result &= encodeUrl(key) & encodeUrl($value)
    else:
      result &= encodeUrl(key) & encodeUrl(value.getStr())
  if result != "":
    result = result[0..^2]
