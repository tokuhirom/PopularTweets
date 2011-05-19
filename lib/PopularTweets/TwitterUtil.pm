use strict;
use warnings;
use utf8;
use 5.010001;

package PopularTweets::TwitterUtil;
use parent qw/Exporter/;
use Time::Piece ();

our @EXPORT_OK = qw/tw_str2time tw_url2img/;

sub tw_str2time($) {
    Time::Piece->strptime(shift, '%a %b %d %T %z %Y')->epoch;
}

sub tw_url2img($) {
    my $url = shift;

    given ($url) {
    when (qr{^http://twitpic\.com/([A-Za-z0-9]+)$}) {
        return "http://twitpic.com/show/large/$1";
    }
    when (qr{\.(jpg|gif|png)$}) {
        return $url;
    }
    default {
        return undef;
    }
    }
}

1;

