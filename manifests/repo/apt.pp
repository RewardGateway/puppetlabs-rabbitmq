# requires
#   puppetlabs-apt
#   puppetlabs-stdlib
class rabbitmq::repo::apt(
  $gpg_key_url,
  $location     = 'https://packagecloud.io/rabbitmq/rabbitmq-server/ubuntu/',
  $release      = 'trusty',
  $repos        = 'main',
  $include_src  = false,
  $architecture = undef,
  ) {

  $pin = $rabbitmq::package_apt_pin

  # ordering / ensure to get the last version of repository
  Class['rabbitmq::repo::apt']
  -> Class['apt::update']
  -> Package<| title == 'rabbitmq-server' |>

  $ensure_source = $rabbitmq::repos_ensure ? {
    false   => 'absent',
    default => 'present',
  }

  apt::source { 'rabbitmq':
    ensure       => $ensure_source,
    location     => $location,
    release      => $release,
    repos        => $repos,
    include_src  => $include_src,
    architecture => $architecture,
  }->
  exec {'Add  RabbitMQ Packagecloud Key Repo':
    cmd => "/usr/bin/curl -L '${gpg_key_url}' 2> /dev/null | apt-key add - &>/dev/null",
    unless => "/usr/bin/apt-key list 2> /dev/null | /bin/grep -q -w 'https://packagecloud.io/rabbitmq/rabbitmq-server'",
  }

  if $pin != '' {
    validate_re($pin, '\d{1,4}')
    apt::pin { 'rabbitmq':
      packages => '*',
      priority => $pin,
      origin   => 'www.rabbitmq.com',
    }
  }
}
