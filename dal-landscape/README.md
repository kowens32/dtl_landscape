[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/1767/badge)](https://bestpractices.coreinfrastructure.org/projects/1767) [![Dependency Status](https://img.shields.io/david/cncf/landscape.svg?style=flat-square)](https://david-dm.org/cncf/landscape) [![Netlify Status](https://api.netlify.com/api/v1/badges/91337728-8166-4c8f-bc39-9159bf97dcbc/deploy-status)](https://app.netlify.com/sites/landscape/deploys)

# Delta Technology Landscape
- [Delta Technology Landscape](#delta-technology-landscape)
  - [Trail Map](#trail-map)
  - [Interactive Version](#interactive-version)
  - [New Entries](#new-entries)
  - [Logos](#logos)
  - [Don't Use SVGs with Embedded Text](#dont-use-svgs-with-embedded-text)
  - [Corrections](#corrections)
  - [External Data](#external-data)
  - [Crunchbase Requirement](#crunchbase-requirement)
  - [License](#license)
  - [Installation](#installation)
  - [Adjusting the Landscape View](#adjusting-the-landscape-view)

The Delta Technology Landscape Project, based upon the [CNCF](https://l.cncf.io) is intended as a map through the previously uncharted terrain of Delta's collection of approved technologies. This attempts to categorize most of the services and product offerings at Delta. 

The software for the interactive landscape has been sourced to https://git.delta.com/ea/dal-landscape.git where it is used for other landscapes as well. This repo includes all of the data and images specific to the CNCF landscapes.

## Trail Map

The Trail Map provides an overview for enterprises starting their development journey.


## Interactive Version

Please see [landscape.delta.com](https://landscape.delta.com).

## New Entries
If you think your project or service should be included, please open a issue to add it to [landscape.yml](landscape.yml). 

When creating new entries, the only 4 required fields are name, homepage_url, logo, and crunchbase. It's generally easier to have the landscape fetch a (required) SVG by adding it's URL rather than saving it yourself in the hosted_logos folder. If you add a repo_url the card will be white instead of grey.

```yml
          - item:
            name: (REQUIRED) Unique_name
            description: Something
            project: standard | emerging | contained
            delta_owner: Name
            homepage_url: (REQUIRED) 'https://to_someting_real'
            stock_ticker: DOW
            logo: (REQUIRED) dynatrace.svg
            open_source: false | true
            twitter: 'https://www.twitter.com/....'
            crunchbase: (REQUIRED) 'https://www.crunchbase.com/organization/dynatrace-software'

```

other supported attributes include the following. Please consult code for detailed behaviors.

```yml
    branch:
    project:
    url_for_bestpractices:
    enduser:
    allow_duplicate_repo:
    unnamed_organization:
```
## Logos

The following rules will produce the most readable and attractive logos:

1. We require SVGs, as they are smaller, display correctly at any scale, and work on all modern browsers. If you only have the logo in another vector format (like AI or EPS), please open an issue and we'll convert it to an SVG for you, or you can often do it yourself at https://cloudconvert.com/. Note that you may need to zip your file to attach it to a Gitlab issue. Please note that we require pure SVGs and will reject SVGs that contain embedded PNGs, since they have the same problems of being bigger and not scaling seamlessly. We also require that SVGs convert fonts to outlines so that they will render correctly whether or not a font is installed. See [Proper SVGs](#proper-svgs) below.
1. When multiple variants exist, use stacked (not horizontal) logos. For example, we use the second column (stacked), not the first (horizontal), of CNCF project [logos](https://github.com/cncf/artwork/#cncf-incubating-logos).
1. Don't use reversed logos (i.e., with a non-white, non-transparent background color). If you only have a reversed logo, create one.
1. Logos must include the company, product or project name in English. It's fine to also include words from another language. If you don't have a version of your logo with the name in it, please open an issue and we'll create one for you (and please specify the font).
1. Match the item name to the English words in the logos. So an Acme Rocket logo that shows "Rocket" should have product name "Rocket", while if the logo shows "Acme Rocket", the product name should be "Acme Rocket". Otherwise, logos looks out of place when you sort alphabetically.
1. Logos should include a company and/or product name but no tagline, which allows them to be larger and more readable. The only exception is if the only format that the logo is ever shown includes the tagline.
1. Google images is often the best way to find a good version of the logo (but ensure it's the up-to-date version). Search for [something logo filetype:svg](https://www.google.com/search?q=something+logo&tbs=ift:svg,imgo:1&tbm=isch) but substitute your project or product name for something.


## Don't Use SVGs with Embedded Text

[Directions](https://github.com/cncf/landscapeapp/blob/master/README.md#svgs-cant-include-text) for fixing.

## Corrections

Please open a issue or pull request with edits to [landscape.yml](landscape.yml). The file [processed_landscape.yml](processed_landscape.yml) is generated and so should never be edited directly.

## External Data

The canonical source for all data is [landscape.yml](landscape.yml). Once a day, we download data for projects and companies from the following sources:

* Project info from GitHub
* Funding info from [Crunchbase](https://www.crunchbase.com/)
* Market cap data from Yahoo Finance
* CII Best Practices Badge [data](https://bestpractices.coreinfrastructure.org/)

The update server enhances the source data with the fetched data and saves the result in [processed_landscape.yml](processed_landscape.yml) and as a JSON [file](https://landscape.cncf.io/data.json), the latter of which is what the app loads to display data.


## Crunchbase Requirement
The original CNCF Landscape project required all landscape entries to include a Crunchbase url. They used the Crunchbase API to fetch the backing organization and headquarters location and (if they exist), Twitter, LinkedIn, funding, parent organization, and stock ticker. 

Using an external source for this info saves effort in most cases, because most organizations are already listed. 

However, a Crunchbase license is prohibitivly expense for our IT requirements.  If the  `CRUNCHBASE_KEY` is present as an environment variable, the applicaiton will request the data from the Crunchbase API.  However, if the `CRUNCHBASE_KEY` evironment variable is NOT present, the data will not be requested and will leverage existing cached material in the `processed_landscape.yml`

## License

This repository contains data received from [Crunchbase](http://www.crunchbase.com) if the `CRUNCHBASE_KEY` is present as an environment variable . This data is not licensed pursuant to the Apache License. It is subject to Crunchbase’s Data Access Terms, available at [https://data.crunchbase.com/v3.1/docs/terms](https://data.crunchbase.com/v3.1/docs/terms), and is only permitted to be used with the Landscape Project if licensed.

Everything else is under the Apache License, Version 2.0, except for project and product logos, which are generally copyrighted by the company that created them, and are simply cached here for reliability. The trail map, static landscape, serverless landscape, and [landscape.yml](landscape.yml) file are alternatively available under the [Creative Commons Attribution 4.0 license](https://creativecommons.org/licenses/by/4.0/).


## Installation

You can install and run locally with the [install directions](./INSTALL.md). It's not necessary to install locally if you just want to edit [landscape.yml](landscape.yml). You can do so via the Gitlab web interface.

## Adjusting the Landscape View
The file `settings.yml` describes the key elements of a
landscape big picture. It specifies where to put various sections. 

All these elements should have `top`, `left`, `width` and `height` properties to
position them. `rows` and `cols` specify how much columns or rows we expect in a
given horizontal or vertical section. 

When we see that those elements can not fit the sections, we need to either increase
the width of all the horizontal sections, or increase height and amount of rows
in a single horitzontal section and adjust the position of sections below.

The best way to test that layout is ok, is to visit `/landscape`, and if it looks ok, run `PORT=3000 babel-node
tools/renderLandscape` and see the rendered png files, they are in `src/images`
folder
