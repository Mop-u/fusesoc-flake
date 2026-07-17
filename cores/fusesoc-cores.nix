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
  core = coreRoot: coreName: providerHash: { inherit coreName coreRoot providerHash; };
  coresIn = coreRoot: f: f (core coreRoot);
in

map (x: fusesocLib.importCore (x // { coreRoot = "${fusesoc-cores}/${x.coreRoot}"; })) (
  [
    # TODO: iob_cache/* iob_eth/iob_eth.core iob_uart16550/iob_uart16550.core (scripts)
    # TODO: pulp-platform.org/* (generators)
    # TODO: verilog-axis/* (generators)
    # TODO: wb_intercon/* (generators)
    {
      # TODO: generator script has issues with tmp dir
      # The core provided by fusesoc-cores is horifically out of date.
      coreName = "swerv_el2.core";
      coreRoot = "chipsalliance.org";
      providerHash = "sha256-Q8mAm1g2/2Bh6qvzSrscZ7qPoFophEzEAO9HcG3cr1s=";
      preservePaths = [
        "configs/swerv_config_gen.py"
        "configs/swerv.config"
      ];
      patches = [ ./patches/swerv_el2_folder_perms.patch ];
    }
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
      coreName = "cdc_utils-0.1-r1.core";
      coreRoot = "cdc_utils";
      providerHash = "sha256-osHfK/tkBepihTaYg/h8wnFFpFDkPedxNp3y/EPZJfc=";
    }
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
    {
      coreName = "jtag_tap-1.13-r1.core";
      coreRoot = "jtag_tap";
      providerHash = "sha256-YYbZguMNRz2Vwxf3uIT75Wp+za+8gXggPxVAy5cjp2M=";
    }
    {
      coreName = "ompic-1.0-r1.core";
      coreRoot = "ompic";
      providerHash = "sha256-AR3tu9nuJ7FRAHdxep98S9X1Zjy+xsb0TTUNvlqKszM=";
    }
    {
      coreName = "or1k_bootloaders-0.9.1-r1.core";
      coreRoot = "or1k_bootloaders";
      providerHash = "sha256-0pUzeFdgtmmD1jFmmFoytA3gBwa1fAwAS0diEdTB7ZM=";
    }
    {
      coreName = "or1ksim_trace-1.0.core";
      coreRoot = "or1ksim_trace";
      providerHash = "sha256-VsNYWNcnkJLGy2bnXfjkw/rN5mOfKaMX/3VvcZgSm7s=";
    }
    {
      coreName = "simple_spi-1.6.1.core";
      coreRoot = "simple_spi";
      providerHash = "sha256-YsutC5zMrudc47bKUo19SRVgCcC01CZjO1Xv0TtrjFg=";
    }
    {
      coreName = "stream_utils-1.3-r1.core";
      coreRoot = "stream_utils";
      providerHash = "sha256-yUbiO1GnZFA/p50l3XZMZiK9HffTlsV0lMXTINohhbU=";
    }
    {
      coreName = "timer-1.0-r1.core";
      coreRoot = "timer";
      providerHash = "sha256-lrSe9aSU8RFzCJ8ceWCwTM85tuT5uAD8L/sj6ZBr0uM=";
    }
    {
      coreName = "uart16550-1.5.5-r1.core";
      coreRoot = "uart16550";
      providerHash = "sha256-q4HVNm6mFxPTyqyPGgIJfDCQ0CTB39NboJnwPIxZAfs=";
    }
    {
      coreName = "vlog_tb_utils-1.1-r1.core";
      coreRoot = "vlog_tb_utils";
      providerHash = "sha256-1PInJS4DvhzZ+8h8zpxgewoAzo4mCb7b4OWRh97h3h0=";
    }
    {
      coreName = "wb_altera_ddr_wrapper-0-r1.core";
      coreRoot = "wb_altera_ddr_wrapper";
      providerHash = "sha256-Tqn3DUcDy4CvlUnFqjpMBztZT5lf/X1QkOMCmreEGb4=";
    }
    {
      coreName = "wb_bfm-1.2.1-r1.core";
      coreRoot = "wb_bfm";
      providerHash = "sha256-Yt9tWXlh/BXC5MTZSwIXLsoh4Ts3C85FBtU6wJJEa+U=";
    }
    {
      coreName = "wb_common-1.0.3.core";
      coreRoot = "wb_common";
      providerHash = "sha256-iVxXgP8+l9U/ObOYc/qyNdDYuTWDF0wNA6FA3JEnjdg=";
    }
    {
      coreName = "wb_ram-1.1-r1.core";
      coreRoot = "wb_ram";
      providerHash = "sha256-HuBDkFASijlXykWnDbAwTlc1lBXaGhkf/VdWZWwRIAo=";
    }
    {
      coreName = "wb_streamer-1.1-r1.core";
      coreRoot = "wb_streamer";
      providerHash = "sha256-30/YibL6I3fbOCGdSnmIb7hWShRKcjfdsjV5Xwtd75o=";
    }
    {
      coreName = "wiredelay-0-r1.core";
      coreRoot = "wiredelay";
      providerHash = "sha256-pfQwxVUHWteVx1GvI9WXCGzpK9SEGxEbv0dnrxUgbiU=";
    }
  ]
  ++ (coresIn "bespoke-silicon-group" (get: [
    (get "basejump_stl-hard.core" "sha256-ceMgT2imgIBzUA0FKl1zXWuUUjKv8g7ZFmwsBXg4hqE=")
    (get "basejump_stl-nonsynth.core" "sha256-ceMgT2imgIBzUA0FKl1zXWuUUjKv8g7ZFmwsBXg4hqE=")
    (get "basejump_stl.core" "sha256-ceMgT2imgIBzUA0FKl1zXWuUUjKv8g7ZFmwsBXg4hqE=")
    (get "bsg-external-hardfloat.core" "sha256-YN9kzBvnqzDUt12BOK9uus1dTjKd0LXpanyEsbenrMM=")
  ]))
  ++ (coresIn "i2c" (get: [
    (get "i2c-1.14-r1.core" "sha256-JVUO5Znh/bqkdbzMRjCcTUrh/HtXf08ArcsQgsQ5X9M=")
    (get "i2c-1.15.core" "sha256-/zD0g4o2NNZhd6HrgXqvdXhU9Y90cyP+VAsIXQJnQRU=")
  ]))
  ++ (coresIn "jtag_vpi" (get: [
    (get "jtag_vpi-r3.core" "sha256-atWzMSY+F02Jx3YfHfcCOru/QZZbS+2HQLhD6UCJ/Kw=")
    (get "jtag_vpi-r4.core" "sha256-atWzMSY+F02Jx3YfHfcCOru/QZZbS+2HQLhD6UCJ/Kw=")
    (get "jtag_vpi-r5.core" "sha256-cdvzLGsA+C7z/mqN16ZmQDYedB+t81k8SO5vpVV8Cx8=")
  ]))
  ++ (coresIn "mor1kx" (get: [
    (get "mor1kx-5.0-r2.core" "sha256-i14TGNXeTVfnnNwZQ514arRV95ncpfD5CDE77Mp0Pt4=")
    (get "mor1kx-5.1.core" "sha256-mjWQ/KFxQbxjhI6MDgg8W/aRRobUWncafeaz21Slg10=")
    (get "mor1kx-5.2.core" "sha256-2PMnwymtnCDYuMmlgOEbupqFf2utVYVpeOGz/nWH3ZE=")
  ]))
  ++ (coresIn "open-logic/3.1.0" (get: [
    (get "olo_axi.core" "sha256-DaW8AyCm0uFYkJarajC+XKhkHqiW1h6hN/84y7scYGM=")
    (get "olo_base.core" "sha256-DaW8AyCm0uFYkJarajC+XKhkHqiW1h6hN/84y7scYGM=")
    (get "olo_intf.core" "sha256-DaW8AyCm0uFYkJarajC+XKhkHqiW1h6hN/84y7scYGM=")
    (get "olo_quartus_tutorial.core" "sha256-DaW8AyCm0uFYkJarajC+XKhkHqiW1h6hN/84y7scYGM=")
    (get "olo_vivado_tutorial.core" "sha256-DaW8AyCm0uFYkJarajC+XKhkHqiW1h6hN/84y7scYGM=")
  ]))
  ++ (coresIn "open-logic/3.2.0" (get: [
    (get "olo_axi.core" "sha256-3enhuVik79tA+J4VvdneICl4/QEU+QcYKqRLEoFU3r0=")
    (get "olo_base.core" "sha256-3enhuVik79tA+J4VvdneICl4/QEU+QcYKqRLEoFU3r0=")
    (get "olo_intf.core" "sha256-3enhuVik79tA+J4VvdneICl4/QEU+QcYKqRLEoFU3r0=")
    (get "olo_quartus_tutorial.core" "sha256-3enhuVik79tA+J4VvdneICl4/QEU+QcYKqRLEoFU3r0=")
    (get "olo_vivado_tutorial.core" "sha256-3enhuVik79tA+J4VvdneICl4/QEU+QcYKqRLEoFU3r0=")
  ]))
  ++ (coresIn "open-logic/3.3.0" (get: [
    (get "en_cl_fix.core" "sha256-GEMghZ0DAH7AgUh6v+Y5O9iVsa1Y87qqg27HVEEHNhs=")
    (get "olo_axi.core" "sha256-hiGJpjfkT8f1OA3DoCstesI2q0UayiAdNK9pkvhkYHo=")
    (get "olo_base.core" "sha256-hiGJpjfkT8f1OA3DoCstesI2q0UayiAdNK9pkvhkYHo=")
    (get "olo_fix.core" "sha256-hiGJpjfkT8f1OA3DoCstesI2q0UayiAdNK9pkvhkYHo=")
    (get "olo_fix_tutorial.core" "sha256-hiGJpjfkT8f1OA3DoCstesI2q0UayiAdNK9pkvhkYHo=")
    (get "olo_intf.core" "sha256-hiGJpjfkT8f1OA3DoCstesI2q0UayiAdNK9pkvhkYHo=")
    (get "olo_quartus_tutorial.core" "sha256-hiGJpjfkT8f1OA3DoCstesI2q0UayiAdNK9pkvhkYHo=")
    (get "olo_vivado_tutorial.core" "sha256-hiGJpjfkT8f1OA3DoCstesI2q0UayiAdNK9pkvhkYHo=")
  ]))
  ++ (coresIn "open-logic/4.0.0" (get: [
    (get "en_cl_fix.core" "sha256-6VfOKvbP+m3bpF/MLw9yzuP3CwyF5OkbdzGY4vcwPZU=")
    (get "olo_axi.core" "sha256-/M0kI/bEtXOQso7xP5Q2lsdRRQph+y2eHz6o3mL3GfI=")
    (get "olo_base.core" "sha256-/M0kI/bEtXOQso7xP5Q2lsdRRQph+y2eHz6o3mL3GfI=")
    (get "olo_fix.core" "sha256-/M0kI/bEtXOQso7xP5Q2lsdRRQph+y2eHz6o3mL3GfI=")
    (get "olo_fix_tutorial.core" "sha256-/M0kI/bEtXOQso7xP5Q2lsdRRQph+y2eHz6o3mL3GfI=")
    (get "olo_intf.core" "sha256-/M0kI/bEtXOQso7xP5Q2lsdRRQph+y2eHz6o3mL3GfI=")
    (get "olo_quartus_tutorial.core" "sha256-/M0kI/bEtXOQso7xP5Q2lsdRRQph+y2eHz6o3mL3GfI=")
    (get "olo_vivado_tutorial.core" "sha256-/M0kI/bEtXOQso7xP5Q2lsdRRQph+y2eHz6o3mL3GfI=")
  ]))
  ++ (coresIn "open-logic/4.1.0" (get: [
    (get "en_cl_fix.core" "sha256-DoPvgMcYrRM5CKZUyA7iU3lA6/3OjpxqCmzCauEKnIg=")
    (get "olo_axi.core" "sha256-h0tb0NxH8qs8bOdVewZdGxm0BNzTGNR+ho7i4ljheLQ=")
    (get "olo_base.core" "sha256-h0tb0NxH8qs8bOdVewZdGxm0BNzTGNR+ho7i4ljheLQ=")
    (get "olo_fix.core" "sha256-h0tb0NxH8qs8bOdVewZdGxm0BNzTGNR+ho7i4ljheLQ=")
    (get "olo_fix_tutorial.core" "sha256-h0tb0NxH8qs8bOdVewZdGxm0BNzTGNR+ho7i4ljheLQ=")
    (get "olo_intf.core" "sha256-h0tb0NxH8qs8bOdVewZdGxm0BNzTGNR+ho7i4ljheLQ=")
    (get "olo_quartus_tutorial.core" "sha256-h0tb0NxH8qs8bOdVewZdGxm0BNzTGNR+ho7i4ljheLQ=")
    (get "olo_vivado_tutorial.core" "sha256-h0tb0NxH8qs8bOdVewZdGxm0BNzTGNR+ho7i4ljheLQ=")
  ]))
  ++ (coresIn "open-logic/4.2.0" (get: [
    (get "en_cl_fix.core" "sha256-/LKm+fiJW0As+yd+/coJVs5+tOPb0eEKi01y+q9j4Ik=")
    (get "olo_axi.core" "sha256-VeM140CZVbPCCDinGsH5oO8AP/VLxjRitZmP4sO1bo0=")
    (get "olo_base.core" "sha256-VeM140CZVbPCCDinGsH5oO8AP/VLxjRitZmP4sO1bo0=")
    (get "olo_fix.core" "sha256-VeM140CZVbPCCDinGsH5oO8AP/VLxjRitZmP4sO1bo0=")
    (get "olo_fix_tutorial.core" "sha256-VeM140CZVbPCCDinGsH5oO8AP/VLxjRitZmP4sO1bo0=")
    (get "olo_intf.core" "sha256-VeM140CZVbPCCDinGsH5oO8AP/VLxjRitZmP4sO1bo0=")
    (get "olo_quartus_tutorial.core" "sha256-VeM140CZVbPCCDinGsH5oO8AP/VLxjRitZmP4sO1bo0=")
    (get "olo_vivado_tutorial.core" "sha256-VeM140CZVbPCCDinGsH5oO8AP/VLxjRitZmP4sO1bo0=")
  ]))
  ++ (coresIn "open-logic/4.3.0" (get: [
    (get "en_cl_fix.core" "sha256-/LKm+fiJW0As+yd+/coJVs5+tOPb0eEKi01y+q9j4Ik=")
    (get "olo_axi.core" "sha256-+qy0Y2qSNa1mbTaGv+dDpGtnUaV/UQoYBoV3YqVD/JI=")
    (get "olo_base.core" "sha256-+qy0Y2qSNa1mbTaGv+dDpGtnUaV/UQoYBoV3YqVD/JI=")
    (get "olo_fix.core" "sha256-+qy0Y2qSNa1mbTaGv+dDpGtnUaV/UQoYBoV3YqVD/JI=")
    (get "olo_fix_tutorial.core" "sha256-+qy0Y2qSNa1mbTaGv+dDpGtnUaV/UQoYBoV3YqVD/JI=")
    (get "olo_intf.core" "sha256-+qy0Y2qSNa1mbTaGv+dDpGtnUaV/UQoYBoV3YqVD/JI=")
    (get "olo_quartus_tutorial.core" "sha256-+qy0Y2qSNa1mbTaGv+dDpGtnUaV/UQoYBoV3YqVD/JI=")
    (get "olo_vivado_tutorial.core" "sha256-+qy0Y2qSNa1mbTaGv+dDpGtnUaV/UQoYBoV3YqVD/JI=")
  ]))
  ++ (coresIn "open-logic/4.4.0" (get: [
    (get "en_cl_fix.core" "sha256-/LKm+fiJW0As+yd+/coJVs5+tOPb0eEKi01y+q9j4Ik=")
    (get "olo_axi.core" "sha256-xMB0iJUPi/4cuOyppNJTwSHV+RGhNGjg8tWwSZ8YNvs=")
    (get "olo_base.core" "sha256-xMB0iJUPi/4cuOyppNJTwSHV+RGhNGjg8tWwSZ8YNvs=")
    (get "olo_fix.core" "sha256-xMB0iJUPi/4cuOyppNJTwSHV+RGhNGjg8tWwSZ8YNvs=")
    (get "olo_fix_tutorial.core" "sha256-xMB0iJUPi/4cuOyppNJTwSHV+RGhNGjg8tWwSZ8YNvs=")
    (get "olo_intf.core" "sha256-xMB0iJUPi/4cuOyppNJTwSHV+RGhNGjg8tWwSZ8YNvs=")
    (get "olo_quartus_tutorial.core" "sha256-xMB0iJUPi/4cuOyppNJTwSHV+RGhNGjg8tWwSZ8YNvs=")
    (get "olo_vivado_tutorial.core" "sha256-xMB0iJUPi/4cuOyppNJTwSHV+RGhNGjg8tWwSZ8YNvs=")
  ]))
  ++ (coresIn "open-logic/4.4.1" (get: [
    (get "en_cl_fix.core" "sha256-/LKm+fiJW0As+yd+/coJVs5+tOPb0eEKi01y+q9j4Ik=")
    (get "olo_axi.core" "sha256-oYXhhqGIZEBm8W11mNmKSJE/hIlXFNBIUgxH0MF4n4Y=")
    (get "olo_base.core" "sha256-oYXhhqGIZEBm8W11mNmKSJE/hIlXFNBIUgxH0MF4n4Y=")
    (get "olo_fix.core" "sha256-oYXhhqGIZEBm8W11mNmKSJE/hIlXFNBIUgxH0MF4n4Y=")
    (get "olo_fix_tutorial.core" "sha256-oYXhhqGIZEBm8W11mNmKSJE/hIlXFNBIUgxH0MF4n4Y=")
    (get "olo_intf.core" "sha256-oYXhhqGIZEBm8W11mNmKSJE/hIlXFNBIUgxH0MF4n4Y=")
    (get "olo_quartus_tutorial.core" "sha256-oYXhhqGIZEBm8W11mNmKSJE/hIlXFNBIUgxH0MF4n4Y=")
    (get "olo_vivado_tutorial.core" "sha256-oYXhhqGIZEBm8W11mNmKSJE/hIlXFNBIUgxH0MF4n4Y=")
  ]))
  ++ (coresIn "open-logic/4.5.0" (get: [
    (get "en_cl_fix.core" "sha256-/LKm+fiJW0As+yd+/coJVs5+tOPb0eEKi01y+q9j4Ik=")
    (get "olo_axi.core" "sha256-U4Rd9Om9GeneignJgxr+DMxQclWMzg0NseSVapWtY3k=")
    (get "olo_base.core" "sha256-U4Rd9Om9GeneignJgxr+DMxQclWMzg0NseSVapWtY3k=")
    (get "olo_fix.core" "sha256-U4Rd9Om9GeneignJgxr+DMxQclWMzg0NseSVapWtY3k=")
    (get "olo_fix_tutorial.core" "sha256-U4Rd9Om9GeneignJgxr+DMxQclWMzg0NseSVapWtY3k=")
    (get "olo_intf.core" "sha256-U4Rd9Om9GeneignJgxr+DMxQclWMzg0NseSVapWtY3k=")
    (get "olo_quartus_tutorial.core" "sha256-U4Rd9Om9GeneignJgxr+DMxQclWMzg0NseSVapWtY3k=")
    (get "olo_vivado_tutorial.core" "sha256-U4Rd9Om9GeneignJgxr+DMxQclWMzg0NseSVapWtY3k=")
  ]))
  ++ (coresIn "openfpga" (get: [
    (get "sofa-chd.core" "sha256-jkB5+TZscXDqIyw45mpa4QONalfTn05Gzy0CLcavL1s=")
    (get "sofa-hd.core" "sha256-jkB5+TZscXDqIyw45mpa4QONalfTn05Gzy0CLcavL1s=")
    (get "sofa-qlhd.core" "sha256-jkB5+TZscXDqIyw45mpa4QONalfTn05Gzy0CLcavL1s=")
  ]))
  ++ (coresIn "verilator_tb_utils" (get: [
    (get "verilator_tb_utils-1.0.core" "sha256-Tiz9+fSxlYl9pTwz61K4StWMqRpoZTnLQ5uizFprg1A=")
    (get "verilator_tb_utils-1.1.core" "sha256-oX4xppapcEhxfZOjIUvk+fZCh03+6KT1bej3l8AgRnU=")
  ]))
  ++ (coresIn "verilog-arbiter" (get: [
    (get "verilog-arbiter-r3.core" "sha256-/hgkOUn7oCSXQXWbUPprC5hpB29KRLjC3Bsz+n7yMVU=")
    (get "verilog-arbiter-r2.core" "sha256-CVTdd0BBJDd8Y1FM2JIvIBb3orErjfLa9465tF7uhk0=")
  ]))
  ++ (coresIn "wb_sdram_ctrl" (get: [
    (get "wb_sdram_ctrl-r3.core" "sha256-owHpJcI2q5xsMRnpyo585T08gGwRzhycmSkpf8niFJk=")
    (get "wb_sdram_ctrl-r4.core" "sha256-KQU8Sf0EQrm6XIetbobzr2aCQblhmyh1tdEO1EuT1io=")
  ]))
  ++ (coresIn "yosys_cells" (get: [
    (get "ecp5-0.8.core" "sha256-DdzoqCsz4z3kVsm8PFupdmdDNpG8d8Hf3dNaogvo5z4=")
    (get "ice40-0.7.core" "sha256-mbFqQ+85Y+/XQF/2BczqZkRV86FevRjia1BPRi0cx6A=")
  ]))
  ++ (coresIn "fusesoc_utils" (
    get:
    let
      paths016 = {
        preservePaths = [
          "chisel.py"
          "custom.py"
          "gitversion.py"
          "icepll.py"
          "template/template_generator.py"
          "template/templates/constants_pkg_sv.j2"
          "template/templates/constants_pkg_vhd.j2"
          "template/templates/sdc.j2"
          "template/templates/ucf.j2"
        ];
      };
      paths013 = {
        preservePaths = [
          "custom.py"
          "gitversion.py"
          "icepll.py"
        ];
      };
      pathsBlinky = {
        preservePaths = [ "sw/proginfo.py" ];
      };
    in
    [
      ((get "generators-0.1.7.core" "sha256-ei2IXefe/RKa77jlZsQQ+/P0lPh2Of4+kqDSBvp9TXU=") // paths016)
      ((get "generators-0.1.6.core" "sha256-9BcJLSH1icMgI1vcpzq4oDvT8iHP3TOSRPsrfEdKsrY=") // paths016)
      (
        (get "generators-0.1.5.core" "sha256-F3U03hw6wwsKt6vJt/4IAxe5VaNR5CHTqs/sufQZxb0=")
        // {
          preservePaths = [
            "custom.py"
            "gitversion.py"
            "icepll.py"
            "template/template_generator.py"
            "template/templates/constants_pkg_sv.j2"
            "template/templates/constants_pkg_vhd.j2"
            "template/templates/sdc.j2"
            "template/templates/ucf.j2"
          ];
        }
      )
      ((get "generators-0.1.4.core" "sha256-15FTNPQBrvoL32PK1p4EHji1ZD8vZZ/j1Gg1NdsipFY=") // paths013)
      ((get "generators-0.1.3.core" "sha256-qlStZecEKRNFNERk9LcQLS/BVxR6r/rMV1B/JI3xLRg=") // paths013)
      ((get "blinky-0.core" "sha256-Fhq93SOpSBi7dB9oC1n0KM2XZFHiEzTsWsVSzBD+j5Y=") // pathsBlinky)
      ((get "blinky-1.0.core" "sha256-2UhRJQ3bgv1TRPxOLQj/2Z/4IwO8aA8v+40fbm/MiHk=") // pathsBlinky)
      ((get "blinky-1.1.core" "sha256-jUX2mpU0lmmIdf3tkpUrEVc4+kpw+8u01ymGy7bn0k0=") // pathsBlinky)
    ]
  ))
  ++ (coresIn "serv" (get: [
    (get "serv-1.0.2.core" "sha256-Io5xQOURxAmNUQR4QnaL72libSPPg6xq0+8F1IdVlEw=")
    (get "serv-1.1.0.core" "sha256-Rm+34mE+ToeLxh4SBtgQ9TnSXn2MP/l7DaOrT+XgF5o=")
    (get "servant-1.0.2-r1.core" "sha256-gfgn0J+Jrxb5V+sm3HyWuv32mM3ytr2IoVY23K23ZRI=")
    (get "servant-1.0.2.core" "sha256-Io5xQOURxAmNUQR4QnaL72libSPPg6xq0+8F1IdVlEw=")
    (get "servant-1.1.0.core" "sha256-Rm+34mE+ToeLxh4SBtgQ9TnSXn2MP/l7DaOrT+XgF5o=")
    (get "serving-1.0.2.core" "sha256-Io5xQOURxAmNUQR4QnaL72libSPPg6xq0+8F1IdVlEw=")
    (get "serving-1.1.0.core" "sha256-Rm+34mE+ToeLxh4SBtgQ9TnSXn2MP/l7DaOrT+XgF5o=")
  ]))
)
