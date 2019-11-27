include ActionView::Helpers::NumberHelper

class Engine
  def self.list_to_message(list)
    list = list.map do |gem|
      "[#{gem['name']}](#{gem['project_uri']})"
    end

    list.join("\n")
  end

  def self.gems(name)
    list_to_message(Gems.gems(name))
  end

  def self.latest
    list_to_message(Gems.latest)
  end

  def self.just_updated
    list_to_message(Gems.just_updated)
  end

  def self.most_downloaded
    gems = Gems.most_downloaded

    list = gems.map do |gem, downloads|
      "[#{gem['full_name']}](https://rubygems.org/gems/#{gem['full_name']}) - #{number_to_human(downloads)}"
    end

    list.join("\n")
  end

  def self.info(name)
    info = Gems.info(name)

    "*name:* #{info['name']}\n*author:* #{info['authors']}\n*downloads:* #{info['downloads']}\n*info:* #{info['info']}"
  end

  def self.search(name)
    list_to_message(Gems.search(name))
  end
end