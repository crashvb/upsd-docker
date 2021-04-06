# upsd

## Overview

This docker image contains [NUT](https://networkupstools.org/).

## Adding device mappings

To expose mapped devices (such as usb, serial, etc), allow the container to communicate with the device:

```yaml
---
version: "3.9"

services:
  upsd:
    device_cgroup_rules:
    - "a 188:* rmw"
    - "a 189:* rmw"
    environment:
      # name type major minor mode owner group
      UPSD_MKNOD_DEFAULT: |
        /dev/ups0,c,188,0,0660,root,dialout
        /dev/ups1,c,188,1,0660,root,dialout
        /dev/ups2,c,189,389,0660,root,dialout
    ...
    volumes:
    - /dev/bus/usb:/dev/bus/usb:rw
```

## Example Configuration
This is an example dynamic configuration with 2 UPS, and 3 users:

```yaml
---
version: "3.9"

services:
  upsd:
    ...
    environment:
      UPSD_CONFD_UPS0: |
        [ups0]
        desc = "CyberPower CPS1500AVR"
        model=CPS1500AVR
        driver = powerpanel
        port = /dev/ups0
        sdorder = 0

      UPSD_CONFD_UPS1: |
        [ups1]
        desc = "CyberPower CPS1500AVR"
        model=CPS1500AVR
        driver = powerpanel
        port = /dev/ups1
        sdorder = 0

      UPSD_CONFD_UPS2: |
        [ups2]
        desc = "CyberPower OR1500LCDRM2U"
        driver = usbhid-ups
        port = auto
        vendorid = 0764
        productid = 0601
        sdorder = 0

      UPSD_USERSD_ADMIN: |
        [admin]
        password = $${ADMIN_PASSWORD}
        actions = SET
        instcmds = ALL

      UPSD_USERSD_UPSMONMASTER: |
        [upsmonmaster]
        password = $${UPSMONMASTER_PASSWORD}
        upsmon master

      UPSD_USERSD_UPSMONSLAVE: |
        [upsmonslave]
        password = $${UPSMONSLAVE_PASSWORD}
        upsmon slave
    ...
```


## Entrypoint Scripts

### upsd

The embedded entrypoint script is located at `/etc/entrypoint.d/upsd` and performs the following actions:

1. A new upsd configuration is generated using the following environment variables:

 | Variable | Default Value | Description |
 | -------- | ------------- | ----------- |
 | UPSD_CERT_DAYS | 30 | Validity period of any generated PKI certificates. |
 | UPSD_CONFD_* | | The contents of `<nut_confpath>/conf.d/*.conf`. For example, `UPSD_CONFD_FOO` will create `<nut_confpath>/conf.d/foo.conf`. The contents of this directory will be used to generate `<nut_confpath>/ups.conf`. |
 | UPSD_KEY_SIZE | 4096 | Key size of any generated PKI keys. |
 | UPSD_CONFD_* | | The contents of `<nut_confpath>/conf.d/*.conf`. For example, `UPSD_CONFD_FOO` will create `<nut_confpath>/conf.d/foo.conf`. The contents of this directory will be used to generate `<nut_confpath>/ups.conf`. |
 | UPSD_NSS_PATH | `<nut_confpath>/nss` | The path to the NSS database. |
 | UPSD_USERSD_* | | The contents of `<nut_confpath>/users.d/*.conf`. For example, `UPSD_USERSD_FOO` will create `<nut_confpath>/users.d/foo.conf`. The contents of this directory will be used to generate `<nut_confpath>/upsd.users`. |

2. Volume permissions are normalized.

## Standard Configuration

### Container Layout

```
/
├─ etc/
│  ├─ entrypoint.d/
│  │  └─ upsd
│  └─ supervisor/
│     └─ config.d/
│        └─ upsd.conf
├─ run/
│  └─ secrets/
│     ├─ nss_password
│     ├─ upsd.crt
│     ├─ upsd.key
│     ├─ upsdca.crt
│     └─ upsd_<user>_password
└─ usr/
   └─ local/
      └─ bin/
         ├─ nut-update-confd
         └─ nut-update-usersd
```

### Exposed Ports

* `3493/tcp` - upsd listening port.

### Volumes

* `/etc/nut` - The upsd configuration directory.

## Development

[Source Control](https://github.com/crashvb/upsd-docker)

