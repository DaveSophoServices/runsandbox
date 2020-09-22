#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Carp;
use Data::Dumper;

use LWP::UserAgent qw();
use URI::Encode qw(uri_encode);

# For HTML parsing for reports
use HTML::TableExtract;
use DateTime::Format::Strptime;

use Time::Piece;

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

my $today = localtime->mdy("/");
my $start = '9/8/2020';

my $classList = join('=',@aClassList);
my $asOf = "AsOfDate=$today";
my $startDate = "StartDate=$start";
my $endDate = "EndDate=$today";
my $startEnd = "$startDate&$endDate";

my $reports = {
    AllergyReport => {
	args => "$asOf&IncludeMedical=true&$classList",
	desc => 'The allergy list is a list of all children with allergies with one page per class.',
	upload => 'aec710d2-3639-4c3b-918c-fbe1eebc4911',
    },
    AllergyReportDetailed => {
	args => "$asOf&$classList",
	desc => 'The allergy list is a list of all children with allergies including the parents contact information.',
	upload => '1100b738-e454-4ed5-83c3-d494667c31a3',
    },
    AllergyReportCombined => {
	args => "$asOf&Includemedical=true&$classList",
	desc => 'The allergy list is a list of all children with allergies combined for all classes.',
	upload => '1198ea89-22f9-493a-a915-2c3da568025a',
    },
    AllergyReportLandscape => {
	args => "$asOf&$classList",
	desc => 'The allergy list is a list of all children with allergies with one page per class.',
	upload => '33982376-a49f-4a8a-b069-0aac2879f09d',
    },
    AllergyReportLandscapeCombined => {
	args => "$asOf&$classList",
	desc => 'The allergy list is a list of all children with allergies combined for all classes.',
	upload => '6a986b57-3e0b-4f18-aae1-acd452dbdeac',
    },
    AllergyReportLandscapeWithRequirements => {
	args => "$asOf&$classList",
	desc => 'The Allergy list is a list of all children with allergies, medical conditions, or Requirements.',
	upload => '43c5db80-ec65-4308-9243-a82ab7e69550',
	
    },
    EmergencyCardReport => {
	# not an easy XLS to take care of
	args => "$asOf&Condensed=true&$classList",
	desc => q/The emergency card is a list of all children's emergency contact informations/,
	upload => '3ddfc135-6c4b-4474-80d8-bf097201fa2a',
    },
    EnrollmentReport => {
	args => "$asOf&$classList&OrderBy=alphabetical&GroupBy=class",
	desc => 'This is a list of the new enrollment for the classes',
	upload => 'b141c070-792e-4899-8058-6b7f7ef0c1f9',
    },
    BirthdayReport => {
	args => "$startEnd&$classList&AllBirthdays=true",
	desc => 'The Birthday Report is a list of all enrolled children that have a birthday within the selected date range.',
	upload => '1e063d3c-58bd-4ddc-aea0-6588f29db173',
    },
    WithdrawalReport => {
	args => "$startEnd&$classList",
	desc => 'This is a list of the Withdrawals for the classes',
	upload => 'e2698adf-ca64-494c-8f81-64f88d41f4e6',
    },
    WaitlistReport => {
	args => "OrderBy=lastname&$classList",
	desc => 'This is a list of the children on waiting list for the classes',
	upload => 'b5a99431-c607-477e-8913-e062f4540b93',
    },
    ChildrenImmunizationsReport => {
	# not a straight list of values. More of a report card
	args => "$asOf&$classList",
	desc => q/This is a list of the children's Immunization informations for the classes/,
	upload => '9ecf7572-6620-425f-a98b-d2b7be7fc80b',
    },
    WeeklyMedicationReport => {
	# not a straight list of values.
	args => "$classList",
	desc => q/This is a list of the children's Weekly Medication informations for the classes/,
	upload => '3bb5b72b-c38a-4c6f-9a79-2994d658a73e',
	
    },
    ParentInfoList => {
	args => "$asOf&$classList",
	desc => q/This is a list of the children's Parents and Guardians' information for the classes/,
	upload => '7a4ba3f8-5331-4be6-9f01-fed7285bb7be',
    },
    ParentPortalAdoption => {
	# requires a different method of loading this one
	#args => "",
	desc => 'A report of how many parents have successfully signed up for Parent Portal',
	upload => '38bab3c9-83af-4fc5-b9cf-9168df6f3fbf',
    },
    ChildList => {
	data => {
	    AsOfDate => $today,
	    OrderBy => 'alphabetical',
	    @aClassList,
	    @aSchedules,
	    IncludeImages => 'false',
	},
	desc => q/This is a list of the children's information for the classes selected/,
	upload => '472cd01a-dc2f-44df-ba6e-603b1bc40ddd',
    },
    ChildRoster => {
	data => {
	    AsOfDate => $today,
	    OrderBy => 'alphabetical',
	    @aClassList,
	    @aSchedules,
	},
	desc => q/This is a list of the children's information for the classes selected/,
	upload => 'f70926e6-0632-442a-b1a5-b53aff5c8964',
    },
    ChildReminderReport => { # needs reminders to be setup
	desc => 'The Child Reminder Report is a list of outstanding or complete reminders',
    },
    StaffTrackingReport => { # needs reminders, tasks to be setup
	desc => 'The Staff Tracking Report is a list of outstanding or complete staff reminders',
    },
    PickupList => {
	args => "$asOf&$classList",
	desc => q/This is a list of each child's authorized pickups for the classes selected/,
	upload => 'af7ed067-7299-4c96-8b70-efed03e4a9ef',
	
    },
    ChildTagsReports => { # needs child tags to be setup
	desc => 'This is a list children and their associated tags',
    },
    ActivityReport => { # needs activities setup
	desc => 'This is a list of the activity report for camps',
    },
    ChildActivityReport => {
	# No daily activities setup
	#args => "$asOf&$classList",
	desc => 'This is a daily log of the activities/checklist for each child',
	upload => 'f023ea8e-4864-4572-9cd2-bd22da50c30a',
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
	upload => '262ccfa2-1d2b-4975-9c15-0f0bb263078a',
    },
    TimeclockPassCodeReport => {
	args => "",
	desc => 'A Report of all guardian and emergency contact timeclock pass codes',
	upload => 'f788c7b3-9e53-4d0f-ae44-db8e85a02587',
    },
    
    ## Attendance Reports
    AttendanceSummary => {
	#args => "$startEnd&$classList",
	desc => 'This is the Attendance Summary',
	upload => '02668b13-a6d9-4700-956c-51bc0465f8a2',
    },
    DailyAttendanceReport => {
	# Sheet
	#args => "$asOf&$classList",
	desc => 'This is the Daily Attendance Sheet',
	upload => 'e18b6f3c-bca6-407a-8718-64acffb9ce51',
    },
    DailyAttendanceProjectionReport => {
	# Sheet
	#args => "$asOf&$classList",
	desc => 'This is the Daily Attendance Sheet with only scheduled children appearing on the report',
	upload => 'ee7789f1-a9b1-4bab-9f83-1ab9e000b689',
    },
    DailyAttendanceFirstName => {
	# Sheet
	#args => "$asOf&$classList",
	desc => 'This is the Daily Attendance Sheet with the first name and initial showing on the report',
	upload => '242d25f7-f0cc-4ed6-a0d7-0917422fcb93',
    },
    DailyAttendanceSheetSignature => {
	# Sheet
	#args => "$asOf&$classList",
	desc => 'This is the Daily Attendance Sheet with Signature and Non-Scheduled Children greyed out',
	upload => 'eea2ea51-e808-481d-adae-aea0cd09c02a',
    },
    DailyAttendanceSignatureAll => {
	# Sheet
	#args => "$asOf&$classList&GroupByClass=true",
	desc => 'This is the Daily Attendance Sheet with Signature',
	upload => '5399ef83-6994-4fd7-ab4b-e472e0b255cd',
    },
    DailyAttendanceSignature => {
	# Sheet
	#args => "$asOf&$classList&GroupByClass=true",
	desc => 'This is the Daily Attendance Sheet with Signature with only scheduled children appearing on the report',
	upload => 'd7215639-20dd-40cc-bcff-2dda51f2fee7',
    },
    DailyAttendanceHealthCheck => {
	# Sheet
 	#args => "$asOf&$classList",
	desc => 'This is the Daily Attendance Sheet with the ability to enter health check information',
	upload => '649180fe-1c10-4df3-962c-01df107d0470',
    },
    DailyAttendanceReportHours => {	
	args => "$startEnd&$classList",
	desc => 'This is the Daily Attendance Report with Times',
	upload => '2b655e03-d035-4ade-bcae-9e7cd3469322',
    },
    WeeklyAttendanceReport => {
	# Sheet
	#args => "$asOf&$classList",
	desc => 'This is the Weekly Attendance Report',
	upload => 'ad7fc665-c303-4cdc-b6d6-ac83758e443c',
    },
    WeeklyAttendanceReportDouble => {
	# Sheet
	#args => "$asOf&$classList",
	desc => 'This is the Weekly Attendance Report Double',
	upload => 'a4afc770-7751-4b16-93b7-2870db9a24b8',
    },
    WeeklyAttendanceReportTriple => {
	# Sheet
	#args => "$asOf&$classList",
	desc => 'This is the Weekly Attendance Report Triple',
	upload => 'fbcc2a2e-55a5-4169-9ca0-75e6258a61ab',
    },
    WeeklyAttendanceProjectionReport => {
	args => "$asOf&$classList",
	desc => 'This is the weekly attendance projection report',
	upload => '824eed33-80ea-4a71-b2b2-c548fa20059f',
    },
    WeeklyAttendanceProjectionReportDouble => {
	# Sheet
	#args=> "$asOf&$classList",
	desc => 'This is the weekly attendace projection report with double.',
    },
    WeeklyAttendanceHoursReport => {
	args=> "$asOf&$classList",
	desc=> 'This is the weekly attendance projection report with times',
	upload => '0da02f00-ef43-42db-8e35-1f08064f87af',
    },
    WeeklySignInSheet => {
	# Sheet
	#args=> "$asOf&classList",
	desc=> 'This is the weekly sign in/out sheet',
    },
    WeeklySignInSheetAMPM => {
	# Sheet
	#args=> "$asOf&$classList&Orderby=lastname",
	desc=> 'This is the weekly sign in/out sheet for AM and PM',
    },
    WeeklySignInOutSheetWithSignature => {
	# Sheet
	#args=> "$asOf&$classList&Orderby=lastname",
	desc=> 'This is the weekly sign in/out sheet with full signature',
    },
    WeeklySignInOutSheetAMPMWithSignature => {
	# Sheet
	#args=> "$asOf&$classList&Orderby=lastname",
	desc=> 'This is the weekly sign in/out sheet with full signature',
    },
    WeeklySignInSheetAMPMHC => {
	# Sheet
	#args=> "$asOf&$classList&Orderby=lastname",
	desc=> 'This is the weekly sign in/out sheet for AM and PM with Health Check',
    },
    WeeklySignInOnly => {
	# Sheet
	#args=> "$asOf&$classList",
	desc=> 'This is the weekly sign in sheet',
    },
    WeeklySignOutOnly => {
	# Sheet
	#args=> "$asOf&$classList",
	desc=> 'This is the weekly sign out sheet',
    },
    WeeklyAttendanceReportWithHealthCheck => {
	# Sheet
	#args=> "$asOf&$classList",
	desc=> 'This is the Weekly Attendance Report With Health Check',
    },
    WeeklyAttendanceAMPM => {
	# Sheet
	#args=> "$asOf&$classList",
	desc=> 'This is the Weekly Attendance Report With AM/PM',
    },
    SemiMonthlyAttendance => {
	# Sheet
	#args=> "$startEnd&$classList&AllEnrolled=true",
	desc=> 'This is the semi-monthly attendance sheet with projections',
    },
    SemiMonthlyAttendanceBandA => {
	# Sheet
	#args=> "$startEnd&$classList&AllEnrolled=true",
	desc=> 'This is the semi-monthly attendance sheet with projections for Before and After School',
    },
    MonthlyAttendanceReport => {
	args=> "$asOf&$classList&Orderby=class",
	desc=> 'This is the monthly attendance report',
	upload => 'fdf17200-275e-4579-97a1-d719d82e0bae',
    },
    MonthlyAttendanceSubmissionReport => {
	args=> "$asOf&$classList&IncludeSubsidizedChildren=true&IncludeUnsubsidizedChildren=true&Orderby=class",
	desc=> 'This is the monthly attendance submission report',
	upload=> '363b67cf-19bd-42ba-9516-8f11597d3f3c',
    },
    MonthlyAttendanceWithDropoffPickup => {
	args=> "$startEnd&$classList",
	desc=> 'This is a detailed list of all attendance with the name of the dropoff/pickup for the selected classes and time period',
	upload => '3657f13e-e907-45a4-985b-7dd04f222f2b',
	
    },
    MonthlyAttendanceProjectionsReport => {
	args=> "$asOf&$classList",
	desc=> 'This is the monthly attendance sheet with projections',
	upload => '51a82cc3-01fc-40ae-9ad8-7cfa91681457',
    },
    MonthlyAttendanceHealthCheck => {
	# Sheet
	#args=> "$asOf&$classList",
	desc=> 'This is the monthly attendance sheet with health check',
    },
    MonthlyAttendanceFiveWeeks => {
	# Sheet
	#args=> "$asOf&Orderby=class&$classList",
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
	upload => 'ace8bcbf-34a4-4bb4-8867-49a979224690',
    },
    WeeklyProjectionReport => {
	args=> "$asOf&$classList",
	desc=> 'This is the weekly projection report',
	upload => '2d54489e-deb2-446e-b537-f7c66e4322f5',
    },
    WeeklyScheduledTimesReport => {
	args=> "$asOf&$classList",
	desc=> 'This is the Weekly Projection Report With Times',
	upload => '3698c993-71cb-4998-941e-01e75bacd912',
    },
    WeeklyProjectionSummaryReport => {
	args=> "$asOf",
	desc=> 'This is the weekly projection summary report',
	upload => '7e0dde89-c4b1-4bd9-9dee-f1319106424f',
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
	upload => 'd912be86-76fb-4bb8-a7d3-ab482a3b1a34',
    },
    AnnualScheduleSummaryReport => {
	data=> {
	    AsOfDate => $today,
	    @aClassList,
	    @aSchedules,
	},
	desc => 'This is the annual schedule summary report',
	upload => 'b7162f15-4825-4b08-a247-d3bbeb1eb4a5',
    },
    BankDepositSummary => {
	args=> "$startEnd&IncludePaidThroughSandbox=true&IncludeNotPaidThroughSandbox=true",
	desc=> 'The Bank Deposit Summary is a breakdown of all bank deposits within a date range',
	upload => '2b9f785b-054c-4119-99b3-a24a5debb5ef',
    },
    EnrollmentBillingReport => {
	args=> "$startEnd&$classList",
	desc=> 'The Enrollment Billing Report is a list of all enrolled children with details regarding how they are billed.',
	upload => 'd633fa65-5544-41e5-b208-d252069a7312',
    },
    ExtraFeesReport => {
	args=> "$startEnd&IncludeAutomatedFees=true&IncludeManuallyAddedFees=true",
	desc=> 'This is a Summary of Extra Fees.',
	upload => '71286839-c26c-42fe-b75a-0aa1185fa304',
    },
    PaymentSummaryReport => {
	args=> "$startEnd",
	desc=> 'The Payment Summary Report is a summary of all payments received by payment type.',
	upload => '04ac5e07-993a-4a19-bd09-74fc587e93ba',
    },
    PaymentDetailReport => {
	args=> "$startEnd&IncludePaidThroughSandbox=true&IncludeNotPaidThroughSandbox=true&PaymentTypes=cash,cc,check,other",
	desc=> 'The Payment Detail Report is a list of all payments received within a date range',
	upload => '3fa57a0c-90db-4710-81f4-d4d3562a97e7',
    },
    PaymentProcessingReport => {
	args => "$startEnd&Deposit=true",
	desc=> 'The Payment Processing Report is a summary of Payment Received',
	upload => 'ac87e754-37ee-4c9a-a5ef-57af477b2809',
	warn => 'Domo processing needs to be verified',
    },
    WriteOffReport => {
	args => "$startEnd",
	desc => 'The Write Off Report is a list of all bad debt written off within a date range',
	upload => '2383e533-0f51-4926-8d26-b030feb1afe9',
    },
    StatementReport => {
	# Long report, not useful format
	#args => "$startEnd&$classList",
	desc => 'This is the customer statement report',
    },
    DetailedStatementReportForLocation => {
	# Long report, not useful format
	#args=> "$startEnd&$classList",
	desc => 'This is the detailed customer statement report',
    },
    SubsidyReport => {
	# No Subsidized kids here
	#args => "$startEnd&$classList",
	desc => 'This is the subsidy report',
    },
    MonthlySubsidyReport => {
	# No Subsidized kids here
	#args => "$asOf",
	desc => 'This is a Subsidy Report that shows Subsidies Estimated vs Subsidies Collected for a Month',
    },
    CustomerAgingReport => {
	args => "$asOf",
	desc => 'The customer aging report is a list of all customers with their Accounts Receivable Aging Summary',
	upload => '9f40feb6-5bad-44fc-b165-478eece4d0c4',
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
    OutstandingInvoices => {
	data => {
	    PaymentTypes => 'cash,cc,check,other',
	    PaymentIntervals => '2month,2weeks,month,week',
	    Status => '{"Unpaid":true,"Paid":true,"Pending":true,"NotEmailed":true,"Emailed":true,"Unprinted":true,"Printed":true}',
	    StartDate => $start,
	    EndDate => $today,
	    OrderBy => 'invoicenumber',
	},
	desc => 'The Invoices Report is a list of all invoices',
	upload => '73f452fe-8e05-49d0-8421-986218f79138',
	
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
    HTML_AttendanceOverview => {
	url => 'https://go.runsandbox.com/Attendance?AttendanceDate=$date',
	table_headers => [ 'Class', 'Scheduled', 'Attended', 'Sick', 'Vacation', 'Other'],
	upload => '0bfcc94d-ce77-44d9-b460-df31c1a117f0',
    },
	    
};

# Convert ARGV into a hashmap of reports to run. If it's empty, we run all reports
my %reps_to_run = map { $_ => 1 } @ARGV;

my $debug = 0;
if ($reps_to_run{debug}) {
    $debug = 1;
    delete $reps_to_run{debug};
}

$ua->add_handler(request_send => sub {
    my ($request, $ua, $handler) = @_;
    # LWP isn't encoding the content in a way that works with sandbox
    $request->{_content} =~ s/\'/%27/g;
    $request->{_content} =~ s/%2B/+/g;
    $request->{_headers}{'content-length'}=length($request->{'_content'});    
    #print Dumper($request);
    return;
		 });

for my $rep (keys %$reports) {
    # if reps_to_run is populated but the report we're about to run isn't in it
    # then we go to the next report
    if (%reps_to_run && !$reps_to_run{$rep}) {
	next;
    } 
    
    my $fname = 'data/'.lc($rep).".xls";
    my $resp;

    carp 'WARN: '.$reports->{$rep}{warn} if $reports->{$rep}{warn};

    if ($reports->{$rep}{url}) {
	my $df = DateTime::Format::Strptime->new(pattern=>'%D');
	my $date = $df->parse_datetime($start);
	my $endDate = $df->parse_datetime($today);
	$fname = 'data/'.lc($rep).'.csv';
	
	open(my $csvOut, ">", $fname) or die "Cannot open $fname for writing: $!";
	print $csvOut "date,class,scheduled,attended,sick,vacation,other\n";
	while (DateTime->compare($date,$endDate) <= 0) {
	    my $url = $reports->{$rep}{url};
	    my $formatted = $date->mdy();
	    $url =~ s/\$date/$formatted/;
	    #carp 'Getting URL :'. $url;
	    $resp = $ua->get($url,
			     Cookie=>$authCookie);
	    my $te = HTML::TableExtract->new( headers => $reports->{$rep}{table_headers});
	    $te->parse($resp->content);
	    if (!$te->tables) {
		carp "No tables detected in ".$reports->{$rep}{url};
	    } 
	    foreach my $ts ($te->tables) {
		foreach my $row ($ts->rows) {
		    s/^-$/0/ for @$row;
		    print $csvOut $date->mdy('/'), ",", join(',', @$row), "\n";
		}
	    }
	    $date->add( days=>1 );
	}
	close $csvOut;
    } elsif ($reports->{$rep}{data}) {
	$reports->{$rep}{data}{Format} = 'xls';	
	$resp = $ua->post("https://go.runsandbox.com/Report/$rep",
			  Content => $reports->{$rep}{data},
			  ':content_file' => $fname,
			  Cookie=>$authCookie,
	    );
	carp Dumper($resp->request) if ($debug);
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
		carp $a if $debug && $a;
	    }
	} else {
	    if (!$debug) {
		carp "Failed URL: ".$resp->request->uri;
	    } else {
		carp Dumper($resp->request);
	    }
	}
    } else {
	carp "No report run for $rep"
    }
}
