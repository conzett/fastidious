# frozen_string_literal: true

module Fastidious
  module Autoflash
    extend ActiveSupport::Concern

    ACTIONS = %w[create update destroy].freeze
    FLASHES = %i[alert flash notice].freeze
    SUCCESS = :".success"
    FAILURE = :".failure"

    # TODO: There might be other render methods that we're missing?
    # TODO: Need `head` method accounted for, extract common code

    def head(status, options = nil)
      assign_flash status
      super
    end

    def render(action = nil, **options, &)
      assign_flash options[:status]
      super
    end

    def redirect_back(*, **options)
      super(*, **(assign_redirect_options options))
    end

    def redirect_back_or_to(*, **options)
      super(*, **(assign_redirect_options options))
    end

    def redirect_to(options = {}, response_options = {})
      super(options, assign_redirect_options(response_options))
    end

    private

    def assign_flash(status)
      return unless ACTIONS.include?(action_name)

      case Rack::Utils.status_code status
      when 0..299 then flash.now.notice = t(SUCCESS)
      when 300..399 then flash.notice = t(SUCCESS)
      when 400..499 then flash.now.alert = t(FAILURE)
      end
    end

    def assign_redirect_options(hash)
      hash[:notice] = t(SUCCESS) if ACTIONS.include?(action_name) && !FLASHES.intersect?(hash.keys)
      hash
    end
  end
end
