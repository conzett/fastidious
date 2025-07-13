# frozen_string_literal: true

module Fastidious
  module LocationAware
    extend ActiveSupport::Concern

    def head(status, options = nil)
      options = transform_location_args(**(options || {}))
      super(options[:status] || status, **options)
    end

    def render(*args, **kwargs)
      options = transform_location_args(**kwargs)
      super(*args, **options)
    end

    private

    def transform_location_args(**options)
      return options unless options.key? :location

      # NOTE: Logic reference;
      # https://developer.mozilla.org/docs/Web/HTTP/Reference/Headers/Location

      # TODO: Handle all status types (string, number, etc.)?

      if request.format.html?
        options[:status] = :see_other
        options[:body] = nil
      elsif options[:status] != :created
        options.delete :location
      end

      options
    end
  end
end
