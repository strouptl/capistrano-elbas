module Elbas
  module AWS
    class InstanceCollection < Base
      include Enumerable

      attr_reader :instances, :options

      def initialize(ids, options = {})
        @ids = ids
        @options = options
        @instances = query_instances_by_ids(ids).map do |i|
          Instance.new(i.instance_id, i.state.code, @options)
        end
      end

      def running
        select(&:running?)
      end

      def each(&block)
        instances.each(&block)
      end

      private
        def aws_namespace
          ::Aws::EC2
        end

        def query_instances_by_ids(ids)
          aws_client
            .describe_instances(instance_ids: @ids)
            .reservations.flat_map(&:instances)
        end
    end
  end
end
