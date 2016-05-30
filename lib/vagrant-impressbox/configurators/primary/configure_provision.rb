module Impressbox
  module Configurators
    module Primary
      # Configures provision script
      class ConfigureProvision < Impressbox::Configurators::AbstractPrimary
        def description
          I18n.t 'configuring.provision'
        end

        def can_be_configured?(_vagrant_config, file_config)
          p = file_config.provision
          false unless p.is_a?(String)
          p.strip!
          !p.empty?
        end

        def configure(vagrant_config, config_file)
          vagrant_config.vm.provision 'impressbox_shell', type: 'shell' do |s|
            s.inline = config_file.provision
          end
        end
      end
    end
  end
end