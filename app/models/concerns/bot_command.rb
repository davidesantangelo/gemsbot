module BotCommand
  extend ActiveSupport::Concern

  COMMANDS = %w(/help /start /stop /latest /updated /popular /gems /info /search /versions)

  INVALID = "/invalid"
  HELP = "/help"
  START = "/start"
  STOP = "/stop"
  LATEST = "/latest"
  UPDATED = "/updated"
  POPULAR = "/popular"
  GEMS = "/gems"
  INFO = "/info"
  SEARCH = "/search"
  VERSIONS = "/versions"

end