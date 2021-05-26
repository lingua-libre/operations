# Operations

!!! This README is a work in progress !!!

This repository contains configuration files and scripts regarding *Lingua Libre*'s installation and various day-to-day maintenance procedures.
This README file serves as a reference sheet and documentation on these matters.

## Installing Lingua Libre

The current architecture is two machines:
* first one has lingualibre.org site (public machine),
* second one has the Blazegraph triplestore (possibly non-public).

### Requirements
- Debian 8+
- php7.0 php7.0-fpm php7.0-mysql php7.0-json php7.0-gd php7.0-mbstring php7.0-xml php7.0-zip php7.0-curl php7.0-apcu php7.0-intl
- composer
- npm
- ffmpeg

### Installation
Get the `deploy.sh` script and put it where the mediawiki installation should be installed and execute it
import db backup
import files backup

## Maintenance scripts

### Details
- `crontab` : 1) Run maintenance scripts on the production instance; 2) Run maintenance scripts on the v2 instance; 3) reload nginx and eventually renew the SSL certificates.
- `create_datasets.sh` : download and zip all available audios into human friendly zips, one zip per language.
  - runs [`CommonsDownloadTool/commons_download_tool.py`](https://github.com/lingua-libre/CommonsDownloadTool/blob/master/commons_download_tool.py) daily.
  - produces page https://lingualibre.org/datasets/
- `deploy.sh` : {to complete}

## Blazegraph

See installation on [this page on Lingua Libre](https://lingualibre.org/wiki/Help:Documentation_op%C3%A9rationelle_Mediawiki) and the [official (Wikimedia-flavour) Blazegraph installation](https://github.com/wikimedia/wikidata-query-rdf/blob/master/docs/getting-started.md).

systemd units for Blazegraph (Blazegraph itself and the updater) are available in this repository in `systemd` directory.
