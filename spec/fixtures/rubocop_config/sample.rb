# rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
class ConfigIgnoredSample
  def complex_method(value)
    if value
      puts value
    else
      puts :none
    end
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
