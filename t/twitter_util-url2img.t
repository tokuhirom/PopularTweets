use strict;
use warnings;
use utf8;
use Test::More;
use PopularTweets::TwitterUtil qw/tw_url2img/;

my @src = (
    'http://twitpic.com/4yfn06' => 'http://twitpic.com/show/large/4yfn06',
    'http://blog-imgs-47.fc2.com/y/a/r/yaraon/l_20110516202847.jpg' => 'http://blog-imgs-47.fc2.com/y/a/r/yaraon/l_20110516202847.jpg',
);

while (my ($src, $expected) = splice @src, 0, 2) {
    is tw_url2img($src), $expected;
}

done_testing;

