# soundlites-site

Soundlites website workspace for `soundlites.io`.

## Links

- Live domain: https://soundlites.io
- GitHub repo: https://github.com/editbyjunior/soundlites-site

## Trust Edge status

This repo has the standard Trust Edge GitHub Actions deploy scaffold in
`.github/workflows/deploy-trust-edge.yml`.

Do not change `soundlites.io` nameservers to Trust Edge until Trust Edge is
authoritative-ready for the domain. As of the last check, Porkbun is still the
live DNS provider and direct SOA checks against `ns1.trustedge.gt` and
`ns2.trustedge.gt` returned `REFUSED`.

Before nameserver cutover, mirror the live Porkbun DNS records into Trust Edge
and verify SOA, NS, A, CNAME, MX, TXT, SPF, DKIM, and DMARC directly against
the Trust Edge nameservers.
