class Mobile
  def initialize(app)
    @app = app
  end

  def call(env)
    uri = env['REQUEST_URI'] 
    req_path = env['REQUEST_PATH']
    path_info = env['PATH_INFO']
    env['PATH_INFO'] = path_info.nil? ? nil : path_info.gsub(/\/mobile/, '')
    env['REQUEST_PATH'] = req_path.nil? ? nil : req_path.gsub(/\/mobile/, '')
    env['REQUEST_URI'] = uri.nil? ? nil : uri.gsub(/\/mobile/, '')
    @app.call(env)
  end
end