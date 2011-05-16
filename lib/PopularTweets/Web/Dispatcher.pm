package PopularTweets::Web::Dispatcher;
use strict;
use warnings;
use Amon2::Web::Dispatcher::Lite;
use JSON qw/decode_json/;

any '/' => sub {
    my ($c) = @_;
    my @rows =
      map { decode_json($_->[0]) } @{
        $c->dbh->selectall_arrayref(
            q{SELECT data FROM post ORDER BY ctime DESC LIMIT 1000})
      };
    $c->render('index.tt', {rows => \@rows});
};

1;
