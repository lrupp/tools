#!/usr/bin/perl -w
# nagios: -epn
#
# check_maintenance - nagios plugin
#
# Copyright (C) 2010, Novell, Inc.
# Copyright (C) 2014, SUSE Linux Products GmbH, Nuremberg
# Copyright (C) 2014, SUSE Linux GmbH, Nuremberg
# Author: Lars Vogdt
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the Novell nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# $Id: check_maintenance.pl,v 1.7 2010/03/16 11:16:18 lrupp Exp $
#

use strict;
use warnings;
use Carp;
use Getopt::Long;
use Pod::Usage;
use Date::Calc qw( Today check_date Date_to_Days );

# cleanup the environment
$ENV{'PATH'}     = '/bin:/usr/bin:/sbin:/usr/sbin:';
$ENV{'BASH_ENV'} = '';
$ENV{'ENV'}      = '';

our $conf = {
    VERSION     => '2.2',
    PROGNAME    => 'check_maintenance',
    maint_file  => '/etc/nagios/maintenance_data.txt',
    budget_date => '01.01.1970',
    timeout     => 120,
    critical    => 4,
    warning     => 8,
    debug       => 0
};

our $print_version = 0;
our $print_help    = 0;
our $exitcode      = 0;
our $hostname      = "localhost";
our %ERRORS        = (
    'OK'        => 0,
    'WARNING'   => 1,
    'CRITICAL'  => 2,
    'UNKNOWN'   => 3,
    'DEPENDENT' => 4
);

#######################################################################
# Functions
#######################################################################

sub DEBUG($) {
    my ($output) = @_;
    print "DEBUG:  $output\n" if ( $conf->{'debug'} );
}

sub read_maintenance_data($) {
    my ($maint_data_file) = @_;
    my %data;
    open my $MAINT_DATA, "<", $maint_data_file
        or croak "Could not open $maint_data_file : $!\n";
    my @maint_data = <$MAINT_DATA>;
    close($MAINT_DATA);
    foreach my $line (@maint_data) {
        chomp $line;
        next if $line =~ /^#/;
        next if $line =~ /^\s+$/;
        if ( $line =~ /.*\|.*\|.*/ ) {
            my ( $host, $date, $comment ) = "";
            ( $host, $date, $comment ) = split( '\|', $line, 3 );
            $host = lc($host);
            $data{$host}{'last_date'} = $date;
            if ( $date =~ /\d{1,2}\.\d{1,2}\.\d{4}/ ) {    # 31.12.2010
                my ( $day, $month, $year ) = split( '\.', $date, 3 );
                if ( check_date( $year, $month, $day ) ) {
                    $data{$host}{'day'}   = $day;
                    $data{$host}{'month'} = $month;
                    $data{$host}{'year'}  = $year;
                }
                else {
                    DEBUG("No valid date for $host");
                    $data{$host}{'day'}   = 0;
                    $data{$host}{'month'} = 0;
                    $data{$host}{'year'}  = 0;
                }
            }
            if ( $date =~ /\d{1,2}\/\d{1,2}\/\d{4}/ ) {    # 31/12/2010
                my ( $day, $month, $year ) = split( '\/', $date, 3 );
                if ( check_date( $year, $month, $day ) ) {
                    $data{$host}{'day'}   = $day;
                    $data{$host}{'month'} = $month;
                    $data{$host}{'year'}  = $year;
                }
                else {
                    DEBUG("No valid date for $host");
                }
            }
            if ( $comment =~ /^(.*)\|(.*)\|(.*)/ ){
                my ( $vendor, $serial, $inventory, $comment ) = split( '\|', $comment );
                DEBUG(
                    "More information in comment detected."
                );
                $data{$host}{'serial'}  = $serial if defined($serial);
                $data{$host}{'inventory'}  = $inventory if defined($inventory);
                $data{$host}{'comment'} = $comment if defined($comment);
                $data{$host}{'vendor'}  = $vendor if defined($vendor);
            }
            elsif ( $comment =~ /.*\|.*/ ) {
                my ( $vendor, $comment ) = split( '\|', $comment, 2 );
                DEBUG(
                    "More information in comment detected. Vendor: $vendor ; comment: $comment"
                );
                $data{$host}{'comment'} = $comment;
                $data{$host}{'vendor'}  = $vendor;
            }
            else {
                $data{$host}{'comment'} = $comment;
            }
        }
        else {
            DEBUG("Could not parse line: $line");
        }
    }
    return \%data;
}

