module Impressbox
  module Configurators
    module Provision
      # This is action to insert keys to remote machine when booting
      class InsertKey < Impressbox::Configurators::AbstractProvision
        def configure(machine, config_file)
          keys = Impressbox::Objects::SshKeyDetect.new(config_file)

          insert_ssh_key_if_needed(
            machine,
            keys.public_key,
            keys.private_key
          )
        end

        private

        def insert_ssh_key_if_needed(machine, public_key, private_key)
          machine.communicate.wait_for_ready 300

          machine_private_key machine.ui, machine.communicate, private_key
          machine_public_key machine.ui, machine.communicate, public_key
        end

        def machine_public_key(ui, c, public_key)
          ui.info I18n.t('ssh_key.updating.public')
          return unless machine_upload_file ui, c, public_key, '~/.ssh/id_rsa.pub'
          afile = '~/.ssh/authorized_keys'
          c.execute 'touch ' + afile
          c.execute 'cat ~/.ssh/id_rsa.pub >> ' + afile
          c.execute "echo `awk '!a[$0]++' " + afile + '` > ' + afile
          c.execute 'chmod 600 ~/.ssh/id_rsa.pub'
        end

        def machine_private_key(ui, communicator, private_key)
          ui.info I18n.t('ssh_key.updating.private')
          if machine_upload_file ui, communicator, private_key, '~/.ssh/id_rsa'
            communicator.execute 'chmod 400 ~/.ssh/id_rsa'
          end
        end

        def machine_upload_file(ui, communicator, src_file, dst_file)
          if src_file.nil?
            ui.info I18n.t('ssh_key.not_found')
            return false
          end
          prepare_guest_file communicator, dst_file
          write_lines_to_remote_file communicator, read_file_good(src_file), dst_file
          true
        end

        def write_lines_to_remote_file(communicator, lines, file)
          lines.each_line do |line|
            communicator.execute "echo \"#{line.rstrip}\" >> #{file}"
          end
        end

        def read_file_good(file)
          text = File.open(file).read
          text.gsub!(/\r\n?/, "\n")
          text
        end

        def prepare_guest_file(communicator, file)
          communicator.execute 'chmod 777 ' + file + ' || :'
          communicator.execute 'touch ' + file
          communicator.execute 'truncate -s 0 ' + file
        end
      end
    end
  end
end
