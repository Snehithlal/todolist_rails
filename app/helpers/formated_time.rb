module FormatedTime
  def format_time(time)
    time.strftime('%l.%M %P, %-d %B %Y')
  end
end
