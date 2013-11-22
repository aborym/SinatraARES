require 'sinatra'
require 'yajl'
require 'ares_cz'

get '/' do

	content_type :json
	halt 403 unless params['token'] == "BAF"

	if params['ico'] && params['ico'].size == 8
		ares = Ares.find(ico: params['ico'])
		if ares.found?
			data = {found: ares.answer}
			code = 200
		else
		data = { error: "IC not found"} 
		code = 404
		end
	else 
		data = { error: "IC is required"} 
		code = 400
	end

	halt code, Yajl::Encoder.encode(data)

end