require 'sinatra'
require 'yajl'
require 'ares_cz'
require 'redis'
require 'uri'

ENV["REDISTOGO_URL"] = 'redis://127.0.0.1:6379' if ENV['RACK_ENV'] == 'development'

uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

get '/' do
	content_type :json
	halt 403 unless params['token'] == "BAF"

	if params['ico'] && params['ico'].size == 8
		REDIS.incr('pristupy')
		ares = Ares.find(ico: params['ico'])
		if ares.found?
			REDIS.incr('nalezeno')
			data = {found: ares.answer}
			code = 200
		else
			REDIS.incr('nenalezeno')
			data = { error: "IC not found"} 
			code = 404
		end
	else 
		data = { error: "IC is required"} 
		code = 400
	end

	halt code, Yajl::Encoder.encode(data)

end

get '/is_alive' do
	"Yeah online :D"
end

get '/stats' do
	content_type :json
	data = {
			celkem: REDIS.get('pristupy'),
			nalezeno: REDIS.get('nalezeno'),
			nenalezeno: REDIS.get('nenalezeno'),
		}
	halt 200, Yajl::Encoder.encode(data)
end