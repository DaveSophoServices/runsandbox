#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Carp;
use Data::Dumper;

use LWP::UserAgent qw();

my $ua = LWP::UserAgent->new();

my $resp = $ua->post("https://go.runsandbox.com/Account/LogOn?ReturnURL=/",
		    Content=>{
			UserName=>'david@thousandpines.com',
			Password=>'RqqQ28cxdc5D5uhvZYo2',
			RememberMe=>"false"});
my @cookies = $resp->header('Set-Cookie');
my $authCookie;
for my $c (@cookies) {
    if ($c =~ /(a_sandbox\=[^;]+);/) {
	$authCookie = $1;
	carp 'Auth Cookie: '.$authCookie;
    }
    # carp 'Cookies: ' . $c;	
}

carp 'Resp: ' . $resp->status_line;

my $classList = 'ClassList=0,39196,39269,39270,39271';
my $asOf = 'AsOfDate=9/7/2020';

my $reports = {
    AttendanceSummary => {
	args => "StartDate=8/1/2020&EndDate=9/7/2020&$classList",
    },
};

for my $rep (keys %$reports) {
    my $fname = lc($rep).".xls";
    $resp = $ua->get("https://go.runsandbox.com/Report/$rep?format=xls&".$reports->{$rep}{args},
		     Cookie=>$authCookie,
		     ':content_file'=> $fname);

    carp "$rep: ".$resp->status_line;
}
