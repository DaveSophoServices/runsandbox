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

carp 'Resp: ' . $resp->status_line if ($resp->code() != 302);
my @aClassList = ('ClassList', '0,39196,39269,39270,39271');
my @aSchedules = ('Schedules', "'','Custom','Flex','Fridays+Only','Full+Week+M-F','Mondays+Only','Three+Days+per+Week+MWF','Thursdays+Only','Tuesdays+Only','Two+Days+per+Week+TTh','Wednesdays+Only'");
    
my $classList = join(@aClassList, '=');
my $today = '9/7/2020';
my $asOf = "AsOfDate=$today";
my $startDate = 'StartDate=8/1/2020';
my $endDate = "EndDate=$today";
my $startEnd = "$startDate&$endDate";

my $reports = {
    AttendanceSummary => {
	args => "$startEnd&$classList",
    },
    AllergyReport => {
	args => "$asOf&IncludeMedical=true&$classList",
    },
    AllergyReportDetailed => {
	args => "$asOf&$classList",
    },
    AllergyReportCombined => {
	args => "$asOf&Includemedical=true&$classList",
    },
    AllergyReportLandscape => {
	args => "$asOf&$classList",
    },
    AllergyReportLandscapeCombined => {
	args => "$asOf&$classList",
    },
    AllergyReportLandscapeWithRequirements => {
	args => "$asOf&$classList",
    },
    EmergencyCardReport => {
	args => "$asOf&Condensed=true&$classList",
    },
    EnrollmentReport => {
	args => "$asOf&$classList&OrderBy=alphabetical&GroupBy=class",
    },
    BirthdayReport => {
	args => "$startEnd&$classList&AllBirthdays=true",
    },
    WithdrawalReport => {
	args => "$startEnd&$classList",
    },
    WaitlistReport => {
	args => "OrderBy=lastname&$classList",
    },
    ChildrenImmunizationsReport => {
	args => "$asOf&$classList",
    },
    WeeklyMedicationReport => {
	args => "$classList",
    },
    ParentInfoList => {
	args => "$asOf&$classList",
    },
    ParentPortalAdoption => {
	args => "",
    },
    ChildList => {
	data => {
	    AsOfDate => $today,
	    Format => 'xls',
	    OrderBy => 'alphabetical',
	    @aClassList,
	    @aSchedules,
	    IncludeImages => 'false',
	},
	upload => '472cd01a-dc2f-44df-ba6e-603b1bc40ddd',
    },
    ChildRoster => {
	data => {
	    AsOfDate => $today,
	    Format => 'xls',
	    OrderBy => 'alphabetical',
	    @aClassList,
	    @aSchedules,
	},
    },
    ChildMinderReport => { # needs reminders to be setup
    },
    StaffTrackingReport => { # needs reminders, tasks to be setup
    },
    PickupList => {
	args => "$asOf&$classList",
    },
    ChildTagsReports => { # needs child tags to be setup
    },
    ActivityReport => { # needs activities setup
    },
    ChildActivityReport => {
	args => "$asOf&$classList",
    },
    SummerCampEnrollmentReport => {
	# needs kids to be enrolled at this location
    },
    StaffEmergencyCard => {
	# doesn't run. Probably need something setup with staff
    },
    StaffList => {
	# need to add staff to get this report
	# args => "$asOf"
    },
    StaffHoursDetail => {
	# need staff
    },
    StaffTimesheet => {
	# need staff
    },
    RequirementsReport => {
	args => "$asOf&$classList",
    },
    TimeclockPassCodeReport => {
	args => "",
    },
    
    ## Attendance Reports
    AttendanceSummary => {
	args => "$startEnd&$classList",
    },
    DailyAttendanceReport => {
	args => "$asOf&$classList",
    },
    DailyAttendanceProjectionReport => {
	args => "$asOf&$classList",
    },
    DailyAttendanceFirstName => {
	args => "$asOf&$classList",
    },
    DailyAttendanceSheetSignature => {
	args => "$asOf&$classList",
    },
    DailyAttendanceSignature => {
	args => "$asOf&$classList&GroupByClass=true",
    },
    DailyAttendanceHealthCheck => {
	args => "$asOf&$classList",
    },
    DailyAttendanceReportHours => {
	args => "$startEnd&$classList",
    },
    WeeklyAttendanceReport => {
	args => "$asOf&$classList",
    },
    
};

# Convert ARGV into a hashmap of reports to run. If it's empty, we run all reports
my %reps_to_run = map { $_ => 1 } @ARGV;

for my $rep (keys %$reports) {
    if (%reps_to_run && !$reps_to_run{$rep}) {
	next;
    }
    
    my $fname = lc($rep).".xls";
    my $resp;
    if ($reports->{$rep}{data}) {
	$resp = $ua->post("https://go.runsandbox.com/Report/$rep",
			  Content => $reports->{$rep}{data},
			  ':content_file' => $fname,
			  Cookie=>$authCookie,
	    );
    } elsif (defined($reports->{$rep}{args})) {
	$resp = $ua->get("https://go.runsandbox.com/Report/$rep?format=xls&".$reports->{$rep}{args},
			 Cookie=>$authCookie,
			 ':content_file'=> $fname);
    }
    if ($resp) {
	carp "$rep: ".$resp->status_line;
	if ($resp->code() == 200) {
	    # upload it
	    if (my $target=$reports->{$rep}{upload}) {
		my $a = `scp $fname thousandpines\@tmcamping.import.domo.com:$target`;
		carp "Upload failed to $target\n$a" if $?;
	    }
	} else {
	    carp Dumper($resp);
	}
    } else {
	carp "No report run for $rep"
    }
}
