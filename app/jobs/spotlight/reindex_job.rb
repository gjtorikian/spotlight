module Spotlight
  class ReindexJob < ActiveJob::Base
    queue_as :default

    def perform(exhibit_or_resources)
      resources = if exhibit_or_resources.is_a? Spotlight::Exhibit
        exhibit_or_resources.resources.find_each
      elsif exhibit_or_resources.is_a? Enumerable
        exhibit_or_resources
      else
        Array(exhibit_or_resources)
      end

      resources.each do |r|
        r.reindex
      end
    end
  end
end
