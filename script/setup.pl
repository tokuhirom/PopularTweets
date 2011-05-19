#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '../extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), '../lib');
use PopularTweets;

my $c = PopularTweets->new();

open my $fh, '<:utf8', 'sql/sqlite3.sql';
my $sql = do { local $/; <$fh> };
print "executing: $sql\n";
$c->dbh->do($sql) or die;
