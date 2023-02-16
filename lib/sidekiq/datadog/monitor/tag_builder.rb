module Sidekiq
  module Datadog
    module Monitor
      class TagBuilder
        SPECIAL_SYMBOLS = /[\/\.:]/i.freeze
        def initialize(common_tags)
          @common_tags = common_tags
        end

        def build(tags_hash)
          custom_tags = tags_hash.map { |key, value| [key, value] if value.to_s != '' }.compact
          custom_tags = custom_tags.map { |key, value| "#{key}:#{normalize_value(value)}" }
          custom_tags + @common_tags
        end

        protected

        def normalize_value(value)
          value.to_s.gsub(SPECIAL_SYMBOLS, '_')
        end
      end
    end
  end
end
