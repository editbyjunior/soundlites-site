# Trust Edge DNS Cutover

Live domain: `soundlites.io`

Current authoritative DNS provider: Porkbun.

Do not point `soundlites.io` nameservers to Trust Edge until `ns1.trustedge.gt`
and `ns2.trustedge.gt` answer authoritatively for the zone.

## Current Live Records To Mirror

Mirror these records into the Trust Edge DNS zone before nameserver cutover.

```text
@                     A      44.227.65.245
@                     A      44.227.76.166
www                   CNAME  pixie.porkbun.com.
@                     MX     10 fwd1.porkbun.com.
@                     MX     20 fwd2.porkbun.com.
@                     TXT    google-site-verification=eXreDjIpBpYSaZdyupnnqOgrJL0PcmS5zkXmQPASllQ
@                     TXT    v=spf1 include:_spf.porkbun.com ~all
_dmarc                TXT    v=DMARC1; p=quarantine; rua=mailto:25f8c5e6@mxtoolbox.dmarc-report.com; ruf=mailto:25f8c5e6@forensics.dmarc-report.com; fo=1
gws._domainkey        TXT    v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmYX4BCu+eIfCEG/CToKTtcjfIdpyktTKvF2JfKxWkw8wPa7c4tPYTQxu1J/dcAtS+hN/xvPwhmN3ANu8FTeO6yyROuYsOpu+eNfvdQBcVC096VnGVVR8/0+YfERd4iOrlJ1iuBx4ksVIZqqWVdKqovE5m84NNgoqtYsAWJbJvd49hfTL1twPou918WKjArWSTNfAKaKl9AhXHe2eoBwLihvITqGLH9UNd9azfi2/OrWLS4Ayu8iPjC6U1yMRCMZetLchfbuVqCknjYdc5EttoYYmuxppYfPeKJ4PUiOQg8l1FzVK6/m0sNoX7CRvaSZNL/7VFNa0uqQwdaIaET+8kwIDAQAB
```

## Required Trust Edge Checks

Run these before changing Porkbun nameservers:

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

## GitHub Deploy State

The repo contains the standard Trust Edge workflow:

```text
.github/workflows/deploy-trust-edge.yml
scripts/prepare-trust-edge-deploy.sh
```

GitHub variables:

```text
TRUST_EDGE_DEPLOY_ENABLED=false
TRUST_EDGE_REMOTE_ROOT=/
TRUST_EDGE_VERIFY_URLS=http://soundlites.io/
https://soundlites.io/
```

Keep `TRUST_EDGE_DEPLOY_ENABLED=false` until scoped FTP credentials exist and
the first manual deploy is ready to test.

Required GitHub secrets before deploy:

```text
TRUST_EDGE_FTP_SERVER
TRUST_EDGE_FTP_USERNAME
TRUST_EDGE_FTP_PASSWORD
```

Use the Trust Edge baseline script after the `soundlites.io` website ID is
known:

```sh
/Users/elderjerezjr/Dev/trustedge-baselines/scripts/provision-trust-edge-ftp.sh \
  --repo editbyjunior/soundlites-site \
  --domain soundlites.io \
  --vault "Private" \
  --org-id "$ENHANCE_ORG_ID" \
  --website-id "$SOUNDLITES_TRUST_EDGE_WEBSITE_ID" \
  --api-base "$ENHANCE_API_BASE" \
  --api-token-op-ref "op://Private/Trust Edge API - jr@progressiveone.com/ENHANCE_API_TOKEN" \
  --ftp-server "66.23.201.82" \
  --home-dir public_html \
  --remote-root / \
  --verify-url http://soundlites.io/ \
  --verify-url https://soundlites.io/
```

Only add `--run-deploy` after the target website object, FTP scope, and deploy
payload have been verified.
