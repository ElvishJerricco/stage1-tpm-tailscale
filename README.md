This code is not exactly good. It's a bit of a mess that's thrown
together to make this work. It could be very much improved.

```mermaid
block-beta
  columns 5
  block:pool:5
    columns 3
    space:1
    t(["ZFS pool"])
    space:1
    r["Root Dataset"]
    rvol["Root Key"]
    svol["SSH / Tailscale Keys"]
  end
  space:5
  rkey["Decrypted Root Key"]
  space
  sshd
  space
  skey["Decrypted SSH / TS"]
  skey --> sshd
  rvol --> rkey
  rkey --"Unlocks"--> r
  svol --> skey
  space:5
  Passphrase
  space
  TPM
  TPM --> skey
  TPM --> rkey
  Passphrase --> rkey
  sshd --> Passphrase
```
