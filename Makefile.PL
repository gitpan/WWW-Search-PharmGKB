use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WWW::Search::PharmGKB',
    AUTHOR              => 'Arun Venkataraman <arvktr@gmail.org>',
    VERSION_FROM        => 'lib/WWW/Search/PharmGKB.pm',
    ABSTRACT_FROM       => 'lib/WWW/Search/PharmGKB.pm',
    INSTALLDIRS 	=> 'site',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
	'SOAP::Lite' => 0,
	'English'    => 0,
    },
);
