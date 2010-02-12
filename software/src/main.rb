$modem = $win.dongle

# Booted up, go enable things
$win.StartAccelerometer.enabled = true

# main loop for polling
loop do
  if $run
    puts $modem.getAccelerometerData.to_a.join(",")
  end
end