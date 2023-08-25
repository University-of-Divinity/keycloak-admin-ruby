module KeycloakAdmin
  class RoleClient < Client
    def initialize(configuration, realm_client)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
    end

    def list
      response = execute_http do
        RestClient::Resource.new(roles_url, @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| RoleRepresentation.from_hash(role_as_hash) }
    end
    
    def get(name)
      response = execute_http do
        RestClient::Resource.new(role_name_url(name), @configuration.rest_client_options).get(headers)
      end
      RoleRepresentation.from_hash JSON.parse(response)
    end

    def users(role_name, first=0, max=100)
      url = "#{role_name_url(role_name)}/users"
      query = {first: first.try(:to_i), max: max.try(:to_i)}.compact
      unless query.empty?
        query_string = query.to_a.map { |e| "#{e[0]}=#{e[1]}" }.join("&")
        url = "#{url}?#{query_string}"
      end
      response = execute_http do
        RestClient::Resource.new(url, @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |user_as_hash| UserRepresentation.from_hash(user_as_hash) }
    end
  
    def save(role_representation)
      execute_http do
        RestClient::Resource.new(roles_url, @configuration.rest_client_options).post(
          create_payload(role_representation), headers
        )
      end
    end

    def roles_url(id=nil)
      if id
        "#{@realm_client.realm_admin_url}/roles/#{id}"
      else
        "#{@realm_client.realm_admin_url}/roles"
      end
    end
    
    def role_name_url(name)
      "#{@realm_client.realm_admin_url}/roles/#{name}"
    end
    
  end
end
