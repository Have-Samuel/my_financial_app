module ChartsHelper
  # Server-rendered donut. segments: [{ value:, color: }, ...]
  # Returns an SVG string; segments are drawn proportionally to `value`.
  def donut_chart(segments, size: 240, thickness: 36)
    total = segments.sum { |s| s[:value].to_i }
    return tag.p("No data yet.", class: "text-sm text-muted") if total <= 0

    radius = (size - thickness) / 2.0
    circumference = 2 * Math::PI * radius
    center = size / 2.0
    offset = 0.0

    circles = segments.filter_map do |segment|
      next if segment[:value].to_i <= 0

      length = segment[:value].to_f / total * circumference
      circle = tag.circle(
        cx: center, cy: center, r: radius, fill: "none",
        stroke: segment[:color], "stroke-width": thickness,
        "stroke-dasharray": "#{length} #{circumference - length}",
        "stroke-dashoffset": -offset,
        transform: "rotate(-90 #{center} #{center})"
      )
      offset += length
      circle
    end

    tag.svg(width: size, height: size, viewBox: "0 0 #{size} #{size}") { safe_join(circles) }
  end
end