sub print_myrevision ($$) {
    my $commandName    = shift;
    my $pluginRevision = shift;
    print "$commandName v$pluginRevision\n";
}

#######################################################################
# Main
#######################################################################

Getopt::Long::Configure('bundling');
GetOptions(
    "H=s"           => \$hostname,
    "hostname=s"    => \$hostname,
    "v"             => \$print_version,
    "version"       => \$print_version,
    "h"             => \$print_help,
    "help"          => \$print_help,
    "d"             => \$conf->{'debug'},
    "debug"         => \$conf->{'debug'},
    "i"             => \$conf->{'ignore'},
    "ignore"        => \$conf->{'ignore'},
    "w=i"           => \$conf->{'warning'},
    "warning=i"     => \$conf->{'warning'},
    "c=i"           => \$conf->{'critical'},
    "critical=i"    => \$conf->{'critical'},
    "f=s"           => \$conf->{'maint_file'},
    "releasefile=s" => \$conf->{'maint_file'},
    "t=i"           => \$conf->{'timeout'},
    "timeout=i"     => \$conf->{'timeout'},
    "b=s"           => \$conf->{'budget_date'},
    "budget_date=s"  => \$conf->{'budget_date'},
) or pod2usage(2);

pod2usage(
    -exitstatus => 0,
    -verbose    => 2,    # 2 to print full pod
) if $print_help;

# Just in case of problems, let's not hang Nagios
$SIG{'ALRM'} = sub {
    print "UNKNOWN - Plugin timed out\n";
    exit $ERRORS{"UNKNOWN"};
};
alarm( $conf->{'timeout'} );

if ($print_version) {
    print_myrevision( $conf->{'PROGNAME'}, $conf->{'VERSION'} );
    exit $ERRORS{'OK'};
}

# check the options...
if ( !-f $conf->{'maint_file'} ) {
    print "CONFIG ERROR - file "
        . $conf->{'maint_file'}
        . " does not exist or is not readable\n";
    pod2usage(2);
    alarm(0);
    exit $ERRORS{"UNKNOWN"};
}
if ( $conf->{'warning'} <= $conf->{'critical'} ) {
    print "CONFIG ERROR - critical value ("
        . $conf->{'critical'}
        . ") must be lower than warning value ("
        . $conf->{'warning'} . ")\n";
    pod2usage(2);
    alarm(0);
    exit $ERRORS{"UNKNOWN"};
}
if ( !defined($hostname) ) {
    print "CONFIG ERROR . no hostname given\n";
    pod2usage(2);
    alarm(0);
    exit $ERRORS{"UNKNOWN"};
}

my $dataref = read_maintenance_data( $conf->{'maint_file'} );

if ( ! $conf->{'ignore'} ) {
  if ( "$conf->{'budget_date'}" =~ /\d{1,2}\.\d{1,2}\.\d{4}/ ){
	my ($day, $month, $year ) = split( '\.', $conf->{'budget_date'}, 3 );
	if ( check_date( $year, $month, $day ) ) {
		$conf->{'budget_day'}=$day;
		$conf->{'budget_month'}=$month;
		$conf->{'budget_year'}=$year;
	}
	else {
		print "ERROR: given budget_day $conf->{'budget_date'} is no valid date.\n";
		pod2usage(2);
		alarm(0);
		exit $ERRORS{"UNKNOWN"};
	}
  }
  elsif ( "$conf->{'budget_date'}" =~ /\d{1,2}\/\d{1,2}\/\d{4}/ ) {
	my ( $day, $month, $year ) = split( '\/', $conf->{'budget_date'}, 3 );
        if ( check_date( $year, $month, $day ) ) {
		$conf->{'budget_day'}=$day;
		$conf->{'budget_month'}=$month;
		$conf->{'budget_year'}=$year;
	}
	else {
                print "ERROR: given budget_day $conf->{'budget_date'} is no valid date.\n";
                pod2usage(2);
                alarm(0);
                exit $ERRORS{"UNKNOWN"};
        }
  }
  else {
	print "ERROR: given budget_date $conf->{'budget_date'} is unkown\n";
	pod2usage(2);
	alarm(0);
	exit $ERRORS{"UNKNOWN"};
  }
}

