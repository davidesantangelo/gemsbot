require 'telegram/bot'

class Bot

  def self.redis
    Redis.new
  end

  def self.get_me
    client.api.get_me
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

  # updated - Returns the 50 most recently updated gems
  # latest - Returns the 50 gems most recently added to RubyGems.org
  # popular - Returns an array containing the top 50 downloaded gem versions of all time

  def self.listener(payload:)
    message = payload['message']
    chat_id = message.dig('chat', 'id')
    text = message['text']

    case text
    when '/start'
      redis.set("lcmd:#{chat_id}","/start")

      client.api.send_message(text: 'Hello', chat_id: chat_id)
    when '/stop'
      redis.set("lcmd:#{chat_id}","/stop")

      client.api.send_message(text: 'Bye', chat_id: chat_id)
    when '/latest'
      redis.set("lcmd:#{chat_id}","/latest")

      client.api.send_message(text: "*Returns the 50 gems most recently added to RubyGems.org*\n\n#{Engine.latest}", chat_id: chat_id, parse_mode: 'Markdown')
    when '/updated'
      redis.set("lcmd:#{chat_id}","/updated")

      client.api.send_message(text: "*Returns the 50 most recently updated gems*\n\n#{Engine.just_updated}", chat_id: chat_id, parse_mode: 'Markdown')
    when '/popular'
      redis.set("lcmd:#{chat_id}","/popular")

      client.api.send_message(text: "*Returns an array containing the top 50 downloaded gem versions of all time.*\n\n#{Engine.most_downloaded}", chat_id: chat_id, parse_mode: 'Markdown')
    when '/gems'
      redis.set("lcmd:#{chat_id}","/gems")

      client.api.send_message(chat_id: chat_id, text: 'type "gems:<username>" and get all gems owned by specified username')
    when '/info'
      redis.set("lcmd:#{chat_id}","/info")

      client.api.send_message(chat_id: chat_id, text: 'type "info:<name>" and get some basic information type')
    when '/search'
      redis.set("lcmd:#{chat_id}","/search")

      client.api.send_message(chat_id: chat_id, text: 'type "search:<name>" and get an array of active gems that match the query')
    else
      if text.start_with?("/")
        client.api.send_message(chat_id: chat_id, text: 'unknow command type /help')
        return
      end

      case redis.get("lcmd:#{chat_id}")
      when '/info'
        client.api.send_message(text: Engine.info(text), chat_id: chat_id, parse_mode: 'Markdown')
      when '/search'
        client.api.send_message(text: Engine.search(text), chat_id: chat_id, parse_mode: 'Markdown')
      when 'gems'
        client.api.send_message(text: Engine.gems(text), chat_id: chat_id, parse_mode: 'Markdown')
      end
    end
  end

  def self.client
    Telegram::Bot::Client.new(RubygBot::Application.credentials.telegram_bot_token)
  end
end