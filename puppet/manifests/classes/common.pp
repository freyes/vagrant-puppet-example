class force_apt_update {
  exec { "aptupdate":
    command => "apt-get update && touch /root/.apt-updated",
    logoutput   => 'on_failure',
    path => "/usr/bin:/bin:/usr/sbin:/sbin",
    creates => "/root/.apt-updated"
  }
  Exec["aptupdate"]  -> Package <| |>
}
