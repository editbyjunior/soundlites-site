# soundlites-site

Soundlites website workspace for `soundlites.io`.

## Links

- Live domain: https://soundlites.io
- GitHub repo: https://github.com/editbyjunior/soundlites-site
- Staging target: https://staging.soundlites.io

## Trust Edge status

This repo has the standard Trust Edge GitHub Actions deploy scaffold in
`.github/workflows/deploy-trust-edge.yml`.

`soundlites.io` now delegates publicly to Trust Edge nameservers:
`ns1.trustedge.gt` and `ns2.trustedge.gt`.

Before marking production live, verify SOA, NS, A, CNAME, MX, TXT, SPF, DKIM,
DMARC, HTTP, and HTTPS against public resolvers and the live domain. The first
static Trust Edge payload is a temporary `index.html` holding page.

## Staging

Current setup:

1. `staging.soundlites.io` has a separate Trust Edge website.
2. DNS points `staging.soundlites.io` to Trust Edge.
3. GitHub has `production` and `staging` environments with separate deploy
   credentials.
4. Use the manual workflow `target` input to deploy either `production` or
   `staging`.

Run either target from `main` and provide the full 40-character SHA for the
exact `main` commit being deployed. The workflow confirms that SHA before
checkout and queues overlapping FTP uploads for the selected target instead of
cancelling an upload in progress. Target-based environment selection and its
separate credentials remain unchanged.

Do not reuse the production FTP account for staging.

## Deploy transport

The workflow's `transport` input picks how the payload reaches Trust Edge:

- `sftp` (default): uploads over SSH with `scripts/upload-trust-edge-sftp.sh`.
  The server is checked only against a pinned host key with strict checking;
  the workflow never runs `ssh-keyscan` or trusts a key on first use.
- `ftps`: the previous FTP upload with verified TLS (`--ssl-reqd`). It stays
  for rollback, but fails until the FTP service presents a publicly trusted
  certificate for the hostname used (EDI-49).

SFTP needs these secrets in each GitHub environment (`production` and
`staging`), each with that website's own values:

| Secret | Value |
| --- | --- |
| `TRUST_EDGE_SSH_HOST` | Server address the Enhance panel shows for SSH |
| `TRUST_EDGE_SSH_USERNAME` | The website's SSH username from the panel |
| `TRUST_EDGE_SSH_PRIVATE_KEY` | Private half of a deploy-only key whose public half is added under the website's Developer tools |
| `TRUST_EDGE_SSH_KNOWN_HOSTS` | One known_hosts line for the server, pinned out of band |

Optional environment variables: `TRUST_EDGE_SSH_PORT` (default `22`) and
`TRUST_EDGE_SSH_REMOTE_ROOT` (default `public_html`, relative to the SSH home
directory).

Pinning the host key: from a trusted machine, connect once with
`ssh -o StrictHostKeyChecking=ask <user>@<host>`, compare the fingerprint
with a second network or an independent source, then copy the server's line
from `~/.ssh/known_hosts` (use `ssh-keygen -F <host>`; the host must match
`TRUST_EDGE_SSH_HOST`, written `[host]:port` for a non-22 port). Each run logs
the pinned fingerprint so it can be compared with the recorded value.

Keep the FTP secrets until an SFTP deploy has passed on staging and then
production.
