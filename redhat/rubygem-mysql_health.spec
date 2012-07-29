%define ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%define gemname mysql_health
%define gemversion 0.5.3
%define geminstdir %{gemdir}/gems/%{gemname}-%{gemversion}
%define gemfile %{gemname}-%{gemversion}.gem
%define gemsummary %(ruby -rrubygems -e 'puts YAML.load(`gem specification %{gemfile}`).summary')
%define gemdesc %(ruby -rrubygems -e 'puts YAML.load(`gem specification %{gemfile}`).description')
%define gemhomepage %(ruby -rrubygems -e 'puts YAML.load(`gem specification %{gemfile}`).homepage')
%define gemlicense %(ruby -rrubygems -e 'puts YAML.load(`gem specification %{gemfile}`).license || "Unknown"')
%define gemdeps %(ruby -rrubygems -e 'puts YAML.load(`gem specification %{gemfile}`.chomp).dependencies.map { |d| "rubygem(%s) %s" % [d.name, d.requirement] }.sort.join(", ")')
%define gemrelease %(date +"%%Y%%m%%d%%H%%M%%S")

Summary: %{gemsummary}
# The version is repeated in the name so as to allow multiple versions of the gem to be installed on the system.
Name: rubygem-%{gemname}-%{gemversion}
Version: %{gemversion}
Release: %{gemrelease}%{?dist}
Group: Development/Languages
License: %{gemlicense}
URL: %{gemhomepage}
Source0: http://rubygems.org/gems/%{gemname}-%{version}.gem
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: rubygems

Requires: %{gemdeps}

BuildRequires: rubygems
BuildRequires: rubygem(bundler)
BuildArch: noarch
Provides: rubygem(%{gemname}) = %{version}

%description
%{gemdesc}

%prep

%build

%install
rm -rf %{buildroot}
install --directory 0755 %{buildroot}%{gemdir}
gem install --local --install-dir %{buildroot}%{gemdir} \
            --force --rdoc %{SOURCE0}
install --directory 0755 %{buildroot}/%{_bindir}
mv %{buildroot}%{gemdir}/bin/%{gemname} %{buildroot}/%{_bindir}
find %{buildroot}%{geminstdir}/bin -type f | xargs chmod a+x

install --directory --mode 0755 %{buildroot}%{_sysconfdir}/%{gemname}
install --directory --mode 0755 %{buildroot}%{_initrddir}
install --mode 755 %{buildroot}%{geminstdir}/redhat/%{gemname}.initrc %{buildroot}%{_initrddir}/%{gemname}

install --directory --mode 0755 %{buildroot}%{_sysconfdir}/sysconfig
cat<<__EOF__>%{buildroot}/%{_sysconfdir}/sysconfig/%{gemname}
__EOF__

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root, -)
%{_bindir}/%{gemname}
%{gemdir}/gems/%{gemname}-%{version}/
%doc %{gemdir}/doc/%{gemname}-%{version}
%{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec
%{_initrddir}/%{gemname}
%{_sysconfdir}/%{gemname}/
%{_sysconfdir}/sysconfig/%{gemname}

%changelog
* Sun Jul 29 2012 Erik Osterman <e@osterman.com>
- Initial package
