use Mix.Config

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.

config :shoehorn,
  init: [:nerves_runtime],
  app: Mix.Project.config()[:app]

config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(Path.join(System.user_home!(), ".ssh/id_rsa.pub"))
  ]

config :nerves_init_gadget,
  ifname: "wlan0",
  address_method: :dhcp,
  mdns_domain: "gamer.local",
  node_name: "gamer",
  node_host: :mdns_domain,
  ssh_console_port: 22

key_mgmt = System.get_env("NERVES_NETWORK_KEY_MGMT") || "WPA-PSK"
config :nerves_network, :default,
   wlan0: [
     ssid: System.get_env("NERVES_NETWORK_SSID"),
     psk: System.get_env("NERVES_NETWORK_PSK"),
     key_mgmt: String.to_atom(key_mgmt)
   ]

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

import_config "#{Mix.Project.config[:target]}.exs"
