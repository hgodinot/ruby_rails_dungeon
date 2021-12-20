class BooleanOverStart < ActiveModel::Validator
  def validate(record)
    return if is_boolean?(record.over) && is_boolean?(record.start)
    
    record.errors.add :base, "Over & Start must both be boolean"
  end

  private

    def is_boolean?(el)
      el.is_a?(TrueClass) || el.is_a?(FalseClass)
    end
end