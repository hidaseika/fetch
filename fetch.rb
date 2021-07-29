#!/usr/bin/env ruby

require 'optparse'
require 'net/http'
require 'oga'

def fetch
  params = {}

  opt = OptionParser.new
  opt.on('--metadata', 'show metadata about fetched site') { |v| v }

  args = opt.parse!(ARGV, into: params)
  args.each do |arg|
    uri = URI(arg).is_a?(URI::HTTP) ? URI(arg) : URI("http://#{arg}")
    response = Net::HTTP.get_response(uri)

    File.open("#{uri.host}.html", 'w') { |f| f.write(response.body) }

    site = Site.new(
      site: uri.host,
      html: response.body,
      last_fetch: Time.now
    )

    site.print_metadata if params[:metadata]
  rescue StandardError
    puts "Failed to fetch '#{arg}'. [message: #{$!}]"
  end
end

class Site
  def initialize(site:, html:, last_fetch:)
    @site = site
    @html = html
    @last_fetch = last_fetch
  end

  def print_metadata
    doc = Oga.parse_html(@html)

    num_links = doc.xpath('//a').length
    images = doc.xpath('//img').length

    puts <<~EOS
      site: #{@site}
      num_link: #{num_links}
      images: #{images}
      last_fetch: #{@last_fetch}

    EOS
  end
end
