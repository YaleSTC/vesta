# frozen_string_literal: true

class FakeProfileQuerier < ProfileQuerier
  def query
    return {} if id == 'badqueryid'
    return fg_attrs.merge(last_name: nil) if id == 'invalidid'
    if User.cas_auth?
      id_attr = :username
      id_value = id
    else
      id_attr = :email
      id_value = "#{id}@example.com"
    end
    fg_attrs.merge(id_attr => id_value)
  end

  private

  def fg_attrs
    FactoryGirl.attributes_for(:student).slice(*PROFILE_FIELDS)
  end
end
