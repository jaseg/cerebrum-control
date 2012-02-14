
require 'json'

class JSONRPCInterface
	def initialize ()
		@registered_methods = Hash.new()
	end

	def register (name, method)
		@registered_methods[name] = method
	end

	def handle_request (params_string)
		params = JSON.parse(params_string)
		begin
			return {"result" => @registered_methods[params["method"]].call (params["params"])
							"error" => nil,
							"id" => params["id"]};
		rescue
			return {"result" => nil,
							"error" => $!,
							"id" => params["id"]};
		end
	end
end
