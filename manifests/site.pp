require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew'],
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { 'v0.6': }
  nodejs::version { 'v0.8': }
  nodejs::version { 'v0.10': }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.0': }
  ruby::version { '2.1.1': }
  ruby::version { '2.1.2': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar',
      'go',
      'bash-completion',
      'python'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  # Creating Jodys Mac env
  osx::recovery_message { 'If this Mac is found, please call 773-330-5322': }
  include osx::software_update
  include osx::no_network_dsstores
  include osx::disable_app_quarantine
  include osx::universal_access::enable_scrollwheel_zoom
  include osx::universal_access::cursor_size
  include osx::universal_access::ctrl_mod_zoom
  include osx::global::enable_keyboard_control_access
  include osx::global::tap_to_click
  include osx::global::expand_print_dialog
  include osx::global::expand_save_dialog 
  include osx::finder::empty_trash_securely
  include osx::finder::enable_quicklook_text_selection
  include osx::finder::show_all_on_desktop
  include osx::finder::show_hidden_files
  include osx::finder::unhide_library
 
  include osx::dock::autohide
  include osx::dock::clear_dock
  include osx::dock::dim_hidden_apps
  include osx::dock::icon_size

  osx::dock::hot_corner { 'Top Left':
    action => 'Put Display to Sleep'
  }
 
  include osx::keyboard::capslock_to_control

  boxen::osx_defaults {
    
    "Trackpad, Point & Click, Tap to click":
      host => currentHost,
      domain => NSGlobalDomain,
      key => "com.apple.mouse.tapBehavior",
      type => boolean,
      value => true;

   "Mouse, Tracking":
      domain => NSGlobalDomain,
      key => "com.apple.mouse.scaling",
      type => float,
      value => 0.875;

   "Trackpad, Tracking":
      domain => NSGlobalDomain,
      key => "com.apple.trackpad.scaling",
      type => float,
      value => 0.875;
   
   "Datetime format":
      domain => "com.apple.menuextra.clock",
      key => DateFormat,
      type => string,
      value => "EEE MMM d  H:mm:ss";
  }


  include caffeine
  include chrome
  include dropbox
  include spectacle
  include tunnelblick
  include vagrant
  include vmware_fusion


  git::config::global { 
    'user.email':
      value  => 'jodylent@gmail.com';

    'user.name': 
      value => 'Jody Lent';

    'color.ui':
      value => 'true';

    'push.default':
      value => 'simple';
  }

  file { "/Users/jlent/projects":
    ensure => "directory",
  }

}
