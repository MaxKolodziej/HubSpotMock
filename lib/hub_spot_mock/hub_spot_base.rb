# frozen_string_literal: true

module HubSpotMock
  class HubSpotBase
    attr_reader :base_id

    def initialize(base_id: nil, api_key: nil)
      @base_id = base_id
      @api_key = api_key
    end

    def tables
      @tables ||= {}
    end

    def table_exists?(table_name)
      tables.key?(table_name)
    end

    def fetch_table(table_name)
      table = tables[table_name]
      table ||= tables.detect do |_name, table|
        table.table_name == table_name || table.table_name_plural == table_name
      end&.[](1)
      unless table
        raise NotImplementedError,
              "before accessing a table it should be created: #{table_name}, please add it to create_mocked_tables method"
      end

      table
    end

    def create_table(table_name_singular, table_name_plural, options = {})
      table = HubSpotTable.new(table_name_singular, table_name_plural, self, options)
      tables[table_name_singular] = table
    end

    def create_response_for_collection(records, properties)
      {
        headers: {},
        body: {
          results: records.map do |record_id, values|
            { id: record_id, properties: fetch_properties(values, properties) }
          end
        }.to_json
      }
    end

    def filter_properties(values, properties = [])
      if properties.any?
        Hash.new(
          values.select { |key, _| properties.include?(key) }
        )
      else
        values
      end
    end
  end
end
