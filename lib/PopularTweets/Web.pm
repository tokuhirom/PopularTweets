package PopularTweets::Web;
use strict;
use warnings;
use parent qw/PopularTweets Amon2::Web/;
use 5.010001;
use CGI qw(escapeHTML);
use URI::Find;
use File::Spec;
use PopularTweets::TwitterUtil qw/tw_str2time tw_url2img/;
use Time::Duration qw/duration/;

# load all controller classes
use Module::Find ();
Module::Find::useall("PopularTweets::Web::C");

# dispatcher
use PopularTweets::Web::Dispatcher;
sub dispatch {
    return PopularTweets::Web::Dispatcher->dispatch($_[0]) or die "response is not generated";
}

# setup view class
use Text::Xslate qw/mark_raw/;
{
    my $view_conf = __PACKAGE__->config->{'Text::Xslate'} || +{};
    unless (exists $view_conf->{path}) {
        $view_conf->{path} = [ File::Spec->catdir(__PACKAGE__->base_dir(), 'tmpl') ];
    }
    my $view = Text::Xslate->new(+{
        'syntax'   => 'TTerse',
        'module'   => [ 'Text::Xslate::Bridge::TT2Like' ],
        'function' => {
            c => sub { Amon2->context() },
            uri_with => sub { Amon2->context()->req->uri_with(@_) },
            uri_for  => sub { Amon2->context()->uri_for(@_) },
            remove_tag => sub {
                local $_ = shift;
                $_ =~ s!<[^>]+>!!g;
                $_;
            },
            auto_link => sub {
                my $html = escapeHTML($_[0]);
                state $finder = URI::Find->new(sub { 
                    my($uri, $orig_uri) = @_;
                    return qq|<a href="$uri">$orig_uri</a>|;
                });
                $finder->find(\$html);
                return mark_raw($html);
            },
            link2foo => sub {
                my $html = $_[0];
                my $ret;
                my $finder = URI::Find->new(sub { 
                    my ($uri) = @_;
                    my $img = tw_url2img($uri);
                    if ($img) {
                        $ret = sprintf(qq|<img src="%s" alt="%s" />|, escapeHTML($img), escapeHTML($uri));
                    }
                });
                $finder->find(\$html);
                return mark_raw($ret);
            },
            tw_str2time => \&tw_str2time,
            ago => sub {
                Time::Duration::ago(time()-shift, 1)
            },
        },
        %$view_conf
    });
    sub create_view { $view }
}

# load plugins
use HTTP::Session::Store::File;
__PACKAGE__->load_plugins(
    'Web::JSON',
    'Web::NoCache', # do not cache the dynamic content by default
    'Web::CSRFDefender',
    'Web::HTTPSession' => {
        state => 'Cookie',
        store => HTTP::Session::Store::File->new(
            dir => File::Spec->tmpdir(),
        )
    },
);

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;
        $res->header( 'X-Content-Type-Options' => 'nosniff' );
    },
);

1;
