module Elbas
  module AWS
    class Instance < Base
      STATE_RUNNING = 16.freeze

      attr_reader :aws_counterpart, :id, :state, :options

      def initialize(id, state, options = {})
        @id = id
        @state = state
        @options = options
        @aws_counterpart = aws_namespace::Instance.new id, client: aws_client
      end

      def formatted_ipv_6_address
        "[#{aws_counterpart.ipv_6_address}]"
      end

      def auto_destination
        (options[:private] ? private_destination_options : public_destination_options).detect { |a| !a.nil? and !a.empty? }
      end

      def destination
        @destination ||= if options[:ipv_4]
                           aws_counterpart.public_ip_address
                         elsif options[:ipv_6]
                           formatted_ipv_6_address
                         elsif options[:private_ip_address]
                           aws_counterpart.private_ip_address
                         else
                           auto_destination
                         end
      end

      def running?
        state == STATE_RUNNING
      end

      private
        def aws_namespace
          ::Aws::EC2
        end

        def private_destination_options
          [aws_counterpart.private_dns_name, aws_counterpart.private_ip_address]
        end

        def public_destination_options
          [aws_counterpart.public_dns_name, aws_counterpart.public_ip_address, formatted_ipv_6_address]
        end
    end
  end
end
