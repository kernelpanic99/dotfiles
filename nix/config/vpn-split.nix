# Routes traffic for selected domains through the VPN.
#
# The domains live in the gitignored nix/config/vpn-split-domains file, one per
# line, with `#` comments. The service reads it from the checkout at runtime,
# so it stays out of the flake and the store. Saving it regenerates the
# dnsmasq config and restarts NetworkManager's dnsmasq.
#
# dnsmasq adds every address it resolves for those domains to nftables sets.
# Packets towards those addresses get fwmark 0x2a, and a policy rule sends
# marked packets through the VPN interface while the VPN is up.
#
# The VPN connection runs as a split tunnel:
#   nmcli c modify <connection> ipv4.never-default yes ipv6.never-default yes
{
  config,
  lib,
  pkgs,
  ...
}: let
  # NetworkManager connection UUIDs are per machine.
  connections = {
    desktop = "b5ab0f47-231c-4abf-89a2-3be7b6dfcc00";
    laptop = "8d0ed832-b90b-44e9-81b9-0fd361f3e3ac";
  };

  connection = connections.${config.networking.hostName};

  domainsFile = "/home/kp/dotfiles/nix/config/vpn-split-domains";
  dnsmasqConf = "/etc/NetworkManager/dnsmasq.d/vpn-split.conf";

  mark = "0x2a";
  table = "142";

  ruleset = pkgs.writeText "vpn-split.nft" ''
    table inet vpn_split {
      set dst4 {
        type ipv4_addr
        flags timeout
        timeout 1h
      }

      set dst6 {
        type ipv6_addr
        flags timeout
        timeout 1h
      }

      chain output {
        type route hook output priority mangle - 10; policy accept;

        ct mark ${mark} meta mark set ${mark} return
        ip daddr @dst4 meta mark set ${mark} ct mark set ${mark}
        ip6 daddr @dst6 meta mark set ${mark} ct mark set ${mark}
      }

      # Replies carry the mark too, so the firewall's reverse path check
      # resolves them against the VPN table.
      chain prerouting {
        type filter hook prerouting priority mangle - 25; policy accept;

        ct mark ${mark} meta mark set ${mark}
      }

      # Marked packets get their source address chosen before rerouting,
      # so rewrite it to the VPN interface address.
      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;

        meta mark ${mark} masquerade
      }
    }
  '';

  dispatcher = pkgs.writeShellScript "vpn-split-dispatcher" ''
    PATH=${lib.makeBinPath [pkgs.iproute2 pkgs.gnugrep]}

    [ "$CONNECTION_UUID" = "${connection}" ] || exit 0

    teardown() {
      ip -4 rule del fwmark ${mark} table ${table} 2>/dev/null
      ip -6 rule del fwmark ${mark} table ${table} 2>/dev/null
      ip -4 route flush table ${table} 2>/dev/null
      ip -6 route flush table ${table} 2>/dev/null
    }

    case "$2" in
      vpn-up)
        teardown

        ip -4 route replace default dev "$VPN_IP_IFACE" table ${table}
        ip -4 rule add fwmark ${mark} table ${table} priority ${table}

        # Without IPv6 on the tunnel, fail IPv6 fast so clients fall back to IPv4.
        if ip -6 addr show dev "$VPN_IP_IFACE" scope global | grep -q inet6; then
          ip -6 route replace default dev "$VPN_IP_IFACE" table ${table}
        else
          ip -6 route replace unreachable default table ${table}
        fi

        ip -6 rule add fwmark ${mark} table ${table} priority ${table}
        ;;

      vpn-down)
        teardown
        ;;
    esac
  '';
in {
  networking.networkmanager = {
    dns = "dnsmasq";

    dispatcherScripts = [
      {
        source = dispatcher;
        type = "basic";
      }
    ];
  };

  systemd.services.vpn-split-domains = {
    description = "dnsmasq config for VPN split routing";
    wantedBy = ["multi-user.target"];
    before = ["NetworkManager.service"];

    path = [pkgs.gnused pkgs.coreutils pkgs.networkmanager pkgs.systemd];

    script = ''
      domains=""

      if [ -f ${domainsFile} ]; then
        domains=$(sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' ${domainsFile} | paste -sd /)
      fi

      mkdir -p "$(dirname ${dnsmasqConf})"

      if [ -n "$domains" ]; then
        echo "nftset=/$domains/4#inet#vpn_split#dst4,6#inet#vpn_split#dst6" > ${dnsmasqConf}
      else
        rm -f ${dnsmasqConf}
      fi

      if systemctl is-active -q NetworkManager.service; then
        nmcli general reload dns-full
      fi
    '';

    serviceConfig.Type = "oneshot";
  };

  systemd.paths.vpn-split-domains = {
    wantedBy = ["multi-user.target"];
    pathConfig.PathChanged = domainsFile;
  };

  systemd.services.vpn-split-nft = {
    description = "nftables sets and marks for VPN split routing";
    wantedBy = ["multi-user.target"];
    before = ["NetworkManager.service"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "-${pkgs.nftables}/bin/nft delete table inet vpn_split";
      ExecStart = "${pkgs.nftables}/bin/nft -f ${ruleset}";
      ExecStop = "${pkgs.nftables}/bin/nft delete table inet vpn_split";
    };
  };
}
