#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use 5.010000;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '../extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), '../lib');
use LWP::UserAgent;
use PopularTweets;
use JSON qw/decode_json encode_json/;
use DBD::SQLite;
use Log::Minimal;
use HTTP::Date qw/str2time/;
use Time::Piece;
use PopularTweets::LongifyURL;
use URI::Find;

my $c = PopularTweets->new();

&main;exit;

sub main {
    my $PATTERN = '%a %b %d %T %z %Y';
    my $longifier = PopularTweets::LongifyURL->new;
    my $finder = URI::Find->new(sub {
        my $uri = shift;
        $longifier->longify($uri);
    });

    LOOP: for my $row (@{get_tl()}) {
        my $id = $row->{in_reply_to_status_id_str};
        infof(" processing status: $id");
        my $exists = $c->dbh->selectrow_array(q{SELECT COUNT(*) FROM post WHERE id=?},{}, $id);
        next if $exists;

        infof(" fetching status: $id");
        my $rt_ctime = Time::Piece->strptime($row->{'created_at'}, $PATTERN) // die "Cannot parse created_at: $row->{created_at}";
        my $url = "http://api.twitter.com/1/statuses/show/${id}.json";
        my $res = __ua()->get($url);
        $res->is_success or do {
            warnf("%s : %s", $url, $res->status_line);
            next LOOP;
        };
        my $dat = eval { decode_json($res->content) } // die "Cannot parse JSON: $@\n@{[ $res->content ]}";
        $finder->find(\($dat->{text}));
        $c->dbh->do(q{INSERT INTO post (id, data, ctime) VALUES (?, ?, ?)}, {}, $id, encode_json($dat), $rt_ctime->epoch);
    }
}

sub __ua {
    state $ua = LWP::UserAgent->new(timeout => 10, agent => "$0/$PopularTweets::VERSION");
    return $ua;
}

sub get_tl {
    infof('fetching timeline');
    my $url = 'http://api.twitter.com/1/statuses/user_timeline.json?screen_name=favstar100_ja&count=200';
    my $res = __ua()->get($url);
    $res->is_success or die $url ." : ".$res->status_line;
    my $dat = eval { decode_json($res->content) } // die "Cannot parse JSON: $@\n@{[ $res->content ]}";
    return $dat;
}
