include ActionView::Helpers::NumberHelper

class Engine
  def self.list_to_message(list)
    list = list.map do |gem|
      "<a href=\"#{gem['project_uri']}\">#{gem['name']}</a>"
    end

    list.join("\n")
  end

  def self.gems(name)
    lists = Gems.gems(name).sort_by { |g| g['downloads'] }.reverse.take(50)

    list_to_message(lists)
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
      "<a href=\"https://rubygems.org/gems/#{gem['full_name']}\">#{gem['full_name']}</a> - #{number_to_human(downloads)}"
    end

    list.join("\n")
  end

  def self.versions(name)
    versions = Gems.versions(name).take(50)

    versions = versions.map do |version|
      "<b>#{version['number']}</b> -> #{version['built_at'].to_time.to_formatted_s(:long)}"
    end

    versions.join("\n")
  end

  def self.info(name)
    info = Gems.info(name)

    "<b>name:</b> #{info['name']}\n" +
    "<b>author:</b> #{info['authors']}\n" +
    "<b>downloads:</b> #{number_to_human(info['downloads'])}\n" +
    "<b>info:</b> #{info['info']}\n" +
    "<b>version:</b> #{info['version']}\n" +
    "<b>homepage_uri:</b> #{info['homepage_uri']}\n" +
    "<b>project_uri:</b> #{info['project_uri']}\n" +
    "<b>gem_uri:</b> #{info['gem_uri']}"
  end

  def self.search(name)
    list_to_message(Gems.search(name))
  end
end