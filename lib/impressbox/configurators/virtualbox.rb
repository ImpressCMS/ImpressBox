require_relative 'base'

module Impressbox
  # Configurators namespace
  module Configurators
    # Virtualbox configurator
    class VirtualBox < Impressbox::Configurators::Base
      # Configure basic settings
      def basic_configure(vmname, cpus, memory, gui)
        @config.vm.provider 'virtualbox' do |v|
          v.gui = gui
          v.vmname = vmname
          v.cpus = cpus
          v.memory = memory
        end
      end

      # Configure specific
      def specific_configure(cfg)
      end
    end
  end
end