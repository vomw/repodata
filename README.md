[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](https://codeberg.org/IzzyOnDroid/.profile/src/branch/master/CODE_OF_CONDUCT.md) [![IzzyOnDroid Open Collective](https://img.shields.io/opencollective/all/IzzyOnDroid?label=OpenCollective+Supporters&logo=opencollective&color=52A7A7)](https://opencollective.com/izzyondroid)

## Repo Metadata
This repository contains the metadata for the Apps available at the [IzzyOnDroid repo](https://apt.izzysoft.de/fdroid) (`metadata/*.yml`). It further contains:

* the [JSON Schema](https://json-schema.org/) for validating said metadata (`schemas/metadata.json`)
* config data for the repo (`config/*`)
* some scripts we use with this repo, e.g. to verify metadata (`tools/*`)
* git hook scripts (in `hooks/`) make use of this. e.g. to ensure committed metadata files are syntactically correct and having all required fields

What this repository does _not_ contain is the `*.apk` files themselves (`repo/` resp. `archive/`), or the source code of the apps in this repo (`build/*`).


## Contributing to this repo
While we reorgnize our repository related processes to be controlled via this repo (for which the availability of this repo is the first step), we will gradually open it for more activity:

* [x] making it available so you can see the underlying metadata
* [x] allowing for PRs to _adjust existing_ metadata (e.g. updating URLs/developer data)
* [x] allowing for PRs to remove apps
* [ ] allowing for PRs to add new apps

At a later point, we also might introduce ways for more localization/translations.

We ask all contributors to adhere to our Contributor Covenant, as linked at the top of this page. Translation of app metadata however should rather be done in the corresponding app's repository – preferably using [Fastlane structures](https://izzyondroid.org/docs/general/Fastlane/). Helping the apps' developers establishing and maintaining those, also helps improving not only our repository – but also the apps' representation in other places they might be listed at, so doing it that way is like feeding multiple birds with one bread 😉.


## Other support options
* to help us covering costs for e.g. servers, material for fairs, etc – see e.g. the link to our Open Collective at the top of the page 🤗
* if you have questions towards an app (to be?) listed in our repo, you can use the issue tracker here
* for other parts of the IzzyOnDroid project (e.g. our [Download Statistics](https://stats.izzyondroid.org/), our [Reproducible Builds](https://izzyondroid.org/about/security/ReproducibleBuilds/), or our [Website](https://izzyondroid.org/)), first check [our other repositories here](https://codeberg.org/IzzyOnDroid) if you can find a matching one, and use the issue tracker there
* our [Website](https://izzyondroid.org/) is also there to help you with [general information](https://izzyondroid.org/about/), [Documentation](https://izzyondroid.org/docs/), [FAQ](https://izzyondroid.org/faq/) – and, when needed, ways to [contact](https://izzyondroid.org/contact/) us.


## License
This repository with its all content is licensed as AGPL-3.0-or-later (see the `LICENSE.txt`), unless explicitly stated otherwise:

> This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License version 3 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
>
> This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the [GNU Affero General Public License](https://www.gnu.org/licenses/agpl.txt) for more details.
