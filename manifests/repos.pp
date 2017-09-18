# == Class: opendaylight::repos
#
# Manages installation of OpenDaylight repositories for RPMs and Debs.
#
# === Parameters
#
# [*deb_repo*]
#  Deb PPA repo to install ODL from. Ignored if on a RPM-based system.
#  Defaults to $::opendaylight::deb_repo
#
# [*rpm_repo*]
#  Repo URL to install ODL RPM from, in .repo baseurl format. Ignored if on a
#  Debian-based system.
#  Defaults to $::opendaylight::rpm_repo
#
# [*rpm_repo_enabled*]
#  Flag to indicate if the the RPM repo should be enabled or disabled.
#  Defualts to 1.
#
# [*rpm_repo_gpgcheck*]
#  Flag to indicate if the RPM repo should be configured with gpgcheck.
#  Defaults to 0.
#
class opendaylight::repos (
  $deb_repo          = $::opendaylight::deb_repo,
  $rpm_repo          = $::opendaylight::rpm_repo,
  $rpm_repo_enabled  = 1,
  $rpm_repo_gpgcheck = 0,
) inherits ::opendaylight {
  if $::osfamily == 'RedHat' {
    # Add OpenDaylight's Yum repository
    yumrepo { 'opendaylight':
      ensure   => present,
      baseurl  => $rpm_repo,
      descr    => 'OpenDaylight SDN Controller',
      enabled  => $rpm_repo_enabled,
      # NB: RPM signing is an active TODO, but is not done. We will enable
      #     this gpgcheck once the RPM supports it.
      gpgcheck => $rpm_repo_gpgcheck,
    }
  } elsif ($::osfamily == 'Debian') {
    include ::apt

    # Add ODL ppa repository
    apt::ppa{ $deb_repo: }
  } else {
    fail("Unknown operating system method: ${::osfamily}")
  }
}
