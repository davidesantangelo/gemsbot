require 'telegram/bot'

class Bot

  def self.redis
    Redis.new
  end

  def self.get_me
    client.api.get_me
  end

  def self.chats_count
    redis.keys.select { |k| k.start_with? 'bot:lcmd:'}.uniq.size
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

  # info - type gem name and get some basic information type
  # search - type gem name and get an array of active gems that match the query
  # gems - type author username and get all gems owned by specified username
  # updated - returns the 50 most recently updated gems
  # latest - returns the 50 gems most recently added to RubyGems.org
  # popular - returns an array containing the top 50 downloaded gem versions of all time
  # versions - type gem name and get an array of version details

  def self.listener(payload:)
    message = payload['message']
    chat_id = message.dig('chat', 'id')
    text = message['text']

    last_bot_command = redis.get("bot:lcmd:#{chat_id}")

    case text
    when '/start'
      redis.set("bot:lcmd:#{chat_id}","/start")

      client.api.send_message(text: 'Hello', chat_id: chat_id)
    when '/stop'
      redis.set("bot:lcmd:#{chat_id}","/stop")

      client.api.send_message(text: 'Bye', chat_id: chat_id)
    when '/latest'
      redis.set("bot:lcmd:#{chat_id}","/latest")

      client.api.send_message(text: "<b>Returns the 50 gems most recently added to RubyGems.org</b>\n\n#{Engine.latest}", chat_id: chat_id, parse_mode: 'HTML')
    when '/updated'
      redis.set("bot:lcmd:#{chat_id}","/updated")

      client.api.send_message(text: "<b>Returns the 50 most recently updated gems</b>\n\n#{Engine.just_updated}", chat_id: chat_id, parse_mode: 'HTML')
    when '/popular'
      redis.set("bot:lcmd:#{chat_id}","/popular")

      client.api.send_message(text: "<b>Returns an array containing the top 50 downloaded gem versions of all time.</b>\n\n#{Engine.most_downloaded}", chat_id: chat_id, parse_mode: 'HTML')
    when '/gems'
      redis.set("bot:lcmd:#{chat_id}","/gems")

      client.api.send_message(chat_id: chat_id, text: 'type author username and get top 50 gems owned by specified username')
    when '/info'
      redis.set("bot:lcmd:#{chat_id}","/info")

      client.api.send_message(chat_id: chat_id, text: 'type gem name and get some basic information type')
    when '/search'
      redis.set("bot:lcmd:#{chat_id}","/search")

      client.api.send_message(chat_id: chat_id, text: 'type gem name and get an array of active gems that match the query')
    when '/versions'
      redis.set("bot:lcmd:#{chat_id}","/versions")

      client.api.send_message(chat_id: chat_id, text: 'type gem name and get an array (latest 50) of version details')
    else
      if text.start_with?("/")
        client.api.send_message(chat_id: chat_id, text: 'Unrecognized command. Say what?')
        return
      end

      case last_bot_command
      when '/info'
        message = Engine.info(text) rescue 'This rubygem could not be found.'

        client.api.send_message(text: message, chat_id: chat_id, parse_mode: 'HTML', disable_web_page_preview: true)
      when '/search'
        gems = Engine.search(text)

        message = unless gems.present?
          "Your search for - *#{text}* - did not match any gems."
        else
          gems
        end

        client.api.send_message(text: message, chat_id: chat_id, parse_mode: 'HTML')
      when '/gems'
        message = Engine.gems(text) rescue 'Author not found.'

        client.api.send_message(text: message, chat_id: chat_id, parse_mode: 'HTML')
      when '/versions'
        message = Engine.versions(text) rescue 'This rubygem could not be found.'

        client.api.send_message(text: message, chat_id: chat_id, parse_mode: 'HTML')
      end
    end
  end

  def self.client
    Telegram::Bot::Client.new(RubygBot::Application.credentials.telegram_bot_token)
  end
end