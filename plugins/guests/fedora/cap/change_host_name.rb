module VagrantPlugins
  module GuestFedora
    module Cap
      class ChangeHostName
        def self.change_host_name(machine, name)
          comm = machine.communicate

          if !comm.test("hostname | grep -w '#{name}'")
            basename = name.split(".", 2)[0]
            comm.sudo <<-EOH
echo '#{name}' > /etc/hostname
hostname -F /etc/hostname
hostnamectl set-hostname --static '#{name}'
hostnamectl set-hostname --transient '#{name}'

# Remove comments and blank lines from /etc/hosts
sed -i'' -e 's/#.*$//' -e '/^$/d' /etc/hosts

# Prepend ourselves to /etc/hosts
grep -w '#{name}' /etc/hosts || {
  sed -i'' '1i 127.0.0.1\\t#{name}\\t#{basename}' /etc/hosts
}
EOH
          end
        end
      end
    end
  end
end
