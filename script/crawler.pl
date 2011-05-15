#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use 5.010000;
use LWP::UserAgent;
use PopularTweets;
use JSON qw/decode_json/;
use DBD::SQLite;

my $c = PopularTweets->new();

&main;exit;

sub main {
    for my $row (@{get_tl()}) {
        my $id = $row->{in_reply_to_status_id_str};
        my $exists = $c->dbh->selectrow_array(q{SELECT COUNT(*) FROM post WHERE id=?},{}, $id);
        next if $exists;

        my $url = "http://api.twitter.com/1/statuses/show/${id}.json";
        my $dat = get($url);
        $c->dbh->do(q{INSERT INTO post (id, data) VALUES (?, ?)}, {}, $id, $dat);
    }
}

sub get {
    my $url = shift;
    state $ua = LWP::UserAgent->new(timeout => 10, agent => "$0/$PopularTweets::VERSION");
    my $res = $ua->get($url);
    $res->is_success or die $url ." : ".$res->status_line;
    my $dat = eval { decode_json($content) } // die "Cannot parse JSON: $@\n$content";
}

sub get_tl {
    my $url = 'http://api.twitter.com/1/statuses/user_timeline.json?screen_name=favstar100_ja';
    return get($url);
}
