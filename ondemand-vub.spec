# Disable debuginfo as it causes issues with bundled gems that build libraries
%global debug_package %{nil}

Summary: Scripts, customizations and tools for Open OnDemand
Name: ondemand-vub
Version: 1.3
Release: 1
BuildArch: noarch
License: GPL
Group: Applications/System
Source: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot

Requires: ondemand

# Disable automatic dependencies as it causes issues with bundled gems and
# node.js packages used in the apps
AutoReqProv: no

%description
Scripts, customizations and tools for Open OnDemand as used at the VUB.

%prep
%setup -q

%build

%install
%{__mkdir_p} %{buildroot}%{_sysconfdir}/ood/config/apps/dashboard/initializers
%{__install} -pm644 ood.rb %{buildroot}%{_sysconfdir}/ood/config/apps/dashboard/initializers/
%{__install} -pm644 ood/profile %{buildroot}%{_sysconfdir}/ood/

%{__mkdir_p} %{buildroot}%{_sysconfdir}/ood/config/apps/myjobs
%{__cp} -pr templates %{buildroot}%{_sysconfdir}/ood/config/apps/myjobs/

%{__mkdir_p} %{buildroot}/%{_localstatedir}/www/ood/public
%{__install} -pm644 html/* %{buildroot}/%{_localstatedir}/www/ood/public/

%{__mkdir_p} %{buildroot}%{_localstatedir}/www/ood/apps/sys
%{__cp} -pr apps/* %{buildroot}%{_localstatedir}/www/ood/apps/sys/


%files
%defattr(-,root,root,-)
/etc/ood/profile
/etc/ood/config/apps/myjobs/templates
/etc/ood/config/apps/dashboard/initializers/ood.rb
/var/www/ood/public
/var/www/ood/apps/sys

%changelog
* Sun Feb 02 2025 Ward Poelmans <ward.poelmans@vub.be>
- Added apps
* Fri Jan 31 2025 Ward Poelmans <ward.poelmans@vub.be>
- First version
