use inc::Module::Install 0.46;
name('Jifty-Plugin-Gladiator');
version_from('lib/Jifty/Plugin/Gladiator.pm');

requires('Jifty' => '0.90422');
requires('Devel::Gladiator');

auto_install();
tests(qw( t/*/t/*.t ));

WriteAll;
