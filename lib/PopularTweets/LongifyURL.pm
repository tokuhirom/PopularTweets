use strict;
use warnings;
use utf8;

package PopularTweets::LongifyURL;
use LWP::UserAgent;

sub new {
    my $class = shift;
    my $ua = LWP::UserAgent->new(timeout => 5, max_redirect => 0);
    bless {ua => $ua}, $class;
}

sub longify {
    my ($self, $url) = @_;
    my $host = URI->new($url)->host;
    unless ($host ~~ [qw/bit.ly htn.to goo.gl/]) {
        return $url; # not supported
    }

    my $res = $self->{ua}->head($url);
    $res->code =~ /^30[0-9]$/ or die "Cannot longify($url): " . $res->is_success;
    return $res->header('Location');
}


1;

