use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'Crypto::TradeData',
    AUTHOR          => 'Taylor Dawson taylordaws47@gmail.com',
    VERSION_FROM    => 'lib/Crypto/TradeData.pm',
    ABSTRACT_FROM   => 'lib/Crypto/TradeData.pm',
    PL_FILES        => {},
    EXE_FILES       => [
        'scripts/websocket_loader',
        'scripts/crypto_data_loader',
    ],
    PREREQ_PM => {
        'Test::More'     => 0,
        'version'        => 0,
        'Moo'            => 0,
        'LWP::UserAgent' => 0,
        'Data::Dumper'   => 0,
        'JSON'           => 0,
        'DBI'            => 0,
    },
    PREREQ_FATAL => 1,
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Crypto-TradeData-*' },
);
