# frozen_string_literal: true

module HubSpotMock
  class HubSpotTable
    def initialize(table_name_singular, table_name_plural, base, options = {})
      @table_name = table_name_singular
      @table_name_plural = table_name_plural
      @base = base
      @linked_tables_options = options.fetch(:linked_tables, [])
      @lookup_fields_options = options.fetch(:lookup_fields, [])
    end

    attr_accessor :base, :linked_tables_options, :lookup_fields_options, :table_name, :table_name_plural

    def records
      @records ||= {}
    end

    def generate_random_id
      HubSpotStore.increase_current_rec_id
      'rec%x' % HubSpotStore.current_rec_id
    end

    def create_record(properties)
      id = generate_random_id
      records[id] = properties
      id
    end

    def fetch_records(record_ids, properties = [])
      record_ids.map do |record_id|
        fetch_record(record_id, properties)
      end
    end

    def fetch_record(record_id, properties = [])
      values = records.fetch(record_id)
      filter_properties(values, properties)
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

    def iterate(batch_size: 0, filter_by_formula: nil, max_records: 0)
      raise NotImplementedError, 'batch_size ignored in MockHubspotClient.iterate' if batch_size != 0

      items = records
      filter_by_formula&.each do |filter_group|
        filter_group['filters'].each do |filter|
          property_name = filter['propertyName']
          operator = filter['operator']
          value = filter['value']
          raise NotImplementedError, 'not implemented operator' if operator.downcase != 'eq'

          items =
            items.select do |_record_id, values|
              # TODO: add different operators
              values[property_name] == value
            end
        end
      end
      items = items.take(max_records) if max_records != 0
      items
    end

    def create_association(table_name1, record1_id, table_name2, record2_id, association_type)
      create_record({ table1: table_name1, table2: table_name2, record1_id: record1_id, record2_id: record2_id,
                      association_type: })
    end

    def search_associations(table_name1, record1_id, table_name2, _association_type)
      associates_records = []
      records.each_value do |values|
        if values[:table1] == table_name1 && values[:table2] == table_name2 && values[:record1_id] == record1_id
          associates_records.push({ table: table_name2, record_id: values[:record2_id] })
        end
        if values[:table1] == table_name2 && values[:table2] == table_name1 && values[:record2_id] == record1_id
          associates_records.push({ table: table_name1, record_id: values[:record1_id],
                                    association_type: values[:association_type] })
        end
      end
      associates_records
    end

    def update_record(record_id, data)
      records[record_id].update(data)
    end

    def delete_record(record_id)
      records.delete(record_id)
    end
  end
end
