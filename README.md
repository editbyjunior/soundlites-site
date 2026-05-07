# soundlites-site

Soundlites website workspace for `soundlites.io`.

## Links

- Live domain: https://soundlites.io
- GitHub repo: https://github.com/editbyjunior/soundlites-site

## Trust Edge status

This repo has the standard Trust Edge GitHub Actions deploy scaffold in
`.github/workflows/deploy-trust-edge.yml`.

`soundlites.io` now delegates publicly to Trust Edge nameservers:
`ns1.trustedge.gt` and `ns2.trustedge.gt`.

Before marking production live, verify SOA, NS, A, CNAME, MX, TXT, SPF, DKIM,
DMARC, HTTP, and HTTPS against public resolvers and the live domain. The first
static Trust Edge payload is a temporary `index.html` holding page.
