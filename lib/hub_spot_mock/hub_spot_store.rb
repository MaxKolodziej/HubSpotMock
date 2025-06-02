# frozen_string_literal: true

module HubSpotMock
  class HubSpotStore
    @rec_nr = 0

    def self.bases
      @bases ||= {}
    end

    def self.clear
      bases.clear
    end

    def self.current_rec_id
      @rec_nr
    end

    def self.increase_current_rec_id
      @rec_nr += 1
    end
  end
end
