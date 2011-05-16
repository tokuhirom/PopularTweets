use strict;
use warnings;
use utf8;
use Test::More;
use PopularTweets::LongifyURL;

my $l = PopularTweets::LongifyURL->new();
is($l->longify('http://bit.ly/lrQGRN'), 'http://www.nnistar.com/gmap/rain.html');

done_testing;

