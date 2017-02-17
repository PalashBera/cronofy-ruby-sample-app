class Event
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :calendar_id,
                :event_id,
                :event_uid,
                :summary,
                :description,
                :event_start,
                :event_end,
                :location_lat,
                :location_long

  validates :calendar_id, presence: true
  validates :event_id, presence: true
  validates :summary, presence: true

  validate :times_are_present
  validate :end_time_is_not_before_start_time if :times_are_present?

  def times_are_present
    unless times_are_present?
      if event_start.empty?
        errors.add(:start_time, "must be present")
      end

      if event_end.empty?
        errors.add(:end_time, "must be present")
      end
    end
  end

  def times_are_present?
    !event_start.empty? and !event_end.empty?
  end

  def end_time_is_not_before_start_time
    return unless times_are_present?

    if start_time > end_time
      errors.add(:end_time, "can't be before the start time")
    end
  end

  def geolocation_valid_if_present
    return if location_lat.empty? and location_long.empty?

    if location_lat.empty?
      errors.add(:location_lat, "Latitude must be set if longitude is set")
    else
      if is_number?(location_lat)
        if location_lat.to_i < -85.05115 || location_lat.to_i > 85.05115
          errors.add(:location_lat, "Latitude must be between -85.05115 and 85.05115")
        end
      else
        errors.add(:location_lat, "Latitude must be a float")
      end
    end

    if location_long.empty?
      errors.add(:location_long, "Longitude must be set if latitude is set")
    else
      if is_number?(location_long)
        if location_long.to_i < -180 || location_long.to_i > 180
          errors.add(:location_long, "Longitude must be between -180 and 180")
        end
      else
        errors.add(:location_long, "Longitude must be a float")
      end
    end
  end

  def start_time
    Time.parse(event_start)
  end

  def end_time
    Time.parse(event_end)
  end

  def data
    event = {
        event_id: event_id,
        summary: summary,
        description: description,
        start: start_time,
        end: end_time
    }

    unless location_lat.empty? && location_long.empty?
      event[:location] = {
          lat: location_lat,
          long: location_long
      }
    end

    event
  end

  def is_number?(val)
    /\A[-+]?[0-9]*\.?[0-9]+\Z/ =~ val
  end
end