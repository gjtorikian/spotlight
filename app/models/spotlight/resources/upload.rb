# encoding: utf-8
module Spotlight
  class Resources::Upload < Spotlight::Resource
    mount_uploader :url, Spotlight::ItemUploader
    include Spotlight::ImageDerivatives
    
    # we want to do this before reindexing
    after_create :update_document_sidecar

    def self.fields(exhibit)
      @fields ||= {}
      @fields[exhibit] ||= [Spotlight::Engine.config.upload_title_field || OpenStruct.new(field_name: exhibit.blacklight_config.index.title_field)] + Spotlight::Engine.config.upload_fields
    end

    def configured_fields
      self.class.fields(exhibit)
    end

    def to_solr
      store_url! # so that #url doesn't return the tmp directory

      solr_hash = super
      
      add_default_solr_fields solr_hash

      add_image_dimensions solr_hash

      add_file_versions solr_hash

      add_sidecar_fields solr_hash

      solr_hash
    end

    private

    
    def add_default_solr_fields solr_hash
      solr_hash[exhibit.blacklight_config.document_model.unique_key.to_sym] = compound_id
    end

    def add_image_dimensions solr_hash
      dimensions = ::MiniMagick::Image.open(url.file.file)[:dimensions]
      solr_hash[:spotlight_full_image_width_ssm] = dimensions.first
      solr_hash[:spotlight_full_image_height_ssm] = dimensions.last
    end

    def add_file_versions solr_hash
      spotlight_image_derivatives.each do |config|
        if config[:version]
          solr_hash[config[:field]] = url.send(config[:version]).url
        else
          solr_hash[config[:field]] = url.url
        end
      end
    end

    def add_sidecar_fields solr_hash
      solr_hash.merge! sidecar.to_solr
    end

    def compound_id
      "#{exhibit_id}-#{id}"
    end
    
    def update_document_sidecar
      sidecar_updates = data.slice(*exhibit.custom_fields.map(&:field).map(&:to_s)).select { |k,v| v.present? }

      sidecar_updates["configured_fields"] = data.slice(*configured_fields.map(&:field_name).map(&:to_s)).select { |k,v| v.present? }

      sidecar.update(data: sidecar.data.merge(sidecar_updates))

      sidecar.save
    end

    def sidecar
      @sidecar ||= document_model.new(id: compound_id).sidecar(exhibit)
    end

  end
end
