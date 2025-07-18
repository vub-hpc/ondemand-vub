# Disable debuginfo as it causes issues with bundled gems that build libraries
%global debug_package %{nil}

Summary: Scripts, customizations and tools for Open OnDemand
Name: ondemand-vub
Version: 2.00
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
%{__install} -pm644 ondemand.d/* %{buildroot}%{_sysconfdir}/ood/config/ondemand.d/

%{__mkdir_p} %{buildroot}%{_sysconfdir}/ood/config/locales
%{__install} -pm644 locales/* %{buildroot}%{_sysconfdir}/ood/config/locales/

%files
%defattr(-,root,root,-)
/etc/ood/config/apps/myjobs/templates
/etc/ood/config/apps/dashboard/initializers/ood.rb
/etc/ood/config/locales/en.yml
/etc/ood/config/ondemand.d/general_options.yml
/etc/ood/config/ondemand.d/global_bc_items.yml
/etc/ood/profile
/var/www/ood/public
/var/www/ood/apps/sys

%changelog
* Thu Jul 10 2025 Alex Domingo <alex.domingo.toro@vub.be>
- Reorganize app scripts by reusing common template snippets
* Sun Jun 29 2025 Ward Poelmans <ward.poelmans@vub.be>
- Use VSC url for ood docs
* Tue Jun 10 2025 Alex Domingo <alex.domingo.toro@vub.be>
- Pin modules of matlab-proxy to each MATLAB version
* Fri Jun 06 2025 Alex Domingo <alex.domingo.toro@vub.be>
- Update JupyterLab with 2024a environment and simplify its form
* Thu Jun 05 2025 Alex Domingo <alex.domingo.toro@vub.be>
- Update Rstudio with 2024a environment and simplify its form
* Fri May 23 2025 Ward Poelmans <ward.poelmans@vub.be>
- Fix tmux option
* Mon Apr 28 2025 Ward Poelmans <ward.poelmans@vub.be>
- The new zen5 have 128 cores per node
* Tue Apr 22 2025 Alex Domingo <alex.domingo.toro@vub.be>
- Disable session locking in RStudio
* Thu Mar 27 2025 Ward Poelmans <ward.poelmans@vub.be>
- Bump wait time to 10 minutes and some debugging output
* Wed Mar 12 2025 Ward Poelmans <ward.poelmans@vub.be>
- Add link to docs
* Tue Mar 11 2025 Samuel Moors <samuel.moors@vub.be>
- Hide advanced options behind a checkbox
* Mon Mar 10 2025 Ward Poelmans <ward.poelmans@vub.be>
- Drop locale as we fixed the title in the metadata
* Fri Mar 07 2025 Samuel Moors <samuel.moors@vub.be>
- Harmonize module version labels
* Thu Mar 06 2025 Samuel Moors <samuel.moors@vub.be>
- Move locales and general options out of quattor into files
* Mon Mar 03 2025 Samuel Moors <samuel.moors@vub.be>
- Small updates
* Sat Mar 01 2025 Samuel Moors <samuel.moors@vub.be>
- Use absolute paths for TensorBoard
- More css tweaks
* Fri Feb 28 2025 Samuel Moors <samuel.moors@vub.be>
- Update icons + some css tweaks
* Thu Feb 27 2025 Samuel Moors <samuel.moors@vub.be>
- Wait until TensorBoard is ready
* Wed Feb 26 2025 Samuel Moors <samuel.moors@vub.be>
- Add symlinks for MATLAB and VS Code
- Set XDG_DATA_HOME for RStudio
- Change user-data-dir for code-server
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
