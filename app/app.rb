require 'sinatra'
require 'logger'
require 'sinatra/reloader' if development?

$logger = Logger.new(STDOUT)

module Homepage
  class App < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end

    configure do
        $_notes = JSON.parse(File.read('/wrk/data/20210919_homepage_notes.json'))
        $_note_refs = {}
        $_notes.each do |n|
            $_note_refs[n['note_id']] = n
        end
    end

    get '/' do
        @notes = $_notes
        slim :index
    end

    get '/notes/:note_id' do
        raise unless /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ === params[:note_id].strip

        @note = $_note_refs[params[:note_id]]
        @content = JSON.parse(@note['content'])
        slim :notes_show
    end

    get '/ping' do
      'pong'
    end
  end
end