# frozen_string_literal: true

module HubSpotMock
  class RequestMockBase
    HUBSPOT_API_URL = 'https://api.hubapi.com:443'
    HUBSPOT_DOMAIN = 'api.hubapi.com'

    def uri
      raise NotImplementedError
    end

    def template
      Addressable::Template.new(uri)
    end

    def stub
      raise NotImplementedError
    end

    def check_if_table_was_created(base_key, table_name)
      HubSpotStore.bases.fetch(base_key).fetch_table(table_name)
    rescue KeyError => _e
      raise NotImplementedError, "This table: #{table_name} was not found, please add it to create_mocked_tables method"
    end

    def extract_base(_request)
      # TODO: take this from request.headers['Authorization']
      'default'
    end
  end
end
