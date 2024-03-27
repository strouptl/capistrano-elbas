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

      def public_dns_hostname
        aws_counterpart.public_dns_name
      end

      def ip_address
        aws_counterpart.public_ip_address
      end

      def ipv_6_address
        aws_counterpart.ipv_6_address
      end

      def formatted_ipv_6_address
        "[#{ipv_6_address}]"
      end

      def auto_destination
        [public_dns_hostname, ip_address, formatted_ipv_6_address].detect { |a| !a.nil? and !a.empty? }
      end

      def destination
        @destination ||= if options[:ipv_4]
                           ip_address
                         elsif options[:ipv_6]
                           formatted_ipv_6_address
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
    end
  end
end
