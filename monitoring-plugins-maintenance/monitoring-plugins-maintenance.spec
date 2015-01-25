#
# spec file for package monitoring-plugins-maintenance
#
# Copyright (c) 2014 SUSE LINUX GmbH, Nuernberg, Germany.
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


Name:           monitoring-plugins-maintenance
Version:        2.2
Release:        0
Summary:        Check, if a host is in service
License:        BSD-3-Clause
Group:          System/Monitoring
Url:            http://en.opensuse.org/Monitoring-plugins-maintenance
Source0:        check_maintenance.pl
BuildRequires:  nagios-rpm-macros
Provides:       nagios-plugins-maintenance = %{version}-%{release}
Obsoletes:      nagios-plugins-maintenance < %{version}-%{release}
Requires:       perl(Date::Calc)
Requires:       perl(Getopt::Long)
Requires:       perl(Pod::Usage)
# nagios can execute the script with embedded perl
Recommends:     perl
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

%description
check_maintenance allows you to let Nagios do the critical check, if the
hardware of a given host is still in service or not.

check_maintenance will read the given file with maintenance data and checks for
a line with the given hostname and service date.

If it succeeds, the service date will be processed against the given warning
and critical values.

All data in the maintenance file behind the second '|' will be printed as
normal output to Nagios, so you can use this to add addtional informations like
the room or inventory number of the host.

%prep
#
%build
#
%install
install -D -m755 %{SOURCE0} %{buildroot}%{nagios_plugindir}/check_maintenance

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
# avoid build dependecy of nagios - own the dirs
%dir %{nagios_libdir}
%dir %{nagios_plugindir}
%{nagios_plugindir}/check_maintenance

%changelog
