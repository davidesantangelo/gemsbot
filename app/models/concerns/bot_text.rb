module BotText
  extend ActiveSupport::Concern

  HELP =
    "I can help you manage rubygems.\n\n" +
    "You can control me by sending these commands:\n\n" +

    "/info - type gem name and get some basic information type\n" +
    "/search - type gem name and get an array of active gems that match the query\n" +
    "/gems - type author username and get top 50 gems owned by specified username\n" +
    "/updated - returns the 50 most recently updated gems\n" +
    "/latest - returns the 50 gems most recently added to RubyGems.org\n" +
    "/popular - returns an array containing the top 50 downloaded gem versions of all time\n" +
    "/versions - type gem name and get an array (latest 50) of version details" + 

    "\n\n\nCreated by https://twitter.com/daviducolo" +
    "\nBMC at https://www.buymeacoffee.com/582rhJH"

  START = "RubyGems.org is the Ruby community’s gem hosting service. This Bot help you to manage API friendly :). Type '/help' and enjoy!!"

  STOP = "/stop"
  LATEST = "<b>Returns the 50 gems most recently added to RubyGems.org</b>\n\n#{Engine.latest}"
  UPDATED = "<b>Returns the 50 most recently updated gems</b>\n\n#{Engine.just_updated}"
  POPULAR = "<b>Returns an array containing the top 50 downloaded gem versions of all time.</b>\n\n#{Engine.most_downloaded}"
  GEMS = "type author username and get top 50 gems owned by specified username"
  INFO = "type gem name and get some basic information type"
  SEARCH = "type gem name and get an array of active gems that match the query"
  VERSIONS = "type gem name and get an array (latest 50) of version details"

end