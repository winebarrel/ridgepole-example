ridgepole-example
=================

## Installation
```sh
bundle install
mysql -u root -e "CREATE DATABASE blog"
bundle exec rake development:apply[blog]
```

## Export
```sh
bundle exec rake development:export[blog]
```

## Dry run
```sh
bundle exec rake development:dry-run[blog]
```

## Apply
```sh
bundle exec rake development:apply[blog]
```
