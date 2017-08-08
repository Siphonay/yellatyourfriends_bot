#!/usr/bin/env ruby

require 'telegram/bot'
require 'net/http'
require 'http-cookie'

abort "usage: #{$PROGRAM_NAME} telegram_token cookie_file" unless ARGV.length == 2

def get_acapela_tts str
  acapela_uri = URI.parse("http://www.acapela-group.com/demo-tts/DemoHTML5Form_V2.php")
  acapela_cookies = HTTP::CookieJar.new
  acapela_cookies.load(ARGV[1], :cookiestxt) if File.exist?(ARGV[1])
  
  acapela_request = Net::HTTP::Post.new acapela_uri
  acapela_request.form_data =
    {
      "MyLanguages" => "sonid10",
      "MySelectedVoice" => "AntoineFromAfar",
      "MyTextForTTS" => str,
      "t" => "1",
      "SendToVaaS" => "",
    }
  acapela_request['Cookie'] = HTTP::Cookie.cookie_value(acapela_cookies.cookies(acapela_uri))
  
  acapela_response = Net::HTTP.start(acapela_uri.hostname, acapela_uri.port) do |http|
    http.request acapela_request
  end

  return acapela_response.body.scan(/http.*?mp3/)
end

#begin
  Telegram::Bot::Client.run(ARGV[0]) do |antoine_bot|
    antoine_bot.listen do |message|
      case message
      when Telegram::Bot::Types::Message
        antoine_bot.api.send_message(chat_id: message.chat.id,
                             text: "Ce bot s'utilise en mode \"inline\", mentionnez le dans une conversation pour l'utiliser.")
      when Telegram::Bot::Types::InlineQuery
        result = [ Telegram::Bot::Types::InlineQueryResultVoice.new(
          #"voice",
          #1,
          get_acapela_tts(message.query)#,
          #"AntoineFromAfar dit:")
                   )]
        antoine_bot.api.answer_inline_query(inline_query_id: message.id, results: result)
      end
    end
  end
#rescue => error
#  STDERR.puts "got error: #{error}"
#end
