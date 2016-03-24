# WebService Food2Fork

[Food2Fork](http://food2fork.com) is a collection of recipes from difference [sources](http://food2fork.com/publishers).  This is a Perl 6 wrapper around their [API](http://food2fork.com/about/api)

## Installation

```
panda install WebService::Food2Fork
```

## Usage

### Creating a link

``` perl6
use WebService::Food2Fork;

my $yum = Food2Fork.new(
              key => 'API Key',   # Required
              cache => ':memory:' # Optional
              );
```

### Searching

``` perl6
my $food = $yum.search('pizza');
```

### Get a recipe

``` perl6
my $time-to-cook = $yum.get('recipe-id');
```

### Caching Results

Using the free tier?  You can use a cache with expiration.  Use `:memory:` as the database to have a temporary database.

By default, searches are cached for 15 minutes.  Recipes are cached for 24 hours.  You can change this.

``` perl6
use WebService::Food2Fork;

my $yum = Food2Fork.new(
              key => 'API Key',    # Required
              cache => ':memory:', # Optional
              cache_search => 15,  # 15 minutes
              cache_recipe => 1440 # 1 day
              );
```

# Acknowledgements

 * [Food2Fork API](http://food2fork.com/about/api)
 * [Net::Curl](https://github.com/azawawi/perl6-net-curl)
 * [JSON::Fast](https://github.com/timo/json_fast)
 * [DBIish](https://github.com/perl6/DBIish)
