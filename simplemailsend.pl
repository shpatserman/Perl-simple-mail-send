#!/usr/bin/perl

use strict;
use warnings;
use utf8::all;

use DDP;
use MIME::Lite;
use Time::Local;
use POSIX qw(strftime);

use FindBin;
use lib "$FindBin::Bin/lib";

use Conf '$conf';

my $dbh = DBI->connect
(
  "dbi:Pg:dbname=$conf->{db}->{dbname};
  host= $conf->{db}->{host};
  port=$conf->{db}->{port};
  user=$conf->{db}->{user};
  password=$conf->{db}->{password}",
  undef, undef, { PrintError => 1 }
);
die unless $dbh;

my $data_ref = get_mail_data( $dbh );
my $reportfilename = "report_" . strftime( '%Y-%m-%d', localtime() ) . ".csv";
my $filepath = $conf->{dir}->{attach} . "/" . $reportfilename;
write_file( $filepath, $data_ref );
email_send( $filepath, $reportfilename );

# Data for file to attach
sub get_mail_data {
    my ( $dbh )= @_;
    my $hash_ref;
    my $id_column_name="id";
    my $sth=$dbh->prepare(qq{
        SELECT 
            id AS "$id_column_name",
            maildate AS maildate,
            phone AS phone
        FROM example_table 
        });
    $sth->execute();
    $hash_ref = $sth->fetchall_hashref( $id_column_name );
    return $hash_ref;
}

# File to attach
sub write_file {
    my ( $filename , $data_ref ) = @_;
    my @cleardata;
    foreach my $key ( keys( %$data_ref ) ) {
        push ( @cleardata, $data_ref->{ $key }->{ 'maildate' } .  ";" . $data_ref->{ $key }->{ 'email' } . ";" . $data_ref->{ $key }->{ 'phone' } . "\n" ); 
    }
    open( my $fh, '>', $filename ) or die "Can't open: '$filename' $!";;
    foreach my $line ( sort @cleardata ) {
        print $fh $line;
    } 
    close $fh;
}

sub email_send {
    my ( $filepath, $filename ) = @_;
    #create email message
    my $message = MIME::Lite->new(
        From    => 'your_fqdn',
        To      => 'user@examiple.com', 
        Subject => 'report',
        Type    => 'text/html; charset=UTF-8',
        Data    => "example report"
    );
    #attach
    $message->attach(
        Type        => 'application/csv',
        Path        => "$filepath",
        Filename    => "$filename",
        Disposition => 'attachment'
        ) or die "Error adding file to email: $!\n";

    #send message
    $message->send("sendmail", "/usr/sbin/sendmail -t -oi -oem");
}

