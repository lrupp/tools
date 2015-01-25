#
# spec file for package monitoring-plugins-transtec
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

Name:           monitoring-plugins-transtec
Summary:        Check the status of a Transtec Storage Array
Version:        1.2
Release:        100
Url:            http://www.transtec.de/
License:        GPL-2.0+
Group:          System/Monitoring
Source0:        check_transtec
BuildRequires:  nagios-rpm-macros
Provides:       nagios-plugins-transtec = %{version}-%{release}
Obsoletes:      nagios-plugins-transtec < %{version}-%{release}
BuildArch:      noarch
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
Nagios plugin (script) to check the status of a Transtec Storage Array.

You need the raidcmd21.jar file from Transtec for this plugin.

Tested with the following models:
* T61F16R1-BA
* T6100F16R1-B
* T6100F16R1-E
* PV610F16R1B
* PX630F24R2C

%prep

%build

%install
install -Dm755 %{SOURCE0} %buildroot/%{nagios_plugindir}/check_transtec
mkdir -p %buildroot/%{_var}/cache/check_transtec

%clean
rm -rf %{buildroot}

%files 
%defattr(-,root,root)
# avoid build dependecy of nagios - own the dirs
%dir %{nagios_libdir}
%dir %{nagios_plugindir}
%{nagios_plugindir}/check_transtec
%dir %attr(0750,%{nagios_user},%{nagios_group}) %{_var}/cache/check_transtec

%changelog
