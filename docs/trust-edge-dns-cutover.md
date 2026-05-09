# Trust Edge DNS Cutover

Live domain: `soundlites.io`

Current authoritative DNS provider: Trust Edge.

Trust Edge authoritative zone is now created and answering on `ns1.trustedge.gt`
and `ns2.trustedge.gt`.

Trust Edge IDs:

```text
website_id=cae47aa8-c7c1-4897-a503-dfe3967b5609
domain_id=83e55a4c-a4da-4f54-a2f9-992b435d37f9
staging_website_id=0774c59e-a135-4b1c-a607-ac6368fb7d9c
staging_domain_id=4c9e10ee-db1c-4581-b5b8-671dbf4f76a1
```

## Current Live Records

These records are active in the Trust Edge DNS zone as of 2026-05-08:

```text
@                     A      66.23.201.82
staging              A      66.23.201.82
www                   CNAME  soundlites.io.
@                     MX     10 fwd1.porkbun.com.
@                     MX     20 fwd2.porkbun.com.
@                     TXT    google-site-verification=eXreDjIpBpYSaZdyupnnqOgrJL0PcmS5zkXmQPASllQ
@                     TXT    v=spf1 include:_spf.porkbun.com ~all
_dmarc                TXT    v=DMARC1; p=quarantine; rua=mailto:25f8c5e6@mxtoolbox.dmarc-report.com; ruf=mailto:25f8c5e6@forensics.dmarc-report.com; fo=1
gws._domainkey        TXT    v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmYX4BCu+eIfCEG/CToKTtcjfIdpyktTKvF2JfKxWkw8wPa7c4tPYTQxu1J/dcAtS+hN/xvPwhmN3ANu8FTeO6yyROuYsOpu+eNfvdQBcVC096VnGVVR8/0+YfERd4iOrlJ1iuBx4ksVIZqqWVdKqovE5m84NNgoqtYsAWJbJvd49hfTL1twPou918WKjArWSTNfAKaKl9AhXHe2eoBwLihvITqGLH9UNd9azfi2/OrWLS4Ayu8iPjC6U1yMRCMZetLchfbuVqCknjYdc5EttoYYmuxppYfPeKJ4PUiOQg8l1FzVK6/m0sNoX7CRvaSZNL/7VFNa0uqQwdaIaET+8kwIDAQAB
```

## Required Trust Edge Checks

These passed directly against both Trust Edge nameservers on 2026-05-08:

```sh
for ns in ns1.trustedge.gt ns2.trustedge.gt; do
  dig +short @"$ns" soundlites.io SOA
  dig +short @"$ns" soundlites.io NS
  dig +short @"$ns" soundlites.io A
  dig +short @"$ns" www.soundlites.io CNAME
  dig +short @"$ns" soundlites.io MX
  dig +short @"$ns" soundlites.io TXT
  dig +short @"$ns" _dmarc.soundlites.io TXT
  dig +short @"$ns" gws._domainkey.soundlites.io TXT
done
```

Expected: all queries return real records, not `REFUSED`.

Current result: passing. Public resolvers `1.1.1.1` and `8.8.8.8` also return
apex `A 66.23.201.82` and `www CNAME soundlites.io.`.

## Porkbun Nameserver Cutover

Porkbun API accepted the nameserver update on 2026-05-06:

```text
ns1.trustedge.gt
ns2.trustedge.gt
```

Porkbun API readback returned the Trust Edge nameservers, and public resolver
checks now return Trust Edge:

```sh
dig NS soundlites.io +trace
dig NS soundlites.io +short
dig NS soundlites.io @8.8.8.8 +short
dig NS soundlites.io @1.1.1.1 +short
```

## GitHub Deploy State

The repo contains the standard Trust Edge workflow:

```text
.github/workflows/deploy-trust-edge.yml
scripts/prepare-trust-edge-deploy.sh
```

GitHub variables:

```text
TRUST_EDGE_DEPLOY_ENABLED=true
TRUST_EDGE_REMOTE_ROOT=/
TRUST_EDGE_VERIFY_URLS=http://soundlites.io/
https://soundlites.io/
```

Deploy is enabled for manual `workflow_dispatch` runs after scoped FTP
credential provisioning.

GitHub secrets provisioned on 2026-05-06:

```text
TRUST_EDGE_FTP_SERVER
TRUST_EDGE_FTP_USERNAME
TRUST_EDGE_FTP_PASSWORD
```

Trust Edge FTP account:

```text
username=deploy-soundlites-site@soundlites.io
home_dir=public_html
1Password item=Trust Edge FTP - soundlites.io - soundlites-site
```

Trust Edge staging FTP account:

```text
username=deploy-soundlites-site-staging@staging.soundlites.io
home_dir=public_html
1Password item=Trust Edge FTP - staging.soundlites.io - soundlites-site
```

Provisioning command used:

```sh
/Users/elderjerezjr/Dev/trustedge-baselines/scripts/provision-trust-edge-ftp.sh \
  --repo editbyjunior/soundlites-site \
  --domain soundlites.io \
  --vault "Personal" \
  --org-id "$ENHANCE_ORG_ID" \
  --website-id "cae47aa8-c7c1-4897-a503-dfe3967b5609" \
  --api-base "$ENHANCE_API_BASE" \
  --api-token "$ENHANCE_API_TOKEN" \
  --ftp-server "66.23.201.82" \
  --home-dir public_html \
  --remote-root / \
  --verify-url http://soundlites.io/ \
  --verify-url https://soundlites.io/
```

Only add `--run-deploy` after the target website object, FTP scope, and deploy
payload have been verified.

## Final Verification

GitHub Actions deploy run `25591587986` completed successfully against commit
`3c431899703ab1e0e86dc43b3b8035d0d4b8dcfc`.

Verification evidence from that run:

```text
http://soundlites.io/   HTTP/1.1 200 OK, nginx, Content-Length 981
https://soundlites.io/  HTTP/2 200, nginx, Content-Length 981
```

Local forced-IP check also returns the baseline page from Trust Edge:

```sh
curl --resolve soundlites.io:80:66.23.201.82 http://soundlites.io/
```

Certificate readback against `66.23.201.82:443` with SNI `soundlites.io`:

```text
issuer=C=US, O=Let's Encrypt, CN=R12
subject=CN=soundlites.io
notBefore=May  9 03:22:11 2026 GMT
notAfter=Aug  7 03:22:10 2026 GMT
```

## Staging Verification

GitHub Actions staging deploy run `25591960580` completed successfully against
commit `67741b8f5c0185bbb5dd8b5f220edce920599500`.

Verification evidence from that run:

```text
http://staging.soundlites.io/   200
https://staging.soundlites.io/  200
```

Local forced-IP checks also return the baseline page from Trust Edge:

```sh
curl --resolve staging.soundlites.io:80:66.23.201.82 http://staging.soundlites.io/
curl --resolve staging.soundlites.io:443:66.23.201.82 https://staging.soundlites.io/
```

Certificate readback against `66.23.201.82:443` with SNI
`staging.soundlites.io`:

```text
issuer=C=US, O=Let's Encrypt, CN=R13
subject=CN=staging.soundlites.io
notBefore=May  9 03:40:07 2026 GMT
notAfter=Aug  7 03:40:06 2026 GMT
```