if ( $conf->{'debug'} ) {
    use Data::Dumper;
    print STDERR "Config:\n" . Data::Dumper->Dump( [$conf] ) . "\n";
    print STDERR "Maintenance data file content\n"
        . Data::Dumper->Dump( [$dataref] ) . "\n";
}

$hostname = lc($hostname);

if ( $dataref->{$hostname} ) {
    DEBUG "Match found for: $hostname";
    my $error            = "UNKNOWN";
    my $ret_str          = "UNKNOWN";
    my $wrong_date       = 0;
    my $service_since_ad = 0;
    my $budget_date      = 0;
    my ( $year, $month, $day ) = Today( [0] );

    if (! check_date(	$dataref->{$hostname}->{'year'},
			$dataref->{$hostname}->{'month'},
		        $dataref->{$hostname}->{'day'})){
    	if ( ! $conf->{'ignore'} ){
	    print "Wrong date values ($dataref->{$hostname}->{'year'}/$dataref->{$hostname}->{'month'}/$dataref->{$hostname}->{'day'}) for host: $hostname in $conf->{'maint_file'} - aborting\n";
            alarm(0);
            exit $ERRORS{"UNKNOWN"};
        }
        else {
            $wrong_date=1;
        }
    }
    if ( ! $wrong_date) {
        $service_since_ad = Date_to_Days(
        $dataref->{$hostname}->{'year'},
        $dataref->{$hostname}->{'month'},
        $dataref->{$hostname}->{'day'},
    );
    }
    my $today_since_ad = Date_to_Days( $year, $month, $day );
    if (defined($conf->{'budget_year'}) && defined($conf->{'budget_month'}) && defined($conf->{'budget_day'})){
        $budget_date    = Date_to_Days( $conf->{'budget_year'}, $conf->{'budget_month'}, $conf->{'budget_day'} );
        DEBUG "Today is   : $today_since_ad";
        DEBUG "Service    : $service_since_ad";
        DEBUG "Budget Day : $budget_date";
    }
    my $difference   = $service_since_ad - $today_since_ad;
    my $warndays     = $conf->{'warning'} * 7;
    my $criticaldays = $conf->{'critical'} * 7;
    use integer;
    my $weeks = $difference / 7;
    my $budget_day_override=0;
    if ( $today_since_ad >= $budget_date ){
        $budget_day_override=1;
    }
    DEBUG
        "Difference:$difference; Warndays:$warndays; Criticaldays:$criticaldays;";

    if ( ! $conf->{'ignore'} ){
        if ( $difference > $warndays ) {
            $ret_str = "OK: " . $weeks . " weeks left";
            $error   = "OK";
        }
        elsif ( $difference < $criticaldays ) {
            if ( $difference < 0 ) {
                $ret_str
                    = "CRITICAL: hardware is out of maintenance since "
                    . abs($weeks)
                    . " weeks";
                if ( $budget_day_override ){
    	            $error = "CRITICAL";
                } 
                else {
                        DEBUG "State is critical, but we did not reach the budget day";
                        $error = "OK";
                }
            }
            else {
                $ret_str = "CRITICAL: only " . $weeks . " weeks left";
                if ( $budget_day_override ){
                    $error   = "CRITICAL";
                } else {
                    $error = "OK";
                }
            }
        }
        elsif ( $difference < $warndays ) {
            $ret_str = "WARNING: only " . $weeks . " weeks left";
            if ( $budget_day_override ){
                $error   = "WARNING";
            }
            else {
                DEBUG "State is warning, but we did not reach the budget day";
                $error = "OK";
            }
        }
        else {
            $ret_str = "UNKOWN: got some misterious data";
            $error   = "UNKOWN";
        }
    }
    else {
        $ret_str = "OK: ignored maintenance information on special request (-i)";
        $error   = "OK";
    }

    $ret_str
        .= ";\nLast Service Date: " . $dataref->{$hostname}->{'last_date'};
    if (   ( defined $dataref->{$hostname}->{'vendor'} )
        && ( $dataref->{$hostname}->{'vendor'} ne "" ) )
    {
        $ret_str .= ";\nVendor: " . $dataref->{$hostname}->{'vendor'};
    }
    if (   ( defined $dataref->{$hostname}->{'serial'} )
        && ( $dataref->{$hostname}->{'serial'} ne "" ) )
    {
        $ret_str .= ";\n" . $dataref->{$hostname}->{'serial'};
    }
    if (   ( defined $dataref->{$hostname}->{'inventory'} )
        && ( $dataref->{$hostname}->{'inventory'} ne "" ) )
    {
        $ret_str .= ";\n" . $dataref->{$hostname}->{'inventory'};
    }
    if ( defined($conf->{'budget_day'}) && "$conf->{'budget_day'}" ne "01.01.1970" ){
        $ret_str .= ";\nBudget day: ".$conf->{'budget_date'};
    }
    $ret_str .= ";\n" . $dataref->{$hostname}->{'comment'} if defined($dataref->{$hostname}->{'comment'});
    print "$ret_str\n";
    $exitcode = $ERRORS{$error};
    alarm(0);
    exit $exitcode;
}
else {
    print "UNKOWN - host $hostname not found in "
        . $conf->{'maint_file'} . "\n";
    alarm(0);
    exit $ERRORS{"UNKNOWN"};
}

