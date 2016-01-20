# coding: utf-8

set :nurseries, Implementation[:nurseries]
set :post_schema, 					JSON.parse(File.read("lib/schemas/nurseries_post.schema"))
set :patch_set_bucket_schema, 		JSON.parse(File.read("lib/schemas/nurseries_patch_set_bucket.schema"))
set :patch_remove_bucket_schema, 	JSON.parse(File.read("lib/schemas/nurseries_patch_remove_bucket.schema"))
set :patch_set_mesurement_schema, 	JSON.parse(File.read("lib/schemas/nurseries_patch_set_mesurement.schema"))

namespace '/nurseries' do
 
	get '/?' do
		content_type :json
		status 200
		settings.nurseries.get_all.to_json
	end

	get '/:name' do |name|
		content_type :json
		begin
			status 200
			settings.nurseries.get(name).to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		end
	end

	post '/?' do
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			JSON::Validator.validate!(settings.post_schema, body)
			id = settings.nurseries.create(body)
			
			status 200
			{ :_id => id }.to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		rescue JSON::Schema::ValidationError => e
			status 400
			{ :error => e.message }.to_json
		end
	end

	patch '/:name' do |name|
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			JSON::Validator.validate!(settings.patch_schema, body)

			case body["op"].upcase			
			when "SET_BUCKET"
				JSON::Validator.validate!(settings.patch_set_bucket_schema, body)
				id = settings.nurseries.set_bucket(name, body["value"]["position"], body["value"]["plant_id"])
		    when "REMOVE_BUCKET"
				JSON::Validator.validate!(settings.patch_remove_bucket_schema, body)
				id = settings.nurseries.remove_bucket(name, body["value"]["position"])
		    when "SET_MESUREMENT"
				JSON::Validator.validate!(settings.patch_set_mesurement_schema, body)
				id = settings.nurseries.set_mesurement(name, body["value"])
			end			
			status 200
			{ :_id => id }.to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		rescue JSON::Schema::ValidationError => e
			status 400
			{ :error => e.message }.to_json			
		end
	end

	delete '/:name' do |name|
		content_type :json
		begin
			id = settings.nurseries.delete(name).to_json

			status 200
			{ :_id => id }.to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		end		
	end
end