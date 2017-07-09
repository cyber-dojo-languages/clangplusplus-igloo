
lambda { |stdout,stderr,status|
  output = stdout + stderr
  igloo_pattern =  /Test run complete. (\d+) tests run, (\d+) succeeded, (\d+) failed./
  if match = igloo_pattern.match(output)
    match[3] == '0' ? :green : :red
  else
   :amber
  end
}
