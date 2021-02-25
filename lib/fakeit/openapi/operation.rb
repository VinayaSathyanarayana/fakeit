module Fakeit
  module Openapi
    class Operation
      def initialize(request_operation, app_options)
        @request_operation = request_operation
        @validator = Fakeit::Validation::Validator.new(request_operation)
        @app_options = app_options
      end

      def status
        response.first.to_i
      end

      def headers
        response_headers
          .to_h
          .transform_values { _1.schema.to_example(example_options) }
          .tap { _1['Content-Type'] = response_content_type if response_content_type }
      end

      def body
        response_schema
          &.schema
          &.to_example(example_options)
          &.then(&JSON.method(:generate))
          .to_s
      end

      def validate(...)
        @validator.validate(...)
      end

      private

      def example_options
        { use_example: @app_options.use_example, use_static: @app_options.method(:use_static?), depth: 0 }
      end

      def response_content
        response.last.content&.find { |k, _| k =~ %r{^application/.*json} }
      end

      def response_schema
        response_content&.last
      end

      def response_content_type
        response_content&.first
      end

      def response_headers
        response.last.headers
      end

      def response
        @request_operation.operation_object.responses.response.min
      end
    end
  end
end
