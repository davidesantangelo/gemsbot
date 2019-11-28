require 'telegram/bot'

class Bot
  include BotCommand
  include BotText

  REDIS_KEY_LCMD_PREFIX = '#{REDIS_KEY_LCMD_PREFIX}'

  def self.redis
    Redis.new
  end

  def self.get_me
    client.api.get_me
  end

  def self.chats_count
    redis.keys.select { |k| k.start_with? REDIS_KEY_LCMD_PREFIX}.uniq.size
  end

  # chats

  def self.get_chat(chat_id:)
    Hashie::Mash.new(client.api.get_chat(chat_id: chat_id))
  end

  def self.get_chat_member(chat_id:, user_id:)
    Hashie::Mash.new(client.api.get_chat_member(chat_id: chat_id, user_id: user_id))
  end

  def self.get_chat_administrators(chat_id:)
    Hashie::Mash.new(client.api.get_chat_administrators(chat_id: chat_id))
  end 

  # updates

  def self.get_webhook_info
    client.api.get_webhook_info
  end

  def self.set_webhook(url:)
    client.api.set_webhook(url: url)
  end

  def self.delete_webhook
    client.api.delete_webhook
  end

  def self.get_updates(offset: 0, limit: 100)
    client.api.get_updates(offset: offset, limit: limit)
  rescue Telegram::Bot::Exceptions::ResponseError
    {}
  end

  # messages

  def self.send_message(command: nil, attrs: {})
    redis.set("#{REDIS_KEY_LCMD_PREFIX}#{attrs[:chat_id]}", command) if command
    client.api.send_message(attrs)
  end

  # info - type gem name and get some basic information type
  # search - type gem name and get an array of active gems that match the query
  # gems - type author username and get top 50 gems owned by specified username
  # updated - returns the 50 most recently updated gems
  # latest - returns the 50 gems most recently added to RubyGems.org
  # popular - returns an array containing the top 50 downloaded gem versions of all time
  # versions - type gem name and get an array (latest 50) of version details

  def self.listener(payload:)
    message = payload['message']
    chat_id = message.dig('chat', 'id')
    text = message['text']

    last_bot_command = redis.get("#{REDIS_KEY_LCMD_PREFIX}#{chat_id}")

    unless BotCommand::COMMANDS.include?(text)
      send_message(command: BotCommand::INVALID, attrs: { chat_id: chat_id, text: 'Unrecognized command. Say what?' })
      return
    end 

    case text
    when BotCommand::START
      send_message(command: BotCommand::START, attrs: { text: BotText::START, chat_id: chat_id })
    when BotCommand::HELP
      send_message(command: BotCommand::HELP, attrs: { text: BotText::HELP, chat_id: chat_id })
    when BotCommand::LATEST
      send_message(command: BotCommand::LATEST, attrs: { text: BotText::LATEST, chat_id: chat_id, parse_mode: 'HTML' })
    when BotCommand::UPDATED
      send_message(command: BotCommand::UPDATED, attrs: { text: BotText::UPDATED, chat_id: chat_id, parse_mode: 'HTML' })
    when BotCommand::POPULAR
      send_message(command: BotCommand::POPULAR, attrs: { text: BotText::POPULAR, chat_id: chat_id, parse_mode: 'HTML' })
    when BotCommand::GEMS
      send_message(command: BotCommand::GEMS, attrs: { text: BotText::GEMS, chat_id: chat_id })
    when BotCommand::INFO
      send_message(command: BotCommand::INFO, attrs: { text: BotText::INFO, chat_id: chat_id })
    when BotCommand::SEARCH
      send_message(command: BotCommand::SEARCH, attrs: { text: BotText::SEARCH, chat_id: chat_id })
    when BotCommand::VERSIONS
      send_message(command: BotCommand::VERSIONS, attrs: { text: BotText::VERSIONS, chat_id: chat_id })
    else
      case last_bot_command
      when BotCommand::INFO
        message = Engine.info(text) rescue 'This rubygem could not be found.'

        send_message(attrs: { text: message, chat_id: chat_id, disable_web_page_preview: true, parse_mode: 'HTML' } ) 
      when BotCommand::SEARCH
        gems = Engine.search(text)

        message = unless gems.present?
          "Your search for - *#{text}* - did not match any gems."
        else
          gems
        end

        send_message(attrs: { text: message, chat_id: chat_id, parse_mode: 'HTML' } ) 
      when BotCommand::GEMS
        message = Engine.gems(text) rescue 'Author not found.'

        send_message(attrs: { text: message, chat_id: chat_id, parse_mode: 'HTML' } )
      when BotCommand::VERSIONS
        message = Engine.versions(text) rescue 'This rubygem could not be found.'

        send_message(attrs: { text: message, chat_id: chat_id, parse_mode: 'HTML' } )
      end
    end
  end

  def self.client
    Telegram::Bot::Client.new(RubygBot::Application.credentials.telegram_bot_token)
  end
end