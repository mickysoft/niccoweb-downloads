# Niccoweb downloads

Runtime packages of the Niccoweb apps for Microsoft Dynamics 365 Business Central **on-premises**.
A runtime package installs and runs like the app, without its source code. Each download is a zip
with the `.runtime.app` file inside.

| App | Business Central 29 | Business Central 14 |
|---|---|---|
| NW Core (required by every Niccoweb app) | [NW-Core-BC29.runtime.zip](https://github.com/mickysoft/niccoweb-downloads/releases/download/nw-core-bc29/NW-Core-BC29.runtime.zip) | [NW-Core-BC14.runtime.zip](https://github.com/mickysoft/niccoweb-downloads/releases/download/nw-core-bc14/NW-Core-BC14.runtime.zip) |
| NCW Replication Engine | [NCW-Replication-Engine-BC29.runtime.zip](https://github.com/mickysoft/niccoweb-downloads/releases/download/replication-engine-bc29/NCW-Replication-Engine-BC29.runtime.zip) | [NCW-Replication-Engine-BC14.runtime.zip](https://github.com/mickysoft/niccoweb-downloads/releases/download/replication-engine-bc14/NCW-Replication-Engine-BC14.runtime.zip) |

The links always give the latest version. The version of each file is in its release notes
([Releases](https://github.com/mickysoft/niccoweb-downloads/releases)).

## Before installing

- Each package is built with the latest update of its Business Central version available at
  build time. Install it on that update or a later one of the same version.
- Install **NW Core first**: the other apps depend on it.
- The apps need a Niccoweb license, activated in Business Central (**NCW Licenses**). Without
  it they install but do nothing. Trials can be requested from the same page.

## Installing (Business Central Administration Shell)

```powershell
$si = 'BC'   # your server instance (on BC14 usually 'NAV')
Publish-NAVApp -ServerInstance $si -Path .\NW-Core-BC29.runtime.app -SkipVerification
Sync-NAVApp    -ServerInstance $si -Name 'NCW Core' -Tenant default
Install-NAVApp -ServerInstance $si -Name 'NCW Core' -Tenant default
```

Then the same for the app. To upgrade an installed version, publish the new file, run
`Sync-NAVApp` and `Start-NAVAppDataUpgrade` instead of `Install-NAVApp`. On BC14 NW Core is
named `NW Core`.

If publishing reports a license error for the app's objects, or for anything else, contact
[Niccoweb support](https://www.niccoweb.com/p/support.html).

## Documentation

- [NCW Replication Engine](https://www.niccoweb.com/p/replication-engine.html) ·
  [configuration guide](https://www.niccoweb.com/p/replication-engine-help.html)
- [NW Core](https://www.niccoweb.com/p/nw-core.html) ·
  [documentation](https://www.niccoweb.com/p/nw-core-documentation.html)

Business Central online cannot install these packages: for it, contact Niccoweb.
