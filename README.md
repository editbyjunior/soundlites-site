# soundlites-site

Soundlites website workspace for `soundlites.io`.

## Links

- Live domain: https://soundlites.io
- GitHub repo: https://github.com/editbyjunior/soundlites-site
- Staging target: `https://staging.soundlites.io` after a dedicated Trust Edge
  site, DNS record, and scoped deploy credentials are provisioned

## Trust Edge status

This repo has the standard Trust Edge GitHub Actions deploy scaffold in
`.github/workflows/deploy-trust-edge.yml`.

`soundlites.io` now delegates publicly to Trust Edge nameservers:
`ns1.trustedge.gt` and `ns2.trustedge.gt`.

Before marking production live, verify SOA, NS, A, CNAME, MX, TXT, SPF, DKIM,
DMARC, HTTP, and HTTPS against public resolvers and the live domain. The first
static Trust Edge payload is a temporary `index.html` holding page.

## Staging

Recommended setup:

1. Create a separate Trust Edge website for `staging.soundlites.io`.
2. Add DNS for `staging.soundlites.io` to that website.
3. Provision a separate FTP user and GitHub `staging` environment using the same
   secret and variable names as production.
4. Use the manual workflow `target` input to deploy either `production` or
   `staging`.

Do not reuse the production FTP account for staging.
