God.watch do |w|
  w.name = 'Cubes Slicer Server'
  w.start = "ps aux | grep slicer | grep -v \"grep\" | awk '{print $2}' | xargs kill -9 && slicer serve slicer.ini"
  w.dir = File.join(__dir__, 'cubes')
  w.log = File.join(__dir__, 'log', 'cubes.log')
  w.start_grace = 20.seconds
  w.interval = 5.seconds

  w.transition(:init, true => :up, false => :start) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end

    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
    end
  end

  w.transition(:up, :restart) do |on|
    on.condition(:http_response_code) do |c|
      c.host = '0.0.0.0'
      c.port = 8085
      c.path = '/info'
      c.code_is_not = 200
      c.timeout = 30
      c.interval = 30.seconds
    end
  end
end
