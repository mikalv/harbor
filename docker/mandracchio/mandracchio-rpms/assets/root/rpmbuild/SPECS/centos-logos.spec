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
