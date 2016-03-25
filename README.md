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

my $yum = Food2Fork.new(:key<API Key>);
```

### Searching

``` perl6
my $food = $yum.search('bbq chicken');
```

$food looks something like:

``` perl6
{
  count   => 30.Int,
  recipes => [
    {
      f2f_url       => "http://food2fork.com/view/41470".Str,
      image_url     => "http://static.food2fork.com/BBQChickenPizzawithCauliflowerCrust5004699695624ce.jpg".Str,
      publisher     => "Closet Cooking".Str,
      publisher_url => "http://closetcooking.com".Str,
      recipe_id     => "41470".Str,
      social_rank   => 99.9999999999994.Rat,
      source_url    => "http://www.closetcooking.com/2013/02/cauliflower-pizza-crust-with-bbq.html".Str,
      title         => "Cauliflower Pizza Crust (with BBQ Chicken Pizza)".Str,
    },
    ...
  ]
}
```

### Caching Results

Using the free tier?  You can use a cache with expiration.  Use `:memory:` as the database to have a temporary database.

By default, searches are cached for 15 minutes.  Recipes are cached for 24 hours.  You can change this.  *There currently isn't an option not to cache*.

``` perl6
use WebService::Food2Fork;

my $yum = Food2Fork.new(
              :key<API Key>,      # Required
              :cache<:memory:>,   # Optional
              :cache_search<15>,  # 15 minutes
              :cache_recipe<1440> # 1 day
              );
```

We'll attempt to use tables `f2f_search` and `f2f_recipe` or we'll die trying...

# Acknowledgements

 * [Food2Fork API](http://food2fork.com/about/api)
 * [Net::Curl](https://github.com/azawawi/perl6-net-curl)
 * [JSON::Fast](https://github.com/timo/json_fast)
 * [DBIish](https://github.com/perl6/DBIish)
