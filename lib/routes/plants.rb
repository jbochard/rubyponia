# coding: utf-8

set :hydroponicSerivces, Implementation[:hydroponic]
set :plant_post_schema, 							JSON.parse(File.read("lib/schemas/plant_post.schema"))
set :plant_patch_add_mesurement_schema, 			JSON.parse(File.read("lib/schemas/plants_patch_add_mesurement.schema"))
set :plant_patch_remove_plant_from_bucket_schema, 	JSON.parse(File.read("lib/schemas/plant_patch_remove_plant_from_bucket.schema"))

namespace '/plants' do
 
	get '/?' do
		content_type :json
		status 200
		settings.hydroponicSerivces.get_all_plants.to_json
	end

	get '/:plant_id' do |plant_id|
		content_type :json
		begin
			status 200
			settings.hydroponicSerivces.get_plant(plant_id).to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		end
	end

	post '/?' do
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			JSON::Validator.validate!(settings.plant_post_schema, body)

			id = settings.hydroponicSerivces.create_plant(body)
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

	patch '/:plant_id' do |plant_id|
		content_type :json
		begin
			body = JSON.parse(request.body.read)
			case body["op"].upcase			
		    when "REMOVE_PLANT_FROM_BUCKET"
				JSON::Validator.validate!(settings.plant_patch_remove_plant_from_bucket_schema, body)
				id = settings.hydroponicSerivces.remove_plant_from_bucket(plant_id)
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

	delete '/:plant_id' do |plant_id|
		content_type :json
		begin
			id = settings.hydroponicSerivces.delete_plant(plant_id)
			status 200
			{ :_id => id }.to_json
		rescue AbstractApplicationExcpetion => e
			status e.code
			{ :error => e.message }.to_json
		end		
	end
end