class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end
