# Management Network SNMP configuration

# Requirements
Access to switches

This configuration is required for hardware discovery of the Shasta system.
It needs to be applied on all switches that are connected to BMCs

# Aruba Configuration
```
snmp-server vrf default
snmpv3 user testuser auth md5 auth-pass plaintext testpass1 priv des priv-pass plaintext testpass2
```

# Dell Configuration
```
snmp-server group cray-reds-group 3 noauth read cray-reds-view
snmp-server user testuser cray-reds-group 3 auth md5 testpass1 priv des testpass2
snmp-server view cray-reds-view 1.3.6.1.2 included 
``` 

# Mellanox Configuration

SNMP is not needed on Mellanox switches.