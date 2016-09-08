#
# spec file for package monitoring-plugins-sks_keyserver
#
# Copyright (c) 2016 SUSE LINUX GmbH, Nuernberg, Germany.
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


Name:           monitoring-plugins-sks_keyserver
Version:        0.1
Release:        0
Summary:        Check the status of a sks keyserver entry
License:        BSD-3-Clause
Group:          System/Monitoring
Url:            http://en.opensuse.org/monitoring-plugins-sks_keyserver
Source0:        check_sks_keyserver
%if 0%{?suse_version}
BuildRequires:  nagios-rpm-macros
%else
%define         nagios_libdir %{_libdir}/nagios
%define         nagios_plugindir %{nagios_libdir}/plugins
%endif
Requires:       perl(Getopt::Long)
Requires:       perl(LWP)
Requires:       perl(JSON)
Requires:       perl(JSON::Parse)
# older RH distributions do not have weak dependencies
# let them require the packages instead to be sure it works
%if ( %{defined rhel_version} && 0%{?rhel_version} <= 7 ) || ( %{defined fedora_version} && 0%{?fedora_version} <= 20 ) || ( %{defined centos_version} && 0%{?centos_version} <= 7 )
Requires:       perl(Data::Dumper)
Requires:       perl
%else
Recommends:     perl(Data::Dumper)
# nagios can execute the script with embedded perl
Recommends:     perl
%endif
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

%description
If you are an administrator of a public SKS server (GPG key server), you should check 
regulary that your server is in the SKS pool. This plugin for your monitoring server
will help you with that as it queries (per default, URL can be adapted) the public 
sks-keyservers.net server for the given hostname and outputs not only if the server
is still in the pool, but also some additional statistics that you might want to 
have at hand from time to time.

Please note that the plugin can also output the states of your peers (option: -p), 
so you can inform then if they are not in the public pool any more.

Warning and critical levels exist to configure the amount of "good" peers you want 
to see your server connected to at any time.

%prep
#
%build
#
%install
install -D -m755 %{SOURCE0} %{buildroot}%{nagios_plugindir}/check_sks_keyserver
%if ! 0%{?suse_version}
sed -i "s|/usr/lib/nagios/plugins|%{_libdir}/nagios/plugins|g" %{buildroot}%{nagios_plugindir}/check_sks_keyserver
%endif


%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
# avoid build dependecy of nagios - own the dirs
%dir %{nagios_libdir}
%dir %{nagios_plugindir}
%{nagios_plugindir}/check_sks_keyserver

%changelog
