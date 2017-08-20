#!/usr/bin/env ruby
# coding: utf-8
# antoinefromafar_bot: un bot inline Telegram pour utiliser la voix de synthèse "AntoineFromAfar" de acapela
# Écrit en Ruby par Siphonay
# Pas de license appliquée

# Chargement des gemmes et bibliothèques nécessaires pour communiquer avec l'API de bots Telegram, envoyer des requêtes HTTP et gérer les cookies
require 'telegram/bot'
require 'net/http'
require 'http-cookie'

# Quitter le script si les arguments nécessaires ne sont pas présents
abort "usage: #{$PROGRAM_NAME} telegram_token cookie_file" unless ARGV.length == 2

# Boucle pour empêcher le programme de crasher si l'API de Telegram ne répond pas
begin
  # Initialisation du bot
  Telegram::Bot::Client.run(ARGV[0]) do |antoine_bot|
    # Traitement de chaque message reçu
    antoine_bot.listen do |message|
      case message

      # Si un message est reçu, répondre pour notifier à l'utilisateur que le bot s'utilise uniquement en mode inline
      when Telegram::Bot::Types::Message
        antoine_bot.api.send_message(chat_id: message.chat.id,
                                     text: "Ce bot s'utilise en mode \"inline\", mentionnez le dans une conversation pour l'utiliser.")

      # Traiter chaque query inline reçue
      when Telegram::Bot::Types::InlineQuery
        if message.query.size == 0              # Si une query vide est reçue, (directement après la mention du bot, per exemple)
          acapela_inline_query = "message vide" # mettre un message de remplacement pour empêcher le crash.
        else                                    # Sinon,
          acapela_inline_query = message.query  # utiliser la query pour la transformer en message vocal.
        end

        # Initialiser les cookies pour acapela si le fichier de cookies spécifié dans les arguments existe (fait a chaque query pour pouvoir update les cookies si le fichier a été mis à jour)
        acapela_cookies = HTTP::CookieJar.new
        acapela_cookies.load(ARGV[1], :cookiestxt) if File.exist?(ARGV[1])
        # Initialisation de l'URL de requête ainsi que ses paramètres
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
        # Utiliser les cookies pour la requête
        acapela_request['Cookie'] = HTTP::Cookie.cookie_value(acapela_cookies.cookies(acapela_uri))

        # Envoi de la requête
        acapela_response = Net::HTTP.start(acapela_uri.hostname, acapela_uri.port) do |http|
          http.request acapela_request
        end

        # Extraction de l'URL du fichier audio de la synthèse vocale dans le corps de la réponse reçue
        acapela_voice_url = acapela_response.body.scan(/http.*?mp3/).join
        # Construction de la réponse de la query inline en assignant la fichier audio reçu au premier et seul résultat
        result =
          [
            ["voice",
             "1",
             acapela_voice_url,
             "AntoineFromAfar dit:"]
          ].map do |arr|
          Telegram::Bot::Types::InlineQueryResultVoice.new(id: arr[1],
                                                           voice_url: arr[2],
                                                           title: arr[3])
        end

        # Envoi de la réponse de la query inline
        antoine_bot.api.answer_inline_query(inline_query_id: message.id,
                                            results: result)
      end
    end
  end
rescue => error
  # Gestion des erreurs
  STDERR.puts "got error: #{error}"     # Écrire l'erreur sur la sortie d'erreur
  retry                                 # Relancer le script
end
