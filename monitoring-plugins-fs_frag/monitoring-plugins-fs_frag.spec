#
# spec file for package monitoring-plugins-fs_frag
#
# Copyright (c) 2014, Lars Vogdt <lars@linux-schulserver.de>
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


%define         realname check_fs_frag
Name:           monitoring-plugins-fs_frag
Version:        1.o
Release:        0
Summary:        Check xfs and ext filesystems for fragmentation
License:        BSD-2-Clause
Group:          System/Monitoring
Url:            https://github.com/lrupp/tools/tree/master/monitoring-plugins-fs_frag
Source0:        check_fs_frag
BuildRequires:  nagios-rpm-macros
Requires:       bc
Requires:       monitoring-plugins-common
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

%description
Check the fragmentation of your ext2, ext3, ext4 or xfs filesystem by invoking 
%{nagios_plugindir}/check_fs_frag

%prep

%build

%install
install -Dm755 %{SOURCE0} %{buildroot}/%{nagios_plugindir}/check_fs_frag

%files
%defattr(-,root,root)
%dir %{nagios_libdir}
%{nagios_plugindir}/

%changelog
