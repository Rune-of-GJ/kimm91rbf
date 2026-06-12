class DiscordNotifier
  COLORS = {
    success: 5763719,  # green
    info:    3447003,  # blue
    warning: 16776960, # yellow
    error:   15548997  # red
  }.freeze

  def self.notify(title:, description:, color: :info)
    url = ENV["DISCORD_WEBHOOK_URL"]
    return unless url.present?

    payload = {
      username: "SpeakFlow",
      embeds: [{
        title: title,
        description: description,
        color: COLORS.fetch(color, COLORS[:info]),
        footer: { text: "SpeakFlow · #{Time.current.strftime('%Y-%m-%d %H:%M')}" }
      }]
    }

    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 3
    http.read_timeout = 5

    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/json"
    req.body = payload.to_json

    http.request(req)
  rescue => e
    Rails.logger.warn "Discord notification failed: #{e.message}"
  end
end
