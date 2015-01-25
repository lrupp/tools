#
# spec file for package monitoring-plugins-dothill
#
# Copyright (c) 2012-2014 SUSE LINUX Products GmbH, Nuernberg, Germany.
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


Name:           monitoring-plugins-dothill
Summary:        Check Dot Hill Revolution Storage Arrays
License:        GPL-2.0
Group:          System/Monitoring
Version:        0.1.0
Release:        100
Url:            http://download.opensuse.org/repositories/server:/monitoring
Source0:        check_dothill
%if 0%{?suse_version} > 1010
# nagios can execute the script with embedded perl
Recommends:     perl 
%endif
Requires:       perl(Getopt::Long)
Requires:       perl(Net::Telnet)
Requires:       perl(Pod::Usage)
BuildArch:      noarch
BuildRequires:  nagios-rpm-macros
Provides:       nagios-plugins-dothill = %{version}-%{release}
Obsoletes:      nagios-plugins-dothill < %{version}-%{release}
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
Check Dot Hill Revolution Storage Arrays with this plugin.

SYNOPSIS

./check_dothill -H <hostname> -u <username> -p <password>  <OPTIONS>

Options:

    -c <file>      | --config <file>
    -H <host>      | --host <host>
    -u <username>  | --username <username>
    -p <password>  | --password <password>

     -S            | --no-sensors
     -C            | --no-controllers
     -V            | --no-vdisks
     -P            | --no-ports
     -D            | --no-disks

                   | --logfile <file>
                   | --loglevel <int>

    -h             | --help
    -d             | --debug


%prep

%build

%install
install -D -m755 %{SOURCE0} %buildroot/%{nagios_plugindir}/check_dothill

%clean
rm -rf %buildroot

%files 
%defattr(-,root,root)
# avoid build dependecy of nagios - own the dirs
%dir %{nagios_libdir}
%dir %{nagios_plugindir}
%{nagios_plugindir}/check_dothill

%changelog
