#!/usr/bin/perl
use strict;
my $FS_BUILD_PATH = "freeswitch.final\\Win32\\Debug";
my $WORKING_DIR = "FSClient\\working";

my $USE_LN = 0; #THIS SHOULD BE SET TO 0 (unless you have an ln equiv for windows)
my $COPY_CONF = 1;
my $VERBOSE = 1;
my $VERBOSE_SYS_RES = 0;
die "Build directory does not exist: $FS_BUILD_PATH" if (! -e $FS_BUILD_PATH);
die "Working directory does not exist: $WORKING_DIR" if (! -e $WORKING_DIR);
my @MAIN_FILES = qw/FreeSwitch.dll libapr.dll libaprutil.dll libbroadvoice.dll libspandsp.dll libteletone.dll mod_managed.dll pthread.dll/;
my @modules = qw/mod_celt mod_commands mod_console mod_dialplan_xml mod_dptools mod_event_socket mod_ilbc mod_local_stream mod_logfile mod_loopback mod_PortAudio mod_siren mod_sndfile mod_sofia mod_speex mod_tone_stream mod_h26x mod_silk/;

my $link_cmd = $USE_LN ? "ln -s -a" : "copy";

sub exec_cmd($){
	my ($cmd) = @_;
	print $cmd . "\n" if ($VERBOSE);
	my $res = `$cmd 2>&1`;
	chomp($res);
	chomp($res);
	$res =~ s/\n/\n\t/g;
	print $res . "\n" if ($VERBOSE_SYS_RES);
}
exec_cmd("mkdir " . $WORKING_DIR . "\\mod") if (-e $WORKING_DIR . "\\mod" == 0);
foreach my $module (@modules){
	my $rel_path = "mod\\" . $module . ".dll";
	next if (-e "$WORKING_DIR\\" . $rel_path && $USE_LN);
	my $src_path = $FS_BUILD_PATH . "\\" . $rel_path;
	if (-e $src_path == 0){
		print "Warning: $src_path does not exist\n";
		next;
	}
	exec_cmd($link_cmd . qq~ "$src_path" "$WORKING_DIR\\$rel_path"~);
}

foreach my $file (@MAIN_FILES){
	next if (-e "$WORKING_DIR\\" . $file && $USE_LN);
	my $src_path = $FS_BUILD_PATH . "\\" . $file;
	$src_path = $FS_BUILD_PATH . "\\mod\\" . $file if (-e $FS_BUILD_PATH . "\\mod\\" . $file); #mainly for putting mod_managed.dll into the root
	if (-e $src_path == 0){
		print "Warning: $src_path does not exist\n";
		next;
	}
	exec_cmd($link_cmd . qq~ "$src_path" "$WORKING_DIR\\$file"~);
}

if ($COPY_CONF){
	exec_cmd("mkdir " . $WORKING_DIR . "\\conf") if (-e $WORKING_DIR . "\\conf" == 0);
	exec_cmd($link_cmd . qq~ "conf\\freeswitch.xml" "$WORKING_DIR\\conf\\freeswitch.xml"~);
}