__END__

=head1 check_maintenance

check_maintenance is a Nagios plugin, allowing to check if a host still is 
in service.

=head1 SYNOPSIS

./check_maintenance -H $HOSTNAME$ -w8 -c4 -f <file_with_maintenance_data>

 Options:
    -H <HOSTNAME>    | --hostname <HOSTNAME>
    -w <int>         | --warning <int>
    -c <int>         | --critical <int>
    -f <file>        | --file <file>
    -b <date>        | --budget_date <date>
    
    -i               | --ignore
    -h               | --help
    -d               | --debug

=head1 OPTIONS

=over 8

=item B<--hostname> F<hostname>

The name of the host.

=item B<--critical> F<int>

Weeks befor the check should return critical.

=item B<--warning> F<int>

Weeks befor the check should return warning.

=item B<--file> F<file>

Read all maintenance data from the given file. Here's the expected structure of 
the file:

=over 8

<hostname>|<last service date>|[additional information shown in check output]

or

<hostname>|<last service date>|[Vendor]|[Serial number]|Inventory/Asset number|[additional information shown in check output]

=back

B<hostname> should be the same as Nagios submits to the check via the $HOSTNAME$ 
variable. Note: all hostnames are converted to lowercase automatically.

The B<last service date> can be one of the following formats:

=over 8

=item * 31.12.2010

=item * 31/12/2010

=back

B<Vendor> is not required, it is currently just an additional output value for the comment section.

All lines without '|' will result in a warning. Best way to mark a line as 
comment is a '#' at the beginning, this allows further improvements in the future.

=item B<--budget_day> F<date>

Instead of issuing a warning/critical once the machine is running out of service, 
do this only <warn> or <crit> days before the budget_day arrises.

=item B<--ignore>

Hosts checked with the ignore option will result always in an OK state. This might helpful if your 
hardware is already out of maintenance but you want to track the other information in Nagios.

=item B<--help>

Produces this output.

=item B<--debug>

Print debug output on console.

=back

=head1 DESCRIPTION

B<check_maintenance> allows you to let Nagios do the critical check, if the
hardware of a given host is still in service or not.

B<check_maintenance> will read the given file with maintenance data and checks for 
a line with the given hostname and service date.

If it succeeds, the service date will be processed against the given warning and 
critical values.

All data in the maintenance file behind the second '|' will be printed as normal 
output to Nagios, so you can use this to add addtional informations like the room 
or inventory number of the host.

=head1 AUTHORS

Written by Lars Vogdt <Lars.Vogdt@novell.com>

=head1 SUPPORT

Please use https://bugzilla.novell.com to submit patches or suggest improvements.

Include version information with all correspondence (when possible use output from 
the --version option of the plugin itself).

=cut

