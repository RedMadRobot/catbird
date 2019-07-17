Pod::Spec.new do |s|
  s.name           = 'Catbird'
  s.version        = '0.0.7'
  s.summary        = 'Mock server for UI tests'
  s.homepage       = 'https://github.com/RedMadRobot/catbird'
  s.license        = { type: 'MIT', file: 'LICENSE' }
  s.author         = { 'Alexander Ignition' => 'ai@redmadrobot.com' }
  s.source         = { git: 'https://github.com/RedMadRobot/catbird.git', tag: s.version.to_s }
  s.source_files   = 'Sources/CatbirdAPI/*.swift'
  s.preserve_paths = 'catbird', 'start.sh', 'stop.sh', 'Public/*', 'Resources/*'
  s.ios.deployment_target = '10.0'
  s.swift_version = '5'
end
