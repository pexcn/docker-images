# VoHive

## Udev Rules

> No longer required since v1.5.x

To allow USB devices to be plugged into any port, must configure udev rules for USB module. Refer to the configuration examples in [`rules.d`](./rules.d/).

## Wi-Fi Calling

For some carriers like Vodafone DE, need to add a hosts entry or use custom DNS to enable Wi-Fi Calling. The reason is that their domain names can only be resolved using local DNS servers from their own country.

```yml
    dns:
      - 194.25.0.52
      - 194.25.0.60
      - 194.25.0.68
    # OR
    extra_hosts:
      - "epdg.epc.mnc002.mcc262.pub.3gppnetwork.org=139.7.117.168"
      - "epdg.epc.mnc002.mcc262.pub.3gppnetwork.org=139.7.117.169"
      - "epdg.epc.mnc002.mcc262.pub.3gppnetwork.org=139.7.117.170"
```
