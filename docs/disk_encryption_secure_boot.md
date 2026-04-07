# Disk Encryption / Secure Boot

To generate a new key that the TPM will tolerate:

```shell
dd if=/dev/random bs=64 count=1 | xxd -p -c999 | tr -d '\n' > /root/luks_key
```