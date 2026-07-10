{
  fetchFromGitHub,
  fusesocLib,
}:
let
  fusesoc-cores = fetchFromGitHub {
    owner = "fusesoc";
    repo = "fusesoc-cores";
    rev = "df5d895909b4289aab8ba368250a332a3c6970ea";
    hash = "sha256-1zNYV6empYAoNkVPgqpGttR38KsHBRU2cxvomafzBsI=";
  };
in
map (x: fusesocLib.importCore (x // { coreRoot = "${fusesoc-cores}/${x.coreRoot}"; })) [
  {
    coreName = "SD-card-controller-0-r3.core";
    coreRoot = "SD-card-controller";
    providerHash = "sha256-C9DiZEIyUIFuhITuxL/RoSThMRo4HJ7dylcWm3TVPn4=";
  }
  {
    coreName = "ac97-1.2-r1.core";
    coreRoot = "ac97";
    providerHash = "sha256-UsFPiuuTzrSfMi4fb2IJKGKdeTM2lpfRsYhb90kOOh4=";
  }
  {
    coreName = "adv_debug_sys-3.1.0-r1.core";
    coreRoot = "adv_debug_sys";
    providerHash = "sha256-t+ffB55laSo7G2qVPuyff0FlWV3tkbt687ESMSozUVc=";
  }
  {
    coreName = "altera_virtual_jtag-1.0-r1.core";
    coreRoot = "altera_virtual_jtag";
    providerHash = "sha256-XzkXUH8BCy8pqzcwvQUdXdX6uz+tEEdvT5d805lwW1c=";
  }
  {
    coreName = "basejump_stl-hard.core";
    coreRoot = "bespoke-silicon-group";
    providerHash = "sha256-ceMgT2imgIBzUA0FKl1zXWuUUjKv8g7ZFmwsBXg4hqE=";
  }
  {
    coreName = "basejump_stl-nonsynth.core";
    coreRoot = "bespoke-silicon-group";
    providerHash = "sha256-ceMgT2imgIBzUA0FKl1zXWuUUjKv8g7ZFmwsBXg4hqE=";
  }
  {
    coreName = "basejump_stl.core";
    coreRoot = "bespoke-silicon-group";
    providerHash = "sha256-ceMgT2imgIBzUA0FKl1zXWuUUjKv8g7ZFmwsBXg4hqE=";
  }
  {
    coreName = "bsg-external-hardfloat.core";
    coreRoot = "bespoke-silicon-group";
    providerHash = "sha256-YN9kzBvnqzDUt12BOK9uus1dTjKd0LXpanyEsbenrMM=";
  }
  {
    coreName = "cdc_utils-0.1-r1.core";
    coreRoot = "cdc_utils";
    providerHash = "sha256-osHfK/tkBepihTaYg/h8wnFFpFDkPedxNp3y/EPZJfc=";
  }
  # TODO: chipsalliance.org/swerv-el2.core (uses generators)
  {
    coreName = "ethmac-0.core";
    coreRoot = "ethmac";
    providerHash = "sha256-ojJye+hy3yZu8kkCE4VBModrQKpKsXZp0MWpAB2WGQ4=";
  }
  {
    coreName = "fifo-1.3-r1.core";
    coreRoot = "fifo";
    providerHash = "sha256-nS4mFYccezxeWdvQtiWYoyNvuumRhYXCt2QMsyBhX7E=";
  }
  {
    coreName = "fplib.core";
    coreRoot = "fplib";
    providerHash = "sha256-8Zt4QFq4Z6u8DV/QqMquR74wpehCEpD7Wj/KJDC4uB4=";
  }
  # TODO: fusesoc_utils/* (generators, scripts)
  {
    coreName = "i2c-1.14-r1.core";
    coreRoot = "i2c";
    providerHash = "sha256-JVUO5Znh/bqkdbzMRjCcTUrh/HtXf08ArcsQgsQ5X9M=";
  }
  {
    coreName = "i2c-1.15.core";
    coreRoot = "i2c";
    providerHash = "sha256-/zD0g4o2NNZhd6HrgXqvdXhU9Y90cyP+VAsIXQJnQRU=";
  }
  # TODO: iob_cache/* iob_eth/iob_eth.core iob_uart16550/iob_uart16550.core (scripts)
  {
    coreName = "jtag_tap-1.13-r1.core";
    coreRoot = "jtag_tap";
    providerHash = "sha256-YYbZguMNRz2Vwxf3uIT75Wp+za+8gXggPxVAy5cjp2M=";
  }
  {
    coreName = "jtag_vpi-r3.core";
    coreRoot = "jtag_vpi";
    providerHash = "sha256-atWzMSY+F02Jx3YfHfcCOru/QZZbS+2HQLhD6UCJ/Kw=";
  }
  {
    coreName = "jtag_vpi-r4.core";
    coreRoot = "jtag_vpi";
    providerHash = "sha256-atWzMSY+F02Jx3YfHfcCOru/QZZbS+2HQLhD6UCJ/Kw=";
  }
  {
    coreName = "jtag_vpi-r5.core";
    coreRoot = "jtag_vpi";
    providerHash = "sha256-cdvzLGsA+C7z/mqN16ZmQDYedB+t81k8SO5vpVV8Cx8=";
  }
  {
    coreName = "mor1kx-5.0-r2.core";
    coreRoot = "mor1kx";
    providerHash = "sha256-i14TGNXeTVfnnNwZQ514arRV95ncpfD5CDE77Mp0Pt4=";
  }
  {
    coreName = "mor1kx-5.1.core";
    coreRoot = "mor1kx";
    providerHash = "sha256-mjWQ/KFxQbxjhI6MDgg8W/aRRobUWncafeaz21Slg10=";
  }
  {
    coreName = "mor1kx-5.2.core";
    coreRoot = "mor1kx";
    providerHash = "sha256-2PMnwymtnCDYuMmlgOEbupqFf2utVYVpeOGz/nWH3ZE=";
  }
  {
    coreName = "ompic-1.0-r1.core";
    coreRoot = "ompic";
    providerHash = "sha256-AR3tu9nuJ7FRAHdxep98S9X1Zjy+xsb0TTUNvlqKszM=";
  }
  {
    coreName = "vlog_tb_utils-1.1-r1.core";
    coreRoot = "vlog_tb_utils";
    providerHash = "sha256-1PInJS4DvhzZ+8h8zpxgewoAzo4mCb7b4OWRh97h3h0=";
  }
  {
    coreName = "verilog-arbiter-r3.core";
    coreRoot = "verilog-arbiter";
    providerHash = "sha256-/hgkOUn7oCSXQXWbUPprC5hpB29KRLjC3Bsz+n7yMVU=";
  }
  {
    coreName = "wiredelay-0-r1.core";
    coreRoot = "wiredelay";
    providerHash = "sha256-pfQwxVUHWteVx1GvI9WXCGzpK9SEGxEbv0dnrxUgbiU=";
  }
]
