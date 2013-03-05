---
title: Using the PostGIS Tiger Geocoder
author: Donald Curtis
tags: sqlalchemy, postgis, postgres
---

In the [PostGIS manual](http://postgis.net/docs/manual-2.0/) there is
a section entitled
[Installing, Upgrading Tiger Geocoder and loading data](http://postgis.net/docs/manual-2.0/postgis_installation.html#loading_extras_tiger_geocoder)
which briefly introduces a geocoder that runs inside of
[Postgres](http://www.postgresql.org/). Basically this can serve as a
replacement for online webservices---provided by Google, Yahoo,
etc.---which take an address as input, normalize it, and provide one
or more possible latitude and longitude coordinates. The benefit of
this approach is that you can geolocate as many addresses as you want
but the downside is that you have to add the data and manage your own
dataset. It may also not be as up-to-date since the current method
relies on the
[TIGER/Line Shapefiles](http://www.census.gov/geo/maps-data/data/tiger.html)
provided by the US Census Bureau. The government does a lot of weird
things but providing this data is one time I'm glad I pay taxes.

## Overview

Data is loaded at a *state* level; during the install process an
`ARRAY` of state abbreviations is passed to a function that generates
a script to load those specific states. All the data that gets
installed by this process lives in its own set of
[schemas](http://www.postgresql.org/docs/9.2/static/ddl-schemas.html).
In the end you can always drop the schemas to remove the data with
little headache---I assume you'd want to call
[`DROP SCHEMA`](http://www.postgresql.org/docs/current/static/sql-dropschema.html)
with the `CASCADE` to fully cleanup after yourself. I know very little about schemas but my naive understanding is that they are like namespaces inside a database.


### Installed Schema

The `tiger` schema holds all the geolocation information for *all*
states that get loaded. These are _base_ tables which all the
individual state tables
[inherit from](http://www.postgresql.org/docs/9.2/static/ddl-inherit.html).
This schema becomes part of the database's
[`search_path`](http://www.postgresql.org/docs/9.2/static/ddl-schemas.html#DDL-SCHEMAS-PATH)
as part of the setup process.

The `tiger_data` schema is where the data for each state actually
lives. Each state has its own table that inherits from the tables in
the `tiger` schema. So the tables in the `tiger` schema are basically
just aggregating the individual tables in the `tiger_data` schema. For
the most part we don't see this---its not in the `search_path`.

The `tiger_staging` schema exists but is empty. From digging through
the source it seems this is a temporary holding area for the import of
TIGER/Line shape files used to cleanup the column names---the default
fields are postfixed with `10`. It is my guess that this schema can be
removed after the data is imported.



## Setup Specializations

For the most part you should just download the PostGIS tarball
[http://postgis.net/stuff/postgis-2.0.3SVN.tar.gz](http://postgis.net/stuff/postgis-2.0.3SVN.tar.gz)
and read the `README` file in the
`postgis-2.0.3SVN/extras/tiger_geocoder/tiger_2010` directory. I made
a few deviations from the `README` instructions that I wanted to
outline here.

I wanted access to the data in the same database that I will be
storing app data so I changed the `THEDB` variable in
`create_geocode.sh` and the `PGDATABASE` variable in
`tiger_loader.sql` to point to my database. I thought about making
this data it's own database but my app needs access to the state,
county, and zcta (zipcode tablation area) geometries so I figured it
was better to live in the same database.
