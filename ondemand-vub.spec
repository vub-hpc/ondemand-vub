# Disable debuginfo as it causes issues with bundled gems that build libraries
%global debug_package %{nil}

Summary: Scripts, customizations and tools for Open OnDemand
Name: ondemand-vub
Version: 1.13
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

%{__mkdir_p} %{buildroot}%{_sysconfdir}/ood/config/ondemand.d
%{__install} -pm644 global_bc_items.yml %{buildroot}%{_sysconfdir}/ood/config/ondemand.d/

%files
%defattr(-,root,root,-)
/etc/ood/profile
/etc/ood/config/apps/myjobs/templates
/etc/ood/config/apps/dashboard/initializers/ood.rb
/etc/ood/config/ondemand.d/global_bc_items.yml
/var/www/ood/public
/var/www/ood/apps/sys

%changelog
* Tue Feb 25 2025 Ward Poelmans <ward.poelmans@vub.be>
- Unversioned code-server module load
* Mon Feb 24 2025 Samuel Moors <samuel.moors@vub.be>
- Revert to bc_num_hours also for desktop and gaussview
* Fri Feb 21 2025 Samuel Moors <samuel.moors@vub.be>
- Various updates
* Sat Feb 15 2025 Samuel Moors <samuel.moors@vub.be>
- Use common before.sh file for all apps
* Wed Feb 12 2025 Samuel Moors <samuel.moors@vub.be>
- Use global form items
* Mon Feb 10 2025 Samuel Moors <samuel.moors@vub.be>
- Fix clean workspace option
* Sat Feb 08 2025 Samuel Moors <samuel.moors@vub.be>
- Add checkbox to start with clean workspace for RStudio
* Thu Feb 06 2025 Samuel Moors <samuel.moors@vub.be>
- Add nglview and py3dmol extensions to jupyterlab
- Fix execute permissions for RStudio rsession.sh script
* Mon Feb 03 2025 Ward Poelmans <ward.poelmans@vub.be>
- Fix shebangs so rpmbuild leaves them alone
* Sun Feb 02 2025 Ward Poelmans <ward.poelmans@vub.be>
- Added apps
* Fri Jan 31 2025 Ward Poelmans <ward.poelmans@vub.be>
- First version
