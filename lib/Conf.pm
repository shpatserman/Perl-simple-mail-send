package Conf;

#
# Main config
#

use strict;
use warnings;
use utf8::all;

use Carp;

use base 'Exporter';
our @EXPORT_OK = qw($conf);

our $VERSION = '0.1';

my $Conf = {

    # DB params 
    db => {
        dbname   => '',
        host     => '',
        port     => '',
        user     => '',
        password => '',
    },

    # Script dirs 
    dir => {

        # Directory with attachments 
        attach => '/var/tmp/reports',
    },

};

# Read config data 
sub load {
    return $Conf;
}

our $conf = load;

1;
