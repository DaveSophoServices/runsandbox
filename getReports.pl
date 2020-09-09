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
    
my $today = '9/7/2020';
my $start = '8/1/2020';

my $classList = join(@aClassList, '=');
my $asOf = "AsOfDate=$today";
my $startDate = "StartDate=$start";
my $endDate = "EndDate=$today";
my $startEnd = "$startDate&$endDate";

my $reports = {
    AllergyReport => {
	args => "$asOf&IncludeMedical=true&$classList",
	desc => 'The allergy list is a list of all children with allergies with one page per class.',
    },
    AllergyReportDetailed => {
	args => "$asOf&$classList",
	desc => 'The allergy list is a list of all children with allergies including the parents contact information.'
    },
    AllergyReportCombined => {
	args => "$asOf&Includemedical=true&$classList",
	desc => 'The allergy list is a list of all children with allergies combined for all classes.',	
    },
    AllergyReportLandscape => {
	args => "$asOf&$classList",
	desc => 'The allergy list is a list of all children with allergies with one page per class.'
    },
    AllergyReportLandscapeCombined => {
	args => "$asOf&$classList",
	desc => 'The allergy list is a list of all children with allergies combined for all classes.'
    },
    AllergyReportLandscapeWithRequirements => {
	args => "$asOf&$classList",
	desc => 'The Allergy list is a list of all children with allergies, medical conditions, or Requirements.',
    },
    EmergencyCardReport => {
	args => "$asOf&Condensed=true&$classList",
	desc => 'The emergency card is a list of all children\'s emergency contact informations',
    },
    EnrollmentReport => {
	args => "$asOf&$classList&OrderBy=alphabetical&GroupBy=class",
	desc => 'This is a list of the new enrollment for the classes',
    },
    BirthdayReport => {
	args => "$startEnd&$classList&AllBirthdays=true",
	desc => 'The Birthday Report is a list of all enrolled children that have a birthday within the selected date range.',
    },
    WithdrawalReport => {
	args => "$startEnd&$classList",
	desc => 'This is a list of the Withdrawals for the classes',
    },
    WaitlistReport => {
	args => "OrderBy=lastname&$classList",
	desc => 'This is a list of the children on waiting list for the classes',
    },
    ChildrenImmunizationsReport => {
	args => "$asOf&$classList",
	desc => 'This is a list of the children\'s Immunization informations for the classes',
    },
    WeeklyMedicationReport => {
	args => "$classList",
	desc => 'This is a list of the children\'s Weekly Medication informations for the classes',
    },
    ParentInfoList => {
	args => "$asOf&$classList",
	desc => 'This is a list of the children\'s Parents and Guardians\' information for the classes',
    },
    ParentPortalAdoption => {
	args => "",
	desc => 'A report of how many parents have successfully signed up for Parent Portal',
    },
    ChildList => {
	data => {
	    AsOfDate => $today,
	    OrderBy => 'alphabetical',
	    @aClassList,
	    @aSchedules,
	    IncludeImages => 'false',
	},
	desc => 'This is a list of the children\'s information for the classes selected',
	upload => '472cd01a-dc2f-44df-ba6e-603b1bc40ddd',
    },
    ChildRoster => {
	data => {
	    AsOfDate => $today,
	    OrderBy => 'alphabetical',
	    @aClassList,
	    @aSchedules,
	},
	desc => 'This is a list of the children\'s information for the classes selected',
    },
    ChildReminderReport => { # needs reminders to be setup
	desc => 'The Child Reminder Report is a list of outstanding or complete reminders',
    },
    StaffTrackingReport => { # needs reminders, tasks to be setup
	desc => 'The Staff Tracking Report is a list of outstanding or complete staff reminders',
    },
    PickupList => {
	args => "$asOf&$classList",
	desc => 'This is a list of each child\'s authorized pickups for the classes selected',
    },
    ChildTagsReports => { # needs child tags to be setup
	desc => 'This is a list children and their associated tags',
    },
    ActivityReport => { # needs activities setup
	desc => 'This is a list of the activity report for camps',
    },
    ChildActivityReport => {
	args => "$asOf&$classList",
	desc => 'This is a daily log of the activities/checklist for each child',
    },
    SummerCampEnrollmentReport => {
	# needs kids to be enrolled at this location
	desc => 'This is the Summer Camp Enrollment Report',
    },
    StaffEmergencyCard => {
	# doesn't run. Probably need something setup with staff
	desc => '',
    },
    StaffList => {
	# need to add staff to get this report
	# args => "$asOf"
	desc => 'This is a list of the Staffs\' information for the classes selected',
    },
    StaffHoursDetail => {
	# need staff
	desc => 'This is a detailed list of all staff hours for the selected time period',
    },
    StaffTimesheet => {
	# need staff
	desc => 'The staff Timesheet is a list of all staff\'s Hours for the given period',
    },
    RequirementsReport => {
	args => "$asOf&$classList",
	desc => 'The Requirements Report is a list of all children with requirements with one page per class.',
    },
    TimeclockPassCodeReport => {
	args => "",
	desc => 'A Report of all guardian and emergency contact timeclock pass codes',
    },
    
    ## Attendance Reports
    AttendanceSummary => {
	args => "$startEnd&$classList",
	desc => 'This is the Attendance Summary',
	upload => '02668b13-a6d9-4700-956c-51bc0465f8a2',
    },
    DailyAttendanceReport => {
	args => "$asOf&$classList",
	desc => 'This is the Daily Attendance Sheet',
    },
    DailyAttendanceProjectionReport => {
	args => "$asOf&$classList",
	desc => 'This is the Daily Attendance Sheet with only scheduled children appearing on the report',
    },
    DailyAttendanceFirstName => {
	args => "$asOf&$classList",
	desc => 'This is the Daily Attendance Sheet with the first name and initial showing on the report',
    },
    DailyAttendanceSheetSignature => {
	args => "$asOf&$classList",
	desc => 'This is the Daily Attendance Sheet with Signature and Non-Scheduled Children greyed out',
    },
    DailyAttendanceSignatureAll => {
	args => "$asOf&$classList&GroupByClass=true",
	desc => 'This is the Daily Attendance Sheet with Signature',
    },
    DailyAttendanceSignature => {
	args => "$asOf&$classList&GroupByClass=true",
	desc => 'This is the Daily Attendance Sheet with Signature with only scheduled children appearing on the report',
    },
    DailyAttendanceHealthCheck => {
	args => "$asOf&$classList",
	desc => 'This is the Daily Attendance Sheet with the ability to enter health check information',
    },
    DailyAttendanceReportHours => {
	args => "$startEnd&$classList",
	desc => 'This is the Daily Attendance Report with Times',
    },
    WeeklyAttendanceReport => {
	args => "$asOf&$classList",
	desc => 'This is the Weekly Attendance Report',
    },
    WeeklyAttendanceReportDouble => {
	args => "$asOf&$classList",
	desc => 'This is the Weekly Attendance Report Double',
    },
    WeeklyAttendanceReportTriple => {
	args => "$asOf&$classList",
	desc => 'This is the Weekly Attendance Report Triple',
    },
    WeeklyAttendanceProjectionReport => {
	args => "$asOf&$classList",
	desc => 'This is the weekly attendance projection report',
    },
    WeeklyAttendanceProjectionReportDouble => {
	args=> "$asOf&classList",
	desc => 'This is the weekly attendace projection report with double.',
    },
    WeeklyAttendanceHoursReport => {
	args=> "$asOf&classList",
	desc=> 'This is the weekly attendance projection report with times',
    },
    WeeklySignInSheet => {
	args=> "$asOf&classList",
	desc=> 'This is the weekly sign in/out sheet',
    },
    WeeklySignInSheetAMPM => {
	args=> "$asOf&$classList&Orderby=lastname",
	desc=> 'This is the weekly sign in/out sheet for AM and PM',
    },
    WeeklySignInOutSheetWithSignature => {
	args=> "$asOf&$classList&Orderby=lastname",
	desc=> 'This is the weekly sign in/out sheet with full signature',
    },
    WeeklySignInOutSheetAMPMWithSignature => {
	args=> "$asOf&$classList&Orderby=lastname",
	desc=> 'This is the weekly sign in/out sheet with full signature',
    },
    WeeklySignInSheetAMPMHC => {
	args=> "$asOf&$classList&Orderby=lastname",
	desc=> 'This is the weekly sign in/out sheet for AM and PM with Health Check',
    },
    WeeklySignInOnly => {
	args=> "$asOf&$classList",
	desc=> 'This is the weekly sign in sheet',
    },
    WeeklySignOutOnly => {
	args=> "$asOf&$classList",
	desc=> 'This is the weekly sign out sheet',
    },
    WeeklyAttendanceReportWithHealthCheck => {
	args=> "$asOf&$classList",
	desc=> 'This is the Weekly Attendance Report With Health Check',
    },
    WeeklyAttendanceAMPM => {
	args=> "$asOf&$classList",
	desc=> 'This is the Weekly Attendance Report With AM/PM',
    },
    SemiMonthlyAttendance => {
	args=> "$startEnd&$classList&AllEnrolled=true",
	desc=> 'This is the semi-monthly attendance sheet with projections',
    },
    SemiMonthlyAttendanceBandA => {
	args=> "$startEnd&$classList&AllEnrolled=true",
	desc=> 'This is the semi-monthly attendance sheet with projections for Before and After School',
    },
    MonthlyAttendanceReport => {
	args=> "$asOf&$classList&Orderby=class",
	desc=> 'This is the monthly attendance report',
    },
    MonthlyAttendanceSubmissionReport => {
	args=> "$asOf&$classList&IncludeSubsidizedChildren=true&IncludeUnsubsidizedChildren=true&Orderby=class",
	desc=> 'This is the monthly attendance submission report',
    },
    MonthlyAttendanceWithDropoffPickup => {
	args=> "$startEnd&$classList",
	desc=> 'This is a detailed list of all attendance with the name of the dropoff/pickup for the selected classes and time period',
    },
    MonthlyAttendanceProjectionsReport => {
	args=> "$asOf&$classList",
	desc=> 'This is the monthly attendance sheet with projections',
    },
    MonthlyAttendanceHealthCheck => {
	args=> "$asOf&$classList",
	desc=> 'This is the monthly attendance sheet with health check',
    },
    MonthlyAttendanceFiveWeeks => {
	args=> "$asOf&Orderby=class&$classList",
	desc=> 'This is the monthly attendance sheet with five weeks showing',
    },
    WeeklySummerCamp => {
	# requires class and week numbers for camps
	desc=> 'This is the weekly attendance sheet for camps',
    },
    WeeklySummerCampInOut => {
	# requires class and week numbers for camps
	desc=> 'This is the weekly attendance sheet for camps with in/out times',
    },
    WeeklySummerCampHealthCheck => {
	# requires class and week numbers for camps
	desc=> 'This is the weekly attendance sheet for camps with health check',
    },

    ## Projection reports
    MonthlyProjectionReport => {
	args=> "$asOf&$classList",
	desc=> 'This is the monthly projection report',
    },
    WeeklyProjectionReport => {
	args=> "$asOf&$classList",
	desc=> 'This is the weekly projection report',
    },
    WeeklyScheduledTimesReport => {
	args=> "$asOf&$classList",
	desc=> 'This is the Weekly Projection Report With Times',
    },
    WeeklyProjectionSummaryReport => {
	args=> "$asOf",
	desc=> 'This is the weekly projection summary report',
    },
    CampProjection => {
	# need to have kids enrolled in camp
	desc=> 'This is the weekly projection report for summer camps',
    },
    
    ## Billing Reports
    AnnualFeeSummaryReport => {
	data=> {
	    AsOfDate => $today,
	    @aClassList,
	    @aSchedules,	    
	},
	desc=> 'This is the annual fee summary report',
    },
    AnnualScheduleSummaryReport => {
	data=> {
	    AsOfDate => $today,
	    @aClassList,
	    @aSchedules,
	},
	desc => 'This is the annual schedule summary report',
    },
    BankDepositSummary => {
	args=> "$startEnd&IncludePaidThroughSandbox=true&IncludeNotPaidThroughSandbox=true",
	desc=> 'The Bank Deposit Summary is a breakdown of all bank deposits within a date range',
    },
    EnrollmentBillingReport => {
	args=> "$startEnd&$classList",
	desc=> 'The Enrollment Billing Report is a list of all enrolled children with details regarding how they are billed.',
    },
    ExtraFeesReport => {
	args=> "$startEnd&IncludeAutomatedFees=true&IncludeManuallyAddedFees=true",
	desc=> 'This is a Summary of Extra Fees.',
    },
    PaymentSummaryReport => {
	args=> "$startEnd",
	desc=> 'The Payment Summary Report is a summary of all payments received by payment type.',
    },
    PaymentDetailReport => {
	#needs invoices
	#args=> "$startEnd&IncludePaidThroughSandbox=true&IncludeNotPaidThroughSandbox=true&
	desc=> 'The Payment Detail Report is a list of all payments received within a date range',
    },
    PaymentProcessingReport => {
	args => "$startEnd&DepositDate=true",
	desc=> 'The Payment Processing Report is a summary of Payment Received',
    },
    WriteOffReport => {
	args => "$startEnd",
	desc => 'The Write Off Report is a list of all bad debt written off within a date range',
    },
    StatementReport => {
	args => "$startEnd&$classList",
	desc => 'This is the customer statement report',
    },
    DetailedStatementReportForLocation => {
	args=> "$startEnd&$classList",
	desc => 'This is the detailed customer statement report',
    },
    SubsidyReport => {
	args => "$startEnd&$classList",
	desc => 'This is the subsidy report',
    },
    MonthlySubsidyReport => {
	args => "$asOf",
	desc => 'This is a Subsidy Report that shows Subsidies Estimated vs Subsidies Collected for a Month',
    },
    CustomerAgingReport => {
	args => "$asOf",
	desc => 'The customer aging report is a list of all customers with their Accounts Receivable Aging Summary',
    },
    ARCreditReport => {
	args => "$asOf",
	desc => 'The ar credit report is a list of all customers that have credits on their accounts.',
    },
    WeeklyAgingReport => {
	args => "$asOf",
	desc => 'The customer aging report is a list of all customers with their Accounts Receivable Aging Summary by week',
    },
    FeeDetailReport => {
	# needs payments
	#args => "$startEnd
	desc => 'The Fee Detail Report is a breakdown of all fees billed for a period.',
    },
    FeeSummaryReport => {
	args => "$startEnd",
	desc => 'This is a summary of all the fees invoiced for the selected time period',
    },
    PriceCodeSummaryReport => {
	args=> "$startEnd",
	desc => 'This is a summary of all the prices invoiced for the selected time period',
    },
    MonthlyFinancialSummaryReport => {
	args => "$startEnd",
	desc => 'The Monthly Financial Summary is a summary of the financial activity for the month',
    },
    AccountingSummaryReport => {
	args => "$startEnd",
	desc => 'The Accounting Summary Report is a summary of the financial activity for the month based on Accrual Accounting',
    },
    AccountingSummaryReportCash => {
	args => "$startEnd",
	desc => 'The Accounting Summary Report is a summary of the financial activity for the month based on Cash Accounting',
    },
    CreditMemoReport => {
	args => "$startEnd",
	desc => 'The Credit Memo Report is a list of all credit memos issued within a date range',
    },
    RefundReport => {
	args => "$startEnd",
	desc => 'A report displaying refunds',
    },
    OutstandingInvoicesReport => {
	data => {
	    PaymentTypes => 'cash,cc,check,other',
	    PaymentIntervals => '2month,2weeks,month,week',
	    Status => '{"Unpaid":true,"Paid":true,"Pending":true,"NotEmailed":true,"Emailed":true,"Unprinted":true,"Printed":true}',
	    StartDate => $start,
	    EndDate => $today,
	    OrderBy => 'invoicenumber',
	},
	desc => 'The Invoices Report is a list of all invoices',
    },
    ExpectedInvoices => {
	data => {
	    PaymentIntervals => '2month,2weeks,month,week',
	    Subsidized => 'IncludeSubsidizedChildren,IncludeUnsubsidizedChildren',
	    OutstandingBalance => 'IncludeInvoiceWithBalance,IncludeInvoiceWithoutBalance',
	    Tags => '',
	    StartDate => $start,
	    EndDate => $today,
	    OrderBy => 'paymentstatus',
	},
	desc => 'The Expected Invoices Report is a list of all expected invoices',
    },

    ## Company Wide
    CompanyFeeSummaryReport => {
	args => "$startEnd",
	desc => 'This is a summary of all the fees invoiced for the selected time period',
    },
    CompanyAgingReport => {
	args => "$asOf",
	desc => 'The Company Wide Aging Report is aging summary for each location.',
    },
    CenterFinancialSummaryReport => {
	args => "$startEnd",
	desc => 'The Company Wide Financial Summary is a summary of the financial activity at each location for the chosen time period',
    },
    CompanyReconciliationReport	=> {
	args => "$asOf",
	desc => 'The Reconciliation Report is an overview of the finances for each location within the company.',
    },
    OutstandingDepositReport => {
	args => "$asOf",
	desc => 'This report will show a list of all security deposits grouped by location',
    },
    OutstandingDepositReportByLocation => {
	args => "$asOf&LocationID=13982",
	desc => 'This report will show a list of all security deposits for one location',
    },
    CompanyPaymentDetailReport => {
	# Need invoices in system
	# args => "$startEnd&"
	desc => 'The Payment Detail Report is a list of all payments received within a date range',
    },
    CompanyExpectedInvoicesReport => {
	args => "$startEnd",
	desc => 'The Company Expected Invoices Report is the total expected invoices for each location',
    },
};

# Convert ARGV into a hashmap of reports to run. If it's empty, we run all reports
my %reps_to_run = map { $_ => 1 } @ARGV;

for my $rep (keys %$reports) {
    # if reps_to_run is populated but the report we're about to run isn't in it
    # then we go to the next report
    if (%reps_to_run && !$reps_to_run{$rep}) {
	next;
    }
    
    my $fname = 'data/'.lc($rep).".xls";
    my $resp;
    if ($reports->{$rep}{data}) {
	$reports->{$rep}{data}{Format} = 'xls';	
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
	    #carp Dumper($resp);
	}
    } else {
	carp "No report run for $rep"
    }
}
