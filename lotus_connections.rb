require 'httparty'
require 'hpricot'

class LotusConnections
  include HTTParty
  base_uri 'https://connections.example.com/profiles/atom'
  basic_auth 'username', ENV['PW']

  def self.find_by_name(name)
    find_by(:name, name)
  end

  def self.find_by_email(email)
    find_by(:email, email)
  end

  def self.find_by_name_or_email(query)
    (find_by_name(query) + find_by_email(query)).uniq
  end

  private
  def self.find_by(param, query)
    raise ArgumentError, "ENV['PW'] not set" if ENV['PW'].blank?

    doc = Hpricot.XML(get('/search.do', :query => {param => "#{query}"}))
    results = []
    doc.search("//entry").each do |entry|
      result ||= %Q{#{entry.search("//title[@type='text']").inner_html} - }
      result << %Q{#{entry.search("//a[@class='email']").inner_html.downcase} }
      unless entry.search("//div[@class='tel']/span").inner_html.blank?
        result << %Q{#{entry.search("//div[@class='tel']/abbr").inner_html}}
        result << %Q{#{entry.search("//div[@class='tel']/span").inner_html}}
      end
      results << result
    end
    results.uniq
  end
end
