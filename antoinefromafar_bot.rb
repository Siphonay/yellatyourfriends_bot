#!/usr/bin/env ruby

require 'telegram/bot'
require 'net/http'
require 'http-cookie'

abort "usage: #{$PROGRAM_NAME} telegram_token cookie_file" unless ARGV.length == 2

acapela_cookies = HTTP::CookieJar.new
acapela_cookies.load(ARGV[1], :cookiestxt) if File.exist?(ARGV[1])

begin
  Telegram::Bot::Client.run(ARGV[0]) do |antoine_bot|
    antoine_bot.listen do |message|
      case message
      when Telegram::Bot::Types::Message
        antoine_bot.api.send_message(chat_id: message.chat.id,
                             text: "Ce bot s'utilise en mode \"inline\", mentionnez le dans une conversation pour l'utiliser.")
      when Telegram::Bot::Types::InlineQuery
        puts "START DEBUG"
        acapela_cookies.each { |cookie| puts cookie }
        puts "END DEBUG"
        if message.query.size == 0
          acapela_inline_query = " "
        else
          acapela_inline_query = message.query
        end
        acapela_uri = URI.parse("http://www.acapela-group.com/demo-tts/DemoHTML5Form_V2.php")
        
        acapela_request = Net::HTTP::Post.new acapela_uri
        acapela_request.form_data =
          {
            "MyLanguages" => "sonid10",
            "MySelectedVoice" => "AntoineFromAfar",
            "MyTextForTTS" => acapela_inline_query,
            "t" => "1",
            "SendToVaaS" => "",
          }
        acapela_request['Cookie'] = HTTP::Cookie.cookie_value(acapela_cookies.cookies(acapela_uri))
        
        acapela_response = Net::HTTP.start(acapela_uri.hostname, acapela_uri.port) do |http|
          http.request acapela_request
        end
        acapela_voice_url = acapela_response.body.scan(/http.*?mp3/).join
        result = [
          ["voice",
           "1",
           acapela_voice_url,
          "AntoineFromAfar dit:"]
        ].map do |arr|
          Telegram::Bot::Types::InlineQueryResultVoice.new(
            id: arr[1],
            voice_url: arr[2],
            title: arr[3])
        end
        antoine_bot.api.answer_inline_query(inline_query_id: message.id,
                                            results: result)
      end
    end
  end
rescue => error
  STDERR.puts "got error: #{error}"
end
