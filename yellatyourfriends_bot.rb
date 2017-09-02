#!/usr/bin/env ruby
# coding: utf-8
# yellatyourfriends_bot: an inline Telegram bot to use the "WillFromAfar" voice from acapela
# Written in Ruby by Siphonay
# No license applied

# Loading required gems and libraries to communicate with the Telegram bot API, send HTTP requests and manage cookies
require 'telegram/bot'
require 'net/http'
require 'http-cookie'

# Exit the script if the required arguments are not present
abort "usage: #{$PROGRAM_NAME} telegram_token cookie_file" unless ARGV.length == 2

# Loop to prevent the program from crashing if the Telegram API isn't responsive
begin
  # Initializing bot
  Telegram::Bot::Client.run(ARGV[0]) do |yell_bot|
    # Processing every message recieved
    yell_bot.listen do |message|
      case message

      # If a message is recieved, answer to notify the user that the bot is only used in inline mode
      when Telegram::Bot::Types::Message
        yell_bot.api.send_message(chat_id: message.chat.id,
                                     text: "This bot is exclusively used in \"inline\" mode, mention it in a conversation to use it.")

      # Process every recieved inline query
      when Telegram::Bot::Types::InlineQuery
        if message.query.size == 0                      # If an empty query is recieved (p.e. directly after the bot is mentionned),
          acapela_inline_query = "empty message"        # put a placeholder message to prevent crashes.
        else                                            # Else,
          acapela_inline_query = message.query          # use the query to turn it into a voice message.
        end

        # Initialize acapela cookies if the cookies file specified in the arguments exists (done at every query to be able to update the cookies if the file has changed)
        acapela_cookies = HTTP::CookieJar.new
        acapela_cookies.load(ARGV[1], :cookiestxt) if File.exist?(ARGV[1])
        # Initializing the request's URL and its parameters
        acapela_uri = URI.parse("http://www.acapela-group.com/demo-tts/DemoHTML5Form_V2.php")
        acapela_request = Net::HTTP::Post.new acapela_uri
        acapela_request.form_data =
          {
            "MyLanguages" => "sonid10",
            "MySelectedVoice" => "WillFromAfar",
            "MyTextForTTS" => acapela_inline_query,
            "t" => "1",
            "SendToVaaS" => "",
          }
        # Use the cookies for the request
        acapela_request['Cookie'] = HTTP::Cookie.cookie_value(acapela_cookies.cookies(acapela_uri))

        # Sending the request
        acapela_response = Net::HTTP.start(acapela_uri.hostname, acapela_uri.port) do |http|
          http.request acapela_request
        end

        # Extracting the audio file URL from the response body
        acapela_voice_url = acapela_response.body.scan(/http.*?mp3/).join
        # Building the answer of the inline query by assigning the audio file URL to the first and only result
        result =
          [
            ["voice",
             "1",
             acapela_voice_url,
             "your message:"]
          ].map do |arr|
          Telegram::Bot::Types::InlineQueryResultVoice.new(id: arr[1],
                                                           voice_url: arr[2],
                                                           title: arr[3])
        end

        # Sending the inline query response
        yell_bot.api.answer_inline_query(inline_query_id: message.id,
                                            results: result)
      end
    end
  end
rescue => error
  # Error management
  STDERR.puts "got error: #{error}"     # Write the error on the error output
  retry                                 # Launch the script again
end
