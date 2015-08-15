#
# spec file for package monitoring-plugins-zypper
#
# Copyright (c) 2015 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           monitoring-plugins-zypper
Summary:        Check for software updates via zypper
License:        BSD-3-Clause
Group:          System/Monitoring
Version:        1.82
Release:        0
Url:            http://en.opensuse.org/Monitoring-plugins-zypper
Source0:        check_zypper.pl
Source1:        usr.lib.nagios.plugins.check_zypper 
Source2:        apparmor-abstractions-zypp
Source3:        apparmor-abstractions-ssl
Source4:        apparmor-abstractions-rpm
Requires:       gawk
Requires:       grep
Requires:       rpm
%if 0%{?suse_version} > 1010
# nagios can execute the script with embedded perl
Recommends:     perl 
Recommends:     apparmor-parser
%endif
Requires:       zypper
BuildArch:      noarch
BuildRequires:  nagios-rpm-macros
Provides:       nagios-plugins-zypper = %{version}-%{release}
Obsoletes:      nagios-plugins-zypper < %{version}-%{release}
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
This plugin checks for software updates on systems that use package
management systems based on the zypper command found in (open)SUSE.

It checks for security, recommended and optional patches and also for
optional package updates.

You can define the status by patch category. Use a commata to list more
than one category to a state.

If you like to know the names of available patches and packages, use
the "-v" option.


%prep

%build

%install
install -D -m755 %{SOURCE0} %buildroot/%{nagios_plugindir}/check_zypper
%if 0%{?suse_version} > 01100
install -D -m644 %{SOURCE1} %{buildroot}%{_sysconfdir}/apparmor.d/usr.lib.nagios.plugins.check_zypper
install -D -m644 %{SOURCE4} %{buildroot}%{_sysconfdir}/apparmor.d/abstractions/rpm
install -D -m644 %{SOURCE3} %{buildroot}%{_sysconfdir}/apparmor.d/abstractions/ssl
install -D -m644 %{SOURCE2} %{buildroot}%{_sysconfdir}/apparmor.d/abstractions/zypp
mkdir -p %{buildroot}%{_sysconfdir}/apparmor.d/local
cat > %{buildroot}%{_sysconfdir}/apparmor.d/local/usr.lib.nagios.plugins.check_zypper << EOF
# Site-specific additions and overrides for usr.lib.nagios.plugins.check_zypper
# See /etc/apparmor.d/local/README for details.
EOF
%else
install -D -m644 %{SOURCE1} %{buildroot}%{_sysconfdir}/apparmor/profiles/extras/usr.lib.nagios.plugins.check_zypper
%endif

%clean
rm -rf %buildroot

%files 
%defattr(-,root,root)
# avoid build dependecy of nagios - own the dirs
%dir %{nagios_libdir}
%dir %{nagios_plugindir}
%if 0%{?suse_version} > 01100
%dir %{_sysconfdir}/apparmor.d
%dir %{_sysconfdir}/apparmor.d/abstractions
%config(noreplace) %{_sysconfdir}/apparmor.d/abstractions/rpm
%config(noreplace) %{_sysconfdir}/apparmor.d/abstractions/ssl
%config(noreplace) %{_sysconfdir}/apparmor.d/abstractions/zypp
%dir %{_sysconfdir}/apparmor.d/local
%config %{_sysconfdir}/apparmor.d/usr.lib.nagios.plugins.check_zypper
%config(noreplace) %{_sysconfdir}/apparmor.d/local/usr.lib.nagios.plugins.check_zypper
%else
%dir %{_sysconfdir}/apparmor
%dir %{_sysconfdir}/apparmor/profiles
%dir %{_sysconfdir}/apparmor/profiles/extras
%config(noreplace) %{_sysconfdir}/apparmor/profiles/extras/usr.lib.nagios.plugins.check_zypper
%endif
%{nagios_plugindir}/check_zypper

%changelog
