use v6;
use Net::Curl;
use Net::Curl::Easy;
use JSON::Fast;
use DBIish;

module WebService::Food2Fork {
  class Food2Fork is export {
    has Str $.key;
    has Str $.cache is rw = ':memory:';
    has Int $.cache_search is rw = 15;
    has Int $.cache_recipe is rw = 1440;
    has $!dbh;

    method !setup-db() {
      self!connect();

      my $search-table = $!dbh.prepare(q:to/SEARCH/);
        SELECT name FROM sqlite_master WHERE type='table' AND name='f2f_search'
      SEARCH
      $search-table.execute();

      if (($search-table.allrows().elems) == 0) {
        $!dbh.do(q:to/SEARCHCREATE/);
          CREATE TABLE f2f_search (
            search_query VARCHAR(255),
            search_result TEXT,
            search_time INT
          )
        SEARCHCREATE
      } else {
        my $clear = $!dbh.prepare(q:to/CLEARSEARCH/);
          DELETE FROM f2f_search WHERE search_time<?
        CLEARSEARCH
        my $old-time = (now.floor()) - ($.cache_search * 60);
        $clear.execute($old-time);
        $clear.finish;
      }
      $search-table.finish;

      my $recipe-table = $!dbh.prepare(q:to/RECIPE/);
        SELECT name FROM sqlite_master WHERE type='table' AND name='f2f_recipe'
      RECIPE
      $recipe-table.execute();

      if (($recipe-table.allrows().elems) == 0) {
        $!dbh.do(q:to/RECIPECREATE/);
          CREATE TABLE f2f_recipe (
            recipe_id VARCHAR(255),
            recipe_result TEXT,
            recipe_time INT
          )
        RECIPECREATE
      } else {
        my $clear = $!dbh.prepare(q:to/CLEARRECIPE/);
          DELETE FROM f2f_recipe WHERE recipe_time<?
        CLEARRECIPE
        my $old-time = (now.floor()) - ($.cache_search * 60);
        $clear.execute($old-time);
        $clear.finish;
      }
      $recipe-table.finish;
    }

    method !connect() {
      unless ($!dbh) {
        $!dbh = DBIish.connect('SQLite', :database($.cache), :RaiseError(True));
      }
    }

    method !disconnect() {
      if ($!dbh) {
        $!dbh.dispose();
      }

      $!dbh = False;
    }

    method !search-db(Str $query) {
      self!setup-db();

      my $search = $!dbh.prepare("SELECT search_result FROM f2f_search WHERE search_query = ? ");
      $search.execute($query);

      my @result = $search.fetchrow();
      return (@result.elems == 0) ?? False !! @result[0];
    }

    method !cache-db(Str $query, Str $result) {
      self!setup-db();

      my $search = $!dbh.prepare("INSERT INTO f2f_search (search_query, search_result, search_time) VALUES ( ? , ? , ? ) ");
      $search.execute($query, $result, now.floor());
      $search.finish;
    }

    method search(Str $query) {
      my $cache-result = self!search-db($query);
      if ($cache-result) {
        return from-json($cache-result);
      } else {
        my $query-url = $query;
        $query-url ~~ s:g/\s+/%20/;
        my $curl = Net::Curl::Easy.new(:url('http://food2fork.com/api/search?key=' ~ $.key ~ '&q=' ~ $query-url));
        my $result = $curl.download;
        if ($result) {
          self!cache-db($query, $result);
          return from-json($result);
        }
      }
      return False;
    }
  }
}
