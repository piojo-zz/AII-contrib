# ${license-info}
# ${developer-info}
# ${author-info}

package AII::freeipa;

use strict;
use warnings;
use CAF::Process;

use constant CMD => qw(set_dandompasswd.py);

sub new
{
    my $class = shift;
    return bless {}, $class;
}

sub get_passwd
{
    my ($self, $server, $domain, $client_ip) = @_;

    my $cmd = CAF::Process->new([CMD, $server, $domain, $client_ip],
                               stdout => \my $pwd, stderr => \my $err);
    if ($?) {
        die "Couldn't run command: $err";
    }
    return $pwd;
}

sub get_boot_interface
{
    my ($self, $hw, $net) = @_;

    while (my ($k, $v) = each(%$hw)) {
        if ($v->{boot}) {
            return $hw->{$v}->{ip};
        }
    }
    die "No boot IP found";
}

sub post_install
{
    my ($self, $config, $path) = @_;

    my $t = $config->getElement($path)->getTree();

    my $nt = $config->getElement("/system/network/interfaces")->getTree();
    my $hw = $config->getElement("/hardware/cards/nic")->getTree();

    my $ip = $self->get_boot_interface($hw, $nt);

    my $passwd = $self->get_passwd($t->{server}, $t->{domain}, $ip);

    print <<EOF;
/usr/sbin/ipa-client-install --domain=$t->{domain} --enable-dns-updates --mkhomedir -w $passwd --realm=$t->{realm} --server=$t->{server} --unattendedsub post_reboot
EOF

}

1;
