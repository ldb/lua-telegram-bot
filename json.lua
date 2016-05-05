
local JSON = require("JSON")
-- JSON Error handlers
function JSON:onDecodeError(message, text, location, etc)
  if text then
    if location then
      message = string.format("%s at char %d of: %s", message, location, text)
    else
      message = string.format("%s: %s", message, text)
    end
  end
  print((os.date("%x %X")), "Error while decoding JSON:\n", message)
end

function JSON:onDecodeOfHTMLError(message, text, _nil, etc)
  if text then
    if location then
      message = string.format("%s at char %d of: %s", message, location, text)
    else
      message = string.format("%s: %s", message, text)
    end
  end
  print((os.date("%x %X")), "Error while decoding JSON [HTML]:\n", message)
end

function JSON:onDecodeOfNilError(message, _nil, _nil, etc)
  if text then
    if location then
      message = string.format("%s at char %d of: %s", message, location, text)
    else
      message = string.format("%s: %s", message, text)
    end
  end
  print((os.date("%x %X")), "Error while decoding JSON [nil]:\n", message)
end

function JSON:onEncodeError(message, etc)
  print((os.date("%x %X")), "Error while encoding JSON:\n", message)
end
return JSON
