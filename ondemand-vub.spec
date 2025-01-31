Summary: Scripts, customizations and tools for Open OnDemand
Name: ondemand-vub
Version: 1.0
Release: 1
BuildArch: noarch
License: GPL
Group: Applications/System
Source: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot

%description
Scripts, customizations and tools for Open OnDemand as used at the VUB.

%prep
%setup -q

%build

%install
%{__mkdir_p} %{buildroot}%{_sysconfdir}/ood/config/apps/dashboard/initializers
%{__install} -pm644 ood.rb %{buildroot}%{_sysconfdir}/ood/config/apps/dashboard/initializers/

%{__mkdir_p} %{buildroot}%{_sysconfdir}/ood/config/apps/myjobs
%{__cp} -pr templates %{buildroot}%{_sysconfdir}/ood/config/apps/myjobs/

%files
%defattr(-,root,root,-)
/etc/ood/config/apps/myjobs/templates
/etc/ood/config/apps/dashboard/initializers/ood.rb

%changelog
* Fri Jan 31 2025 Ward Poelmans <ward.poelmans@vub.be>
- First version
