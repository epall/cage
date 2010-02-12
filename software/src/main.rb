$modem = $win.dongle
$die = false

# Booted up, go enable things
$win.StartAccelerometer.enabled = true

# main loop for polling
loop do
  if $run
    puts $modem.getAccelerometerData.to_a.join(",")
  end

  if $die
    puts "Closing port"
    $die = false
    $modem.closePort
  end
end
