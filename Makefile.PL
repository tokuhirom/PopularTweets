use ExtUtils::MakeMaker;

eval "use File::Which; File::Which::which('cronlog');" or do {
	use File::Temp;
	my $tmp = File::Temp->new(UNLINK => 1);
	system "curl -L --output $tmp http://github.com/kazuho/kaztools/tarball/master";
	system "cpanm -nv $tmp";
};

WriteMakefile(
    NAME          => 'PopularTweets',
    AUTHOR        => 'Some Person <person@example.com>',
    VERSION_FROM  => 'lib/PopularTweets.pm',
    PREREQ_PM     => {
        'Amon2'                           => '2.34',
        'Text::Xslate'                    => '1.1005',
        'Text::Xslate::Bridge::TT2Like'   => '0.00008',
        'Plack::Middleware::ReverseProxy' => '0.09',
        'HTML::FillInForm::Lite'          => '1.09',
        'Time::Piece'                     => '1.20',
		'JSON' => 2,
		'Cache::FileCache' => 0,
		'LWP::UserAgent' => 0,
		'DBD::SQLite' => 0,
		'DBI' => 0,
		'Amon2::DBI' => 0,
		'URI::Find' => 0,
		'Time::Duration' => 0,
    },
	CONFIGURE_REQUIRES => {
		'File::Which' => 0,
	},
    MIN_PERL_VERSION => '5.008001',
    (-d 'xt' and $ENV{AUTOMATED_TESTING} || $ENV{RELEASE_TESTING}) ? (
        test => {
            TESTS => 't/*.t xt/*.t',
        },
    ) : (),
);
