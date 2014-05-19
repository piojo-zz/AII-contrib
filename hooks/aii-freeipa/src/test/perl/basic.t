#!/usr/bin/perl 
# -*- mode: cperl -*-
# ${license-info}
# ${developer-info}
# ${author-info}
# ${build-info}

use strict;
use warnings;
use Test::More;
use AII::freeipa;
use CAF::Object;
#use NCM::Component;
use Test::Quattor qw(basic);

use helper;

my $cfg = get_config_for_profile('basic');
#my $cmp = NCM::Component->new("dummy");

my $aii = AII::freeipa->new();
is (ref ($aii), "AII::freeipa", "AII:freeipa correctly instantiated");

my $path;
#
command_history_reset;
set_output("disable");

$path = "/system/aii/hooks/remove/0";
$aii->remove($cfg, $path);
ok(command_history_ok(["ipa aii --disable x y.z"]), 
    "ipa aii --disable called");

# test ks post 
command_history_reset;
set_output("install_ip");

open STDOUT, ">target/test/test.out" or die "Could not redirect STDOUT! $!";
$aii->post_install($cfg, $path);
close STDOUT;

ok(command_history_ok(["ipa aii --install --ip 5.6.7.8 x y.z"]), 
    "ipa aii --install --ip called");

open T, "target/test/test.out" or die "Could not read from test.out! $!";
my @contents = <T>;
close T;
my $out=join("", @contents);
like($out, qr(^/usr/sbin/ipa-client-install)m, "Call ipa-client-install");
like($out, qr/--domain=z\s+--mkhomedir\s+-w\s+onetimepassword\s+--realm=DUMMY\s+--server=ipa.y.z\s+--unattendedsub\s+post_reboot/, "FreeIPA params ok");
like($out, qr(--enable-dns-updates)m, "IPA dns enabled");

done_testing();
