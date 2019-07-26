Pod::Spec.new do |s|
  s.name           = 'Catbird'
  s.version        = '0.0.9'
  s.summary        = 'Mock server for UI tests'
  s.homepage       = 'https://github.com/RedMadRobot/catbird'
  s.license        = { type: 'MIT', file: 'LICENSE' }
  s.author         = { 'Alexander Ignition' => 'ai@redmadrobot.com' }
  s.source_files   = 'Sources/CatbirdAPI/*.swift'
  s.source         = { http: "#{s.homepage}/releases/download/#{s.version}/catbird.zip" }
  s.preserve_paths = '*'
  s.swift_version = '5'
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'
end
