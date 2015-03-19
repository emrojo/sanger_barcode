module Sanger::Barcode::Printing
class Label
  attr_accessor :number, :study, :suffix, :output_plate_purpose, :prefix, :output_plate_role

  def initialize(options = {})
    unless options.nil?
      @number = options[:number]
      @study = options[:study]
      @suffix = options[:suffix]
      @prefix= options[:prefix]
      if !options[:batch].nil? && !options[:batch].output_plate_purpose.nil?
        @output_plate_purpose = options[:batch].output_plate_purpose.name
        @output_plate_role    = options[:batch].output_plate_role
      end
      @label_name = options[:label_name]
      @label_description = options[:label_description]
      @barcode_type   = options[:type]
    end
  end

  def get_study_string_content
    params = @study.split(/ /)
    barcode = params.pop.strip
    plate_purpose = params.join(" ").strip
    return { :barcode => barcode, :plate_purpose => plate_purpose }
  end

  def printable(printer_type, options)
    default_prefix = options[:prefix]
    barcode_type   = options[:type] || @barcode_type || "short"
    study_name     = options[:study_name]
    user_login    = options[:user_login]

    # Contents for 1st and 2nd line in barcode label (Custom labels)
    label_name = [options[:label_name], @label_name].detect(&:present?)
    label_description = [options[:label_description], @label_description].detect(&:present?)

    number      = self.number.to_i
    prefix      = self.barcode_prefix(default_prefix)
    suffix      = self.suffix
    description = self.barcode_description
    text        = self.barcode_text(default_prefix)

    barcode_type="custom-labels"
    case barcode_type
    when "long"
      text = "#{study_name}" if study_name
      description = "#{user_login} #{output_plate_purpose} #{barcode_name}" if user_login
    when "cherrypick"
      text = "#{study_name}" if study_name
      description = "#{output_plate_role} #{output_plate_purpose} #{barcode_name}".strip
    when "custom-labels"
      study_content = get_study_string_content
      text = ["#{label_name}", "#{prefix}#{study_content[:barcode]}#{suffix}", text].detect(&:present?)
      description = ["#{label_description}", "#{study_content[:plate_purpose]}", description].detect(&:present?)
    end
    scope          = description

    return BarcodeLabelDTO.new(number,
                            description,
                            text,
                            prefix,
                            text, #scope,  #text or description
                            suffix)
  end


  def barcode_name
    # at that point we should probably remove the first to chars of the study if its LE
    # but the old code doesn't do it, maybe a bug
    # for now, we keep the old (buggy) code behavior
    name = study ?  study.gsub("_", " ").gsub("-"," ") : nil
  end
  def barcode_description
    "#{barcode_name}_#{number}"
  end

  def barcode_prefix(default_prefix)
    #todo move upstream
    prefix || begin
      p = study[0..1]
      p == "LE" ? p : default_prefix
    end
  end

  def barcode_text(default_prefix)
     "#{barcode_prefix(default_prefix)} #{number.to_s}"
  end


end
end
