
require 'json'
require 'net/http'

class JSONRPCServer
	def initialize ()
		@registered_methods = Hash.new()
	end

	def register (name, method)
		@registered_methods[name] = method
	end

	def handle_request (params_string)
		params = JSON.parse(params_string)
		begin
			return {"result" => @registered_methods[params["method"]].call(*params["params"]),
							"error" => nil,
							"id" => params["id"]}.to_json;
		rescue
			return {"result" => nil,
							"error" => $!,
							"id" => params["id"]}.to_json;
		end
	end
end

#CAUTION! responds_to does *NOT* work on a json-rpc-client.
class JSONRPCClient
  def initialize (host, port, path="/")
    @host, @port, @path = host, port, path
  end

  def method_missing (method, *params, &block)
    rq = Net::HTTP.new(@host, @port)
    data = {"method" => method, "params" => params, "id" => "foo"}.to_json
    res = JSON.parse rq.post(@path, data).body
    raise Exception.new(res["error"]) if res["error"]
    return res["result"]
  end
end
