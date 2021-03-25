:   eval 'exec perl -S $0 "$@"'
    if $running_under_some_shell;

#-----------------Created by Sakib Rahman on 11 May, 2018--------------------------#
#------http://www.troubleshooters.com/codecorn/littperl/perlreg.htm---------#

use Cwd;
use Cwd 'abs_path';
use File::Find ();
use File::Basename;

use Getopt::Std;

#-------------Declare variables explicitly so "my" not needed----------------#
use strict 'vars';
use vars qw($opt_h $opt_T $opt_D $opt_F $opt_S $scale $Default_Options $count
            $tosca_dir $map_dir $file_base $file_name $map_file_name $j
            $filename $map_file_base $file $dir $ext $value @linevalue
            $radius $theta $z_loc $Br $Btheta $Bz $Bmod $angle_rotate
            );

use Cwd qw(cwd getcwd);

#----------------Set up some basic environment variables---------------------#
$tosca_dir = getcwd; 

#-----------------Get the option flags---------------------------------------#
getopts('hT:D:F:S:');

$Default_Options = "";

if ($#ARGV > -1){
    print STDERR "Unknown arguments specified: @ARGV\nExiting.\n";
    displayusage();
    exit;
}

if ($opt_h){
    displayusage();
    exit;
}

$map_dir = undef;
if ($opt_D ne ""){
    $map_dir = $opt_D;
} else {
    $map_dir = "map/beamHybrid/lp";
}

$file_base = undef;
if ($opt_F ne ""){
    $file_base = $opt_F;
} else {
    $file_base = "Post_201810291245579201";
}

$scale= undef;
if ($opt_S ne ""){
    $scale = $opt_S;
} else {
    $scale = 1.0;
}


# Command lines that worked:
# perl -wne ' if (/.{0}(Opening file for reading:).{58}(.+)$/) {my($filename)=$2; print "$filename";  } else { }' $tosca_dir/$map_dir/$file_base.lp | more  
# perl -wne ' if (/(\s*[0-9e+-]+){7}/i) { if (/(©|Minimum|Reduce|Integral)/) {  } else { print "$_" }} ' $tosca_dir/$map_dir/$file_base.lp > $file_base.tmp

$file_name ="$tosca_dir/$map_dir/$file_base.lp";
print "\nReading TOSCA file $file_base from \n$tosca_dir/$map_dir/\n\n";

open(TOSCAFILE, "<$file_name") or die "$file_name: $!\n";

while (<TOSCAFILE>)
{
    my($line) = $_;
#    print "$line";
    chomp($line);
    if ($line =~ /.{0}(Opening file for reading:).{1}(.+)$/) 
    {
	$filename=$2; 
	last;  
    }
}
close TOSCAFILE;
    
fileparse_set_fstype(MSWin32);
chomp($filename);

($file,$dir,$ext) = fileparse($filename, qr/\.[^.]*/);
fileparse_set_fstype(UNIX);

print "The conductor file name is $file\n";
$map_file_name ="$tosca_dir/$map_dir/../text/$file.txt";

if ($opt_T ne ""){
  $angle_rotate = $opt_T;
}else{ 
  $angle_rotate = -180;
}

$count = 0;
open(TOSCAFILE, "<$file_name") or die "$file_name: $!\n";
open(MAPFILE, ">$map_file_name") or die "$map_file_name: $!\n";
while (<TOSCAFILE>)
{
    my($line2) = $_;
    if (($line2 =~ /(\s*[0-9e+-]+){7}/i) and ($line2 !~ /(©|Minimum|Reduce|Integral)/))
    {    

# Convert cm to m, Gauss to Tesla, and rotate to +/- 25 degrees
	@linevalue = split(' ',$line2);

	$radius=$linevalue[0]/1000.;
	$theta =$linevalue[1]+$angle_rotate;
	$z_loc =$linevalue[2]/1000.; 
	$Br    =$scale*$linevalue[3]/1.e4; 
	$Btheta=$scale*$linevalue[4]/1.e4;  
	$Bz    =$scale*$linevalue[5]/1.e4; 
	$Bmod  =$scale*$linevalue[6]/1.e4; 

	$count++;

	if(($count>1) and ($radius==0.015) and ($theta==-25)){
	    if(count%9231==0){
		print "$count\n";
	    } else {
		print STDERR "Something wrong with line $count:\n";
		print STDERR "$radius\t$theta\t$z_loc\t$Br\t$Btheta\t$Bz\n";
		last;
	    }
	}
	print MAPFILE "$radius\t$theta\t$z_loc\t$Br\t$Btheta\t$Bz\n";
    }
}
close TOSCAFILE;
close MAPFILE;

exit;

################################################
sub crashout ($) {
    my ($tmpline) = @_;
    die("\*\*\tThe environment is not correctly set up to run batchsub.pl;\n".
	"\*\*\tyou might need to source env_jlabcue first.\n".
	"\*\*\tParticularly:\n\*\*\t\t$tmpline");
}
################################################
sub displayusage {
    print STDERR
	"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n",
	"batch_test.pl is a job submission tool for converting TOSCA maps\n",
	"on the JLab batch farm computer cluster.\n\n",
	"Usage:\n\tbatch_test.pl -h\n",
	"\tbatch_test.pl [-D <map directory>]\n",
	"\t              [-F <TOSCA .lp file name>] \n\n",
	"Options:\n",
	"\t-h\n",
	"\t\tPrint usage information\n",
	"\t-D\n",
	"\t\tChange default map directory\n",
	"\t-F\n",
	"\t\tSpecify TOSCA .lp name\n",
	"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";

    my @optionlines = split  /(.{40,}?)( -)|$/, $Default_Options;
    my ($optline, $preline);
    foreach $optline (@optionlines){
	next if ($optline =~ /^$/);
	if ($optline =~ /^ -$/){
	    $preline = "-";
	} else {
	    print STDERR
		"\t\t  $preline$optline\n";
	    $preline = "";
	}
    }
}
