# port/mandracchio*

## Function

These images contain the Mandracchio build system


cat > /root/rpmbuild/SPECS/centos-logos.spec <<EOF
Summary:   CentOS Logos Dummy Package, its over 9000
Name:      centos-logos
Version:   9000.0.1
Release:   3%{?dist}
License:   Copyright © 2014 Port Direct.  All rights reserved.
Packager:  Port Direct <support@port.direct>
Vendor:    Port Direct
Group:     System Environment/Base
URL:       https://port.direct/
BuildArch: noarch
Obsoletes: gnome-logos
Obsoletes: fedora-logos <= 16.0.2-2
Obsoletes: redhat-logos
Provides: gnome-logos = %{version}-%{release}
Provides: system-logos = %{version}-%{release}
Provides: redhat-logos = %{version}-%{release}
Provides: system-backgrounds-gnome
Conflicts: kdebase <= 3.1.5
Conflicts: anaconda-images <= 10
Conflicts: redhat-artwork <= 5.0.5

%description
This is a dummy package, it replaces the default-centos logos package with no content.
This saves about 20mb when installing httpd.

%files

%changelog
* Wed Sep 14 2016 Pete Birley 0
- dummy package
EOF
rpmbuild -bb /root/rpmbuild/SPECS/centos-logos.spec


Wed Aug 24 2005
%global codename verne
%global dist .el7.centos

Name: centos-logos
Summary: CentOS-related icons and pictures
Version: 70.0.6
Release: 3%{?dist}
Group: System Environment/Base
URL: http://www.centos.org
# No upstream, done in internal git
Source0: centos-logos-%{version}.tar.xz
License: Copyright © 2014 The CentOS Project.  All rights reserved.

BuildArch: noarch
Obsoletes: gnome-logos
Obsoletes: fedora-logos <= 16.0.2-2
Obsoletes: redhat-logos
Provides: gnome-logos = %{version}-%{release}
Provides: system-logos = %{version}-%{release}
Provides: redhat-logos = %{version}-%{release}
# We carry the GSettings schema override, tell that to gnome-desktop3
Provides: system-backgrounds-gnome
Conflicts: kdebase <= 3.1.5
Conflicts: anaconda-images <= 10
Conflicts: redhat-artwork <= 5.0.5
# For splashtolss.sh
#FIXME: dropped for now since it's not available yet
#BuildRequires: syslinux-perl, netpbm-progs
Requires(post): coreutils
BuildRequires: hardlink
# For _kde4_* macros:
BuildRequires: kde-filesystem

%description
The redhat-logos package (the "Package") contains files created by the
CentOS Project to replace the Red Hat "Shadow Man" logo and  RPM logo.
The Red Hat "Shadow Man" logo, RPM, and the RPM logo are trademarks or
registered trademarks of Red Hat, Inc.

The Package and CentOS logos (the "Marks") can only used as outlined
in the included COPYING file. Please see that file for information on
copying and redistribution of the CentOS Marks.

%prep
%setup -q

%build

%install

%changelog
* Wed Sep 30 2015 Johnny Hughes <johnny@centos.org> - 70.0.6-3
- fix centos bug 9258
