#!/usr/bin/perl -w

BEGIN { 
    $ENV{CATALYST_ENGINE} ||= 'HTTP';
    $ENV{CATALYST_SCRIPT_GEN} = 31;
    require Catalyst::Engine::HTTP;
}  

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use FindBin;
use lib "$FindBin::Bin/../lib";

use File::Find::Rule;
use Path::Class;


my $debug             = 0;
my $fork              = 0;
my $help              = 0;
my $host              = undef;
my $port              = $ENV{JSAN_PROVE_PORT} || $ENV{CATALYST_PORT} || 3000;
my $keepalive         = 0;
my $restart           = $ENV{JSAN_PROVE_RELOAD} || $ENV{CATALYST_RELOAD} || 0;
my $restart_delay     = 1;
my $restart_regex     = '(?:/|^)(?!\.#).+(?:\.yml$|\.yaml$|\.conf|\.pm)$';
my $restart_directory = undef;
my $follow_symlinks   = 0;

my @preload 		  = ();
my @browsers 		  = ();		

my @argv = @ARGV;

GetOptions(
    'debug|d'             => \$debug,
    'fork'                => \$fork,
    'help|?'              => \$help,
    'host=s'              => \$host,
    'port=s'              => \$port,
    'keepalive|k'         => \$keepalive,
    'restart|r'           => \$restart,
    'restartdelay|rd=s'   => \$restart_delay,
    'restartregex|rr=s'   => \$restart_regex,
    'restartdirectory=s@' => \$restart_directory,
    'followsymlinks'      => \$follow_symlinks,
    
    'preload|p=s'	      => \@preload,
    'browser|b=s'	      => \@browsers,
);

pod2usage(1) if $help;

if ( $restart && $ENV{CATALYST_ENGINE} eq 'HTTP' ) {
    $ENV{CATALYST_ENGINE} = 'HTTP::Restarter';
}
if ( $debug ) {
    $ENV{CATALYST_DEBUG} = 1;
}


#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
my @tests = @ARGV;

if (!@tests) {
	@tests = sort File::Find::Rule->file->name('*.js')->in(dir('t'));
	
	die "No tests found\n" unless @tests;
	
	@tests = map { file($_)->relative() } @tests;
}

$ENV{JSAN_PROVE_TESTS} = join "\n", @tests;
$ENV{JSAN_PROVE_PRELOAD} = join "\n", @preload;
$ENV{JSAN_PROVE_BROWSERS} = join "\n", @browsers;
$ENV{CATALYST_ENGINE} = 'HTTP::Stopable';


# This is require instead of use so that the above environment
# variables can be set at runtime.
require JSAN::Prove;

my $result = JSAN::Prove->run( $port, $host, {
    argv              => \@argv,
    'fork'            => $fork,
    keepalive         => $keepalive,
    restart           => $restart,
    restart_delay     => $restart_delay,
    restart_regex     => qr/$restart_regex/,
    restart_directory => $restart_directory,
    follow_symlinks   => $follow_symlinks,
});

exit($result);

=head1 NAME

jsan_prove_server.pl - Catalyst Testserver

=head1 SYNOPSIS

jsan_prove_server.pl [options]

 Options:
   -d -debug          force debug mode
   -f -fork           handle each request in a new process
                      (defaults to false)
   -? -help           display this help and exits
      -host           host (defaults to all)
   -p -port           port (defaults to 3000)
   -k -keepalive      enable keep-alive connections
   -r -restart        restart when files get modified
                      (defaults to false)
   -rd -restartdelay  delay between file checks
   -rr -restartregex  regex match files that trigger
                      a restart when modified
                      (defaults to '\.yml$|\.yaml$|\.conf|\.pm$')
   -restartdirectory  the directory to search for
                      modified files, can be set mulitple times
                      (defaults to '[SCRIPT_DIR]/..')
   -follow_symlinks   follow symlinks in search directories
                      (defaults to false. this is a no-op on Win32)
 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Run a Catalyst Testserver for this application.

=head1 AUTHORS

Catalyst Contributors, see Catalyst.pm

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
