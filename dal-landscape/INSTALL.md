# Local or (Manual) OpenShift Installation

## Install on Mac
1. Install [Homebrew](https://brew.sh/)
2. `brew install node`
3. `git clone git@git.delta.com:jesse/dtl_landscape.git`

## Install on Linux
1. `git clone git@git.delta.com:jesse/dtl_landscape.git`
2. Please follow [this script](https://github.com/cncf/landscapeapp/blob/master/update_server/setup.template) to install correct versions of `nodejs` and other packages on Linux.

## Local development
The CNCF team recommends installing one or more landscapes as sibling directories to the landscapeapp. Then, you want to install the npm modules for landscapeapp but not for any of the landscapes. So, if you're in a directory called `${HOME}/dev`, you would do:
```sh
dev$ git clone git@git.delta.com:jesse/dtl_landscape.git
dev$ cd dtl_landscape/landscapeapp
dev$ npm install
```
Now, to use the local landscapeapp as a shared module you can add the following to your `~/.bash_profile`:
```sh
function y { PROJECT_PATH=`pwd` npm run --prefix ../landscapeapp "$@"; }
export -f y
# yf does a normal build and full test run
alias yf='y fetch'
alias yl='y check-links'
alias yq='y remove-quotes'
alias yp='y build && y open:dist'
# yo does a quick build and opens up the landscape in your browser
alias yo='y open:src'
```
Reload with `. ~/.bash_profile` and then use `yo`, `yf`, etc. to run functions on the landscape in your landscape directory. `a` will do a git pull on each of the project directories you specify and install any necessary node modules for landscapeapp.

* `y open:src` or alias `yo` (starts a development server) or
* `y build && y open:dist` (compiles and opens a production build for testing)

## Review build details
1. `y build`
1. `open dist/report.html`

## Adding addtional Lanscapes

If you wish to add additional landscapel you will also need to modify the `migrate.js` in the landscape module.  See the `extraLandscape` (currently assigned as the API landscape) and `thirdLandscape` as examples, with the `thirdLandscape` modeled after the `https://landscape.cncf.io/format=members` landscape.

# Docker for OpenShift - Manual Sandbox

The following is a manual deployment that may be done with Delta's Enterprise SBX Cluster, or local minishift/crc implementation.  However, for an enterprise deployment, please see the [INSTALL-OCP.md](./INSTALL-OCP.md)

In a Sandbox environment, you may issue the following from `${PROJECT_HOME}` after a successful production build
```shell
#Login
oc login --token=${MY_TOKEN} --server=https://api.sr1a1.paasdev.delta.com:6443
#Select project
oc project ${TARGET_PROJECT}
#Create a BuildConfig object in OpenShift
oc new-build --image-stream=nginx --binary=true --name=tech-landscape
#Start the build process from our local directory
oc start-build tech-landscape --from-dir=./dist
#Create Deploy Config Object
oc new-app tech-landscape:latest
#Expose the route
oc expose svc/tech-landscape
#Get your route and open in a browser (macosx)
open "http://$(oc get route tech-landscape -o=jsonpath='{.spec.host}')/"
```

## Updating data

After making your changes to `landscape.yml`, run `y fetch` to fetch any needed data and generate [processed_landscape.yml](processed_landscape.yml) and [data.json](. /src/data.json).

`y fetch` runs in 4 modes of increasingly aggressive downloading, with a default to easy. Reading data from the cache (meaning from processed_landscape.yml) means that no new data is fetched if the project/product already exists. The modes are:

| Data cached            | easy   | medium   | hard   | complete   |
|------------------------|--------|----------|--------|------------|
| **Crunchbase**         | true   | false    | false  | false      |
| **GitHub basic stats** | true   | false    | false  | false      |
| **GitHub start dates** | true   | true     | false  | false      |
| **Image data**         | true   | true     | true   | false      |

* **Easy** mode just fetches any data needed for new projects/products.
* **Medium** fetches Crunchbase and basic GitHub data for all projects/products.
* **Hard** also fetches GitHub start dates. These should not change so this should not be necessary.
* **Complete** also re-fetches all images. This is problematic because images tend to become unavailable (404) over time, even though the local cache is fine.

Easy mode (the default) is what you should use if you update `landscape.yml` and want to see the results locally. The Netlify build server runs easy mode, which makes it possible to just commit a change to landscape.yml and have the results reflected in production. Run with `npm run fetch`.

Medium mode is what is run by the update server, with commits back to the repo. It needs to be run regularly to update last commit date, stars, and Crunchbase info. Run with `npm run update`.

Hard and complete modes should be unnecessary except in cases of possible data corruption. Even then, it's better to just delete any problematic entries from `processed_landscape.yml` and easy mode will recreate them with up-to-date information.

### Adding a custom image

If you can't find the right logo on the web, you can create a custom one and host it in this repo:

1. Save the logo to `src/hosted_logos/`, for example, `src/hosted_logos/apex.svg`. Use lowercase spinal case (i.e., hyphens) for the name.
1. Update landscape.yml, for example, `logo: ./src/hosted_logos/apex.svg`. The location must start with`./src/hosted_logos`.
1. If you've updated the local logo since a previous commit, you need to delete the cached version in `.src/cached_logos/`. E.g., delete `./src/cached_logos/apex.svg`.
1. Update `processed_landscape.yml` with `npm run fetch`.
1. Commit and push. Double-check your work in the Netlify preview after opening a pull request.